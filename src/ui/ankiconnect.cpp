// SPDX-License-Identifier: GPL-3.0-or-later

#ifndef FK_SERVER_ONLY

#include "ui/ankiconnect.h"

#include <QDate>
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
constexpr ushort ANKI_PORT = 8766;

const QStringList DUE_QUERIES = {"is:due prop:due<1", "is:due"};
const QStringList LEARN_QUERIES = {"is:learn"};
const QStringList NEW_QUERIES = {"is:new"};

qint64 g_activeCardId = -1;
int g_mistakeCount = 0;
QString g_nextPool = "due";
QString g_ankiBaseUrl;
QString g_lastPickDeck;
QString g_lastPickMeaning;
QString g_lastPickWord;
QString g_lastQueryDeck;
QNetworkAccessManager *g_network = nullptr;

void logLine(QtMsgType type, const QString &line) {
  if (type == QtWarningMsg)
    qWarning("%ls", qUtf16Printable(line));
  else
    qInfo("%ls", qUtf16Printable(line));
}

void logInfo(const QString &message, const QString &detail = {}) {
  const QString line = detail.isEmpty()
      ? QString("%1 %2").arg(LOG_PREFIX, message)
      : QString("%1 %2 | %3").arg(LOG_PREFIX, message, detail);
  logLine(QtInfoMsg, line);
}

void logWarn(const QString &message, const QString &detail = {}) {
  const QString line = detail.isEmpty()
      ? QString("%1 %2").arg(LOG_PREFIX, message)
      : QString("%1 %2 | %3").arg(LOG_PREFIX, message, detail);
  logLine(QtWarningMsg, line);
}

bool isQuietAnkiAction(const QString &action) {
  return action == "findCards" || action == "findNotes" || action == "cardsInfo"
      || action == "notesInfo";
}

QNetworkAccessManager *networkManager() {
  if (!g_network)
    g_network = new QNetworkAccessManager();
  return g_network;
}

qint64 jsonToCardId(const QJsonValue &value) {
  if (value.isString())
    return value.toString().toLongLong();
  return static_cast<qint64>(value.toDouble());
}

QJsonValue cardIdToJson(qint64 cardId) {
  return QJsonValue(static_cast<double>(cardId));
}

struct CardStats {
  QString deckName;
  int reps = -1;
  int lapses = -1;
};

QString deckFromCard(const QJsonObject &card) {
  QString deck = card.value("deckName").toString();
  if (deck.isEmpty())
    deck = card.value("deck").toString();
  return deck;
}

CardStats cardStatsFromJson(const QJsonObject &card) {
  CardStats stats;
  stats.deckName = deckFromCard(card);
  if (card.contains("reps"))
    stats.reps = card.value("reps").toInt(-1);
  if (card.contains("lapses"))
    stats.lapses = card.value("lapses").toInt(-1);
  return stats;
}

std::optional<QJsonValue> queryAnki(const QString &action,
                                    const QJsonObject &params = {});

std::optional<CardStats> fetchCardStats(qint64 cardId) {
  if (cardId <= 0)
    return std::nullopt;

  QJsonArray cardsParam;
  cardsParam.append(cardIdToJson(cardId));
  const auto cardsResult = queryAnki("cardsInfo", {{"cards", cardsParam}});
  if (!cardsResult.has_value() || !cardsResult->isArray())
    return std::nullopt;

  const auto cards = cardsResult->toArray();
  if (cards.isEmpty() || !cards.first().isObject())
    return std::nullopt;

  return cardStatsFromJson(cards.first().toObject());
}

QStringList withDeckFilter(const QStringList &queries, const QString &deck) {
  QStringList filtered;
  for (const auto &query : queries)
    filtered << QString("%1 deck:\"%2\"").arg(query, deck);
  return filtered;
}

QString ankiHostFromRoomName(const QString &roomName) {
  QString host = roomName.trimmed();
  if (host.endsWith(QStringLiteral("_free"))) {
    host.chop(5);
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
      const auto stats = cardStatsFromJson(card);
      return QString("cardId=%1 note=%2 deck=%3 reps=%4 lapses=%5")
          .arg(jsonToCardId(card.value("cardId")))
          .arg(jsonToCardId(card.value("note")))
          .arg(stats.deckName.isEmpty() ? "-" : stats.deckName)
          .arg(stats.reps)
          .arg(stats.lapses);
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
                                    const QJsonObject &params) {
  if (g_ankiBaseUrl.isEmpty()) {
    logWarn("AnkiConnect 地址未设置，请先传入房间名");
    return std::nullopt;
  }

  if (!isQuietAnkiAction(action)) {
    if (!params.isEmpty())
      logInfo(QString("-> %1 %2").arg(action, g_ankiBaseUrl),
              QString::fromUtf8(QJsonDocument(params).toJson(QJsonDocument::Compact)));
    else
      logInfo(QString("-> %1 %2").arg(action, g_ankiBaseUrl));
  }

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
  if (!isQuietAnkiAction(action)) {
    const auto summary = summarizeAnkiResult(action, result);
    if (summary.isEmpty())
      logInfo(QString("<- %1 ok").arg(action));
    else
      logInfo(QString("<- %1").arg(action), summary);
  }
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

std::optional<AnkiConnect::WordPair>
mapFieldsToWordPair(const QJsonObject &fields, const QString &seriesTag = {}) {
  const auto word = cleanWord(stripHtml(getField(fields, {"Word", "Back", "word", "back", "B", "b"})));
  if (word.isEmpty())
    return std::nullopt;

  const auto meaning = stripHtml(getField(fields, {"Meaning", "Front", "meaning", "front", "D", "d", "释义"}));
  if (!seriesTag.isEmpty() && !meaning.contains(seriesTag))
    return std::nullopt;

  const auto method = stripHtml(getField(fields, {"Method", "method", "F", "f", "综合法"}));
  const auto association =
      stripHtml(getField(fields, {"Association", "association", "G", "g", "联想法"}));

  AnkiConnect::WordPair pair;
  if (!association.isEmpty()) {
    QString methodNoEnglish = method;
    methodNoEnglish.remove(QRegularExpression("[a-zA-Z]"));
    pair.front = QString("%1 %2 %3").arg(meaning, methodNoEnglish, association).simplified();
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

    QStringList cardIds;
    cardIds.reserve(ids.size());
    for (const auto &id : ids)
      cardIds << QString::number(jsonToCardId(id));
    logInfo(QString("findCards [%1]").arg(label),
            QString("query=%1 count=%2").arg(query).arg(cardIds.size()));
    return cardIds;
  }

  return {};
}

std::optional<AnkiConnect::WordPair> loadWordPairFromCardId(qint64 cardId,
                                                            const QString &seriesTag) {
  if (cardId <= 0)
    return std::nullopt;

  QJsonArray cardsParam;
  cardsParam.append(cardIdToJson(cardId));
  const auto cardsResult = queryAnki("cardsInfo", {{"cards", cardsParam}});
  if (!cardsResult.has_value() || !cardsResult->isArray())
    return std::nullopt;

  const auto cards = cardsResult->toArray();
  if (cards.isEmpty() || !cards.first().isObject())
    return std::nullopt;

  const auto card = cards.first().toObject();
  const auto stats = cardStatsFromJson(card);
  QString deckName = stats.deckName;
  if (deckName.isEmpty())
    deckName = g_lastQueryDeck;
  const auto noteId = jsonToCardId(card.value("note"));
  if (noteId <= 0)
    return std::nullopt;

  QJsonArray notesParam;
  notesParam.append(cardIdToJson(noteId));
  const auto notesResult = queryAnki("notesInfo", {{"notes", notesParam}});
  if (!notesResult.has_value() || !notesResult->isArray())
    return std::nullopt;

  const auto notes = notesResult->toArray();
  if (notes.isEmpty() || !notes.first().isObject())
    return std::nullopt;

  const auto fields = notes.first().toObject().value("fields").toObject();
  const QString rawMeaning =
      stripHtml(getField(fields, {"Meaning", "Front", "meaning", "front", "D", "d", "释义"}));
  const auto pair = mapFieldsToWordPair(fields, seriesTag);
  if (!pair.has_value())
    return std::nullopt;

  logInfo(QString("取词成功 deck=%1 cardId=%2 word=%3 reps=%4 lapses=%5")
              .arg(deckName.isEmpty() ? "-" : deckName)
              .arg(cardId)
              .arg(pair->back)
              .arg(stats.reps)
              .arg(stats.lapses),
          QString("meaning=%1").arg(rawMeaning.isEmpty() ? "-" : rawMeaning));

  g_lastPickDeck = deckName;
  g_lastPickMeaning = rawMeaning;
  g_lastPickWord = pair->back;

  g_activeCardId = cardId;
  g_mistakeCount = 0;
  return pair;
}

} // namespace

namespace AnkiConnect {

namespace {

constexpr int BASE_YEAR = 2026;
constexpr int UL_BASE_START_GRADE = 3;
constexpr int ORANGE_BASE_START_GRADE = 6;

bool isUlPlayer(const QString &playerName) {
  return playerName.trimmed().compare(QStringLiteral("ul"), Qt::CaseInsensitive) == 0;
}

/** 最高年级上学期 → 逐级降至一年级 → 最高年级下学期 */
QStringList buildGradeDeckOrder(const QString &prefix, int maxGrade) {
  QStringList order;
  if (maxGrade < 1)
    return order;

  order << QStringLiteral("%1%2年级上学期").arg(prefix).arg(maxGrade);
  for (int grade = maxGrade - 1; grade >= 1; --grade) {
    order << QStringLiteral("%1%2年级下学期").arg(prefix).arg(grade);
    order << QStringLiteral("%1%2年级上学期").arg(prefix).arg(grade);
  }
  order << QStringLiteral("%1%2年级下学期").arg(prefix).arg(maxGrade);
  return order;
}

QStringList rotateFromDeck(const QStringList &decks, const QString &startDeck) {
  if (decks.isEmpty())
    return decks;

  const int idx = decks.indexOf(startDeck);
  if (idx <= 0)
    return decks;

  QStringList rotated;
  rotated.reserve(decks.size());
  for (int i = 0; i < decks.size(); ++i)
    rotated << decks[(idx + i) % decks.size()];
  return rotated;
}

int maxGradeForYear(int baseStartGrade, int year) {
  return qMax(baseStartGrade, baseStartGrade + (year - BASE_YEAR));
}

QStringList deckOrderForPrefixYear(const QString &prefix, int baseStartGrade, int year,
                                   const QString &seriesLabel) {
  const int maxGrade = maxGradeForYear(baseStartGrade, year);
  const QString startDeck = QStringLiteral("%1%2年级上学期").arg(prefix).arg(maxGrade);
  const auto order =
      rotateFromDeck(buildGradeDeckOrder(prefix, maxGrade), startDeck);
  logInfo(QString("牌组顺序(%1 %2→起始%3)").arg(seriesLabel).arg(year).arg(startDeck),
          order.join(" → "));
  return order;
}

} // namespace

QStringList deckOrderForUser(const QString &playerName) {
  const int year = QDate::currentDate().year();
  if (isUlPlayer(playerName))
    return deckOrderForPrefixYear(QStringLiteral("佳"), UL_BASE_START_GRADE, year,
                                  QStringLiteral("ul"));
  return deckOrderForPrefixYear(QStringLiteral("橙"), ORANGE_BASE_START_GRADE, year,
                                QStringLiteral("橙"));
}

QString seriesTagForUser(const QString &playerName) {
  return isUlPlayer(playerName) ? QStringLiteral("佳") : QStringLiteral("橙");
}

QString getAnkiDeckForUser(const QString &playerName) {
  const auto order = deckOrderForUser(playerName);
  if (!order.isEmpty())
    return order.first();

  const int year = QDate::currentDate().year();
  if (isUlPlayer(playerName))
    return QStringLiteral("佳%1年级上学期").arg(maxGradeForYear(UL_BASE_START_GRADE, year));
  return QStringLiteral("橙%1年级上学期").arg(maxGradeForYear(ORANGE_BASE_START_GRADE, year));
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
  case 1: return "重来";
  case 2: return "困难";
  case 3: return "良好";
  case 4: return "简单";
  default: return "未知";
  }
}

void resetMistakeCount() { g_mistakeCount = 0; }

void recordWrongAttempt() { g_mistakeCount++; }

int mistakeCount() { return g_mistakeCount; }

void clearActiveCard() {
  g_activeCardId = -1;
  g_mistakeCount = 0;
}

void setAnkiRoom(const QString &roomName) {
  const QString host = ankiHostFromRoomName(roomName);
  const QString url = QString("http://%1:%2").arg(host).arg(ANKI_PORT);
  if (url == g_ankiBaseUrl)
    return;
  g_ankiBaseUrl = url;
  logInfo(QString("AnkiConnect room=%1 url=%2").arg(roomName, g_ankiBaseUrl));
}

QString ankiRoomUrl() { return g_ankiBaseUrl; }

bool submitFeedback(int mistakeCount) {
  const auto ease = easeFromMistakes(mistakeCount);
  return answerDueCard(ease, mistakeCount);
}

std::optional<WordPair> getNextDueCard(qint64 skipCardId, const QString &playerName) {
  const QString seriesTag = seriesTagForUser(playerName);
  const QStringList decks = deckOrderForUser(playerName);
  const QStringList poolOrder = g_nextPool == "due"
      ? QStringList{"due", "learn", "new"}
      : QStringList{"new", "due", "learn"};

  for (int attempt = 0; attempt < 3; ++attempt) {
    if (attempt > 0)
      QThread::msleep(100);

    for (const auto &deck : decks) {
      const QStringList dueQueries = withDeckFilter(DUE_QUERIES, deck);
      const QStringList learnQueries = withDeckFilter(LEARN_QUERIES, deck);
      const QStringList newQueries = withDeckFilter(NEW_QUERIES, deck);

      for (const auto &poolName : poolOrder) {
        QStringList queries;
        QString label;
        if (poolName == "due") {
          queries = dueQueries;
          label = QStringLiteral("复习");
        } else if (poolName == "learn") {
          queries = learnQueries;
          label = QStringLiteral("学习中");
        } else {
          queries = newQueries;
          label = QStringLiteral("新卡");
        }

        const auto cardIdStrings =
            findCardIdsByQueries(queries, QString("%1 %2").arg(label, deck));
        if (cardIdStrings.isEmpty())
          continue;

        g_lastQueryDeck = deck;
        for (const auto &idString : cardIdStrings) {
          const auto id = idString.toLongLong();
          if (skipCardId >= 0 && id == skipCardId)
            continue;
          if (auto pair = loadWordPairFromCardId(id, seriesTag)) {
            g_nextPool = (poolName == "new") ? "due" : "new";
            return pair;
          }
        }
      }
    }

    if (attempt == 0)
      logWarn(QString("未找到可学单词卡 player=%1 tag=%2").arg(playerName, seriesTag));
  }
  return std::nullopt;
}

bool answerDueCard(AnkiEase ease, int mistakeCount) {
  if (g_activeCardId < 0)
    return false;

  const qint64 cardId = g_activeCardId;
  const auto beforeStats = fetchCardStats(cardId);
  const QString deckName = beforeStats.has_value() && !beforeStats->deckName.isEmpty()
      ? beforeStats->deckName
      : g_lastQueryDeck;

  QJsonObject answer{{"cardId", cardIdToJson(cardId)}, {"ease", ease}};
  const auto result =
      queryAnki("answerCards", {{"answers", QJsonArray{answer}}});

  bool ok = false;
  QString rawResult = "null";
  if (result.has_value()) {
    rawResult = QString::fromUtf8(
        QJsonDocument(result.value()).toJson(QJsonDocument::Compact));
    if (result->isArray() && !result->toArray().isEmpty())
      ok = result->toArray().first().toBool();
  }

  const auto afterStats = fetchCardStats(cardId);
  const int repsBefore = beforeStats.has_value() ? beforeStats->reps : -1;
  const int lapsesBefore = beforeStats.has_value() ? beforeStats->lapses : -1;
  const int repsAfter = afterStats.has_value() ? afterStats->reps : -1;
  const int lapsesAfter = afterStats.has_value() ? afterStats->lapses : -1;

  logInfo(QString("answerCards cardId=%1 ease=%2 ok=%3 deck=%4")
              .arg(cardId)
              .arg(ease)
              .arg(ok ? "true" : "false")
              .arg(deckName.isEmpty() ? "-" : deckName),
          QString("result=%1 reps=%2->%3 lapses=%4->%5")
              .arg(rawResult)
              .arg(repsBefore)
              .arg(repsAfter)
              .arg(lapsesBefore)
              .arg(lapsesAfter));

  if (ok)
    g_activeCardId = -1;
  return ok;
}

qint64 activeCardId() { return g_activeCardId; }

QString lastPickDeck() { return g_lastPickDeck; }

QString lastPickMeaning() { return g_lastPickMeaning; }

QString lastPickWord() { return g_lastPickWord; }

} // namespace AnkiConnect

#endif
