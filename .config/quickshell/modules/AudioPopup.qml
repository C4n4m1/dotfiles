import qs.bar
import qs.assets
import qs.modules
import qs.modules.widgets
import QtQuick
import Quickshell
import QtQuick.Layouts
import Quickshell.Widgets
import Quickshell.Wayland

Scope {
    id: root
    property bool showPopup: false
    property int popUpWidth: audioWidget.implicitWidth //445
    property int popUpHeight: audioWidget.implicitHeight//200

    function toggleVisibility() {
        if (showPopup == false) {
            showPopup = true;
            closeOtherPopup.start();
        } else {
            showPopup = false;
        }
    }

    Timer {
        id: closeOtherPopup
        interval: 1
        repeat: false
        onTriggered: {
            BatteryPopup.showPopup = false;
            RessourcePopup.showPopup = false;
        }
    }

    PanelWindow {
        id: popupWindow
        color: "transparent"
        visible: showPopup
        WlrLayershell.namespace: "quickshell:barWidgets"

        anchors {
            top: true
            left: false
            right: true
            bottom: false
        }

        margins {
            top: 6
            right: 6
            left: 6
            bottom: 6
        }

        implicitHeight: root.popUpHeight
        implicitWidth: root.popUpWidth

        mask: Region {
            item: audioWidget
        }

        AudioPopupComponent {
            // use playerWidth && playerHeight if available
            id: audioWidget
            // visible: root.showPopup
            anchors.fill: parent
        }
    }
}
