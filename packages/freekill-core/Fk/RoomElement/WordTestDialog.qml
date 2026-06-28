// SPDX-License-Identifier: GPL-3.0-or-later
// Anki 单词测试对话框（LunarLtk CustomDialog）

import QtQuick
import QtQuick.Controls
import LunarLtk.Pages.Popups

GraphicsBox {
  id: root

  property string dialogJson: ""
  property string result: ""
  property var front
  property var back
  property var word
  property var frontArr
  property var backArr
  property var requestJava
  property var aa
  property var spring_ip_or_room_name
  property var playerName
  property var front_back
  property bool wordSubmitted: false

  title.text: front ? front : ""
  width: Math.max(400, body.width + 20)
  height: body.height + title.height + 20

  Column {
    id: body
    x: 10
    y: title.height + 5
    spacing: 8

    Text {
      width: 900
      wrapMode: Text.WordWrap
      text: frontArr ? ("[" + frontArr[2] + "]   " + frontArr[0]) : ""
      color: "#70DB93"
      font.pointSize: 24
    }

    TextField {
      id: input1
      width: 900
      color: "#E4D5A0"
      font.pointSize: 24
      Keys.onReturnPressed: finishWord(input1.text)
    }

    Button {
      text: "OK"
      onClicked: finishWord(input1.text)
    }
  }

  function ankiCall(cmd) {
    if (typeof Backend !== "undefined" && Backend.getOneWord)
      return Backend.getOneWord(spring_ip_or_room_name, cmd, playerName);
    return "";
  }

  function finishWord(answerText) {
    if (wordSubmitted)
      return;
    wordSubmitted = true;
    var ans = answerText.trim().toLowerCase();
    var target = word ? word.trim().toLowerCase() : "";
    if (ans === "aa")
      ankiCall("giveup");
    else if (ans === target)
      ankiCall("done");
    else
      ankiCall("wrong");
    result = answerText + "," + front_back;
    if (typeof ClientInstance !== "undefined")
      ClientInstance.replyToServer("", result);
    else if (typeof Cpp !== "undefined")
      Cpp.replyToServer(result);
    close();
  }

  function loadData(data) {
    var jsonObject = typeof data === "string" ? JSON.parse(data) : data;
    requestJava = jsonObject.requestJava;
    aa = jsonObject.aa;
    spring_ip_or_room_name = jsonObject.ip;
    playerName = jsonObject.player || "";
    if (!playerName && typeof Self !== "undefined" && Self && Self.screenName)
      playerName = Self.screenName;
    front_back = jsonObject.str_front_and_back;
    if (requestJava === "true") {
      var front_back_temp = ankiCall("no");
      if (front_back_temp && front_back_temp.indexOf("_=front_xxxxxxxxxx_back=_") !== -1)
        front_back = front_back_temp;
    }
    processString(front_back);
  }

  function processString(front_and_back) {
    var arr = front_and_back.split("_=front_xxxxxxxxxx_back=_");
    front = arr[0];
    back = arr[1];
    frontArr = front.split(" ");
    backArr = back.split(" ");
    word = backArr[0].trim();
  }

  Component.onCompleted: {
    if (dialogJson)
      loadData(dialogJson);
  }
}
