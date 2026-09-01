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
    property int popUpWidth: batteryWidget.implicitWidth //445
    property int popUpHeight: batteryWidget.implicitHeight//200

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
            AudioPopup.showPopup = false;
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
            item: batteryWidget
        }

        BatteryPopupComponent {
            id: batteryWidget
        }
    }
}
