// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Fk
import LunarLtk.Pages.Popups
import LunarLtk
import LunarLtk.Components
import Fk.Components.Common

import "models"

GraphicsBox {
  id: root

  required property ChooseSkillModel dataModel

  title.text: dataModel.promptText
  width: Math.max(40 + Math.min(5, dataModel.skillEntries.length) * (88 + (dataModel.generals ? 36 : 0)), 248)
  height: Math.max(60 + Math.min(32, dataModel.skillEntries.length) * 11, 230)

  Flickable {
    ScrollBar.vertical: ScrollBar {}
    flickableDirection: Flickable.VerticalFlick
    anchors.fill: parent
    anchors.topMargin: 40
    anchors.leftMargin: 20
    anchors.rightMargin: 20
    anchors.bottomMargin: 50
    contentWidth: skillsList.width
    contentHeight: skillsList.height
    clip: true

    GridLayout {
      id: skillsList
      Layout.alignment: Qt.AlignHCenter
      columns: 5

      Repeater {
        model: root.dataModel.skillEntries

        RowLayout {
          required property var modelData

          Avatar {
            id: avatarPic
            visible: modelData._general !== ""
            Layout.preferredHeight: 36
            Layout.preferredWidth: 36
            general: modelData._general
          }

          SkillButton {
            id: skillBtn
            enabled: true
            dataModel: Ltk.createSkillModel(modelData.name, { isActive: true, enabled: true })
            Connections {
              target: skillBtn.dataModel
              function onSelectedChanged() {
                root.dataModel.toggleSkill(modelData.name, skillBtn.dataModel.selected);
                root.updateSelectable();
              }
            }
          }
        }
      }
    }
  }

  Row {
    spacing: 8
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.bottom: parent.bottom
    anchors.bottomMargin: 10

    MetroButton {
      id: buttonConfirm
      Layout.alignment: Qt.AlignHCenter
      text: Lua.tr("OK")
      width: 80
      height: 35
      enabled: root.dataModel.feasible

      onClicked: {
        root.dataModel.accepted();
      }
    }

    MetroButton {
      id: detailBtn
      Layout.alignment: Qt.AlignHCenter
      width: 80
      height: 35
      text: Lua.tr("Show General Detail")
      onClicked: {
        let _skills = [];
        if (root.dataModel.result.length > 0) {
          _skills = root.dataModel.result;
        } else {
          for (let i = 0; i < root.dataModel.skillEntries.length; i++) {
            _skills.push(root.dataModel.skillEntries[i].name);
          }
        }
        root.parent.showInfoPopup(Qt.createComponent(Cpp.path + "/packages/utility/qml/SkillDetail.qml"), {
          skills: _skills
        });
      }
    }

    MetroButton {
      id: buttonCancel
      Layout.alignment: Qt.AlignHCenter
      width: 80
      height: 35
      text: Lua.tr("Cancel")
      visible: root.dataModel.cancelable

      onClicked: {
        root.dataModel.rejected();
      }
    }
  }

  function updateSelectable() {
    buttonConfirm.enabled = dataModel.feasible;
  }
}
