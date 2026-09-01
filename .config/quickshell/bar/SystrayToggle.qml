pragma Singleton

import QtQuick
import QtQuick.Layouts

Item {
    id: trayMaster
    implicitHeight: parent.height
    implicitWidth: trayOpen ? 320 : trayButton.width

    property bool trayOpen: true

    function toggleTray() {
        if (trayOpen) {trayOpen = false} else {trayOpen = true}
        isActive = trayOpen
    }

    Behavior on implicitWidth {
        PropertyAnimation {
            duration: 500
            easing.type: Easing.OutExpo
        }
    }

    // Encapsulate the tray options
    Row {
        spacing: 5
        anchors.fill: parent
        Text {
            id: trayButton
            anchors.verticalCenter: parent.verticalCenter
            text: trayOpen ? "" : ""
            color: inactiveColour
            font.pointSize: 15

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onEntered: parent.color = foregroundColour
                onExited: parent.color = inactiveColour
                onPressed: toggleTray()
            }
        }

        // The actuall tray
        SysTray {
            bar: root_bar
            visible: true
            Layout.fillWidth: false
            Layout.fillHeight: true
        }
    }
}

//:TODO
