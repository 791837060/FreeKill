#include "pch.h"
// SPDX-License-Identifier: GPL-3.0-or-later

#ifndef FK_SERVER_ONLY

#include "ankiconnect.h"

#include <QEventLoop>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QRegularExpression>
#include <QThread>

namespace {

constexpr int API_VERSION = 6;
constexpr auto LOG_PREFIX = "[Anki]";
constexpr ushort ANKI_PORT = 8766; // 8766 nginx 8765

const QStringList DUE_QUERIES = {"is:due prop:due<1", "is:due"};
const QStringList NEW_QUERIES = {"is:new"};

qint64 g_activeCardId = -1;
int g_mistakeCount = 0;
QString g_nextPool = "due";
QString g_ankiBaseUrl;
QNetworkAccessManager *g_network = nullptr;

QNetworkAccessManager *networkManager() {
  if (!g_network)
    g_network = new QNetworkAccessManager();
  return g_network;
}

void logInfo(const QString &message, const QVariant &detail = {}) {
  if (detail.isValid())
    qInfo() << LOG_PREFIX << message << detail;
  else
    qInfo() << LOG_PREFIX << message;
}

void logWarn(const QString &message, const QVariant &detail = {}) {
  if (detail.isValid())
    qWarning() << LOG_PREFIX << message << detail;
  else
    qWarning() << LOG_PREFIX << message;
}

qint64 jsonToCardId(const QJsonValue &value) {
  if (value.isString())
    return value.toString().toLongLong();
  return static_cast<qint64>(value.toDouble());
}

QJsonValue cardIdToJson(qint64 cardId) {
  return QJsonValue(static_cast<double>(cardId));
}

QStringList withDeckFilter(const QStringList &queries, const QString &deck) {
  QStringList filtered;
  for (const auto &query : queries)
    filtered << QString("%1 deck:%2").arg(query, deck);
  return filtered;
}

QString ankiHostFromRoomName(const QString &roomName) {
  QString host = roomName.trimmed();
  for (const auto &suffix :
       {QStringLiteral("_free"), QStringLiteral("_gao"), QStringLiteral("_chu")}) {
    if (host.endsWith(suffix)) {
      host.chop(suffix.size());
      break;
    }
  }

  static const QRegularExpression ipRegex(
      R"(^(?:[0-9]{1,3}\.){3}[0-9]{1,3}$)");
  if (ipRegex.match(host).hasMatch())
    return host;

  static const QRegularExpression findIp(R"((?:[0-9]{1,3}\.){3}[0-9]{1,3})");
  const auto match = findIp.match(roomName);
  if (match.hasMatch())
    return match.captured(0);

  return host;
}

QString summarizeAnkiResult(const QString &action, const QJsonValue &result) {
  if (result.isArray()) {
    const auto arr = result.toArray();
    if (action == "findCards" || action == "findNotes") {
      QString firstId;
      if (!arr.isEmpty())
        firstId = QString::number(jsonToCardId(arr.first()));
      return QString("%1 条，首张 %2").arg(arr.size()).arg(firstId.isEmpty() ? "-" : firstId);
    }
    if (action == "cardsInfo" && !arr.isEmpty() && arr.first().isObject()) {
      const auto card = arr.first().toObject();
      return QString("cardId=%1 note=%2 deck=%3")
          .arg(jsonToCardId(card.value("cardId")))
          .arg(jsonToCardId(card.value("note")))
          .arg(card.value("deckName").toString());
    }
    if (action == "notesInfo" && !arr.isEmpty() && arr.first().isObject()) {
      const auto note = arr.first().toObject();
      return QString("noteId=%1 fields=%2")
          .arg(jsonToCardId(note.value("noteId")))
          .arg(note.value("fields").toObject().keys().join(','));
    }
    if (action == "answerCards" && !arr.isEmpty())
      return arr.first().toBool() ? "true" : "false";
    return QString("%1 项").arg(arr.size());
  }
  if (result.isDouble() || result.isBool())
    return result.toVariant().toString();
  return {};
}

std::optional<QJsonValue> queryAnki(const QString &action,
                                    const QJsonObject &params = {}) {
  if (g_ankiBaseUrl.isEmpty()) {
    logWarn("AnkiConnect 地址未设置，请先传入房间名");
    return std::nullopt;
  }

  if (!params.isEmpty() && action != "findCards" && action != "findNotes")
    logInfo(QString("→ %1 %2").arg(action, g_ankiBaseUrl), params.toVariantMap());
  else
    logInfo(QString("→ %1 %2").arg(action, g_ankiBaseUrl));

  QUrl url(g_ankiBaseUrl);
  QNetworkRequest request(url);
  request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");

  QJsonObject body{
      {"action", action},
      {"version", API_VERSION},
      {"params", params},
  };

  QNetworkReply *reply = networkManager()->post(
      request, QJsonDocument(body).toJson(QJsonDocument::Compact));

  QEventLoop loop;
  QObject::connect(reply, &QNetworkReply::finished, &loop, &QEventLoop::quit);
  loop.exec();

  if (reply->error() != QNetworkReply::NoError) {
    logWarn(QString("✗ %1").arg(action), reply->errorString());
    reply->deleteLater();
    return std::nullopt;
  }

  const auto data = reply->readAll();
  reply->deleteLater();

  if (data.isEmpty()) {
    logWarn(QString("✗ %1").arg(action), "AnkiConnect 返回空响应");
    return std::nullopt;
  }

  const auto doc = QJsonDocument::fromJson(data);
  if (!doc.isObject()) {
    logWarn(QString("✗ %1").arg(action), "无效 JSON 响应");
    return std::nullopt;
  }

  const auto obj = doc.object();
  const auto error = obj.value("error");
  if (!error.isNull() && !error.toString().isEmpty()) {
    logWarn(QString("✗ %1").arg(action), error.toString());
    return std::nullopt;
  }

  const auto result = obj.value("result");
  logInfo(QString("✓ %1").arg(action), summarizeAnkiResult(action, result));
  return result;
}

QString getField(const QJsonObject &fields, const QStringList &names) {
  for (const auto &name : names) {
    const auto value = fields.value(name);
    if (value.isObject()) {
      const auto text = value.toObject().value("value").toString().trimmed();
      if (!text.isEmpty())
        return text;
    }
  }

  QMap<QString, QJsonValue> lowerMap;
  for (auto it = fields.begin(); it != fields.end(); ++it)
    lowerMap.insert(it.key().toLower(), it.value());

  for (const auto &name : names) {
    const auto value = lowerMap.value(name.toLower());
    if (value.isObject()) {
      const auto text = value.toObject().value("value").toString().trimmed();
      if (!text.isEmpty())
        return text;
    }
  }

  return {};
}

QString stripHtml(QString text) {
  return text.replace(QRegularExpression("<[^>]+>"), "").trimmed();
}

QString cleanWord(const QString &rawWord) {
  auto word = rawWord.toLower();
  word.remove(QRegularExpression("[^a-z]"));
  return word;
}

/** 与 Java xinyueshaTest 一致：ch=front, en2=back */
std::optional<AnkiConnect::WordPair>
mapFieldsToWordPair(const QJsonObject &fields) {
  const auto word = cleanWord(stripHtml(getField(fields, {"Word", "Back", "word", "back", "B", "b"})));
  if (word.isEmpty())
    return std::nullopt;

  const auto meaning = stripHtml(getField(fields, {"Meaning", "Front", "meaning", "front", "D", "d", "释义"}));
  const auto method = stripHtml(getField(fields, {"Method", "method", "F", "f", "综合法"}));
  const auto association =
      stripHtml(getField(fields, {"Association", "association", "G", "g", "联想法"}));

  AnkiConnect::WordPair pair;
  if (!association.isEmpty()) {
    // Java: F = f.replaceAll("[a-zA-Z]", "")
    QString methodNoEnglish = method;
    methodNoEnglish.remove(QRegularExpression("[a-zA-Z]"));
    // front = d + " " + F + " " + g  → Content2.ch
    pair.front = QString("%1 %2 %3").arg(meaning, methodNoEnglish, association).simplified();
    // back = b + " " + g + " " + f  → Content2.en2
    pair.back = QString("%1 %2 %3").arg(word, association, method).simplified();
  } else {
    pair.front = meaning;
    pair.back = word;
  }

  return pair;
}

QStringList findCardIdsByQueries(const QStringList &queries,
                                 const QString &label) {
  for (const auto &query : queries) {
    const auto result = queryAnki("findCards", {{"query", query}});
    if (!result.has_value() || !result->isArray())
      continue;

    const auto ids = result->toArray();
    if (ids.isEmpty())
      continue;

    const qint64 firstId = jsonToCardId(ids.first());
    logInfo(QString("findCards(%1) [%2]").arg(query, label),
            QString("共 %1 张，取首张 %2").arg(ids.size()).arg(firstId));
    return {QString::number(firstId)};
  }

  return {};
}

QStringList findStudyCardIds(const QString &playerName) {
  const auto deck = AnkiConnect::getAnkiDeckForUser(playerName);
  const QStringList dueQueries = withDeckFilter(DUE_QUERIES, deck);
  const QStringList newQueries = withDeckFilter(NEW_QUERIES, deck);

  const QStringList order =
      g_nextPool == "due" ? QStringList{"due", "new"} : QStringList{"new", "due"};

  for (const auto &poolName : order) {
    const bool isDue = poolName == "due";
    const auto cardIds =
        findCardIdsByQueries(isDue ? dueQueries : newQueries,
                             QString("%1 deck:%2").arg(isDue ? "复习" : "新卡", deck));
    if (cardIds.isEmpty())
      continue;

    g_nextPool = isDue ? "new" : "due";
    return cardIds;
  }

  return {};
}

std::optional<AnkiConnect::WordPair> loadWordPairFromCardId(qint64 cardId) {
  if (cardId <= 0) {
    logWarn("无效 cardId", cardId);
    return std::nullopt;
  }

  QJsonArray cardsParam;
  cardsParam.append(cardIdToJson(cardId));
  const auto cardsResult = queryAnki("cardsInfo", {{"cards", cardsParam}});
  if (!cardsResult.has_value() || !cardsResult->isArray())
    return std::nullopt;

  const auto cards = cardsResult->toArray();
  if (cards.isEmpty() || !cards.first().isObject())
    return std::nullopt;

  const auto card = cards.first().toObject();
  const auto noteId = jsonToCardId(card.value("note"));
  if (noteId <= 0) {
    logWarn("无效 noteId", QJsonObject{{"cardId", QString::number(cardId)}});
    return std::nullopt;
  }

  QJsonArray notesParam;
  notesParam.append(cardIdToJson(noteId));
  const auto notesResult = queryAnki("notesInfo", {{"notes", notesParam}});
  if (!notesResult.has_value() || !notesResult->isArray())
    return std::nullopt;

  const auto notes = notesResult->toArray();
  if (notes.isEmpty() || !notes.first().isObject())
    return std::nullopt;

  const auto fields = notes.first().toObject().value("fields").toObject();

  const auto pair = mapFieldsToWordPair(fields);
  if (!pair.has_value()) {
    logWarn("Word 字段为空",
            QJsonObject{{"cardId", QString::number(cardId)},
                        {"fieldNames", QJsonArray::fromStringList(fields.keys())}});
    return std::nullopt;
  }

  g_activeCardId = cardId;
  g_mistakeCount = 0;
  logInfo("学习卡片",
          QJsonObject{{"cardId", QString::number(cardId)},
                      {"deck", card.value("deckName").toString()},
                      {"word", pair->back.section(' ', 0, 0)},
                      {"front", pair->front},
                      {"back", pair->back}});
  return pair;
}

} // namespace

namespace AnkiConnect {

QString getAnkiDeckForUser(const QString &playerName) {
  // ul 玩家 → deck 31，其他玩家 → deck 61（与 room.wordList / ip 无关）
  return playerName.trimmed().toLower() == "ul" ? "31" : "61";
}

AnkiEase easeFromMistakes(int mistakeCount) {
  if (mistakeCount >= 3)
    return 2;
  if (mistakeCount >= 1)
    return 3;
  return 4;
}

QString easeLabelZh(AnkiEase ease) {
  switch (ease) {
  case 1:
    return "重来";
  case 2:
    return "困难";
  case 3:
    return "良好";
  case 4:
    return "简单";
  default:
    return "未知";
  }
}

void resetMistakeCount() { g_mistakeCount = 0; }

void recordWrongAttempt() {
  g_mistakeCount++;
  if (g_mistakeCount <= 3 || g_mistakeCount % 5 == 0)
    logInfo(QString("单词输错累计 %1 次").arg(g_mistakeCount));
}

int mistakeCount() { return g_mistakeCount; }

void clearActiveCard() {
  g_activeCardId = -1;
  g_mistakeCount = 0;
}

void setAnkiRoom(const QString &roomName) {
  const QString host = ankiHostFromRoomName(roomName);
  g_ankiBaseUrl = QString("http://%1:%2").arg(host).arg(ANKI_PORT);
  logInfo(QString("AnkiConnect 房间 %1 → %2").arg(roomName, g_ankiBaseUrl));
}

QString ankiRoomUrl() { return g_ankiBaseUrl; }

bool submitFeedback(int mistakeCount) {
  const auto ease = easeFromMistakes(mistakeCount);
  const bool ok = answerDueCard(ease, mistakeCount);
  const QString resultText =
      QString("[Anki] getOneWord 反馈结果: %1 %2 输错 %3 次")
          .arg(ok ? "成功" : "失败", easeLabelZh(ease))
          .arg(mistakeCount);
  logInfo(resultText);
  qDebug() << resultText;
  return ok;
}

std::optional<WordPair> getNextDueCard(qint64 skipCardId, const QString &playerName) {
  try {
    const auto deck = getAnkiDeckForUser(playerName);
    logInfo(QString("玩家 %1 → 牌组 %2")
                .arg(playerName.isEmpty() ? "(未登录)" : playerName, deck));

    for (int attempt = 0; attempt < 3; ++attempt) {
      if (attempt > 0)
        QThread::msleep(100);

      const auto cardIdStrings = findStudyCardIds(playerName);
      if (cardIdStrings.isEmpty()) {
        if (skipCardId < 0)
          logWarn("无可学卡片（复习+新卡均为空）");
        return std::nullopt;
      }

      qint64 cardId = -1;
      if (skipCardId < 0) {
        cardId = cardIdStrings.first().toLongLong();
      } else {
        for (const auto &idString : cardIdStrings) {
          const auto id = idString.toLongLong();
          if (id != skipCardId) {
            cardId = id;
            break;
          }
        }
      }

      if (cardId > 0)
        return loadWordPairFromCardId(cardId);
    }

    if (skipCardId >= 0)
      logWarn("评分后未找到下一张卡", skipCardId);

    return std::nullopt;
  } catch (...) {
    logWarn("getNextDueCard 失败");
    return std::nullopt;
  }
}

bool answerDueCard(AnkiEase ease, int mistakeCount) {
  const QString easeText = easeLabelZh(ease);

  if (g_activeCardId < 0) {
    logWarn(QString("✗ 反馈失败(%1)：无当前 cardId，请先取词").arg(easeText));
    return false;
  }

  const qint64 cardId = g_activeCardId;
  if (mistakeCount >= 0) {
    logInfo(QString("→ 提交 Anki 反馈：%1 (ease=%2)，输错 %3 次，cardId=%4")
                .arg(easeText)
                .arg(ease)
                .arg(mistakeCount)
                .arg(cardId));
  } else {
    logInfo(QString("→ 提交 Anki 反馈：%1 (ease=%2)，cardId=%3")
                .arg(easeText)
                .arg(ease)
                .arg(cardId));
  }

  QJsonObject answer{{"cardId", cardIdToJson(cardId)}, {"ease", ease}};
  const auto result =
      queryAnki("answerCards", {{"answers", QJsonArray{answer}}});

  bool ok = false;
  if (result.has_value() && result->isArray() && !result->toArray().isEmpty())
    ok = result->toArray().first().toBool();

  if (ok) {
    g_activeCardId = -1;
    const QString msg =
        QString("✓ Anki 反馈成功：%1，cardId=%2").arg(easeText).arg(cardId);
    logInfo(msg);
    qDebug() << LOG_PREFIX << msg;
  } else {
    const QString msg =
        QString("✗ Anki 反馈失败：%1，cardId=%2（请确认 Anki 已打开且 AnkiConnect 正常）")
            .arg(easeText)
            .arg(cardId);
    logWarn(msg);
    qDebug() << LOG_PREFIX << msg;
  }

  return ok;
}

qint64 activeCardId() { return g_activeCardId; }

} // namespace AnkiConnect

#endif
