import QtQuick
import "../RoomElement"
import QtQuick.Layouts
import QtQuick.Controls 2.15

//TestDialog
GraphicsBox {    
  
    property string custom_string: ""
    
    // 使用空格作为分隔符拆分字符串为单词数组  
    property var en_line0_lower
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
    property var part0_2
    property var front_back
    property var jsonObject 

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

    

    Item {  //Column Item
        width: 1050 // 根据需要设置宽度  
        height: 35 // 根据需要设置高度  
  
              Text {
                anchors.fill: parent // 填充整个 Item  
                verticalAlignment: Text.AlignVCenter // 文本垂直居中  
                horizontalAlignment: Text.AlignHCenter // 文本水平也居中（如果需要）
                text: {
        if (root.frontArr === null || root.frontArr === Qt.undefined) {
            return "";  // 或者返回任何你想要的文本
        } else {
            return "[" + root.frontArr[2] + "]   " + root.frontArr[0];
        }
    }
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
                text: {
        if (root.frontArr === null || root.frontArr === Qt.undefined) {
            return "";  // 或者返回任何你想要的文本
        } else {
            return "[" + root.frontArr[2] + "]   " + root.frontArr[0];
        }
    }
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
          text: {
        if (root.frontArr === null || root.frontArr === Qt.undefined) {
            return "";  // 或者返回任何你想要的文本
        } else {
            if("false" == aa){
                return root.frontArr[0]+"   ["+root.frontArr[2]+"]";
            }else{
                if (root.backArr === null || root.backArr === Qt.undefined) {
                    return "";  // 或者返回任何你想要的文本
                } else {
                    return root.backArr[0]+"   ["+root.backArr[2]+"]";
                }
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
                    ClientInstance.replyToServer("", input1.text+","+front_back);
                    finished();
                    Backend.playSound(mp3); 
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
 
                      var name = word.trim().toLowerCase(); // 假设name是一个已知的字符串，您可能需要根据实际情况修改  
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
                          if (inputText.length > (name.length+1)) { 
                            ClientInstance.replyToServer("", input1.text+","+front_back);
                            finished();
                            Backend.playSound(mp3); 
                          }
                      } else if (isEqual) {  
                          textColor = "green";  
                      } else {  
                          textColor = "red";  
                      }

                      if(input1.text.trim().toLowerCase() == word.trim().toLowerCase()){
                        ClientInstance.replyToServer("", input1.text+","+front_back);
                        finished();
                        Backend.playSound(mp3); 
                      }

                      if(input1.text.trim().toLowerCase() == "aa"){
                        ClientInstance.replyToServer("", "aa"+","+front_back);
                        finished();
                        Backend.playSound(mp3); 
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
            
            ClientInstance.replyToServer("", input1.text+","+front_back);
            finished();
            Backend.playSound(mp3); 
          }
          //font.weight: Font.Bold // 设置字体加粗 
          //font.pixelSize: 20
          font.pointSize: 10
      }
}//row Item 
    
    
   
       

      } //row end
    } //Column Item end  
        
     
     Item {//Column Item   
         width: 1050 // 根据需要设置宽度  
         height: 35 // 根据需要设置高度  
         Text {
            text: {
        if (root.frontArr === null || root.frontArr === Qt.undefined) {
            return "";  // 或者返回任何你想要的文本
        } else {
            return root.frontArr[1];
        }
    }
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
         height: 360 // 根据需要设置高度 

    BQVirtualKeyboard {
        id: virtualKeyboard
        y: 0
        anchors.horizontalCenter: parent.horizontalCenter
        visible: true
    }
     } //Column Item
  } //Column end

  function loadData(data) {
    //{"front": "'..front..'",  "back": "'..back..'", "requestJava": "'..requestJava..'", "str_front_and_back": "'..str_front_and_back..'", "ip": "'..room.wordList..'"}
    
    // data loadData: {
    // "front": "adj.生病的，坏的 我(熟词)+11(象形) 我11岁的时候生病了", 
    // "back": "ill  我11岁的时候生病了 i我(熟词I)+ll11(象形)", 
    // "requestJava": "true", 
    // "str_front_and_back": "adj.生病的，坏的 我(熟词)+11(象形) 我11岁的时候生病了_=front_xxxxxxxxxx_back=_ill 我11岁的时候生病了 i我(熟词I)+ll11(象形)", 
    // "ip": "192.168.3.7"}

    console.log("======================================================data loadData: " + data);
    jsonObject = JSON.parse(data);
     requestJava = jsonObject.requestJava
     aa = jsonObject.aa
     spring_ip_or_room_name = jsonObject.ip
     if(requestJava == "true"){
       front_back = jsonObject.str_front_and_back;
       var front_back_temp = Backend.getOneWord(spring_ip_or_room_name, "no");
       console.log("ip:"+spring_ip_or_room_name+"  front_back_temp: " + front_back_temp);
       if (front_back_temp && front_back_temp.indexOf("_=front_xxxxxxxxxx_back=_") !== -1) {
           front_back = front_back_temp
        }else{
           front_back = jsonObject.str_front_and_back;
        }
     }else{
       front_back = jsonObject.str_front_and_back;
     }
     en_line0_lower = processString(front_back)
  }


     function shuffleArray(array) {
        // 打乱数组顺序（Fisher-Yates 洗牌算法）
        for (let i = array.length - 1; i > 0; i--) {
            const j = Math.floor(Math.random() * (i + 1));
            [array[i], array[j]] = [array[j], array[i]];  // 交换元素
        }
    }

    function processString(front_and_back) {
          var front_and_backArr = front_and_back.split("_=front_xxxxxxxxxx_back=_"); 
          front = front_and_backArr[0]
          back =  front_and_backArr[1]
          frontArr = front.split(" ");
          backArr = back.split(" ");
          word = backArr[0].trim(); 
          mp3 = "./audio/word/"+ word;
          mp3Zh = "./audio/word/"+ word +"_zh"
          
            var finalParts = [];  
            var subParts = splitWordAndAddLetters(word);  
            for (var j = 0; j < subParts.length; ++j) {  
                var subPart = subParts[j].trim(); // 使用 trim() 来移除字符串两端的空白字符  
                if (subPart !== "") { // 检查字符串是否为空  
                    finalParts.push(subPart);  
                }  
            }  
            return finalParts;  
        
    }

    function splitWordAndAddLetters(word) {
        // 拆分单词成字母数组
        let letters = word.split('');

        // 如果字母数量少于6个，随机添加3个不重复字母
        if (letters.length < 7) {
            const lettersToAdd = generateRandomLetters(7 - letters.length);  // 获取所需的随机字母
            letters = letters.concat(lettersToAdd);
        }

        // 打乱字母顺序
        shuffleArray(letters);
        return letters;
    }

    function generateRandomLetters(numLetters) {
        const alphabet = "abcdefghijklmnopqrstuvwxyz";  // 可选：使用大写字母
        const randomLetters = [];
        const usedLetters = new Set();

        while (randomLetters.length < numLetters) {
            const randomIndex = Math.floor(Math.random() * alphabet.length);
            const letter = alphabet[randomIndex];

            // 确保字母不重复
            if (!usedLetters.has(letter)) {
                randomLetters.push(letter);
                usedLetters.add(letter);
            }
        }

        return randomLetters;
    }

    //BQVirtualKeyboard {
        //id: virtualKeyboard
        //y: 180
        //anchors.horizontalCenter: parent.horizontalCenter
        ////visible: input1.hasFocus
    //}
}
