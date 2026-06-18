import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Widgets
import "./components"

ColumnLayout {
  id: root

  property var pluginApi: null
  property var cfg: pluginApi?.pluginSettings || ({})
  property var defaults: pluginApi?.manifest?.metadata?.defaultSettings || ({})
  property real preferredWidth: 980 * Style.uiScaleRatio

  property string valueIconColor: cfg.iconColor ?? defaults.iconColor ?? "primary"
  property var valueHotkeys: []
  property var valueMacros: []
  property var expandedHotkeys: ({})
  property var expandedMacros: ({})

  width: parent ? parent.width : preferredWidth
  implicitWidth: preferredWidth
  implicitHeight: contentColumn.implicitHeight
  spacing: 0

  Component.onCompleted: resetEditorState()

  function localPath(relativePath) {
    var url = Qt.resolvedUrl(relativePath).toString();
    if (url.startsWith("file://")) {
      return url.slice(7);
    }
    return url;
  }

  function executorBaseCommand() {
    return [
      "python3",
      root.localPath("../backend/execute.py"),
      "--settings",
      root.localPath("../settings.json")
    ];
  }

  function runBackend(args) {
    Quickshell.execDetached(root.executorBaseCommand().concat(args));
  }

  component BindSectionCard: Rectangle {
    id: cardRoot
    Layout.fillWidth: true
    implicitHeight: cardContent.implicitHeight + (Style.marginL * 2)
    radius: Style.iRadiusL
    color: Qt.alpha(Color.mSurfaceVariant, 0.9)

    default property alias contentData: cardContent.data
    property alias spacing: cardContent.spacing

    ColumnLayout {
      id: cardContent
      anchors.fill: parent
      anchors.margins: Style.marginL
      spacing: Style.marginM
    }
  }

  ColumnLayout {
    id: contentColumn
    width: parent ? parent.width : root.preferredWidth
    spacing: Style.marginM

    NText {
      Layout.fillWidth: true
      text: pluginApi?.tr("settings.summary")
      color: Color.mOnSurfaceVariant
      wrapMode: Text.WordWrap
    }

    NColorChoice {
      Layout.fillWidth: true
      label: pluginApi?.tr("settings.iconColor.label")
      description: pluginApi?.tr("settings.iconColor.description")
      currentKey: root.valueIconColor
      onSelected: key => root.valueIconColor = key
    }

    ColumnLayout {
      Layout.fillWidth: true
      spacing: Style.marginS

      RowLayout {
        Layout.fillWidth: true

        NText {
          text: pluginApi?.tr("settings.hotkeys.title")
          pointSize: Style.fontSizeM
          font.weight: Font.Medium
          color: Color.mOnSurface
        }

        Item {
          Layout.fillWidth: true
        }

        NButton {
          text: pluginApi?.tr("settings.hotkeys.add")
          icon: "plus"
          onClicked: root.addHotkey()
        }
      }

      NText {
        Layout.fillWidth: true
        visible: root.valueHotkeys.length === 0
        text: pluginApi?.tr("settings.hotkeys.empty")
        color: Color.mOnSurfaceVariant
        wrapMode: Text.WordWrap
      }

      Repeater {
        model: root.valueHotkeys

        delegate: NCollapsible {
          Layout.fillWidth: true
          contentSpacing: Style.marginM

          readonly property int itemIndex: index
          readonly property var hotkey: modelData

          label: root.hotkeyDisplayName(hotkey, itemIndex)
          description: root.hotkeySummary(hotkey)
          expanded: root.isHotkeyExpanded(hotkey.id)
          onToggled: expanded => root.setHotkeyExpanded(hotkey.id, expanded)

          BindSectionCard {
            GridLayout {
              Layout.fillWidth: true
              columns: 2
              columnSpacing: Style.marginM
              rowSpacing: Style.marginM

              NTextInput {
                Layout.fillWidth: true
                label: pluginApi?.tr("settings.hotkeys.name.label")
                description: pluginApi?.tr("settings.hotkeys.name.description")
                text: hotkey.name
                onTextChanged: root.setHotkeyName(itemIndex, text)
              }

              NKeybindRecorder {
                Layout.fillWidth: true
                label: pluginApi?.tr("settings.hotkeys.trigger.label")
                description: pluginApi?.tr("settings.hotkeys.trigger.description")
                currentKeybinds: hotkey.trigger ? [hotkey.trigger] : []
                maxKeybinds: 1
                allowEmpty: true
                onKeybindsChanged: root.updateHotkey(itemIndex, {
                                                      "trigger": newKeybinds.length > 0 ? newKeybinds[0] : ""
                                                    })
              }

              NComboBox {
                Layout.fillWidth: true
                label: pluginApi?.tr("settings.hotkeys.mode.label")
                description: pluginApi?.tr("settings.hotkeys.mode.description")
                model: [
                  { key: "action", name: pluginApi?.tr("settings.hotkeys.mode.action") },
                  { key: "macro", name: pluginApi?.tr("settings.hotkeys.mode.macro") }
                ]
                currentKey: hotkey.mode
                onSelected: key => root.updateHotkey(itemIndex, { "mode": key })
              }

              NToggle {
                Layout.fillWidth: true
                label: pluginApi?.tr("settings.hotkeys.enabled.label")
                description: pluginApi?.tr("settings.hotkeys.enabled.description")
                checked: hotkey.enabled
                onToggled: checked => root.updateHotkey(itemIndex, { "enabled": checked })
              }
            }

            NComboBox {
              Layout.fillWidth: true
              visible: hotkey.mode === "action"
              label: pluginApi?.tr("settings.hotkeys.actionType.label")
              description: pluginApi?.tr("settings.hotkeys.actionType.description")
              model: [
                { key: "runCommand", name: pluginApi?.tr("common.action.runCommand") },
                { key: "openUrl", name: pluginApi?.tr("common.action.openUrl") },
                { key: "notify", name: pluginApi?.tr("common.action.notify") },
                { key: "typeText", name: pluginApi?.tr("common.action.typeText") }
              ]
              currentKey: hotkey.actionType
              onSelected: key => root.updateHotkey(itemIndex, { "actionType": key })
            }

            NTextInput {
              Layout.fillWidth: true
              visible: hotkey.mode === "action"
              label: pluginApi?.tr("settings.hotkeys.payload.label")
              description: pluginApi?.tr("settings.hotkeys.payload.description")
              text: hotkey.payload
              onTextChanged: root.setHotkeyPayload(itemIndex, text)
            }

            NComboBox {
              Layout.fillWidth: true
              visible: hotkey.mode === "macro"
              label: pluginApi?.tr("settings.hotkeys.macro.label")
              description: pluginApi?.tr("settings.hotkeys.macro.description")
              model: root.macroModel()
              currentKey: hotkey.macroId
              onSelected: key => root.updateHotkey(itemIndex, { "macroId": key })
            }

            RowLayout {
              Layout.fillWidth: true
              spacing: Style.marginM

              NButton {
                text: pluginApi?.tr("settings.hotkeys.test")
                icon: "player-play"
                outlined: true
                onClicked: root.testHotkey(hotkey.id)
              }

              NButton {
                text: pluginApi?.tr("settings.hotkeys.save")
                icon: "check"
                onClicked: root.saveAndCollapseHotkey(hotkey.id)
              }

              NButton {
                text: pluginApi?.tr("common.remove")
                icon: "trash"
                outlined: true
                onClicked: root.removeHotkey(itemIndex)
              }

              Item {
                Layout.fillWidth: true
              }
            }
          }
        }
      }
    }

    ColumnLayout {
      Layout.fillWidth: true
      spacing: Style.marginS

      RowLayout {
        Layout.fillWidth: true

        NText {
          text: pluginApi?.tr("settings.macros.title")
          pointSize: Style.fontSizeM
          font.weight: Font.Medium
          color: Color.mOnSurface
        }

        Item {
          Layout.fillWidth: true
        }

        NButton {
          text: pluginApi?.tr("settings.macros.add")
          icon: "plus"
          onClicked: root.addMacro()
        }
      }

      NText {
        Layout.fillWidth: true
        visible: root.valueMacros.length === 0
        text: pluginApi?.tr("settings.macros.empty")
        color: Color.mOnSurfaceVariant
        wrapMode: Text.WordWrap
      }

      Repeater {
        model: root.valueMacros

        delegate: NCollapsible {
          Layout.fillWidth: true
          contentSpacing: Style.marginM

          readonly property int macroIndex: index
          readonly property var macro: modelData

          label: root.macroDisplayName(macro, macroIndex)
          description: root.macroSummary(macro)
          expanded: root.isMacroExpanded(macro.id)
          onToggled: expanded => root.setMacroExpanded(macro.id, expanded)

          BindSectionCard {
            GridLayout {
              Layout.fillWidth: true
              columns: 2
              columnSpacing: Style.marginM
              rowSpacing: Style.marginM

              NTextInput {
                Layout.fillWidth: true
                label: pluginApi?.tr("settings.macros.name.label")
                description: pluginApi?.tr("settings.macros.name.description")
                text: macro.name
                onTextChanged: root.setMacroName(macroIndex, text)
              }

              NToggle {
                Layout.fillWidth: true
                label: pluginApi?.tr("settings.macros.enabled.label")
                description: pluginApi?.tr("settings.macros.enabled.description")
                checked: macro.enabled
                onToggled: checked => root.updateMacro(macroIndex, { "enabled": checked })
              }
            }

            RowLayout {
              Layout.fillWidth: true

              NText {
                text: pluginApi?.tr("settings.macros.actions.title")
                font.weight: Font.Medium
                color: Color.mOnSurface
              }

              Item {
                Layout.fillWidth: true
              }

              NButton {
                text: pluginApi?.tr("settings.macros.actions.add")
                icon: "plus"
                onClicked: root.addMacroAction(macroIndex)
              }
            }

            Repeater {
              model: macro.actions

              delegate: Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: actionCard.implicitHeight + (Style.marginM * 2)
                radius: Style.iRadiusL
                color: Qt.alpha(Color.mSurface, 0.72)
                border.color: Color.mOutline
                border.width: Style.borderS

                readonly property int actionIndex: index
                readonly property var action: modelData

                ColumnLayout {
                  id: actionCard
                  anchors.fill: parent
                  anchors.margins: Style.marginM
                  spacing: Style.marginM

                  RowLayout {
                    Layout.fillWidth: true

                    NText {
                      text: pluginApi?.tr("settings.macros.actions.itemTitle", {
                                            number: actionIndex + 1
                                          })
                      font.weight: Font.Medium
                      color: Color.mOnSurface
                    }

                    Item {
                      Layout.fillWidth: true
                    }

                    NButton {
                      text: pluginApi?.tr("common.remove")
                      icon: "trash"
                      outlined: true
                      onClicked: root.removeMacroAction(macroIndex, actionIndex)
                    }
                  }

                  GridLayout {
                    Layout.fillWidth: true
                    columns: 2
                    columnSpacing: Style.marginM
                    rowSpacing: Style.marginM

                    NComboBox {
                      Layout.fillWidth: true
                      label: pluginApi?.tr("settings.macros.actions.type.label")
                      description: pluginApi?.tr("settings.macros.actions.type.description")
                      model: [
                        { key: "runCommand", name: pluginApi?.tr("common.action.runCommand") },
                        { key: "openUrl", name: pluginApi?.tr("common.action.openUrl") },
                        { key: "notify", name: pluginApi?.tr("common.action.notify") },
                        { key: "typeText", name: pluginApi?.tr("common.action.typeText") },
                        { key: "delay", name: pluginApi?.tr("common.action.delay") }
                      ]
                      currentKey: action.type
                      onSelected: key => root.updateMacroAction(macroIndex, actionIndex, { "type": key })
                    }

                    NSpinBox {
                      Layout.fillWidth: true
                      label: pluginApi?.tr("settings.macros.actions.delay.label")
                      from: 0
                      to: 60000
                      stepSize: 50
                      value: action.delayMs
                      onValueChanged: root.updateMacroAction(macroIndex, actionIndex, { "delayMs": value })
                    }

                    BindMultilineInput {
                      Layout.fillWidth: true
                      Layout.columnSpan: 2
                      visible: action.type !== "delay"
                      label: pluginApi?.tr("settings.macros.actions.value.label")
                      description: pluginApi?.tr("settings.macros.actions.value.description")
                      text: action.value
                      onValueChanged: value => root.setMacroActionValue(macroIndex, actionIndex, value)
                    }
                  }
                }
              }
            }

            RowLayout {
              Layout.fillWidth: true
              spacing: Style.marginM

              NButton {
                text: pluginApi?.tr("settings.macros.test")
                icon: "player-play"
                outlined: true
                onClicked: root.testMacro(macro.id)
              }

              NButton {
                text: pluginApi?.tr("settings.macros.save")
                icon: "check"
                onClicked: root.saveAndCollapseMacro(macro.id)
              }

              NButton {
                text: pluginApi?.tr("common.remove")
                icon: "trash"
                outlined: true
                onClicked: root.removeMacro(macroIndex)
              }

              Item {
                Layout.fillWidth: true
              }
            }
          }
        }
      }
    }
  }

  function deepClone(value) {
    return JSON.parse(JSON.stringify(value));
  }

  function makeId(prefix) {
    return prefix + "-" + Date.now() + "-" + Math.floor(Math.random() * 100000);
  }

  function newAction() {
    return {
      "id": makeId("action"),
      "type": "runCommand",
      "value": "",
      "delayMs": 0
    };
  }

  function newMacro() {
    return {
      "id": makeId("macro"),
      "name": "",
      "enabled": true,
      "actions": [newAction()]
    };
  }

  function newHotkey() {
    return {
      "id": makeId("hotkey"),
      "name": "",
      "enabled": true,
      "trigger": "",
      "mode": "action",
      "actionType": "runCommand",
      "payload": "",
      "macroId": ""
    };
  }

  function normalizeHotkeys(list) {
    var source = Array.isArray(list) ? list : [];
    return source.map(function(item) {
      return {
        "id": item.id || makeId("hotkey"),
        "name": item.name || "",
        "enabled": item.enabled !== false,
        "trigger": item.trigger || "",
        "mode": item.mode === "macro" ? "macro" : "action",
        "actionType": item.actionType || "runCommand",
        "payload": item.payload || "",
        "macroId": item.macroId || ""
      };
    });
  }

  function normalizeMacros(list) {
    var source = Array.isArray(list) ? list : [];
    return source.map(function(item) {
      var actions = Array.isArray(item.actions) && item.actions.length > 0 ? item.actions : [newAction()];
      return {
        "id": item.id || makeId("macro"),
        "name": item.name || "",
        "enabled": item.enabled !== false,
        "actions": actions.map(function(action) {
          var parsedDelay = Number(action.delayMs);
          return {
            "id": action.id || makeId("action"),
            "type": action.type || "runCommand",
            "value": action.value || "",
            "delayMs": isFinite(parsedDelay) ? parsedDelay : 0
          };
        })
      };
    });
  }

  function resetEditorState() {
    root.valueHotkeys = normalizeHotkeys(cfg.hotkeys ?? defaults.hotkeys ?? []);
    root.valueMacros = normalizeMacros(cfg.macros ?? defaults.macros ?? []);
    root.expandedHotkeys = {};
    root.expandedMacros = {};
  }

  function updateHotkey(index, patch) {
    var next = deepClone(root.valueHotkeys);
    next[index] = Object.assign({}, next[index], patch);
    root.valueHotkeys = next;
  }

  function removeHotkey(index) {
    var next = deepClone(root.valueHotkeys);
    var hotkeyId = next[index] ? next[index].id : "";
    next.splice(index, 1);
    root.valueHotkeys = next;
    if (hotkeyId) {
      var expanded = Object.assign({}, root.expandedHotkeys);
      delete expanded[hotkeyId];
      root.expandedHotkeys = expanded;
    }
  }

  function addHotkey() {
    var next = deepClone(root.valueHotkeys);
    var hotkey = newHotkey();
    next.push(hotkey);
    root.valueHotkeys = next;
    root.setHotkeyExpanded(hotkey.id, true);
  }

  function setHotkeyName(index, value) {
    if (!root.valueHotkeys[index]) {
      return;
    }
    root.valueHotkeys[index].name = value;
  }

  function setHotkeyPayload(index, value) {
    if (!root.valueHotkeys[index]) {
      return;
    }
    root.valueHotkeys[index].payload = value;
  }

  function updateMacro(index, patch) {
    var next = deepClone(root.valueMacros);
    next[index] = Object.assign({}, next[index], patch);
    root.valueMacros = next;
  }

  function removeMacro(index) {
    var next = deepClone(root.valueMacros);
    var macroId = next[index] ? next[index].id : "";
    next.splice(index, 1);
    root.valueMacros = next;
    if (macroId) {
      var expanded = Object.assign({}, root.expandedMacros);
      delete expanded[macroId];
      root.expandedMacros = expanded;
    }
  }

  function addMacro() {
    var next = deepClone(root.valueMacros);
    var macro = newMacro();
    next.push(macro);
    root.valueMacros = next;
    root.setMacroExpanded(macro.id, true);
  }

  function setMacroName(index, value) {
    if (!root.valueMacros[index]) {
      return;
    }
    root.valueMacros[index].name = value;
  }

  function addMacroAction(macroIndex) {
    var next = deepClone(root.valueMacros);
    next[macroIndex].actions.push(newAction());
    root.valueMacros = next;
  }

  function updateMacroAction(macroIndex, actionIndex, patch) {
    var next = deepClone(root.valueMacros);
    next[macroIndex].actions[actionIndex] = Object.assign({}, next[macroIndex].actions[actionIndex], patch);
    root.valueMacros = next;
  }

  function removeMacroAction(macroIndex, actionIndex) {
    var next = deepClone(root.valueMacros);
    next[macroIndex].actions.splice(actionIndex, 1);
    if (next[macroIndex].actions.length === 0) {
      next[macroIndex].actions.push(newAction());
    }
    root.valueMacros = next;
  }

  function setMacroActionValue(macroIndex, actionIndex, value) {
    if (!root.valueMacros[macroIndex] || !root.valueMacros[macroIndex].actions[actionIndex]) {
      return;
    }
    root.valueMacros[macroIndex].actions[actionIndex].value = value;
  }

  function macroModel() {
    return root.valueMacros.map(function(macro) {
      return {
        "key": macro.id,
        "name": macro.name && macro.name.length > 0 ? macro.name : pluginApi?.tr("settings.hotkeys.macroFallback")
      };
    });
  }

  function setHotkeyExpanded(hotkeyId, expanded) {
    var next = Object.assign({}, root.expandedHotkeys);
    next[hotkeyId] = expanded;
    root.expandedHotkeys = next;
  }

  function isHotkeyExpanded(hotkeyId) {
    return root.expandedHotkeys[hotkeyId] === true;
  }

  function collapseHotkey(hotkeyId) {
    root.setHotkeyExpanded(hotkeyId, false);
  }

  function saveAndCollapseHotkey(hotkeyId) {
    root.collapseHotkey(hotkeyId);
    root.persistCurrentSettings();
  }

  function testHotkey(hotkeyId) {
    root.persistCurrentSettings();
    root.runBackend(["run-hotkey", hotkeyId]);
  }

  function hotkeyDisplayName(hotkey, hotkeyIndex) {
    if (hotkey.name && hotkey.name.length > 0) {
      return hotkey.name;
    }
    return pluginApi?.tr("settings.hotkeys.itemTitle", { number: hotkeyIndex + 1 });
  }

  function hotkeySummary(hotkey) {
    var status = hotkey.enabled ? pluginApi?.tr("settings.common.enabled") : pluginApi?.tr("settings.common.disabled");
    var trigger = hotkey.trigger && hotkey.trigger.length > 0 ? hotkey.trigger : pluginApi?.tr("settings.hotkeys.summary.unsetTrigger");
    var modeLabel = hotkey.mode === "macro" ? pluginApi?.tr("settings.hotkeys.mode.macro") : pluginApi?.tr("settings.hotkeys.mode.action");
    return pluginApi?.tr("settings.hotkeys.summary.text", {
                           "trigger": trigger,
                           "mode": modeLabel,
                           "status": status
                         });
  }

  function setMacroExpanded(macroId, expanded) {
    var next = Object.assign({}, root.expandedMacros);
    next[macroId] = expanded;
    root.expandedMacros = next;
  }

  function isMacroExpanded(macroId) {
    return root.expandedMacros[macroId] === true;
  }

  function collapseMacro(macroId) {
    root.setMacroExpanded(macroId, false);
  }

  function saveAndCollapseMacro(macroId) {
    root.collapseMacro(macroId);
    root.persistCurrentSettings();
  }

  function testMacro(macroId) {
    root.persistCurrentSettings();
    root.runBackend(["run-macro", macroId]);
  }

  function macroDisplayName(macro, macroIndex) {
    if (macro.name && macro.name.length > 0) {
      return macro.name;
    }
    return pluginApi?.tr("settings.macros.itemTitle", { number: macroIndex + 1 });
  }

  function macroSummary(macro) {
    var status = macro.enabled ? pluginApi?.tr("settings.common.enabled") : pluginApi?.tr("settings.common.disabled");
    var count = Array.isArray(macro.actions) ? macro.actions.length : 0;
    return pluginApi?.tr("settings.macros.summary", {
                           "count": count,
                           "status": status
                         });
  }

  function persistCurrentSettings() {
    if (!pluginApi) {
      return;
    }

    pluginApi.pluginSettings.iconColor = root.valueIconColor;
    pluginApi.pluginSettings.hotkeys = root.deepClone(root.valueHotkeys);
    pluginApi.pluginSettings.macros = root.deepClone(root.valueMacros);
    pluginApi.saveSettings();
    root.runBackend(["sync-hotkeys"]);
  }

  function saveSettings() {
    root.persistCurrentSettings();
  }
}
