import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Widgets

Item {
  id: root

  property var pluginApi: null
  property ShellScreen screen
  readonly property var geometryPlaceholder: panelContainer
  readonly property bool allowAttach: true

  property var cfg: pluginApi?.pluginSettings || ({})
  property var defaults: pluginApi?.manifest?.metadata?.defaultSettings || ({})

  readonly property var hotkeys: cfg.hotkeys ?? defaults.hotkeys ?? []
  readonly property var macros: cfg.macros ?? defaults.macros ?? []

  function typeLabel(type) {
    switch (type) {
    case "runCommand":
      return pluginApi?.tr("common.action.runCommand");
    case "openUrl":
      return pluginApi?.tr("common.action.openUrl");
    case "notify":
      return pluginApi?.tr("common.action.notify");
    case "typeText":
      return pluginApi?.tr("common.action.typeText");
    case "delay":
      return pluginApi?.tr("common.action.delay");
    default:
      return type || pluginApi?.tr("common.unknown");
    }
  }

  anchors.fill: parent

  Rectangle {
    id: panelContainer
    width: 900 * Style.uiScaleRatio
    height: 640 * Style.uiScaleRatio
    color: "transparent"
    anchors.centerIn: parent

    ColumnLayout {
      anchors.fill: parent
      anchors.margins: Style.marginM
      spacing: Style.marginS

      NBox {
        Layout.fillWidth: true
        Layout.fillHeight: true

        ColumnLayout {
          anchors.fill: parent
          anchors.margins: Style.marginM
          spacing: Style.marginM

          RowLayout {
            Layout.fillWidth: true

            NIcon {
              icon: "keyboard"
              color: Color.resolveColorKey("primary")
            }

            NText {
              text: pluginApi?.tr("panel.title")
              pointSize: Style.fontSizeM
              font.weight: Font.Bold
              color: Color.mOnSurface
            }

            Item {
              Layout.fillWidth: true
            }

            NText {
              text: pluginApi?.tr("panel.badge")
              color: Color.resolveColorKey("warning")
              font.weight: Font.Medium
            }
          }

          NText {
            Layout.fillWidth: true
            text: pluginApi?.tr("panel.description")
            color: Color.mOnSurfaceVariant
            wrapMode: Text.WordWrap
          }

          GridLayout {
            Layout.fillWidth: true
            columns: 2
            columnSpacing: Style.marginM
            rowSpacing: Style.marginS

            NBox {
              Layout.fillWidth: true

              ColumnLayout {
                anchors.fill: parent
                anchors.margins: Style.marginM
                spacing: Style.marginXS

                NText {
                  text: pluginApi?.tr("panel.cards.hotkeys.title")
                  font.weight: Font.Medium
                  color: Color.mOnSurface
                }

                NText {
                  text: pluginApi?.tr("panel.cards.hotkeys.description", {
                                        count: root.hotkeys.length
                                      })
                  color: Color.mOnSurfaceVariant
                  wrapMode: Text.WordWrap
                }
              }
            }

            NBox {
              Layout.fillWidth: true

              ColumnLayout {
                anchors.fill: parent
                anchors.margins: Style.marginM
                spacing: Style.marginXS

                NText {
                  text: pluginApi?.tr("panel.cards.macros.title")
                  font.weight: Font.Medium
                  color: Color.mOnSurface
                }

                NText {
                  text: pluginApi?.tr("panel.cards.macros.description", {
                                        count: root.macros.length
                                      })
                  color: Color.mOnSurfaceVariant
                  wrapMode: Text.WordWrap
                }
              }
            }

            NBox {
              Layout.fillWidth: true

              ColumnLayout {
                anchors.fill: parent
                anchors.margins: Style.marginM
                spacing: Style.marginXS

                NText {
                  text: pluginApi?.tr("panel.cards.niri.title")
                  font.weight: Font.Medium
                  color: Color.mOnSurface
                }

                NText {
                  text: pluginApi?.tr("panel.cards.niri.description")
                  color: Color.mOnSurfaceVariant
                  wrapMode: Text.WordWrap
                }
              }
            }
          }

          GridLayout {
            Layout.fillWidth: true
            columns: 2
            columnSpacing: Style.marginM
            rowSpacing: Style.marginS

            NBox {
              Layout.fillWidth: true

              ColumnLayout {
                anchors.fill: parent
                anchors.margins: Style.marginM
                spacing: Style.marginS

                NText {
                  text: pluginApi?.tr("panel.preview.hotkeys")
                  font.weight: Font.Medium
                  color: Color.mOnSurface
                }

                NText {
                  visible: root.hotkeys.length === 0
                  text: pluginApi?.tr("panel.empty.hotkeys")
                  color: Color.mOnSurfaceVariant
                  wrapMode: Text.WordWrap
                }

                Repeater {
                  model: Math.min(root.hotkeys.length, 3)

                  delegate: ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    readonly property var hotkey: root.hotkeys[index]

                    NText {
                      Layout.fillWidth: true
                      text: (hotkey.name || pluginApi?.tr("panel.unnamed.hotkey")) + " - " + (hotkey.trigger || pluginApi?.tr("panel.unset.trigger"))
                      color: Color.mOnSurface
                      elide: Text.ElideRight
                    }

                    NText {
                      Layout.fillWidth: true
                      text: hotkey.mode === "macro"
                        ? pluginApi?.tr("panel.hotkey.macroTarget", {
                            macro: hotkey.macroId || pluginApi?.tr("panel.unset.macro")
                          })
                        : pluginApi?.tr("panel.hotkey.actionTarget", {
                            action: root.typeLabel(hotkey.actionType),
                            target: hotkey.payload || pluginApi?.tr("panel.unset.payload")
                          })
                      color: Color.mOnSurfaceVariant
                      elide: Text.ElideRight
                    }
                  }
                }
              }
            }

            NBox {
              Layout.fillWidth: true

              ColumnLayout {
                anchors.fill: parent
                anchors.margins: Style.marginM
                spacing: Style.marginS

                NText {
                  text: pluginApi?.tr("panel.preview.macros")
                  font.weight: Font.Medium
                  color: Color.mOnSurface
                }

                NText {
                  visible: root.macros.length === 0
                  text: pluginApi?.tr("panel.empty.macros")
                  color: Color.mOnSurfaceVariant
                  wrapMode: Text.WordWrap
                }

                Repeater {
                  model: Math.min(root.macros.length, 2)

                  delegate: ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    readonly property var macro: root.macros[index]
                    readonly property var firstAction: (macro.actions && macro.actions.length > 0) ? macro.actions[0] : null

                    NText {
                      Layout.fillWidth: true
                      text: (macro.name || pluginApi?.tr("panel.unnamed.macro")) + " - " + pluginApi?.tr("panel.macro.stepCount", { count: macro.actions ? macro.actions.length : 0 })
                      color: Color.mOnSurface
                      elide: Text.ElideRight
                    }

                    NText {
                      Layout.fillWidth: true
                      text: firstAction
                        ? pluginApi?.tr("panel.macro.firstAction", {
                            action: root.typeLabel(firstAction.type),
                            target: firstAction.value || pluginApi?.tr("panel.unset.payload")
                          })
                        : pluginApi?.tr("panel.macro.noActions")
                      color: Color.mOnSurfaceVariant
                      elide: Text.ElideRight
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
