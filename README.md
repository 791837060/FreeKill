# 新月杀（FreeKill）

![](https://img.shields.io/github/repo-size/notify-ctrl/freekill?color=green)
![](https://img.shields.io/github/languages/top/Notify-ctrl/FreeKill)
![](https://img.shields.io/github/license/notify-ctrl/freekill)
![](https://img.shields.io/github/v/tag/notify-ctrl/freekill)
![](https://img.shields.io/github/issues/notify-ctrl/freekill)
[![Gitter](https://badges.gitter.im/Join%20Chat.svg)](https://app.gitter.im/#/room/#FreeKill:gitter.im)
![](https://img.shields.io/github/stars/notify-ctrl/freekill?style=social)

___

## 关于本项目

新月杀（FreeKill）是一款开源的三国杀游戏，但其目的不在于补完官方所有武将，而是着力于提供一个最适合DIY的框架。

## 项目文档

[新月杀文档](https://qsgs-fans.github.io/FreeKill/usr/index.html)

### 依赖的库

以下是新月杀运行所必不可少的依赖库：

* [![](https://img.shields.io/badge/qt6-50D160?style=for-the-badge&logo=qt&logoColor=white)](https://www.qt.io)
* [![](https://img.shields.io/badge/lua5.4-030380?style=for-the-badge&logo=lua)](https://www.lua.org)
* [![](https://img.shields.io/badge/sqlite3-7ABEEA?style=for-the-badge&logo=sqlite)](https://www.sqlite.org)
* [![](https://img.shields.io/badge/libgit2-FFFFFF?style=for-the-badge&logo=git)](https://www.libgit2.org)
* [![](https://img.shields.io/badge/openssl-721412?style=for-the-badge&logo=openssl)](https://www.openssl.org)

新月杀在编译过程中，需要用到cmake, flex, bison, swig。

___

## 安装和使用

Release页面提供Windows版和Android版的打包好的文件，请直接下载使用。

Linux用户则需要从头开始编译，不过对于ArchLinux上，可以从AUR中安装：

    $ yay -S freekill

初始界面是连入服务器的界面，可以选择加入服务器，也可以单机开始游戏。

___

## 如何构建

关于如何从头构建新月杀，详见[编译教程](https://qsgs-fans.github.io/FreeKill/inner/01-compile.html)。

___

## 参与其中

若您能为新月杀做出贡献，我们将不胜感激。

如若您能提出良好的建议，请fork本仓库然后提交PR。您也可以单纯只提出一个issue，或者为repo点一个star。再次感谢您的帮助。

有关做出贡献的细节，详见`CONTRIBUTING.md`。（施工中）

___

## 许可证

本仓库使用GPLv3作为许可证。详见`LICENSE`文件。

QNetworkAccessManager* manager = new QNetworkAccessManager(this);
    //指定请求的url地址
    QUrl url("http://192.168.3.25:8000/api/wx/student/question/answer/xinyuesha");
    QNetworkRequest request(url);
    //设置请求头
    request.setRawHeader("Accept","application/json, text/plain, */*");
    request.setRawHeader("Connection","keep-alive");
    request.setRawHeader("token","123111111111111111111111111111111111");
    request.setRawHeader("User-Agent","Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/118.0.0.0 Safari/537.36");
    request.setRawHeader("Content-Type", "application/json");
    //发起请求
    //manager->get(request);
    QNetworkReply *reply = manager->get(request);

    QEventLoop loop;
    QObject::connect(reply, &QNetworkReply::finished, &loop, &QEventLoop::quit);
    loop.exec(); // 这会阻塞，直到 finished 信号被发出

    
    //读取HTTP网页请求的数据
    //获取状态码
    int replyCode = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
    //qDebug() << "replyCode: " << replyCode;
    //连接成功
    if(reply->error() == QNetworkReply::NoError && replyCode == 200)
    {
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
                        QString front = jsonObject["ch"].toString(); //d f g
                        //编号a	单词b	音标c	释义d	拆分e	综合法f	                联想法g	        例句h	                        翻译i
                        //1	    ball	[bɔːl]	n.球	ba+ll	ba爸(拼音)+ll筷子(象形)	爸爸用筷子夹球	The kid is playing the ball. 	孩子在玩皮球。
                        //QString en = jsonObject["en"].toString()+","+jsonObject["en2"].toString(); // b g f
                        QString back = jsonObject["en2"].toString(); // b g f
                        lua_pushstring(L,front.toUtf8().constData());
                        lua_pushstring(L,back.toUtf8().constData());
                        lua_settable(L,-3);//弹出上两个，表在顶
                        // 输出结果
                        //qDebug() << "Chinese:" << ch << "English:" << en;
                    }
                }
            } else {
                qDebug() << "The JSON document is not an array.";
            }
        } else {
            qDebug() << "Invalid JSON: " << "jsonString";
        }
        //qDebug() << QString::fromUtf8(data);
    }
    else{
        qDebug() << "网络连接错误: " << reply->errorString();
    }

    
    reply->deleteLater();
    delete manager;

___

## 点一下小星星呗！

[![Star History Chart](https://api.star-history.com/svg?repos=Qsgs-Fans/FreeKill&type=Date)](https://star-history.com/#Qsgs-Fans/FreeKill&Date)

QString QmlBackend::testUl() {
  //ul start
  //由 QNetworkAccessManager 发起get请求
  QNetworkAccessManager* manager = new QNetworkAccessManager(this);
  //指定请求的url地址
  QUrl url("http://192.168.3.25:8000/api/wx/student/question/answer/xinyueshaTest");
  QNetworkRequest request(url);
  //设置请求头
  request.setRawHeader("Accept","application/json, text/plain, */*");
  request.setRawHeader("Connection","keep-alive");
  request.setRawHeader("token","123111111111111111111111111111111111");
  request.setRawHeader("User-Agent","Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/118.0.0.0 Safari/537.36");
  request.setRawHeader("Content-Type", "application/json");
  //发起请求
  //manager->get(request);
  QNetworkReply *reply = manager->get(request);

  QEventLoop loop;
  QObject::connect(reply, &QNetworkReply::finished, &loop, &QEventLoop::quit);
  loop.exec(); // 这会阻塞，直到 finished 信号被发出

  //ul lua_newtable(L);
  //读取HTTP网页请求的数据
  //获取状态码
  int replyCode = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
  //qDebug() << "replyCode: " << replyCode;
  //连接成功
  if(reply->error() == QNetworkReply::NoError && replyCode == 200)
  {
    //大多数服务器返回utf-8格式
    QByteArray data = reply->readAll();
    //应答成功，对接收到的数据进行JSON解析
    //解析网页JSON 将数据保存至day类对象数组中 并调用刷新界面函数
    // 将JSON字符串转换为QJsonDocument
    QJsonDocument jsonDoc = QJsonDocument::fromJson(data);
    // 检查是否解析成功
    if (!jsonDoc.isNull()) {
 qDebug() << "Invalid JSON: " << "jsonString";
    } else {
      qDebug() << "Invalid JSON: " << "jsonString";
    }
    //qDebug() << QString::fromUtf8(data);
  }
  else{
    qDebug() << "网络连接错误: " << reply->errorString();
  }
  return "replyCode";
  //lua_setglobal(L,"wordListVar"); //将堆栈顶位置设置全局变量并出堆栈
}

if (!QFile::exists(fname)) {
    QNetworkAccessManager* manager = new QNetworkAccessManager(this);
    QUrl url("http://192.168.3.25:8000/api/wx/student/question/answer/requestAiOne");
    QNetworkRequest request(url);

    // ... 设置请求头 ...
    //设置请求头
    request.setRawHeader("Accept","application/json, text/plain, */*");
    request.setRawHeader("Connection","keep-alive");
    request.setRawHeader("token","123111111111111111111111111111111111");
    request.setRawHeader("User-Agent","Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/118.0.0.0 Safari/537.36");
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");

    QJsonObject jsonObject;
    jsonObject["word"] = name;
    QJsonDocument jsonDocPar(jsonObject);
    QByteArray jsonByteArray = jsonDocPar.toJson(QJsonDocument::Compact);

    QNetworkReply *reply = manager->post(request, jsonByteArray);

    // 连接 finished 信号到槽函数
    QObject::connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        // 读取和处理响应数据...
        int replyCode = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
        if(reply->error() == QNetworkReply::NoError && replyCode == 200) {
            // 解析响应并处理结果
            QString responseString = reply->readAll();
            // ... 在这里处理 responseString ...

            // 如果需要，您可以发出一个信号来通知其他部分结果已经可用
        } else {
            qDebug() << "Network error: " << reply->errorString();
        }

        // 清理
        reply->deleteLater();
    });

    // 注意：这里不再需要等待响应，函数会立即返回
    return;
  }



build.bat

cd D:\GitHub\FreeKill\FK\src
cd ../
cmake -DCMAKE_BUILD_TYPE=MinSizeRel -G "MinGW Makefiles" -D "CMAKE_MAKE_PROGRAM:PATH=D:\\Qt\\Tools\\mingw1120_64\\bin\\make.exe" -B D:/GitHub/FreeKill/FK/build
cd D:\GitHub\FreeKill\FK\build
mingw32-make -j2
cd D:\GitHub\FreeKill\FK\
mkdir FreeKill-release
cp build/FreeKill.exe FreeKill-release
cp -r Fk FreeKill-release
cd FreeKill-release
cp D:\Qt\6.5.3\mingw_64\bin\windeployqt .
windeployqt FreeKill.exe
cp -r ../.git .
git restore .
rm -rf .git* android doc lib lang translations src
cd ..
cp lib/win/* FreeKill-release
cp build/zh_CN.qm FreeKill-release
cp D:/Qt/6.5.3/mingw_64/bin/li*.dll FreeKill-release
cp '/c/Program Files/OpenSSL-Win64/bin/libcrypto-1_1-x64.dll' FreeKill-release