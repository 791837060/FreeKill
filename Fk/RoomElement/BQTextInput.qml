import QtQuick 2.15

// 自定义文本输入框
Rectangle {
    width: 200; height: 40
    color: "white"

    property int rightDis: 0                        // 右侧缩进
    property int pixelSize: 16                      // 字体大小
    property string textFontFamily: ""              // 字体样式
    property string placeholderText: ""             // 提示文本
    property alias textInput: input                 // 文本输入
    property bool isPassword: false                 // 密码输入
    property string imageSource: ""                 // 图像资源
    property bool hasFocus: input.focus             // 输入框焦点

    signal imagePressed()

    TextInput {
        id: input
        x: 5
        width: parent.width - rightDis - 10
        height: parent.height
        activeFocusOnPress: true
        font.pixelSize: pixelSize
        font.family: textFontFamily
        verticalAlignment: TextInput.AlignVCenter
        echoMode: isPassword ? TextInput.Password : TextInput.Normal
        clip: true

        Text {
            x: 5
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: pixelSize
            font.family: textFontFamily
            verticalAlignment: Text.AlignVCenter
            text: placeholderText
            visible: input.text == ""
        }
    }

    Image {
        id: image
        width: rightDis; height: rightDis
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: (parent.height - rightDis) / 2
        source: imageSource
        visible: rightDis != 0

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                image.focus = true
                imagePressed()
            }
        }
    }
}
