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
    property var ch: processStringCh(front_back)
  
    // 使用空格作为分隔符拆分字符串为单词数组  
    property var en_line0_lower: processString(front_back)

    property var mp3
    property var mp3Zh
    property var word
    property var frontArr
    property var backArr
    property var front
    property var back
    property var requestJava
    property var part0_2
    property var front_back

  id: root
  //title.text: Backend.translate("en")
  title.text: front
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
                text: "["+root.frontArr[2]+"]   "+root.frontArr[0]
                color: "red"
                font.weight: Font.Bold // 设置字体加粗  
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
                text: "["+root.frontArr[2]+"]   "+root.frontArr[0]
                color: "red"
                font.weight: Font.Bold // 设置字体加粗  
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
          text: root.frontArr[0]+"   ["+root.frontArr[2]+"]"
          color: "#E4D5A0"
          font.weight: Font.Bold // 设置字体加粗  
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
            //placeholderTextColor: "red"
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
            font.weight: Font.Bold // 设置字体加粗  
            //font.pixelSize: 30 // 设置字体大小，你可以根据需要调整这个值来放大字体 pointSize
            font.pointSize: 30
            height: 35 // 根据字体大小设置合适的高度
            // 使用JavaScript表达式来更新textColor属性  
              Component.onCompleted: {  
                  function updateTextColor() {  
                      //if (input1.text.trim().toLowerCase() == "name".trim().toLowerCase()) {  
                          //textColor = "green";  
                      //} else {  
                          //textColor = "red";  
                      //}  

                      var inputText = input1.text.trim().toLowerCase();  
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
                  }  
        
                  // 当input1的文本改变时，更新颜色  
                  input1.textChanged.connect(updateTextColor);  
        
                  // 初始设置颜色  
                  updateTextColor();  
              }  
        
              // 定义textColor属性  
              property color textColor: "red" // 初始颜色为红色
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
          font.weight: Font.Bold // 设置字体加粗 
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
            text: root.frontArr[1]
            anchors.fill: parent // 填充整个 Item  
            verticalAlignment: Text.AlignVCenter // 文本垂直居中  
            horizontalAlignment: Text.AlignHCenter // 文本水平也居中（如果需要）
            color: "red"
            font.weight: Font.Bold // 设置字体加粗  
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
        visible: input1.hasFocus
    }
     } //Column Item
  } //Column end

  function loadData(data) {
     custom_string = data;
     part0_2 = custom_string.split("-xxxxxx-"); 
     requestJava = part0_2[3]
     if(requestJava == "true"){
       front_back = Backend.getOneWord("no", "no");
     }else{
       front_back = part0_2[5];
     }
  }

    function processStringCh(str) {  
        if(requestJava == "true"){
          // vi./vt.写字，写 皇冠(编码)+日(拼音)+特(拼音) 戴着皇冠的日本特务在写字_=front_xxxxxxxxxx_back=_write 戴着皇冠的日本特务在写字 w皇冠(编码)+ri日(拼音)+te特(拼音)
          var front_and_backArr = str.split("_=front_xxxxxxxxxx_back=_"); 
          front = front_and_backArr[0]
          back =  front_and_backArr[1]
          frontArr = front.split(" ");
          backArr = back.split(" ");
          word =backArr[0].trim(); 
          mp3 = "./audio/word/"+ word;
          mp3Zh = "./audio/word/"+ word +"_zh"
        }else{
          front = part0_2[0]
          back =  part0_2[2]
          frontArr = front.split(" ");
          backArr = back.split(" ");
          ownerRoom = part0_2[4]
          word =backArr[0].trim(); 
          mp3 = "./audio/word/"+ word;
          mp3Zh = "./audio/word/"+ word +"_zh"
        }
        Backend.playSound(mp3);
        return front;  
    }

     function shuffleArray(array) {
        // 打乱数组顺序（Fisher-Yates 洗牌算法）
        for (let i = array.length - 1; i > 0; i--) {
            const j = Math.floor(Math.random() * (i + 1));
            [array[i], array[j]] = [array[j], array[i]];  // 交换元素
        }
    }

    function processString(str) {
         // vi./vt.写字，写 皇冠(编码)+日(拼音)+特(拼音) 戴着皇冠的日本特务在写字_=front_xxxxxxxxxx_back=_write 戴着皇冠的日本特务在写字 w皇冠(编码)+ri日(拼音)+te特(拼音)
          var front_and_backArr = str.split("_=front_xxxxxxxxxx_back=_"); 
          front = front_and_backArr[0]
          back =  front_and_backArr[1]
          frontArr = front.split(" ");
          backArr = back.split(" ");
          word =backArr[0].trim(); 
          
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
