import QtQuick 2.15

// 自定义虚拟键盘
Rectangle {
    id: virtualKeyboard
    //width: 710; height: 360 多两行时启用
    width: 710; height: 290 
    radius: 5
    color: "black"

    property bool isUpper: false            // 是否大写
    property bool isEnglish: true           // 是否英文
    property int page: 1                    // 字符页面
    property int pixelSize: 16              // 字体大小
    property string textFontFamily: ""      // 字体样式
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
        y: 10
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 10

        Repeater {
            model: {
                if (isEnglish) {
                    isUpper ? en_line1_upper : root.en_line0_lower
                } else {
                    page == 1 ? char_page1_line1 : char_page2_line1
                }
            }

            Rectangle {
                width: 60; height: 60
                radius: 5
                color: area1.pressed ? "#2A2826" : "#383533"

                Text {
                    id: word_sub
                    anchors.fill: parent
                    font.pixelSize: pixelSize
                    font.family: textFontFamily
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    color: area1.pressed ? "#5D4B37" : "#FFFFFF"
                    text: modelData
                }

                MouseArea {
                    id: area1
                    anchors.fill: parent
                    focus: false
                    onClicked: {
                        //var focusedItem = ClientInstance.getFocusedItem(virtualKeyboard.parent)
                        //focusedItem.text = focusedItem.text + modelData
                        input1.text = input1.text + modelData
                        word_sub.text = ""
                    }
                }
            }
        }
    }

    // 第一行
    Row {
        y: 80
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 10

        Repeater {
            model: {
                if (isEnglish) {
                    isUpper ? en_line1_upper : en_line1_lower
                } else {
                    page == 1 ? char_page1_line1 : char_page2_line1
                }
            }

            Rectangle {
                width: 60; height: 60
                radius: 5
                color: area1.pressed ? "#2A2826" : "#383533"

                Text {
                    anchors.fill: parent
                    font.pixelSize: pixelSize
                    font.family: textFontFamily
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    color: area1.pressed ? "#5D4B37" : "#FFFFFF"
                    text: modelData
                }

                MouseArea {
                    id: area1
                    anchors.fill: parent
                    focus: false
                    onClicked: {
                        //var focusedItem = ClientInstance.getFocusedItem(virtualKeyboard.parent)
                        //focusedItem.text = focusedItem.text + modelData
                        input1.text = input1.text + modelData
                        
                    }
                }
            }
        }
    }

    // 第二行
    Row {
        y: 150
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 10

        Repeater {
            model: {
                if (isEnglish) {
                    isUpper ? en_line2_upper : en_line2_lower
                } else {
                    page == 1 ? char_page1_line2 : char_page2_line2
                }
            }

            Rectangle {
                width: 60; height: 60
                radius: 5
                color: area2.pressed ? "#2A2826" : "#383533"

                Text {
                    anchors.fill: parent
                    font.pixelSize: pixelSize
                    font.family: textFontFamily
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    color: area2.pressed ? "#5D4B37" : "#FFFFFF"
                    text: modelData
                }

                MouseArea {
                    id: area2
                    anchors.fill: parent
                    focus: false
                    onClicked: {
                        //var focusedItem = ClientInstance.getFocusedItem(virtualKeyboard.parent)
                        //focusedItem.text = focusedItem.text + modelData
                        input1.text = input1.text + modelData
                    }
                }
            }
        }
    }

    // 第三行
    Row {
        y: 220
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 10

        // shift
        Rectangle {
            width: 95; height: 60
            radius: 5
            color: area_shift.pressed ? "#2A2826" : "#383533"

            Text {
                anchors.fill: parent
                font.pixelSize: pixelSize
                font.family: textFontFamily
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                color: area_shift.pressed ? "#5D4B37" : (isEnglish && isUpper ? "#239B56" : "#FFFFFF")
                text: isEnglish ? "Shift" : (page == 1 ? "1/2" : "2/2")
            }

            MouseArea {
                id: area_shift
                anchors.fill: parent
                focus: false
                onClicked: {
                    if (isEnglish) {
                        isUpper = !isUpper
                    } else {
                        page == 1 ? (page = 2) : (page = 1)
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
                width: 60; height: 60
                radius: 5
                color: area3.pressed ? "#2A2826" : "#383533"

                Text {
                    anchors.fill: parent
                    font.pixelSize: pixelSize
                    font.family: textFontFamily
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    color: area3.pressed ? "#5D4B37" : "#FFFFFF"
                    text: modelData
                }

                MouseArea {
                    id: area3
                    anchors.fill: parent
                    focus: false
                    onClicked: {
                        //var focusedItem = ClientInstance.getFocusedItem(virtualKeyboard.parent)
                        //focusedItem.text = focusedItem.text + modelData
                        input1.text = input1.text + modelData
                        
                    }
                }
            }
        }

        // backspace
        Rectangle {
            width: 95; height: 60
            radius: 5
            color: area_backspace.pressed ? "#2A2826" : "#383533"

            Text {
                anchors.fill: parent
                font.pixelSize: pixelSize
                font.family: textFontFamily
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                color: area_backspace.pressed ? "#5D4B37" : "#FFFFFF"
                text: languageType == 1 ? "回 退" : "Backspace"
            }

            MouseArea {
                id: area_backspace
                anchors.fill: parent
                focus: false
                onClicked: {
                    //var focusedItem = ClientInstance.getFocusedItem(virtualKeyboard.parent)
                    //focusedItem.text = focusedItem.text.slice(0, -1)
                    input1.text = input1.text.slice(0, -1)
                
                }
            }
        }
    }

    // 第四行
    Row {
        y: 290
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 10

        // switch
        Rectangle {
            width: 95; height: 60
            radius: 5
            color: area_switch.pressed ? "#2A2826" : "#383533"

            Text {
                anchors.fill: parent
                font.pixelSize: pixelSize
                font.family: textFontFamily
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                color: area_switch.pressed ? "#5D4B37" : "#FFFFFF"
                text: isEnglish ? "&123" : "ABC"
            }

            MouseArea {
                id: area_switch
                anchors.fill: parent
                focus: false
                onClicked: isEnglish = !isEnglish
            }
        }

        // space
        Rectangle {
            width: 375; height: 60
            radius: 5
            color: area_space.pressed ? "#2A2826" : "#383533"

            Text {
                anchors.fill: parent
                font.pixelSize: pixelSize
                font.family: textFontFamily
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                color: area_space.pressed ? "#5D4B37" : "#FFFFFF"
                text: languageType == 1 ? "空 格" : "Space"
            }

            MouseArea {
                id: area_space
                anchors.fill: parent
                focus: false
                onClicked: {
                    //var focusedItem = ClientInstance.getFocusedItem(virtualKeyboard.parent)
                    //focusedItem.text += " "
                    input1.text += " "
            
                }
            }
        }

        // clear
        Rectangle {
            width: 95; height: 60
            radius: 5
            color: area_clear.pressed ? "#2A2826" : "#383533"

            Text {
                anchors.fill: parent
                font.pixelSize: pixelSize
                font.family: textFontFamily
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                color: area_clear.pressed ? "#5D4B37" : "#FFFFFF"
                text: languageType == 1 ? "清 空" : "Clear"
            }

            MouseArea {
                id: area_clear
                anchors.fill: parent
                focus: false
                onClicked: {
                    //var focusedItem = ClientInstance.getFocusedItem(virtualKeyboard.parent)
                    //focusedItem.text = ""
                    input1.text = ""
                    
                }
            }
        }

        // hide
        Rectangle {
            id: hide
            width: 95; height: 60
            radius: 5
            color: area_hide.pressed ? "#2A2826" : "#383533"

            Text {
                anchors.fill: parent
                font.pixelSize: pixelSize
                font.family: textFontFamily
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                color: area_hide.pressed ? "#5D4B37" : "#FFFFFF"
                text: languageType == 1 ? "隐 藏" : "Hide"
            }

            MouseArea {
                id: area_hide
                anchors.fill: parent
                onClicked: hide.focus = true
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
//                    font.family: textFontFamily
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
//                    font.family: textFontFamily
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
//                font.family: textFontFamily
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
//                    font.family: textFontFamily
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
//                font.family: textFontFamily
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
//                font.family: textFontFamily
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
//                font.family: textFontFamily
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
//                font.family: textFontFamily
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
//                font.family: textFontFamily
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
