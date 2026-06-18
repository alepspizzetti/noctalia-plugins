import QtQuick
import Quickshell
import Quickshell.Io

Item {
  id: root

  property var pluginApi: null

  Component.onCompleted: root.runBackend(["sync-hotkeys"])

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
      root.localPath("./backend/execute.py"),
      "--settings",
      root.localPath("./settings.json")
    ];
  }

  function runBackend(args) {
    Quickshell.execDetached(root.executorBaseCommand().concat(args));
  }

  IpcHandler {
    target: "plugin:bindhub"

    function toggle() {
      if (!pluginApi) return;
      pluginApi.withCurrentScreen(screen => {
        pluginApi.togglePanel(screen);
      });
    }

    function runHotkey(hotkeyId: string) {
      if (!hotkeyId) return;
      root.runBackend(["run-hotkey", hotkeyId]);
    }

    function runMacro(macroId: string) {
      if (!macroId) return;
      root.runBackend(["run-macro", macroId]);
    }

    function typeText(text: string) {
      if (!text) return;
      root.runBackend(["type-text", text]);
    }

    function syncHotkeys() {
      root.runBackend(["sync-hotkeys"]);
    }
  }
}
