import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Widgets

ColumnLayout {
  id: root

  property var pluginApi: null
  property var cfg: pluginApi?.pluginSettings || ({})
  property var defaults: pluginApi?.manifest?.metadata?.defaultSettings || ({})

  property string valueIconColor: cfg.iconColor ?? defaults.iconColor ?? "success"
  property string valuePanelPosition: cfg.panelPosition ?? defaults.panelPosition ?? "top"
  property int valuePanelWidth: cfg.panelWidth ?? defaults.panelWidth ?? 980
  property int valuePanelHeightPercent: Math.round((cfg.panelHeightRatio ?? defaults.panelHeightRatio ?? 0.84) * 100)
  property int valueZoomPercent: cfg.zoomPercent ?? defaults.zoomPercent ?? 100

  spacing: Style.marginL

  NComboBox {
    Layout.fillWidth: true
    label: pluginApi?.tr("settings.iconColor.label")
    description: pluginApi?.tr("settings.iconColor.description")
    model: Color.colorKeyModel
    currentKey: root.valueIconColor
    onSelected: key => root.valueIconColor = key
  }

  NComboBox {
    Layout.fillWidth: true
    label: pluginApi?.tr("settings.panelPosition.label")
    description: pluginApi?.tr("settings.panelPosition.description")
    model: [
      { key: "top", name: pluginApi?.tr("settings.positions.top") },
      { key: "bottom", name: pluginApi?.tr("settings.positions.bottom") },
      { key: "left", name: pluginApi?.tr("settings.positions.left") },
      { key: "right", name: pluginApi?.tr("settings.positions.right") },
      { key: "center", name: pluginApi?.tr("settings.positions.center") }
    ]
    currentKey: root.valuePanelPosition
    onSelected: key => root.valuePanelPosition = key
  }

  NSpinBox {
    Layout.fillWidth: true
    label: pluginApi?.tr("settings.panelWidth.label")
    from: 480
    to: 1800
    stepSize: 20
    value: root.valuePanelWidth
    onValueChanged: root.valuePanelWidth = value
  }

  NSpinBox {
    Layout.fillWidth: true
    label: pluginApi?.tr("settings.panelHeight.label")
    description: pluginApi?.tr("settings.panelHeight.description", { value: root.valuePanelHeightPercent })
    from: 40
    to: 100
    stepSize: 1
    value: root.valuePanelHeightPercent
    onValueChanged: root.valuePanelHeightPercent = value
  }

  NSpinBox {
    Layout.fillWidth: true
    label: pluginApi?.tr("settings.zoom.label")
    description: pluginApi?.tr("settings.zoom.description", { value: root.valueZoomPercent })
    from: 50
    to: 200
    stepSize: 5
    value: root.valueZoomPercent
    onValueChanged: root.valueZoomPercent = value
  }

  function saveSettings() {
    if (!pluginApi) return;
    pluginApi.pluginSettings.iconColor = root.valueIconColor;
    pluginApi.pluginSettings.panelPosition = root.valuePanelPosition;
    pluginApi.pluginSettings.panelWidth = root.valuePanelWidth;
    pluginApi.pluginSettings.panelHeightRatio = root.valuePanelHeightPercent / 100;
    pluginApi.pluginSettings.zoomPercent = root.valueZoomPercent;
    pluginApi.saveSettings();
  }
}
