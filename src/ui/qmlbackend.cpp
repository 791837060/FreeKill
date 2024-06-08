#include "pch.h"
// SPDX-License-Identifier: GPL-3.0-or-later

#include "qmlbackend.h"
#include <qjsondocument.h>

#ifndef FK_SERVER_ONLY
#include <qaudiooutput.h>
#include <qmediaplayer.h>
#include <qrandom.h>
#include <QNetworkDatagram>
#include <QDnsLookup>

#include <QClipboard>
#include <QMediaPlayer>
#include "mod.h"
#endif

#include <cstdlib>
#ifndef Q_OS_WASM
#include "server.h"
#endif
#include "client.h"
#include "util.h"
#include "replayer.h"

QmlBackend *Backend = nullptr;

QmlBackend::QmlBackend(QObject *parent) : QObject(parent) {
  Backend = this;
#ifndef FK_SERVER_ONLY
  engine = nullptr;
  replayer = nullptr;
  rsa = RSA_new();
  udpSocket = new QUdpSocket(this);
  udpSocket->bind(0);
  connect(udpSocket, &QUdpSocket::readyRead,
          this, &QmlBackend::readPendingDatagrams);
#endif
}

QmlBackend::~QmlBackend() {
  Backend = nullptr;
#ifndef FK_SERVER_ONLY
  RSA_free(rsa);
#endif
}

void QmlBackend::cd(const QString &path) { QDir::setCurrent(path); }

QStringList QmlBackend::ls(const QString &dir) {
  QString d = dir;
#ifdef Q_OS_WIN
  if (d.startsWith("file:///"))
    d.replace(0, 8, "file://");
#endif
  return QDir(QUrl(d).path())
      .entryList(QDir::Files | QDir::Dirs | QDir::NoDotAndDotDot);
}

QString QmlBackend::pwd() { return QDir::currentPath(); }

bool QmlBackend::exists(const QString &file) {
  QString s = file;
#ifdef Q_OS_WIN
  if (s.startsWith("file:///"))
    s.replace(0, 8, "file://");
#endif
  return QFile::exists(QUrl(s).path());
}

bool QmlBackend::isDir(const QString &file) {
  return QFileInfo(QUrl(file).path()).isDir();
}

#ifndef FK_SERVER_ONLY

QQmlApplicationEngine *QmlBackend::getEngine() const { return engine; }

void QmlBackend::setEngine(QQmlApplicationEngine *engine) {
  this->engine = engine;
}

void QmlBackend::startServer(ushort port) {
#ifndef Q_OS_WASM
  if (!ServerInstance) {
    Server *server = new Server(this);

    if (!server->listen(QHostAddress::Any, port)) {
      server->deleteLater();
      emit notifyUI("ErrorMsg", tr("Cannot start server!"));
    }
  }
#endif
}

void QmlBackend::joinServer(QString address) {
  if (ClientInstance != nullptr)
    return;
  Client *client = new Client(this);
  connect(client, &Client::error_message, this, [=](const QString &msg) {
    if (replayer) {
      emit replayerShutdown();
    }
    client->deleteLater();
    emit notifyUI("ErrorMsg", msg);
    emit notifyUI("BackToStart", "[]");
  });
  QString addr = "127.0.0.1";
  ushort port = 9527u;

  if (address.contains(QChar(':'))) {
    QStringList texts = address.split(QChar(':'));
    addr = texts.value(0);
    port = texts.value(1).toUShort();
  } else {
    addr = address;
    // SRV解析查询
    QDnsLookup* dns = new QDnsLookup(QDnsLookup::SRV, "_freekill._tcp." + addr);
    QEventLoop eventLoop;
    // 阻塞的SRV解析查询回调
    connect(dns, &QDnsLookup::finished,[&eventLoop](void){
        eventLoop.quit();
    });
    dns->lookup();
    eventLoop.exec();
    if (dns->error() == QDnsLookup::NoError) { // SRV解析成功
      const auto records = dns->serviceRecords();
      const QDnsServiceRecord &record = records.first();
      QHostInfo host = QHostInfo::fromName(record.target());
      if (host.error() == QHostInfo::NoError) { // 主机解析成功
          addr = host.addresses().first().toString();
          port = record.port();
      }
    }
  }

  client->connectToHost(addr, port);
}

void QmlBackend::quitLobby(bool close) {
  if (ClientInstance)
    delete ClientInstance;
  // if (ServerInstance && close)
  //   ServerInstance->deleteLater();
}

void QmlBackend::emitNotifyUI(const QString &command, const QString &jsonData) {
  emit notifyUI(command, jsonData);
}

QString QmlBackend::translate(const QString &src) {
  if (!ClientInstance)
    return src;

  lua_State *L = ClientInstance->getLuaState();
  lua_getglobal(L, "Translate");
  auto bytes = src.toUtf8();
  lua_pushstring(L, bytes.data());

  int err = lua_pcall(L, 1, 1, 0);
  const char *result = lua_tostring(L, -1);
  if (err) {
    qCritical() << result;
    lua_pop(L, 1);
    return "";
  }
  lua_pop(L, 1);
  return QString(result);
}

void QmlBackend::pushLuaValue(lua_State *L, QVariant v) {
  QVariantList list;
  switch (v.typeId()) {
  case QMetaType::Bool:
    lua_pushboolean(L, v.toBool());
    break;
  case QMetaType::Int:
  case QMetaType::UInt:
    lua_pushinteger(L, v.toInt());
    break;
  case QMetaType::Double:
    lua_pushnumber(L, v.toDouble());
    break;
  case QMetaType::QString: {
    auto bytes = v.toString().toUtf8();
    lua_pushstring(L, bytes.data());
    break;
  }
  case QMetaType::QVariantList:
    lua_newtable(L);
    list = v.toList();
    for (int i = 1; i <= list.length(); i++) {
      lua_pushinteger(L, i);
      pushLuaValue(L, list[i - 1]);
      lua_settable(L, -3);
    }
    break;
  default:
    // qCritical() << "cannot handle QVariant type" << v.typeId();
    lua_pushnil(L);
    break;
  }
}

QString QmlBackend::callLuaFunction(const QString &func_name,
                                    QVariantList params) {
  if (!ClientInstance) return "{}";

  lua_State *L = ClientInstance->getLuaState();
  lua_getglobal(L, func_name.toLatin1().data());

  foreach (QVariant v, params) {
    pushLuaValue(L, v);
  }

  int err = lua_pcall(L, params.length(), 1, 0);
  const char *result = lua_tostring(L, -1);
  if (err) {
    qCritical() << result;
    lua_pop(L, 1);
    return "";
  }
  lua_pop(L, 1);

  return QString(result);
}

QString QmlBackend::pubEncrypt(const QString &key, const QString &data) {
  // 在用公钥加密口令时，也随机生成AES密钥/IV，并随着口令一起加密
  // AES密钥和IV都是固定16字节的，所以可以放在开头
  auto key_bytes = key.toLatin1();
  BIO *keyio = BIO_new_mem_buf(key_bytes.constData(), -1);
  PEM_read_bio_RSAPublicKey(keyio, &rsa, NULL, NULL);
  BIO_free_all(keyio);

  auto data_bytes = data.toUtf8();
  auto rand_generator = QRandomGenerator::securelySeeded();
  QByteArray aes_key_;
  for (int i = 0; i < 2; i++) {
    aes_key_.append(QByteArray::number(rand_generator.generate64(), 16));
  }
  if (aes_key_.length() < 32) {
    aes_key_.append(QByteArray("0").repeated(32 - aes_key_.length()));
  }

  aes_key = aes_key_;

  data_bytes.prepend(aes_key_);

  unsigned char buf[RSA_size(rsa)];
  RSA_public_encrypt(data.length() + 32,
                     (const unsigned char *)data_bytes.constData(), buf, rsa,
                     RSA_PKCS1_PADDING);
  return QByteArray::fromRawData((const char *)buf, RSA_size(rsa)).toBase64();
}

QString QmlBackend::loadConf() {
  QFile conf("freekill.client.config.json");
  if (!conf.exists()) {
    conf.open(QIODevice::WriteOnly);
    static const char *init_conf = "{}";
    conf.write(init_conf);
    conf.close();
    return init_conf;
  }
  conf.open(QIODevice::ReadOnly);
  auto ret = conf.readAll();
  conf.close();
  return ret;
}

QString QmlBackend::loadTips() {
  QFile conf("waiting_tips.txt");
  if (!conf.exists()) {
    conf.open(QIODevice::WriteOnly);
    static const char *init_conf = "转啊~ 转啊~";
    conf.write(init_conf);
    conf.close();
    return init_conf;
  }
  conf.open(QIODevice::ReadOnly);
  auto ret = conf.readAll();
  conf.close();
  return ret;
}

void QmlBackend::saveConf(const QString &conf) {
  QFile c("freekill.client.config.json");
  c.open(QIODevice::WriteOnly);
  c.write(conf.toUtf8());
  c.close();
}

void QmlBackend::replyDelayTest(const QString &screenName,
                                const QString &cipher) {
  auto md5 = calcFileMD5();

  QJsonArray arr;
  arr << screenName << cipher << md5 << FK_VERSION << GetDeviceUuid();
  ClientInstance->notifyServer("Setup", JsonArray2Bytes(arr));
}

void QmlBackend::playSound(const QString &name, int index) {
  QString fname(name);
  if (index == -1) {
    int i = 1;
    while (true) {
      if (!QFile::exists(name + QString::number(i) + ".mp3")) {
        i--;
        break;
      }
      i++;
    }

    index = i == 0 ? 0 : (QRandomGenerator::global()->generate()) % i + 1;
  }
  if (index != 0)
    fname = fname + QString::number(index) + ".mp3";
  else
    fname = fname + ".mp3";

  if (!QFile::exists(fname))
    return;

  auto player = new QMediaPlayer;
  auto output = new QAudioOutput;
  player->setAudioOutput(output);
  player->setSource(QUrl::fromLocalFile(fname));
  output->setVolume(m_volume / 100);
  connect(player, &QMediaPlayer::playbackStateChanged, this, [=]() {
    if (player->playbackState() == QMediaPlayer::StoppedState) {
      player->deleteLater();
      output->deleteLater();
    }
  });
  player->play();
}

void QmlBackend::playSoundWav(const QString &name, int index) {
  QString fname(name);
  if (index == -1) {
    int i = 1;
    while (true) {
      if (!QFile::exists(name + QString::number(i) + ".wav")) {
        i--;
        break;
      }
      i++;
    }

    index = i == 0 ? 0 : (QRandomGenerator::global()->generate()) % i + 1;
  }
  if (index != 0)
    fname = fname + QString::number(index) + ".wav";
  else
    fname = fname + ".wav";

  if (!QFile::exists(fname))
    return;

  auto player = new QMediaPlayer;
  auto output = new QAudioOutput;
  player->setAudioOutput(output);
  player->setSource(QUrl::fromLocalFile(fname));
  output->setVolume(m_volume / 100);
  connect(player, &QMediaPlayer::playbackStateChanged, this, [=]() {
    if (player->playbackState() == QMediaPlayer::StoppedState) {
      player->deleteLater();
      output->deleteLater();
    }
  });
  player->play();
}

QString QmlBackend::getOneWord(const QString &ownerRoom, const QString &rightWord) {
  //lua_State *L = ClientInstance->getLuaState();
  QNetworkAccessManager* manager = new QNetworkAccessManager(this);
  QUrl url("http://192.168.3.25:8000/api/wx/student/question/answer/xinyueshaTest");
  QNetworkRequest request(url);

  // 设置请求头
  //设置请求头
  request.setRawHeader("Accept","application/json, text/plain, */*");
  request.setRawHeader("Connection","keep-alive");
  request.setRawHeader("token","123111111111111111111111111111111111");
  request.setRawHeader("User-Agent","Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/118.0.0.0 Safari/537.36");
  request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");

  // 构建 JSON 数据
  QJsonObject jsonObject;
  jsonObject["ownerRoom"] = ownerRoom; // 示例键值对
  jsonObject["rightWord"] = rightWord;

  // 将 JSON 对象转换为字符串
  QJsonDocument jsonDocPar(jsonObject);
  QByteArray jsonByteArray = jsonDocPar.toJson(QJsonDocument::Compact);

  // 发送 POST 请求并附带 JSON 数据
  QNetworkReply *reply = manager->post(request, jsonByteArray);

  QEventLoop loop;
  QString result;
  QObject::connect(reply, &QNetworkReply::finished, &loop, &QEventLoop::quit);
  loop.exec();

  // 读取和处理响应数据...
  int replyCode = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
  if(reply->error() == QNetworkReply::NoError && replyCode == 200) {
        //大多数服务器返回utf-8格式
        QByteArray data = reply->readAll();
        //应答成功，对接收到的数据进行JSON解析
        //解析网页JSON 将数据保存至day类对象数组中 并调用刷新界面函数
        // 将JSON字符串转换为QJsonDocument
        QJsonDocument jsonDoc = QJsonDocument::fromJson(data);
        // 检查是否解析成功
        if (!jsonDoc.isNull()) {
            if (jsonDoc.isArray()) {
                // 获取JSON数组
                QJsonArray jsonArray = jsonDoc.array();
                // 遍历数组中的每个对象
                for (const QJsonValue &value : jsonArray) {
                    if (value.isObject()) {
                        QJsonObject jsonObject = value.toObject();
                        // 获取"ch"和"en"字段的值
                        //编号a	单词b	音标c	释义d	拆分e	综合法f	                联想法g	        例句h	                        翻译i
                        //1	    ball	[bɔːl]	n.球	    ba+ll	ba爸(拼音)+ll筷子(象形)	爸爸用筷子夹球	The kid is playing the ball. 	孩子在玩皮球。
                        QString front = jsonObject["ch"].toString(); // d f g
                        QString back = jsonObject["en2"].toString();// b g f
                        //lua_pushstring(L,ch.toUtf8().constData());
                        //lua_pushstring(L,en.toUtf8().constData());
                        //lua_settable(L,-3);//弹出上两个，表在顶
                        // word + cn + word +back
                        result  = front +","+back;
                    }
                }
            } else {
                qDebug() << "The JSON document is not an array.";
            }
        } else {
            qDebug() << "Invalid JSON: " << "jsonString";
        }
        //qDebug() << QString::fromUtf8(data);
  } else {
        qDebug() << "Network error: " << reply->errorString();
  }
  //lua_setglobal(L,"wordListVar"); //将堆栈顶位置设置全局变量并出堆栈
  // 清理并返回结果（如果需要）
  reply->deleteLater();
  manager->deleteLater(); // 如果不再需要 manager，也可以在这里删除它
  // 输出结果
  qDebug() << "result:" << result ;
  return result; // 或者返回其他有意义的字符串或数据
}

void QmlBackend::copyToClipboard(const QString &s) {
  QGuiApplication::clipboard()->setText(s);
}

QString QmlBackend::readClipboard() {
  return QGuiApplication::clipboard()->text();
}

void QmlBackend::setAESKey(const QString &key) { aes_key = key; }

QString QmlBackend::getAESKey() const { return aes_key; }

void QmlBackend::installAESKey() {
  ClientInstance->installAESKey(aes_key.toLatin1());
}

void QmlBackend::createModBackend() {
  engine->rootContext()->setContextProperty("ModBackend", new ModMaker);
}


void QmlBackend::detectServer() {
  static const char *ask_str = "fkDetectServer";
  udpSocket->writeDatagram(ask_str,
      strlen(ask_str),
      QHostAddress::Broadcast,
      9527);
}

void QmlBackend::getServerInfo(const QString &address) {
  QString addr = "127.0.0.1";
  ushort port = 9527u;
  static const char *ask_str = "fkGetDetail,";

  if (address.contains(QChar(':'))) {
    QStringList texts = address.split(QChar(':'));
    addr = texts.value(0);
    port = texts.value(1).toUShort();
  } else {
    addr = address;
  }

  QByteArray ask(ask_str);
  ask.append(address.toLatin1());

  if (QHostAddress(addr).isNull()) { // 不是ip？考虑解析域名
    QHostInfo::lookupHost(addr, this, [=](const QHostInfo &host) {
      if (host.error() == QHostInfo::NoError) {
        udpSocket->writeDatagram(ask, ask.size(),
            host.addresses().first(), port);
      }
      else if (host.error() == QHostInfo::HostNotFound
        && !address.contains(QChar(':'))){ // 直接解析主机失败，尝试获取其SRV记录
        QDnsLookup* dns = new QDnsLookup(QDnsLookup::SRV, "_freekill._tcp." + addr);
        // SRV解析回调
        connect(dns, &QDnsLookup::finished, this, [=]() {
          if (dns->error() != QDnsLookup::NoError) {
            return;
          }
          // SRV解析成功，再次进行解析主机
          const auto records = dns->serviceRecords();
          if (records.isEmpty()) {
            return;
          }
          const QDnsServiceRecord &record = records.first();
          // 获取到真实端口
          QHostInfo::lookupHost(record.target(), [=](const QHostInfo &host) {
            if (host.error() == QHostInfo::NoError) {
              // 获取到真实地址
              udpSocket->writeDatagram(ask, ask.size(),
                host.addresses().first(), record.port());
            }
          });
        });
        // SRV解析查询
        dns->lookup();
      }
    });
  } else {
    udpSocket->writeDatagram(ask, ask.size(),
        QHostAddress(addr), port);
  }
}

void QmlBackend::readPendingDatagrams() {
  while (udpSocket->hasPendingDatagrams()) {
    QNetworkDatagram datagram = udpSocket->receiveDatagram();
    if (datagram.isValid()) {
      auto data = datagram.data();
      auto addr = datagram.senderAddress();
      // auto port = datagram.senderPort();

      if (data == "me") {
        emit notifyUI("ServerDetected", addr.toString());
      } else {
        auto arr = QJsonDocument::fromJson(data).array();
        emit notifyUI("GetServerDetail", JsonArray2Bytes(arr));
      }
    }
  }
}

void QmlBackend::removeRecord(const QString &fname) {
  QFile::remove("recording/" + fname);
}

void QmlBackend::playRecord(const QString &fname) {
  auto replayer = new Replayer(this, fname);
  setReplayer(replayer);
  replayer->start();
}

Replayer *QmlBackend::getReplayer() const {
  return replayer;
}

void QmlBackend::setReplayer(Replayer *rep) {
  auto r = replayer;
  if (r) {
    r->disconnect(this);
    disconnect(r);
  }
  replayer = rep;
  if (rep) {
    connect(rep, &Replayer::duration_set, this, [this](int sec) {
        this->emitNotifyUI("ReplayerDurationSet", QString::number(sec));
        });
    connect(rep, &Replayer::elasped, this, [this](int sec) {
        this->emitNotifyUI("ReplayerElapsedChange", QString::number(sec));
        });
    connect(rep, &Replayer::speed_changed, this, [this](qreal speed) {
        this->emitNotifyUI("ReplayerSpeedChange", QString::number(speed));
        });
    connect(this, &QmlBackend::replayerToggle, rep, &Replayer::toggle);
    connect(this, &QmlBackend::replayerSlowDown, rep, &Replayer::slowDown);
    connect(this, &QmlBackend::replayerSpeedUp, rep, &Replayer::speedUp);
    connect(this, &QmlBackend::replayerUniform, rep, &Replayer::uniform);
    connect(this, &QmlBackend::replayerShutdown, rep, &Replayer::shutdown);
  }
}

void QmlBackend::controlReplayer(QString type) {
  if (type == "toggle") {
    emit replayerToggle();
  } else if (type == "speedup") {
    emit replayerSpeedUp();
  } else if (type == "slowdown") {
    emit replayerSlowDown();
  } else if (type == "uniform") {
    emit replayerUniform();
  } else if (type == "shutdown") {
    emit replayerShutdown();
  }
}

#endif
