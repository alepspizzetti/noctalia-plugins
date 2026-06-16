import QtQuick
import Quickshell
import Quickshell.Io

Item {
  id: root

  property var pluginApi: null

  IpcHandler {
    target: "plugin:whatsapp-web"

    function toggle() {
      if (!pluginApi) return;
      pluginApi.withCurrentScreen(screen => {
        pluginApi.togglePanel(screen);
      });
    }
  }
}
