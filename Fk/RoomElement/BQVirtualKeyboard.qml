import QtQuick 2.15

// 自定义虚拟键盘
Rectangle {
    id: virtualKeyboard
    //width: 710; height: 360 多两行时启用
    //width: 1110; height: 360
    width: 1010; height: 360 
    radius: 5
    color: "black"

    property bool isUpper: false            // 是否大写
    property bool isEnglish: true           // 是否英文
    property int page: 1                    // 字符页面
    property int pixelSize: 16              // 字体大小
    //property string textFontFamily: ""      // 字体样式
    property int languageType: 1            // 语言 1-中文 2-英文

    property var en_line1_lower: ["q", "w", "e", "r", "t", "y", "u", "i", "o", "p"]
    property var en_line1_upper: ["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"]
    property var en_line2_lower: ["a", "s", "d", "f", "g", "h", "j", "k", "l"]
    property var en_line2_upper: ["A", "S", "D", "F", "G", "H", "J", "K", "L"]
    property var en_line3_lower: ["z", "x", "c", "v", "b", "n", "m"]
    property var en_line3_upper: ["Z", "X", "C", "V", "B", "N", "M"]

    property var char_page1_line1: ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]
    property var char_page1_line2: ["~", "-", "+", ";", ":", "_", "=", "|", "\\"]
    property var char_page1_line3: ["`", ",", ".", "<", ">", "/", "?"]

    property var char_page2_line1: ["!", "@", "#", "$", "%", "^", "&", "*", "(", ")"]
    property var char_page2_line2: ["[", "]", "{", "}", "'", "\"", "I", "II", "III"]
    property var char_page2_line3: ["IV", "V", "VI", "VII", "VIII", "IX", "X"]

    // 第0行
    Row {
        y: 0
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 5

        Repeater {
            model: {
                if (isEnglish) {
                    isUpper ? en_line1_upper : root.en_line0_lower
                } else {
                    page == 1 ? char_page1_line1 : char_page2_line1
                }
            }

            Rectangle {
                width: 110; height: 70
                radius: 5
                color: area0.pressed ? "#2A2826" : "#383533"
                property bool clicked2: false // 定义点击状态变量
                Text {
                    id: word_sub
                    anchors.fill: parent
                    //font.family: textFontFamily
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    //color: area0.pressed ? "#FFFFFF" : "#000000"
                    color: parent.clicked2 ? "green" : (area0.pressed ? "#FFFFFF" : "#000000")
                    text: modelData

                    // 动态计算字体大小  
                    //property real availableWidth: parent.width - 5 // 减去一些间距以确保文本不会紧贴边界  
                    //property real availableHeight: parent.height - 5 // 同上  
                    //property real fontSize: Math.min(availableWidth, availableHeight) // 假设每个字符大约占据相同的宽度  
                    //font.weight: Font.Bold // 设置字体加粗 
                    font.pixelSize: 60
                }

                MouseArea {
                    id: area0
                    anchors.fill: parent
                    focus: false
                    //onPressed: {
                        //var focusedItem = ClientInstance.getFocusedItem(virtualKeyboard.parent)
                        //focusedItem.text = focusedItem.text + modelData
                        //input1.text = input1.text + modelData
                    //}

                    onPressed: {
                        parent.clicked2 = true; // 点击后设置 clicked2 为 true，改变字体颜色为红色
                        console.log("parent.clicked2 = " + parent.clicked2)
                    }

                     TapHandler {
                        id: tapHandler1
                        onTapped: {
                            input1.text = input1.text + modelData;
                            if (input1.text.length % 3 === 1) {                              
                                Backend.playSoundWav(mp3Zh);  
                            }  
                        }
                    }
                }
            }
        }
    }

    // 第一行
    Row {
        y: 75
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 5

        Repeater {
            model: {
                if (isEnglish) {
                    isUpper ? en_line1_upper : en_line1_lower
                } else {
                    page == 1 ? char_page1_line1 : char_page2_line1
                }
            }

            Rectangle {
                width: 110; height: 70
                radius: 5
                color: area1.pressed ? "#2A2826" : "#383533"
                property bool clicked2: false // 定义点击状态变量
                Text {
                    anchors.fill: parent
                    //font.weight: Font.Bold // 设置字体加粗 
                    font.pixelSize: 60
                    //font.family: textFontFamily
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    // color: area1.pressed ? "#FFFFFF" : "#000000"
                    // 根据 clicked2 属性控制字体颜色
                    color: parent.clicked2 ? "#FFFFFF" : (area1.pressed ? "#FFFFFF" : "#000000")
                    text: modelData
                }

                MouseArea {
                    id: area1
                    anchors.fill: parent
                    focus: false
                    //onPressed: {
                        //var focusedItem = ClientInstance.getFocusedItem(virtualKeyboard.parent)
                        //focusedItem.text = focusedItem.text + modelData
                        //input1.text = input1.text + modelData
                    //}
                    onPressed: {
                        parent.clicked2 = true; // 点击后设置 clicked2 为 true，改变字体颜色为红色
                        console.log("parent.clicked2 = " + parent.clicked2)
                    }
                     TapHandler {
                        id: tapHandler2
                        onTapped: {
                            input1.text = input1.text + modelData;
                            if (input1.text.length % 3 === 1) {                              
                                Backend.playSoundWav(mp3Zh);  
                            }
                        }
                    }
                }
            }
        }
    }

    // 第二行
    Row {
        y: 150
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 5

        Repeater {
            model: {
                if (isEnglish) {
                    isUpper ? en_line2_upper : en_line2_lower
                } else {
                    page == 1 ? char_page1_line2 : char_page2_line2
                }
            }

            Rectangle {
                width: 110; height: 70
                radius: 5
                property bool isTouching: false
                color: area2.pressed ? "#2A2826" : "#383533"
                property bool clicked2: false // 定义点击状态变量
                Text {
                    anchors.fill: parent
                    //font.weight: Font.Bold // 设置字体加粗 
                    font.pixelSize: 60
                    //font.family: textFontFamily
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    //color: area2.pressed ? "#FFFFFF" : "#000000"
                    color: parent.clicked2 ? "#FFFFFF" : (area2.pressed ? "#FFFFFF" : "#000000")
                    text: modelData
                }

//白色 #FFFFFF
//2 红色 #FF0000
//3 绿色 #00FF00
//4 蓝色 #0000FF
//5 牡丹红 #FF00FF
//6 青色 #00FFFF
//7 黄色 #FFFF00
//8 黑色 #000000
//9 海蓝 #70DB93
//10 巧克力色 #5C3317
//11 蓝紫色 #9F5F9F
//12 黄铜色 #B5A642
//13 亮金色 #D9D919
//14 棕色 #A67D3D
//15 青铜色 #8C7853
                
                 MouseArea {
                    id: area2
                    anchors.fill: parent
                    focus: false
                    //onPressed: {
                        //input1.text = input1.text + modelData
                    //}

                    onPressed: {
                        parent.clicked2 = true; // 点击后设置 clicked2 为 true，改变字体颜色为红色
                        console.log("parent.clicked2 = " + parent.clicked2)
                    }
                      
                    TapHandler {
                        id: tapHandler
                        onTapped: {
                            input1.text = input1.text + modelData
                            if (input1.text.length % 3 === 1) {                              
                                Backend.playSoundWav(mp3Zh);  
                            }
                        }
                    }
                }   
            }
        }
    }

    // 第三行
    Row {
        y: 225
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 5

        // clear
        Rectangle {
            width: 95; height: 70
            radius: 5
            color: area_clear.pressed ? "#2A2826" : "#383533"

            Text {
                anchors.fill: parent
                //font.weight: Font.Bold // 设置字体加粗 
                    font.pixelSize: 32
                //font.family: textFontFamily
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                color: area_clear.pressed ? "#FFFFFF" : "#000000"
                text: languageType == 1 ? "清 空" : "Clear"
            }

            MouseArea {
                id: area_clear
                anchors.fill: parent
                focus: false
                //onPressed: {
                    //var focusedItem = ClientInstance.getFocusedItem(virtualKeyboard.parent)
                    //focusedItem.text = ""
                    //input1.text = ""
                    
                //}
                 TapHandler {
                        id: tapHandler3
                        onTapped: {
                            input1.text = ""
                        }
                    }
            }
        }

        Repeater {
            model: {
                if (isEnglish) {
                    isUpper ? en_line3_upper : en_line3_lower
                } else {
                    page == 1 ? char_page1_line3 : char_page2_line3
                }
            }

            Rectangle {
                width: 110; height: 70
                radius: 5
                color: area3.pressed ? "#2A2826" : "#383533"
                property bool clicked2: false // 定义点击状态变量
                Text {
                    anchors.fill: parent
                    //font.weight: Font.Bold // 设置字体加粗 
                    font.pixelSize: 60
                    //font.family: textFontFamily
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    //color: area3.pressed ? "#FFFFFF" : "#000000"
                    color: parent.clicked2 ? "#FFFFFF" : (area3.pressed ? "#FFFFFF" : "#000000")
                    text: modelData
                }

                MouseArea {
                    id: area3
                    anchors.fill: parent
                    focus: false
                    //onPressed: {
                        //var focusedItem = ClientInstance.getFocusedItem(virtualKeyboard.parent)
                        //focusedItem.text = focusedItem.text + modelData
                        //input1.text = input1.text + modelData
                        
                    //}

                    onPressed: {
                        parent.clicked2 = true; // 点击后设置 clicked2 为 true，改变字体颜色为红色
                        console.log("parent.clicked2 = " + parent.clicked2)
                    }
                     TapHandler {
                        id: tapHandler4
                        onTapped: {
                            input1.text = input1.text + modelData;
                            if (input1.text.length % 3 === 1) {                              
                                Backend.playSoundWav(mp3Zh);  
                            }
                        }
                    }
                }
            }
        }

        // backspace
        Rectangle {
            width: 95; height: 70
            radius: 5
            color: area_backspace.pressed ? "#2A2826" : "#383533"

            Text {
                anchors.fill: parent
                //font.weight: Font.Bold // 设置字体加粗 
                font.pixelSize: 32
                //font.family: textFontFamily
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                color: area_backspace.pressed ? "#FFFFFF" : "#000000"
                text: languageType == 1 ? "回 退" : "Backspace"
            }

            MouseArea {
                id: area_backspace
                anchors.fill: parent
                focus: false
                //onPressed: {
                    //var focusedItem = ClientInstance.getFocusedItem(virtualKeyboard.parent)
                    //focusedItem.text = focusedItem.text.slice(0, -1)
                   // input1.text = input1.text.slice(0, -1)
                
               // }

                TapHandler {
                    id: tapHandler5
                    onTapped: {
                       
                        input1.text = input1.text.slice(0, -1)
                    }
                }
            }
        }
    }

    // 第四行
    Row {
        y: 300
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 5

        // switch
        Rectangle {
            width: 95; height: 70
            radius: 5
            color: area_switch.pressed ? "#2A2826" : "#383533"

            Text {
                anchors.fill: parent
                //font.weight: Font.Bold // 设置字体加粗 
                    font.pixelSize: 32
                //font.family: textFontFamily
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                color: area_switch.pressed ? "#FFFFFF" : "#000000"
                text: isEnglish ? "&123" : "ABC"
            }

            MouseArea {
                id: area_switch
                anchors.fill: parent
                focus: false
                //onPressed: isEnglish = !isEnglish
                TapHandler {
                    id: tapHandler6
                    onTapped: {
                         isEnglish = !isEnglish
                    }
                }
            }
        }

        // space
        Rectangle {
            width: 375; height: 70
            radius: 5
            color: area_space.pressed ? "#2A2826" : "#383533"

            Text {
                anchors.fill: parent
                //font.weight: Font.Bold // 设置字体加粗 
                    font.pixelSize: 32
                //font.family: textFontFamily
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                color: area_space.pressed ? "#FFFFFF" : "#000000"
                text: languageType == 1 ? "空 格" : "Space"
            }

            MouseArea {
                id: area_space
                anchors.fill: parent
                focus: false
                //onPressed: {
                    //var focusedItem = ClientInstance.getFocusedItem(virtualKeyboard.parent)
                    //focusedItem.text += " "
                    //input1.text += " "
            
                //}

                TapHandler {
                    id: tapHandler7
                    onTapped: {
                         input1.text += " "
                    }
                }
            }
        }

        

        // shift
        Rectangle {
            width: 95; height: 70
            radius: 5
            color: area_shift.pressed ? "#2A2826" : "#383533"

            Text {
                anchors.fill: parent
                //font.weight: Font.Bold // 设置字体加粗 
                font.pixelSize: 32
                //font.family: textFontFamily
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                color: area_shift.pressed ? "#FFFFFF" : (isEnglish && isUpper ? "#239B56" : "#000000")
                text: isEnglish ? "Shift" : (page == 1 ? "1/2" : "2/2")
            }

            MouseArea {
                id: area_shift
                anchors.fill: parent
                focus: false
                //onPressed: {
                   // if (isEnglish) {
                        //isUpper = !isUpper
                    //} else {
                        //page == 1 ? (page = 2) : (page = 1)
                    //}
                //}

                TapHandler {
                    id: tapHandler8
                    onTapped: {
                        if (isEnglish) {
                        isUpper = !isUpper
                        } else {
                            page == 1 ? (page = 2) : (page = 1)
                        }
                    }
                }
            }
        }

        // enter
        Rectangle {  
            id: enter
            width: 375; height: 70  
            radius: 5  
            color: area_enter.pressed ? "#2A2826" : "#383533"  
        
            Text {  
                anchors.fill: parent  
                //font.weight: Font.Bold // 设置字体加粗  
                font.pixelSize: 32  
                verticalAlignment: Text.AlignVCenter  
                horizontalAlignment: Text.AlignHCenter  
                color: area_enter.pressed ? "#FFFFFF" : "#000000"  
                text: languageType == 1 ? "回车" : "Enter" // 更改文本为“回车”或“Enter”  
            }  
        
            MouseArea {  
                id: area_enter  
                anchors.fill: parent  
                focus: false  
                //onPressed: {  
                    //ClientInstance.replyToServer("", input1.text+","+root.front_back);
                    //finished(); 
                //}
                
                TapHandler {
                    id: tapHandler9
                    onTapped: {
                        ClientInstance.replyToServer("", input1.text+","+root.front_back);
                        finished(); 
                    }
                }
                  
            }  
}
    }

    

    

    //    // 第一行
//    Row {
//        y: 80
//        anchors.horizontalCenter: parent.horizontalCenter
//        spacing: 10
//
//        Repeater {
//            model: {
//                if (isEnglish) {
//                    isUpper ? en_line1_upper : en_line1_lower
//                } else {
//                    page == 1 ? char_page1_line1 : char_page2_line1
//                }
//            }
//
//            Rectangle {
//                width: 60; height: 60
//                radius: 5
//                color: area1.pressed ? "#2A2826" : "#383533"
//
//                Text {
//                    anchors.fill: parent
//                    font.pixelSize: pixelSize
//                    //font.family: textFontFamily
//                    verticalAlignment: Text.AlignVCenter
//                    horizontalAlignment: Text.AlignHCenter
//                    color: area1.pressed ? "#5D4B37" : "#FFFFFF"
//                    text: modelData
//                }
//
//                MouseArea {
//                    id: area1
//                    anchors.fill: parent
//                    focus: false
//                    onClicked: {
//                        var focusedItem = ClientInstance.getFocusedItem(virtualKeyboard.parent)
//                        focusedItem.text = focusedItem.text + modelData
//                    }
//                }
//            }
//        }
//    }
//
//    // 第二行
//    Row {
//        y: 150
//        anchors.horizontalCenter: parent.horizontalCenter
//        spacing: 10
//
//        Repeater {
//            model: {
//                if (isEnglish) {
//                    isUpper ? en_line2_upper : en_line2_lower
//                } else {
//                    page == 1 ? char_page1_line2 : char_page2_line2
//                }
//            }
//
//            Rectangle {
//                width: 60; height: 60
//                radius: 5
//                color: area2.pressed ? "#2A2826" : "#383533"
//
//                Text {
//                    anchors.fill: parent
//                    font.pixelSize: pixelSize
//                    //font.family: textFontFamily
//                    verticalAlignment: Text.AlignVCenter
//                    horizontalAlignment: Text.AlignHCenter
//                    color: area2.pressed ? "#5D4B37" : "#FFFFFF"
//                    text: modelData
//                }
//
//                MouseArea {
//                    id: area2
//                    anchors.fill: parent
//                    focus: false
//                    onClicked: {
//                        var focusedItem = ClientInstance.getFocusedItem(virtualKeyboard.parent)
//                        focusedItem.text = focusedItem.text + modelData
//                    }
//                }
//            }
//        }
//    }
//
//    // 第三行
//    Row {
//        y: 220
//        anchors.horizontalCenter: parent.horizontalCenter
//        spacing: 10
//
//        // shift
//        Rectangle {
//            width: 95; height: 60
//            radius: 5
//            color: area_shift.pressed ? "#2A2826" : "#383533"
//
//            Text {
//                anchors.fill: parent
//                font.pixelSize: pixelSize
//                //font.family: textFontFamily
//                verticalAlignment: Text.AlignVCenter
//                horizontalAlignment: Text.AlignHCenter
//                color: area_shift.pressed ? "#5D4B37" : (isEnglish && isUpper ? "#239B56" : "#FFFFFF")
//                text: isEnglish ? "Shift" : (page == 1 ? "1/2" : "2/2")
//            }
//
//            MouseArea {
//                id: area_shift
//                anchors.fill: parent
//                focus: false
//                onClicked: {
//                    if (isEnglish) {
//                        isUpper = !isUpper
//                    } else {
//                        page == 1 ? (page = 2) : (page = 1)
//                    }
//                }
//            }
//        }
//
//        Repeater {
//            model: {
//                if (isEnglish) {
//                    isUpper ? en_line3_upper : en_line3_lower
//                } else {
//                    page == 1 ? char_page1_line3 : char_page2_line3
//                }
//            }
//
//            Rectangle {
//                width: 60; height: 60
//                radius: 5
//                color: area3.pressed ? "#2A2826" : "#383533"
//
//                Text {
//                    anchors.fill: parent
//                    font.pixelSize: pixelSize
//                    //font.family: textFontFamily
//                    verticalAlignment: Text.AlignVCenter
//                    horizontalAlignment: Text.AlignHCenter
//                    color: area3.pressed ? "#5D4B37" : "#FFFFFF"
//                    text: modelData
//                }
//
//                MouseArea {
//                    id: area3
//                    anchors.fill: parent
//                    focus: false
//                    onClicked: {
//                        var focusedItem = ClientInstance.getFocusedItem(virtualKeyboard.parent)
//                        focusedItem.text = focusedItem.text + modelData
//                    }
//                }
//            }
//        }
//
//        // backspace
//        Rectangle {
//            width: 95; height: 60
//            radius: 5
//            color: area_backspace.pressed ? "#2A2826" : "#383533"
//
//            Text {
//                anchors.fill: parent
//                font.pixelSize: pixelSize
//                //font.family: textFontFamily
//                verticalAlignment: Text.AlignVCenter
//                horizontalAlignment: Text.AlignHCenter
//                color: area_backspace.pressed ? "#5D4B37" : "#FFFFFF"
//                text: languageType == 1 ? "回 退" : "Backspace"
//            }
//
//            MouseArea {
//                id: area_backspace
//                anchors.fill: parent
//                focus: false
//                onClicked: {
//                    var focusedItem = ClientInstance.getFocusedItem(virtualKeyboard.parent)
//                    focusedItem.text = focusedItem.text.slice(0, -1)
//                }
//            }
//        }
//    }
//
//    // 第四行
//    Row {
//        y: 290
//        anchors.horizontalCenter: parent.horizontalCenter
//        spacing: 10
//
//        // switch
//        Rectangle {
//            width: 95; height: 60
//            radius: 5
//            color: area_switch.pressed ? "#2A2826" : "#383533"
//
//            Text {
//                anchors.fill: parent
//                font.pixelSize: pixelSize
//                //font.family: textFontFamily
//                verticalAlignment: Text.AlignVCenter
//                horizontalAlignment: Text.AlignHCenter
//                color: area_switch.pressed ? "#5D4B37" : "#FFFFFF"
//                text: isEnglish ? "&123" : "ABC"
//            }
//
//            MouseArea {
//                id: area_switch
//                anchors.fill: parent
//                focus: false
//                onClicked: isEnglish = !isEnglish
//            }
//        }
//
//        // space
//        Rectangle {
//            width: 375; height: 60
//            radius: 5
//            color: area_space.pressed ? "#2A2826" : "#383533"
//
//            Text {
//                anchors.fill: parent
//                font.pixelSize: pixelSize
//                //font.family: textFontFamily
//                verticalAlignment: Text.AlignVCenter
//                horizontalAlignment: Text.AlignHCenter
//                color: area_space.pressed ? "#5D4B37" : "#FFFFFF"
//                text: languageType == 1 ? "空 格" : "Space"
//            }
//
//            MouseArea {
//                id: area_space
//                anchors.fill: parent
//                focus: false
//                onClicked: {
//                    var focusedItem = ClientInstance.getFocusedItem(virtualKeyboard.parent)
//                    focusedItem.text += " "
//                }
//            }
//        }
//
//        // clear
//        Rectangle {
//            width: 95; height: 60
//            radius: 5
//            color: area_clear.pressed ? "#2A2826" : "#383533"
//
//            Text {
//                anchors.fill: parent
//                font.pixelSize: pixelSize
//                //font.family: textFontFamily
//                verticalAlignment: Text.AlignVCenter
//                horizontalAlignment: Text.AlignHCenter
//                color: area_clear.pressed ? "#5D4B37" : "#FFFFFF"
//                text: languageType == 1 ? "清 空" : "Clear"
//            }
//
//            MouseArea {
//                id: area_clear
//                anchors.fill: parent
//                focus: false
//                onClicked: {
//                    var focusedItem = ClientInstance.getFocusedItem(virtualKeyboard.parent)
//                    focusedItem.text = ""
//                }
//            }
//        }
//
//        // hide
//        Rectangle {
//            id: hide
//            width: 95; height: 60
//            radius: 5
//            color: area_hide.pressed ? "#2A2826" : "#383533"
//
//            Text {
//                anchors.fill: parent
//                font.pixelSize: pixelSize
//                //font.family: textFontFamily
//                verticalAlignment: Text.AlignVCenter
//                horizontalAlignment: Text.AlignHCenter
//                color: area_hide.pressed ? "#5D4B37" : "#FFFFFF"
//                text: languageType == 1 ? "隐 藏" : "Hide"
//            }
//
//            MouseArea {
//                id: area_hide
//                anchors.fill: parent
//                onClicked: hide.focus = true
//            }
//        }
//    }

}
