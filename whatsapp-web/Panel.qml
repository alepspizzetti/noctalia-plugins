import QtQuick
import QtQuick.Layouts
import QtCore
import QtWebEngine
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

  readonly property string panelPosition: cfg.panelPosition ?? defaults.panelPosition ?? "top"
  readonly property int panelWidth: cfg.panelWidth ?? defaults.panelWidth ?? 980
  readonly property real panelHeightRatio: cfg.panelHeightRatio ?? defaults.panelHeightRatio ?? 0.84
  readonly property int zoomPercent: cfg.zoomPercent ?? defaults.zoomPercent ?? 100
  readonly property real panelHeight: screen ? screen.height * panelHeightRatio : 720 * Style.uiScaleRatio
  readonly property real contentPreferredWidth: panelWidth * Style.uiScaleRatio
  readonly property real contentPreferredHeight: panelHeight

  readonly property string dataDir: StandardPaths.writableLocation(StandardPaths.AppDataLocation).toString().replace("file://", "") + "/whatsapp-web"
  readonly property string cacheDir: StandardPaths.writableLocation(StandardPaths.CacheLocation).toString().replace("file://", "") + "/whatsapp-web"

  property string statusText: pluginApi?.tr("panel.statusReady")
  property bool hasLoadError: false

  anchors.fill: parent

  function grantSitePermission(origin, feature) {
    switch (feature) {
    case WebEngineView.Notifications:
    case WebEngineView.ClipboardReadWrite:
    case WebEngineView.LocalFontsAccess:
    case WebEngineView.MediaAudioCapture:
    case WebEngineView.MediaVideoCapture:
    case WebEngineView.MediaAudioVideoCapture:
      webView.grantFeaturePermission(origin, feature, true);
      return;
    default:
      webView.grantFeaturePermission(origin, feature, false);
      return;
    }
  }

  WebEngineProfile {
    id: webProfile
    storageName: "noctalia-whatsapp-web"
    offTheRecord: false
    persistentStoragePath: root.dataDir
    cachePath: root.cacheDir
    httpCacheType: WebEngineProfile.DiskHttpCache
    persistentCookiesPolicy: WebEngineProfile.ForcePersistentCookies
    persistentPermissionsPolicy: WebEngineProfile.PersistentPermissionsPolicy.StoreOnDisk
  }

  Rectangle {
    id: panelContainer
    width: root.contentPreferredWidth
    height: root.contentPreferredHeight
    color: "transparent"

    anchors.left: root.panelPosition === "left" ? parent.left : undefined
    anchors.right: root.panelPosition === "right" ? parent.right : undefined
    anchors.top: root.panelPosition === "top" ? parent.top : undefined
    anchors.bottom: root.panelPosition === "bottom" ? parent.bottom : undefined
    anchors.horizontalCenter: root.panelPosition === "center" || root.panelPosition === "top" || root.panelPosition === "bottom" ? parent.horizontalCenter : undefined
    anchors.verticalCenter: root.panelPosition === "center" || root.panelPosition === "left" || root.panelPosition === "right" ? parent.verticalCenter : undefined

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
          spacing: Style.marginS

          RowLayout {
            Layout.fillWidth: true
            spacing: Style.marginS

            NIcon {
              icon: "message-circle"
              color: Color.resolveColorKey("success")
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

            NIconButton {
              icon: "arrow-left"
              tooltipText: pluginApi?.tr("panel.back")
              enabled: webView.canGoBack
              onClicked: webView.goBack()
            }

            NIconButton {
              icon: "arrow-right"
              tooltipText: pluginApi?.tr("panel.forward")
              enabled: webView.canGoForward
              onClicked: webView.goForward()
            }

            NIconButton {
              icon: "refresh-cw"
              tooltipText: pluginApi?.tr("panel.reload")
              onClicked: webView.reload()
            }
          }

          NText {
            Layout.fillWidth: true
            text: root.statusText
            pointSize: Style.fontSizeXS
            color: root.hasLoadError ? Color.mError : Color.mOnSurfaceVariant
            elide: Text.ElideRight
          }

          Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: Style.radiusM
            color: Color.mSurfaceVariant
            clip: true

            WebEngineView {
              id: webView
              anchors.fill: parent
              profile: webProfile
              url: "https://web.whatsapp.com/"
              zoomFactor: root.zoomPercent / 100.0

              settings.javascriptEnabled: true
              settings.localStorageEnabled: true
              settings.javascriptCanAccessClipboard: true
              settings.playbackRequiresUserGesture: false
              settings.pdfViewerEnabled: true

              onFeaturePermissionRequested: function(securityOrigin, feature) {
                root.grantSitePermission(securityOrigin, feature);
              }

              onLoadingChanged: function(loadingInfo) {
                root.hasLoadError = loadingInfo.status === WebEngineView.LoadFailedStatus;
                if (loadingInfo.status === WebEngineView.LoadStartedStatus) {
                  root.statusText = pluginApi?.tr("panel.statusLoading");
                } else if (loadingInfo.status === WebEngineView.LoadSucceededStatus) {
                  root.statusText = title && title.length > 0 ? title : pluginApi?.tr("panel.statusReady");
                } else if (loadingInfo.status === WebEngineView.LoadFailedStatus) {
                  root.statusText = pluginApi?.tr("panel.statusLoadFailed");
                }
              }

              onRenderProcessTerminated: function() {
                root.hasLoadError = true;
                root.statusText = pluginApi?.tr("panel.statusCrashed");
              }

              onNewWindowRequested: function(request) {
                webView.acceptAsNewWindow(request);
              }
            }

            Rectangle {
              anchors.fill: parent
              color: Qt.rgba(Color.mSurface.r, Color.mSurface.g, Color.mSurface.b, 0.6)
              visible: webView.loading

              ColumnLayout {
                anchors.centerIn: parent
                spacing: Style.marginS

                NIcon {
                  id: loadingIcon
                  icon: "loader-circle"
                  color: Color.mOnSurface
                  Layout.alignment: Qt.AlignHCenter

                  RotationAnimation on rotation {
                    running: webView.loading
                    loops: Animation.Infinite
                    from: 0
                    to: 360
                    duration: 1200
                  }
                }

                NText {
                  text: pluginApi?.tr("panel.loading")
                  color: Color.mOnSurface
                  pointSize: Style.fontSizeS
                }
              }
            }
          }
        }
      }
    }
  }
}
