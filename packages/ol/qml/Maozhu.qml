import QtQuick
import QtQuick.Layouts
import Fk
import LunarLtk
import LunarLtk.Components

ColumnLayout {
  id: root
  anchors.fill: parent
  signal finish()
  property string name
  property var value: ({ name: "", map: [] })
  property int playerid

  BigGlowText {
    Layout.fillWidth: true
    Layout.preferredHeight: childrenRect.height + 4

    text: Lua.tr(root.name) + ' - ' + Lua.tr(root.value.name)
  }

  PeixiuMap {
    Layout.fillWidth: true
    Layout.fillHeight: true
    mapData: root.value?.map ?? []
  }
}
