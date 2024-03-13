import QtQuick
import "../RoomElement"
import QtQuick.Layouts
import QtQuick.Controls 2.15

//TestDialog
GraphicsBox {
    function processString(str) {  
        var parts = str.split("-ulwfcyvi-");  
        var finalParts = [];  
  
        for (var i = 1; i < parts.length; ++i) {  
            var subParts = parts[i].split("_ulwfcyvi_");  
            for (var j = 0; j < subParts.length; ++j) {  
                var subPart = subParts[j].trim(); // 使用 trim() 来移除字符串两端的空白字符  
                if (subPart !== "") { // 检查字符串是否为空  
                    finalParts.push(subPart);  
                }  
            }  
        }  
  
        return finalParts;  
    }
  property string custom_string: ""
    
    // 假设我们有一个包含多个单词的字符串  
    // -ulwfcyvi-
    // _ulwfcyvi_
    //property string sentence: "假设我们有一个包含多个单词的字符串-ulwfcyvi-u_ulwfcyvi_l_ulwfcyvi_w_ulwfcyvi_f_ulwfcyvi_c"  
    property var ch: custom_string.split("-ulwfcyvi-")[0]
  
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
    spacing: 10

    Text {
      text: root.ch
      color: "#E4D5A0"
    }

    TextField {
        id: input1
        Layout.fillWidth: true
        placeholderText: qsTr("w")
        placeholderTextColor: "red"
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
        background: Rectangle {
            color: "royalblue"  // 设置背景颜色 royalblue 宝蓝
            radius: 5  // 设置圆角半径
        }
        width: 200
        height: 50
      }

    Button {
        Layout.fillWidth: true
        enabled: input1.text !== ""
        text: "OK"
        onClicked: {
          ClientInstance.replyToServer("", input1.text);
          finished();
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

    //BQVirtualKeyboard {
        //id: virtualKeyboard
        //y: 180
        //anchors.horizontalCenter: parent.horizontalCenter
        ////visible: input1.hasFocus
    //}
}
