import QtQuick
import "../RoomElement"
import QtQuick.Layouts
import QtQuick.Controls 2.15

//TestDialog
GraphicsBox {    
  property string custom_string: ""
    
    // 假设我们有一个包含多个单词的字符串  
    // -xxxxxx-
    // _xxxxxx_
    property var ch: processStringCh(custom_string)
  
    // 使用空格作为分隔符拆分字符串为单词数组  
    property var en_line0_lower: processString(custom_string)

  id: root
  title.text: Backend.translate("en")
  width: Math.max(140, body.width + 20)
  height: body.height + title.height + 20

  Column {
    id: body
    x: 10
    y: title.height + 5
    spacing: 5

    Text {
      text: root.ch
      color: "#E4D5A0"
      font.weight: Font.Bold // 设置字体加粗  
      font.pixelSize: 30 // 设置字体大小，你可以根据需要调整这个值来放大字体
      height: 35 // 根据字体大小设置合适的高度
    }

    Row {  
        spacing: 5
        
        TextField {
          id: input1
          Layout.fillWidth: true
          //placeholderText: qsTr("w")
          //placeholderTextColor: "red"
          text: ""
          color: "#E4D5A0"
          Keys.onPressed: {
              if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                  // console.log("回车键被按下")
                  // 在这里添加你希望在按下回车键时执行的代码
                  ClientInstance.replyToServer("", input1.text);
                  finished();
              }
          }
          //background: Rectangle {
              //color: "royalblue"  // 设置背景颜色 royalblue 宝蓝
              //radius: 5  // 设置圆角半径
          //}
          width: 400
          height: 50
          font.weight: Font.Bold // 设置字体加粗 
          font.pixelSize: 30
        }

    Button {
        Layout.fillWidth: true
        enabled: input1.text !== ""
        text: "OK"
        width: 400
        height: 50
        onClicked: {
          ClientInstance.replyToServer("", input1.text);
          finished();
        }
        font.weight: Font.Bold // 设置字体加粗 
        font.pixelSize: 20
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
        var parts = str.split("-xxxxxx-");  
        Backend.playSound("./audio/word/"+ parts[2].trim());
        return parts[0];  
    }

    function processString(str) {  
        var parts = str.split("-xxxxxx-");  
        var finalParts = [];  
  
        for (var i = 1; i < parts.length - 1; ++i) {  
            var subParts = parts[i].split("_xxxxxx_");  
            for (var j = 0; j < subParts.length; ++j) {  
                var subPart = subParts[j].trim(); // 使用 trim() 来移除字符串两端的空白字符  
                if (subPart !== "") { // 检查字符串是否为空  
                    finalParts.push(subPart);  
                }  
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
