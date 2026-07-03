import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import Fk
import Fk.Pages.LunarLTK

// WordTestDialog (from FK @ 3a24652)
GraphicsBox {
  
    property string custom_string: ""
    
    // 使用空格作为分隔符拆分字符串为单词数组  
    property var mp3
    property var mp3Zh
    property var word
    property var frontArr
    property var backArr
    property var front
    property var back
    property var requestJava
    property var aa
    property var spring_ip_or_room_name
    property var playerName
    property var part0_2
    property var front_back
    property var jsonObject
    property string lastInputForMistake: ""
    property bool wordSubmitted: false
    property int sessionWrongCount: 0
    property string dialogJson: ""
    property string uiSourceLabel: ""
    property string meaningLineRich: ""
    property string methodLineRich: ""
    property string backLineRich: ""

  id: root
  //title.text: Backend.translate("en")
  title.text: {
        if (root.front === null || root.front === Qt.undefined) {
            return "";  // 或者返回任何你想要的文本
        } else {
            return root.front;
        }
  }
  width: Math.max(140, body.width + 20)
  height: body.height + title.height + 20

  Column {
    id: body
    x: 10
    y: title.height + 5
    spacing: 10

    

    // Item {  //Column Item
        // width: 1050 // 根据需要设置宽度
        // height: 35 // 根据需要设置高度
  
              // Text {
                // anchors.fill: parent // 填充整个 Item
                // verticalAlignment: Text.AlignVCenter // 文本垂直居中
                // horizontalAlignment: Text.AlignHCenter // 文本水平也居中（如果需要）
                // textFormat: Text.RichText
                // text: root.meaningLineRich
                // color: "#70DB93"
                // font.pointSize: 30
                // height: 35 // 根据字体大小设置合适的高度
              // }
    // }  //Column Item

        Item {
            width: 1050
            height: 28
            Text {
                id: ankiStatusText
                anchors.fill: parent
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                color: "#FFD700"
                font.pointSize: 18
                text: ""
            }
        }

    Item {  //Column Item
        width: 1050 // 根据需要设置宽度  
        height: 35 // 根据需要设置高度  
  
              Text {
                anchors.fill: parent // 填充整个 Item  
                verticalAlignment: Text.AlignVCenter // 文本垂直居中  
                horizontalAlignment: Text.AlignHCenter // 文本水平也居中（如果需要）
                textFormat: Text.RichText
                text: root.meaningLineRich
                color: "#70DB93"
                //font.weight: Font.Bold // 设置字体加粗  
                //font.pixelSize: 30 // 设置字体大小，你可以根据需要调整这个值来放大字体 pointSize
                font.pointSize: 30
                height: 35 // 根据字体大小设置合适的高度
              }
    }  //Column Item

    Item {  //Column Item
        width: 1050 // 根据需要设置宽度  
        height: 35 // 根据需要设置高度  
  
        Text {
          anchors.fill: parent // 填充整个 Item  
          verticalAlignment: Text.AlignVCenter // 文本垂直居中  
          horizontalAlignment: Text.AlignHCenter // 文本水平也居中（如果需要）
          textFormat: Text.RichText
          text: {
        if (root.frontArr === null || root.frontArr === Qt.undefined) {
            return "";
        } else {
            if("false" == aa){
                return root.frontLinePlainRich();
            }else{
                return root.backLineRich;
            }
        }
    }
          color: "#E4D5A0"
          //font.weight: Font.Bold // 设置字体加粗  
          //font.pixelSize: 30 // 设置字体大小，你可以根据需要调整这个值来放大字体 pointSize
          font.pointSize: 30
          height: 35 // 根据字体大小设置合适的高度
        }
    } //Column Item 


      

    Item {  //Column Item
        width: 1050 // 根据需要设置宽度  
        height: 35 // 根据需要设置高度  
  
        Row {  
          spacing: 5
          Item { //row Item  
        width: 0 // 根据需要设置宽度  
        height: 35 // 根据需要设置高度 
          TextField {
            visible: false
            id: input1
            Layout.fillWidth: true
            Layout.fillHeight: true
            //placeholderText: qsTr("w")
            //placeholderTextColor: "#70DB93"
            text: ""
            color: "#E4D5A0"
            Keys.onPressed: {
                if (event.key == Qt.Key_Return || event.key == Qt.Key_Enter) {
                    // console.log("回车键被按下")
                    // 在这里添加你希望在按下回车键时执行的代码
                    finishWord(input1.text);
                }
            }
            width: 0
            //height: 50
            //font.weight: Font.Bold // 设置字体加粗 
            //font.pixelSize: 30
            font.pointSize: 28
          }
          } //row Item 


Item { //row Item  
        width: 950 // 根据需要设置宽度  
        height: 35 // 根据需要设置高度 
          Text {
            anchors.fill: parent // 填充整个 Item  
            verticalAlignment: Text.AlignVCenter // 文本垂直居中  
            horizontalAlignment: Text.AlignHCenter // 文本水平也居中（如果需要）
            text: input1.text
            color: textColor
            //font.weight: Font.Bold // 设置字体加粗  
            //font.pixelSize: 30 // 设置字体大小，你可以根据需要调整这个值来放大字体 pointSize
            font.pointSize: 30
            height: 35 // 根据字体大小设置合适的高度
            // 使用JavaScript表达式来更新textColor属性  
              Component.onCompleted: {  
                  function updateTextColor() {  

                      var inputText = input1.text.trim().toLowerCase(); 
                      if (word === null || word === Qt.undefined) {
    return;
}
 
                      var name = word.trim().toLowerCase();
                      var trimmed = root.trimToValidPrefix(inputText, name);
                      if (trimmed !== inputText) {
                          root.countTypingMistakes(inputText, name);
                          input1.text = trimmed;
                          lastInputForMistake = trimmed;
                          textColor = "#70DB93";
                          root.updateAnkiStatus();
                          return;
                      }

                      root.countTypingMistakes(inputText, name);
                      var minLength = Math.min(inputText.length, name.length);  
            
                      // 检查input1的文本和name的每个字符是否相等  
                      var isEqual = true;  
                      for (var i = 0; i < minLength; ++i) {  
                          if (inputText[i] !== name[i]) {  
                              isEqual = false;  
                              break;  
                          }  
                      }  
            
                      // 根据比较结果设置Text的颜色  
                      if (inputText.length > name.length) {  
                          textColor = "red";
                          input1.text = root.trimToValidPrefix(inputText, name);
                          lastInputForMistake = input1.text;
                      } else if (isEqual) {  
                          textColor = "green";  
                      } else {  
                          textColor = "red";  
                      }

                      if(input1.text.trim().toLowerCase() == word.trim().toLowerCase()){
                        finishWord(input1.text);
                      }

                      if(input1.text.trim().toLowerCase() == "aa"){
                        finishWord("aa");
                      }
                  }  
        
                  // 当input1的文本改变时，更新颜色  
                  input1.textChanged.connect(updateTextColor);  
        
                  // 初始设置颜色  
                  updateTextColor();  
              }  
        
              // 定义textColor属性  
              property color textColor: "#70DB93" // 初始颜色为红色
          }
}//row Item 


Item {  //row Item 
        width: 100 // 根据需要设置宽度  
        height: 35 // 根据需要设置高度 
      Button {
          Layout.fillWidth: true
          enabled: input1.text !== ""
          text: "OK"
          width: 100
          height: 50
          onClicked: {
            finishWord(input1.text);
          }
          //font.weight: Font.Bold // 设置字体加粗 
          //font.pixelSize: 20
          font.pointSize: 10
      }
}//row Item 
    
    
   
       

      } //row end
    } //Column Item end  

    //Item {
        //width: 1050
        //height: 22
        //Text {
            //id: uiSourceText
            //anchors.fill: parent
            //verticalAlignment: Text.AlignVCenter
            //horizontalAlignment: Text.AlignHCenter
            //color: "#88CCFF"
            //font.pointSize: 14
            //text: root.uiSourceLabel
        //}
    //}


        
     
     Item {//Column Item   
         width: 1050 // 根据需要设置宽度  
         height: 35 // 根据需要设置高度  
         Text {
            textFormat: Text.RichText
            text: root.methodLineRich
            anchors.fill: parent // 填充整个 Item  
            verticalAlignment: Text.AlignVCenter // 文本垂直居中  
            horizontalAlignment: Text.AlignHCenter // 文本水平也居中（如果需要）
            color: "#70DB93"
            //font.weight: Font.Bold // 设置字体加粗  
            //font.pixelSize: 30 // 设置字体大小，你可以根据需要调整这个值来放大字体 pointSize
            font.pointSize: 30
            height: 35 // 根据字体大小设置合适的高度
          }
    
    }//Column Item 

     Item { //Column Item 
         width: 1010 // 根据需要设置宽度  
         height: 300 // 根据需要设置高度 

    BQVirtualKeyboard {
        id: virtualKeyboard
        y: 0
        anchors.horizontalCenter: parent.horizontalCenter
        visible: true
        wordMp3: root.mp3 || ""
        wordMp3Zh: root.mp3Zh || ""
        resolveAudioPath: root.wordAudioPath
        dialogHost: root
    }
     } //Column Item
  } //Column end

  function escapeHtml(s) {
    return String(s || "")
        .replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;");
  }

  /** 从记忆法（+ 分段）提取中文关键字，与 Anki 模板一致 */
  function extractKeywords(method) {
    var keywords = [];
    if (!method)
      return keywords;
    var segs = String(method).split("+");
    for (var i = 0; i < segs.length; i++) {
      var m = segs[i].match(/([\u4e00-\u9fa5]+)(?=\(|$)/);
      if (m && m[1])
        keywords.push(m[1]);
    }
    return keywords;
  }

  function getMethodSource() {
    if (frontArr && frontArr.length > 1 && frontArr[1])
      return String(frontArr[1]);
    if (backArr && backArr.length > 2 && backArr[2])
      return String(backArr[2]);
    return "";
  }

  function highlightMethodText(method, keywords) {
    var html = escapeHtml(method);
    for (var i = 0; i < keywords.length; i++) {
      var kw = keywords[i];
      if (!kw)
        continue;
      var escaped = escapeHtml(kw);
      html = html.split(escaped).join(
          '<font color="#ffd166"><b>' + escaped + '</b></font>');
    }
    return html;
  }

  function highlightAssociationText(assoc, keywords) {
    var html = escapeHtml(assoc);
    for (var i = 0; i < keywords.length; i++) {
      var kw = keywords[i];
      if (!kw)
        continue;
      var escaped = escapeHtml(kw);
      html = html.split(escaped).join(
          ' <font color="#7bdff2">(' + escaped + ')</font> ');
    }
    return html.trim();
  }

  function frontLinePlainRich() {
    var meaning = (frontArr && frontArr.length > 0) ? frontArr[0] : "";
    var bracket = (frontArr && frontArr.length > 2) ? frontArr[2] : "";
    var keywords = extractKeywords(getMethodSource());
    // return escapeHtml(meaning) + "   [" + highlightAssociationText(bracket, keywords) + "]";
    return highlightAssociationText(bracket, keywords);
  }

  function refreshKeywordHighlight() {
    var methodSrc = getMethodSource();
    var keywords = extractKeywords(methodSrc);
    var assoc = (frontArr && frontArr.length > 2) ? frontArr[2] : "";
    if (!assoc && backArr && backArr.length > 1)
      assoc = backArr[1];
    var meaning = (frontArr && frontArr.length > 0) ? frontArr[0] : "";
    // meaningLineRich = "[" + highlightAssociationText(assoc, keywords) + "]   " + escapeHtml(meaning);
    meaningLineRich =  escapeHtml(meaning);
    methodLineRich = highlightMethodText(
        (frontArr && frontArr.length > 1) ? frontArr[1] : methodSrc, keywords);
    var backWord = (backArr && backArr.length > 0) ? backArr[0] : "";
    var backMethod = (backArr && backArr.length > 2) ? backArr[2] : "";
    // backLineRich = escapeHtml(backWord) + "   [" + highlightMethodText(backMethod, keywords) + "]";
    backLineRich = highlightMethodText(backMethod, keywords)
  }

  function resetTypingTrack() {
    lastInputForMistake = "";
    wordSubmitted = false;
  }

  function wordAudioPath(base) {
    if (!base)
      return "";
    var p = String(base).replace(/^\.\//, "");
    if (typeof AppPath !== "undefined" && AppPath) {
      var full = AppPath + "/" + p;
      full = full.replace("file:///", "");
      if (full.startsWith("file://"))
        full = full.slice(7);
      return full;
    }
    return base;
  }

  function cleanWordSound(raw) {
    if (!raw)
      return "";
    return String(raw).toLowerCase().replace(/[^a-z]/g, "");
  }

  function syncKeyboardAudio() {
    virtualKeyboard.wordMp3 = wordAudioPath(mp3);
    virtualKeyboard.wordMp3Zh = wordAudioPath(mp3Zh);
  }

  function playWordMp3() {
    if (mp3)
      Backend.playSound(wordAudioPath(mp3));
  }

  function playWordWav() {
    if (mp3Zh)
      Backend.playSoundWav(wordAudioPath(mp3Zh));
  }

  function trimToValidPrefix(text, target) {
    var a = (text || "").trim().toLowerCase();
    var b = (target || "").trim().toLowerCase();
    var n = Math.min(a.length, b.length);
    var len = 0;
    for (var i = 0; i < n; i++) {
      if (a.charAt(i) === b.charAt(i))
        len = i + 1;
      else
        break;
    }
    return a.substring(0, len);
  }

  function easeLabelFromCount(cnt) {
    if (cnt >= 3)
      return "困难";
    if (cnt >= 1)
      return "良好";
    return "简单";
  }

  function updateAnkiStatus() {
    var cnt = sessionWrongCount;
    if (typeof Backend.resetWordSession === "function"
        && typeof Backend.getWordMistakeCount === "function")
      cnt = Math.max(cnt, Backend.getWordMistakeCount());
    var ease = easeLabelFromCount(cnt);
    if (typeof Backend.getWordAnkiEaseLabel === "function")
      ease = Backend.getWordAnkiEaseLabel();
    ankiStatusText.text = "错误次数: " + cnt + "  |  Anki掌握度: " + ease;
  }

  /** 每按错一个字母计 1 次（字母变红时累计） */
  function ankiCall(cmd) {
    return Backend.getOneWord(spring_ip_or_room_name, cmd, playerName);
  }

  function countTypingMistakes(inputText, name) {
    if (inputText.length <= lastInputForMistake.length) {
      lastInputForMistake = inputText;
      return;
    }
    for (var i = lastInputForMistake.length; i < inputText.length; i++) {
      if (i >= name.length || inputText.charAt(i) !== name.charAt(i)) {
        sessionWrongCount++;
        ankiCall("wrong");
        updateAnkiStatus();
      }
    }
    lastInputForMistake = inputText;
  }

  function finishWord(answerText) {
    if (wordSubmitted)
      return;

    var ans = answerText.trim().toLowerCase();
    var target = (word === null || word === Qt.undefined) ? "" : word.trim().toLowerCase();

    if (ans === "aa") {
      wordSubmitted = true;
      console.log("[Anki] finishWord 放弃 aa → giveup");
      ankiCall("giveup");
    } else if (ans === target) {
      wordSubmitted = true;
      console.log("[Anki] finishWord 答对 → done");
      ankiCall("done");
    } else {
      // 答错：不换词，清掉错误字母，继续在本对话框内重试
      input1.text = trimToValidPrefix(ans, target);
      lastInputForMistake = input1.text;
      updateAnkiStatus();
      return;
    }

    var replyPayload = front_back;
    if (!replyPayload || replyPayload === "nil" || replyPayload === "undefined") {
      replyPayload = resolveFrontBack(jsonObject || {});
    }
    ClientInstance.replyToServer("", answerText + "," + replyPayload);
    finished();
    playWordMp3();
  }

  function resolveFrontBack(obj) {
    var fb = obj.str_front_and_back;
    if (typeof fb === "string" && fb !== "nil" && fb !== "undefined"
        && fb.indexOf("_=front_xxxxxxxxxx_back=_") !== -1) {
      return fb;
    }
    var f = obj.front;
    var b = obj.back;
    if (typeof f === "string" && f !== "nil" && f !== "undefined"
        && typeof b === "string" && b !== "nil" && b !== "undefined") {
      return f + "_=front_xxxxxxxxxx_back=_" + b;
    }
    return "vi./vt.写字，写 皇冠(编码)+日(拼音)+特(拼音) 戴着皇冠的日本特务在写字_=front_xxxxxxxxxx_back=_write 戴着皇冠的日本特务在写字 w皇冠(编码)+ri日(拼音)+te特(拼音)";
  }

  function parseLoadPayload(data) {
    if (typeof data === "string") {
      try {
        return JSON.parse(data);
      } catch (e) {
        console.warn("WordTestDialog: JSON.parse failed", e);
        return {};
      }
    }
    if (typeof data === "object" && data !== null)
      return data;
    return {};
  }

  function formatUiSourceLabel(src) {
    if (src === "core")
      return "来源: core（freekill-core · LunarLtk UI）";
    if (src === "本体")
      return "来源: 本体（内置 lua · Fk/LunarLTK UI）";
    if (typeof src === "string" && src !== "")
      return "来源: " + src;
    return "来源: 未知";
  }

  function resolveUiSource(obj) {
    var src = obj.uiSource;
    if (typeof src === "string" && src !== "" && src !== "nil" && src !== "undefined")
      return src;
    return "core";
  }

  function resetWordSessionState() {
    sessionWrongCount = 0;
    if (typeof Backend.resetWordSession === "function")
      Backend.resetWordSession();
  }

  function applyWordPayload(obj) {
    requestJava = obj.requestJava
    aa = obj.aa
    spring_ip_or_room_name = obj.ip
    playerName = obj.player || ""
    resetWordSessionState()
    uiSourceLabel = formatUiSourceLabel(resolveUiSource(obj))
    if (!playerName && typeof Self !== "undefined" && Self && Self.screenName)
      playerName = Self.screenName
    resetTypingTrack()
    front_back = resolveFrontBack(obj);
    processString(front_back)
    input1.text = ""
    updateAnkiStatus()
    playWordMp3()
    playWordWav()
  }

  function hasServerWordPair(obj) {
    var fb = resolveFrontBack(obj || {});
    return typeof fb === "string"
        && fb.indexOf("_=front_xxxxxxxxxx_back=_") !== -1;
  }

  function loadData(data) {
    console.log("WordTestDialog loadData:", data);
    jsonObject = parseLoadPayload(data);
    applyWordPayload(jsonObject);
    if (requestJava !== "true")
      return;
    Qt.callLater(function() {
      var front_back_temp = ankiCall("no");
      var sep = front_back_temp ? front_back_temp.indexOf("_=front_xxxxxxxxxx_back=_") : -1;
      console.log("anki pick len=" + (front_back_temp ? front_back_temp.length : 0)
          + " sep=" + sep
          + " deck=" + (typeof Backend.getWordAnkiPickDeck === "function"
              ? Backend.getWordAnkiPickDeck() : "")
          + " meaning=" + (typeof Backend.getWordAnkiPickMeaning === "function"
              ? Backend.getWordAnkiPickMeaning() : "")
          + " word=" + (typeof Backend.getWordAnkiPickWord === "function"
              ? Backend.getWordAnkiPickWord() : ""));
      if (front_back_temp && sep !== -1) {
        front_back = front_back_temp;
        processString(front_back);
        input1.text = "";
        updateAnkiStatus();
      }
    });
  }


    function processString(front_and_back) {
          if (!front_and_back || typeof front_and_back !== "string"
              || front_and_back === "nil" || front_and_back === "undefined"
              || front_and_back.indexOf("_=front_xxxxxxxxxx_back=_") === -1) {
            front_and_back = resolveFrontBack({});
          }
          var front_and_backArr = front_and_back.split("_=front_xxxxxxxxxx_back=_"); 
          front = front_and_backArr[0] || ""
          back = front_and_backArr[1] || ""
          frontArr = front.split(" ");
          backArr = (back || "").split(" ");
          word = cleanWordSound((backArr[0] || "").trim());
          if (!word)
            word = cleanWordSound(back);
          mp3 = "./audio/word/" + word;
          mp3Zh = "./audio/word/" + word + "_zh";
          syncKeyboardAudio();
          refreshKeywordHighlight();
    }

    //BQVirtualKeyboard {
        //id: virtualKeyboard
        //y: 180
        //anchors.horizontalCenter: parent.horizontalCenter
        ////visible: input1.hasFocus
    //}

  function shown() {
    if (dialogJson)
      loadData(dialogJson);
  }

  Component.onCompleted: {
    shown();
  }
}
