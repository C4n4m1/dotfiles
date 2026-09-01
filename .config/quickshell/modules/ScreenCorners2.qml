import qs.assets
import qs.bar
import qs.services
import Quickshell
import QtQuick.Layouts
import Quickshell.Widgets
import QtQuick 2.15
import QtQuick.Window 2.15
import Quickshell.Wayland

Loader {
    active: Style.screenCorners || NiriService.inOverview
    // active: Style.screenCorners && (!ToplevelManager.activeToplevel.maximized || NiriService.inOverview)
    sourceComponent: PanelWindow {
        id: root
        visible: true
        // implicitWidth: 1920
        // implicitHeight: 1080
        // implicitHeight: 946 //1080 - Bar.root_bar.barHeight

        // Window background must be transparent so holes show wallpaper / what's behind
        color: "transparent"
        // flags: Qt.FramelessWindowHint
        anchors {
            top: true
            left: true
            right: true
            bottom: true
        }

        WlrLayershell.namespace: "quickshell:screenCorners2"
        // WlrLayershell.layer: WlrLayer.Overlay
        // exclusionMode: ExclusionMode.Ignore
        mask: Region {
            item: null
        }

        Rectangle {
            anchors.fill: parent
            clip: true
            color: (NiriService.inOverview || !NiriService.activeToplevelMaximized) ? Qt.rgba(0, 0, 0, 0.8) : Style.bgDark
            layer.enabled: true

            Rectangle {
                anchors.fill: parent
                radius: 15
                color: "transparent"
            }
        }
    }
}
