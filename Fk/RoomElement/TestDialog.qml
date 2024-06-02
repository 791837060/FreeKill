import QtQuick
import "../RoomElement"
import QtQuick.Layouts
import QtQuick.Controls 2.15

//TestDialog
GraphicsBox {    
  property string custom_string: ""
    
    // 假设我们有一个包含多个单词的字符串  
    // -xxxxxx-
    // _xxxxxx_ 拆分字母
    property var ch: processStringCh(custom_string)
  
    // 使用空格作为分隔符拆分字符串为单词数组  
    property var en_line0_lower: processString(custom_string)

    property var mp3
    property var mp3Zh
    property var word
    property var frontArr
    property var backArr
    property var front
    property var back
    property var requestJava
    property var ownerRoom

  id: root
  //title.text: Backend.translate("en")
  width: Math.max(140, body.width + 20)
  height: body.height + title.height + 20

  Column {
    id: body
    x: 10
    y: title.height + 5
    spacing: 5

      Text {
          text: root.frontArr[0]+" "+root.frontArr[2]
          color: "#E4D5A0"
          font.weight: Font.Bold // 设置字体加粗  
          //font.pixelSize: 30 // 设置字体大小，你可以根据需要调整这个值来放大字体 pointSize
          font.pointSize: 14
          height: 35 // 根据字体大小设置合适的高度
        }

        Text {
          text: root.frontArr[0]+" "+root.frontArr[2]
          color: "#E4D5A0"
          font.weight: Font.Bold // 设置字体加粗  
          //font.pixelSize: 30 // 设置字体大小，你可以根据需要调整这个值来放大字体 pointSize
          font.pointSize: 14
          height: 35 // 根据字体大小设置合适的高度
        }
      
      Text {
          text: root.frontArr[0]+" "+root.frontArr[2]
          color: "#E4D5A0"
          font.weight: Font.Bold // 设置字体加粗  
          //font.pixelSize: 30 // 设置字体大小，你可以根据需要调整这个值来放大字体 pointSize
          font.pointSize: 14
          height: 35 // 根据字体大小设置合适的高度
        }
    

    Row {  
        spacing: 5
        
        TextField {
          id: input1
          Layout.fillWidth: true
          Layout.fillHeight: true
          //placeholderText: qsTr("w")
          //placeholderTextColor: "red"
          text: ""
          color: "#E4D5A0"
          Keys.onPressed: {
              if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                  // console.log("回车键被按下")
                  // 在这里添加你希望在按下回车键时执行的代码
                  Backend.playSound(mp3);
                  if(requestJava === "true" && input1.text.trim().toLowerCase() === word.trim().toLowerCase()){
                    const front_back = Backend.getOneWord(ownerRoom);
                    ClientInstance.replyToServer("", input1.text+","+front_back);
                  }else{
                    ClientInstance.replyToServer("", input1.text);
                  }
                  finished();
              }
          }
          //width: 250
          //height: 50
          //font.weight: Font.Bold // 设置字体加粗 
          //font.pixelSize: 30
          font.pointSize: 14
        }
        

        Text {
          text: input1.text
          color: "#E4D5A0"
          font.weight: Font.Bold // 设置字体加粗  
          //font.pixelSize: 30 // 设置字体大小，你可以根据需要调整这个值来放大字体 pointSize
          font.pointSize: 14
          height: 35 // 根据字体大小设置合适的高度
        }

    Button {
        Layout.fillWidth: true
        enabled: input1.text !== ""
        text: "OK"
        width: 100
        height: 50
        onClicked: {
          Backend.playSound(mp3);
          if(requestJava === "true" && input1.text.trim().toLowerCase() === word.trim().toLowerCase()){
            const front_back = Backend.getOneWord(ownerRoom);
            // word + cn + word +back
            ClientInstance.replyToServer("", input1.text+","+front_back);
          }else{
            ClientInstance.replyToServer("", input1.text);
          }
          finished();
        }
        font.weight: Font.Bold // 设置字体加粗 
        //font.pixelSize: 20
        font.pointSize: 10
    }

  
        Text {
          text: root.frontArr[1]
          color: "#E4D5A0"
          font.weight: Font.Bold // 设置字体加粗  
          //font.pixelSize: 30 // 设置字体大小，你可以根据需要调整这个值来放大字体 pointSize
          font.pointSize: 14
          height: 35 // 根据字体大小设置合适的高度
        }

        

    }

    BQVirtualKeyboard {
        id: virtualKeyboard
        y: 110
        anchors.horizontalCenter: parent.horizontalCenter
        visible: input1.hasFocus
    }
  }

  function loadData(data) {
    custom_string = data;
  }


    function processStringCh(str) {  
        // front  .."-xxxxxx-"..  subStr .."-xxxxxx-".. back.."-xxxxxx-"..requestJava.."-xxxxxx-"..ownerRoom
        var part0_2 = str.split("-xxxxxx-"); 
        front = part0_2[0]
        back =  part0_2[2]
        frontArr = front.split(" ");
        backArr = back.split(" ");
        requestJava = part0_2[3]
        ownerRoom = part0_2[4]
        word =backArr[0].trim(); 
        mp3 = "./audio/word/"+ word;
        mp3Zh = "./audio/word/"+ word +"_zh"
        Backend.playSoundWav(mp3Zh);
        return front;  
    }

    function processString(str) {  
        var part0_2 = str.split("-xxxxxx-");  
        var finalParts = [];  
        var subParts = part0_2[1].split("_xxxxxx_");  
            for (var j = 0; j < subParts.length; ++j) {  
                var subPart = subParts[j].trim(); // 使用 trim() 来移除字符串两端的空白字符  
                if (subPart !== "") { // 检查字符串是否为空  
                    finalParts.push(subPart);  
                }  
            }  
        return finalParts;  
    }

    //BQVirtualKeyboard {
        //id: virtualKeyboard
        //y: 180
        //anchors.horizontalCenter: parent.horizontalCenter
        ////visible: input1.hasFocus
    //}
}
