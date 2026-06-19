#pragma once
// SPDX-License-Identifier: GPL-3.0-or-later

#ifndef FK_SERVER_ONLY

#include <optional>
#include <QString>
#include <QtGlobal>

namespace AnkiConnect {

struct WordPair {
  QString front;
  QString back;
};

/** Anki reviewer ease: 1=Again 2=Hard 3=Good 4=Easy */
using AnkiEase = int;

QString getAnkiDeckForUser(const QString &username);
AnkiEase easeFromMistakes(int mistakeCount);
QString easeLabelZh(AnkiEase ease);
void resetMistakeCount();
void recordWrongAttempt();
int mistakeCount();
bool submitFeedback(int mistakeCount);
void clearActiveCard();
std::optional<WordPair> getNextDueCard(qint64 skipCardId = -1,
                                       const QString &username = QString());
bool answerDueCard(AnkiEase ease, int mistakeCount = -1);
qint64 activeCardId();

} // namespace AnkiConnect

#endif
