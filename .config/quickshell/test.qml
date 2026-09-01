import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland

PanelWindow {
    WlrLayershell.namespace: "quickshell:test"
    color: 'transparent'
    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }

    // margins: 30
    MouseArea {
        anchors.fill: parent
        onClicked: () => {
            parent.visible = false;
        }
    }
}
