#include "pch.h"
#include <QQuickItem>
// SPDX-License-Identifier: GPL-3.0-or-later

#ifndef _CLIENT_H
#define _CLIENT_H

#include "router.h"
#include "clientplayer.h"

#ifndef FK_SERVER_ONLY
#include "qmlbackend.h"
#endif

class Client : public QObject {
  Q_OBJECT
public:
  Client(QObject *parent = nullptr);
  ~Client();

  void connectToHost(const QString &server, ushort port);

  Q_INVOKABLE void replyToServer(const QString &command, const QString &jsonData);
  Q_INVOKABLE QQuickItem* getFocusedItem(QQuickItem* rootItem);
  Q_INVOKABLE void notifyServer(const QString &command, const QString &jsonData);

  Q_INVOKABLE void callLua(const QString &command, const QString &jsonData, bool isRequest = false);
  LuaFunction callback;

  ClientPlayer *addPlayer(int id, const QString &name, const QString &avatar);
  void removePlayer(int id);
  Q_INVOKABLE void clearPlayers();
  void changeSelf(int id);

  lua_State *getLuaState();
  void installAESKey(const QByteArray &key);

  void saveRecord(const QString &json, const QString &fname);

signals:
  void error_message(const QString &msg);

public slots:
  void processReplay(const QString &, const QString &);

private:
  Router *router;
  QMap<int, ClientPlayer *> players;
  ClientPlayer *self;

  lua_State *L;
};

extern Client *ClientInstance;

#endif // _CLIENT_H
