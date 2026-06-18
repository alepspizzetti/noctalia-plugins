import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.Commons
import qs.Widgets

ColumnLayout {
  id: root

  property string label: ""
  property string description: ""
  property alias text: input.text
  property alias placeholderText: input.placeholderText
  property alias wrapMode: input.wrapMode

  signal valueChanged(string value)
  signal editingFinished

  spacing: Style.marginS

  NLabel {
    label: root.label
    description: root.description
    visible: root.label !== "" || root.description !== ""
    Layout.fillWidth: true
  }

  Control {
    Layout.fillWidth: true
    Layout.minimumHeight: Math.round(140 * Style.uiScaleRatio)

    background: Rectangle {
      radius: Style.iRadiusM
      color: Color.mSurface
      border.color: input.activeFocus ? Color.mSecondary : Color.mOutline
      border.width: Style.borderS

      Behavior on border.color {
        ColorAnimation {
          duration: Style.animationFast
        }
      }
    }

    contentItem: TextArea {
      id: input

      color: Color.mOnSurface
      placeholderTextColor: Qt.alpha(Color.mOnSurfaceVariant, 0.6)
      wrapMode: TextEdit.Wrap
      selectByMouse: true
      persistentSelection: true
      background: null
      leftPadding: Style.marginM
      rightPadding: Style.marginM
      topPadding: Style.marginM
      bottomPadding: Style.marginM
      font.pointSize: Style.fontSizeS * Style.uiScaleRatio

      onTextChanged: root.valueChanged(text)
      onActiveFocusChanged: {
        if (!activeFocus) {
          root.editingFinished();
        }
      }

      Keys.onPressed: event => {
                        if ((event.key === Qt.Key_Return || event.key === Qt.Key_Enter) && (event.modifiers & Qt.ShiftModifier)) {
                          insert(cursorPosition, "\n");
                          event.accepted = true;
                        }
                      }
    }
  }
}
