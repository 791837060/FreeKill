#pragma once
// SPDX-License-Identifier: GPL-3.0-or-later

#ifndef FK_SERVER_ONLY

#include <optional>
#include <QString>
#include <QStringList>
#include <QtGlobal>

namespace AnkiConnect {

struct WordPair {
  QString front;
  QString back;
};

/** Anki reviewer ease: 1=Again 2=Hard 3=Good 4=Easy */
using AnkiEase = int;

QString getAnkiDeckForUser(const QString &playerName);
/** 按规则排序的牌组名列表（已按当年起始年级旋转） */
QStringList deckOrderForUser(const QString &playerName);
/** 释义字段须包含此标记字才视为该用户的单词（橙 / 佳） */
QString seriesTagForUser(const QString &playerName);
AnkiEase easeFromMistakes(int mistakeCount);
QString easeLabelZh(AnkiEase ease);
void resetMistakeCount();
void recordWrongAttempt();
int mistakeCount();
bool submitFeedback(int mistakeCount);
void clearActiveCard();
void setAnkiRoom(const QString &roomName);
QString ankiRoomUrl();
std::optional<WordPair> getNextDueCard(qint64 skipCardId = -1,
                                       const QString &playerName = QString());
bool answerDueCard(AnkiEase ease, int mistakeCount = -1);
qint64 activeCardId();

} // namespace AnkiConnect

#endif
