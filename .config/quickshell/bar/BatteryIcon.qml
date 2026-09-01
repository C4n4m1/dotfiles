pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.assets
import qs.services

Item {
    id: root
    anchors.verticalCenter: parent.verticalCenter

    WrapperMouseArea {
        visible: true
        hoverEnabled: true
        anchors.verticalCenter: parent.verticalCenter
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            BarPopupManager.toggleBatteryPopup();
        }
        child: RowLayout {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 0

            ClippingWrapperRectangle {
                id: batteryIcon
                z: 1
                // anchors.verticalCenter: parent.verticalCenter
                radius: 4
                color: Battery.isCharging ? Style.greenDesaturated : Battery.percentageValue > 20 ? Style.textMutedDesaturated : Style.orangeDesaturated
                implicitHeight: 15
                implicitWidth: 30
                // border.width: 1
                // border.color: "transparent"

                Rectangle {
                    // Or Rectangle with transparent color
                    color: "transparent"
                    anchors.fill: parent

                    Rectangle {
                        id: batteryLv
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        height: parent.height
                        width: parent.width * Battery.percentageValue / 100
                        color: Battery.isCharging ? Style.green : Battery.percentageValue > 20 ? Style.textMuted : Style.orange
                    }
                }
            }

            WrapperRectangle {
                z: 0
                anchors.verticalCenter: parent.verticalCenter
                color: "transparent"
                margin: 1.5
                radius: 0

                Rectangle {
                    z: 0
                    anchors.verticalCenter: parent.verticalCenter
                    radius: 5
                    color: Battery.percentageValue != 100 ? batteryIcon.color : batteryLv.color
                    implicitHeight: 6
                    implicitWidth: 2
                    Layout.leftMargin: -2
                }
            }

            Text {
                z: 1
                text: Battery.percentageValue
                font.family: "Geist ExtraBold"
                font.pixelSize: Style.fontSize - 1
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                anchors.verticalCenter: parent.verticalCenter
                anchors.centerIn: batteryIcon
            }
        }
    }
}
