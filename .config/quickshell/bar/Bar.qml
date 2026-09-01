import qs.assets
import qs.services
import qs.modules
import qs.modules.widgets
import QtQuick
import Quickshell
import QtQuick.Layouts
import Quickshell.Widgets
import Quickshell.Wayland

Scope {
    id: bar
    property int height: root_bar.barHeight

    PanelWindow {
        id: root_bar
        property int barHeight: 35
        property int screenRounding: 18
        property bool showBarShadow: true

        implicitHeight: root_bar.barHeight
        WlrLayershell.namespace: "quickshell:bar"
        exclusiveZone: root_bar.barHeight

        anchors {
            top: true
            left: true
            right: true
        }

        color: "transparent"

        Item {
            id: barContent
            anchors {
                right: parent.right
                left: parent.left
                top: parent.top
            }
            implicitHeight: root_bar.barHeight
            height: root_bar.barHeight

            Rectangle {
                id: barBackground
                border {
                    color: Style.borderMuted
                    width: 0
                }
                color: Style.bgDark
                anchors {
                    fill: parent
                }

                RowLayout {
                    implicitHeight: parent.height
                    implicitWidth: parent.width
                    spacing: 0
                    Layout.fillWidth: true
                    anchors.fill: parent

                    RowLayout {
                        implicitHeight: parent.height
                        implicitWidth: parent.width
                        Layout.fillWidth: true

                        Layout.leftMargin: 7
                        Layout.rightMargin: 7
                        spacing: 15
                        Layout.alignment: Qt.AlignLeft

                        Workspaces {
                            bar: barBackground
                            Layout.alignment: Qt.AlignVCenter
                        }

                        Text {
                            text: (NiriService.focusedWindowTitle != "") ? ">" : ""
                            color: Style.textMuted
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter

                            font.pixelSize: Style.fontSize
                            font.family: Style.iconFontFamily
                            font.weight: Style.iconFontWeight

                            Layout.alignment: Qt.AlignLeft
                            Layout.fillHeight: true
                            Layout.preferredHeight: parent.height
                        }

                        Text {
                            text: {
                                function truncate(str, maxLength) {
                                    return str.length > maxLength ? str.slice(0, maxLength) + "..." : str;
                                }
                                truncate(NiriService.focusedWindowTitle || "", 70);
                            }
                            color: Style.textMuted
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter

                            font.pixelSize: Style.fontSize
                            font.family: Style.fontFamily
                            font.weight: Style.fontWeight

                            Layout.alignment: Qt.AlignLeft
                            Layout.fillHeight: true
                            Layout.minimumHeight: parent.height
                        }
                    }

                    // Midle section
                    RowLayout {
                        implicitHeight: parent.height
                        Layout.fillWidth: true

                        Layout.leftMargin: 7
                        Layout.rightMargin: 7
                        spacing: 15
                        Layout.alignment: Qt.AlignLeft
                    }

                    // Right section
                    RowLayout {
                        implicitHeight: parent.height
                        Layout.fillWidth: true

                        Layout.leftMargin: 7
                        Layout.rightMargin: 15
                        spacing: 14
                        Layout.alignment: Qt.AlignRight

                        RowLayout {
                            id: audio
                            WrapperMouseArea {
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                enabled: true
                                onClicked: {
                                    // AudioPopup.toggleVisibility();
                                    BarPopupManager.toggleAudioPopup();
                                }
                                child: RowLayout {
                                    Text {
                                        text: Audio.icon
                                        font.pixelSize: Style.iconFontSize - 5
                                        font.family: Style.iconFontFamily
                                        font.weight: Style.iconFontWeight + 400

                                        Layout.fillHeight: true
                                        Layout.minimumHeight: parent.height
                                        verticalAlignment: Text.AlignVCenter
                                        color: (Audio.volume > 100) ? Style.red : Style.textMuted
                                    }

                                    Text {
                                        text: parseInt(Audio.volume * 100) + "%"
                                        Layout.fillHeight: true
                                        Layout.minimumHeight: parent.height
                                        verticalAlignment: Text.AlignVCenter
                                        Layout.alignment: Qt.AlignRight

                                        font.pixelSize: 14
                                        font.weight: Style.fontWeight
                                        font.family: Style.fontFamily
                                        color: (Audio.volume > 100) ? Style.red : Style.textMuted
                                    }
                                }
                            }
                        }

                        // Battery
                        RowLayout {
                            // IconImage {
                            //     source:Quickshell.iconPath(Battery.icon)
                            //     implicitSize: 24
                            // }
                            BatteryIcon {
                                Layout.rightMargin: 35
                            }


                            WrapperMouseArea {
                                visible: false
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                enabled: true
                                onClicked: {
                                    // BatteryPopup.toggleVisibility();
                                    BarPopupManager.toggleBatteryPopup();
                                }
                                child: RowLayout {
                                    Text {
                                        text: Battery.batteryIcon
                                        color: Battery.isCharging ? Style.green : Battery.percentageValue > 20 ? Style.textMuted : Style.orange
                                        font.pixelSize: Style.iconFontSize
                                        font.family: Style.iconFontFamily
                                        font.weight: Style.iconFontWeight

                                        Layout.fillHeight: true
                                        Layout.minimumHeight: parent.height
                                        verticalAlignment: Text.AlignVCenter
                                        Layout.alignment: Qt.AlignRight
                                    }
                                    Text {
                                        text: Battery.percentage
                                        color: Battery.isCharging ? Style.textMuted : Battery.percentageValue > 20 ? Style.textMuted : Style.orange
                                        Layout.fillHeight: true
                                        Layout.minimumHeight: parent.height
                                        verticalAlignment: Text.AlignVCenter
                                        Layout.alignment: Qt.AlignRight

                                        font.pixelSize: 14
                                        font.weight: Style.fontWeight
                                        font.family: Style.fontFamily
                                    }
                                }
                            }
                        }

                        RowLayout {
                            id: ressourceUsage
                            property var color: (memory.text > 95) ? Style.red : Style.textMuted
                            WrapperMouseArea {
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                enabled: true
                                onClicked: {
                                    // RessourcePopup.toggleVisibility();
                                    BarPopupManager.toggleRessourcePopup();
                                    // console.log("show ressourceUsage", BarPopupManager.showRessourcePopup);
                                }
                                child: RowLayout {
                                    Text {
                                        text: "􀫦"
                                        font.pixelSize: Style.iconFontSize - 5
                                        font.family: Style.iconFontFamily
                                        font.weight: Style.iconFontWeight + 400

                                        Layout.fillHeight: true
                                        Layout.minimumHeight: parent.height
                                        verticalAlignment: Text.AlignVCenter
                                        color: ressourceUsage.color
                                    }

                                    Text {
                                        id: memory
                                        text: parseInt(RessourceUsage.memoryUsedPercentage * 100) + "%"
                                        Layout.fillHeight: true
                                        Layout.minimumHeight: parent.height
                                        verticalAlignment: Text.AlignVCenter
                                        Layout.alignment: Qt.AlignRight

                                        font.pixelSize: 14
                                        font.weight: Style.fontWeight
                                        font.family: Style.fontFamily
                                        color: ressourceUsage.color
                                    }
                                }
                            }
                        }

                        Text {
                            text: "|"
                            color: Style.textMuted
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter

                            font.pixelSize: Style.fontSize - 5
                            font.family: Style.fontFamily
                            font.weight: Style.fontWeight

                            Layout.alignment: Qt.AlignLeft
                            Layout.fillHeight: true
                            Layout.minimumHeight: parent.height
                        }

                        SysTray {
                            bar: root_bar
                            visible: true
                            Layout.fillWidth: false
                            Layout.fillHeight: true
                        }

                        Text {
                            text: "|"
                            color: Style.textMuted
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter

                            font.pixelSize: Style.fontSize - 5
                            font.family: Style.fontFamily
                            font.weight: Style.fontWeight

                            Layout.alignment: Qt.AlignLeft
                            Layout.fillHeight: true
                            Layout.minimumHeight: parent.height
                        }
                        ClockWidget {
                            color: Style.textMuted
                            Layout.fillHeight: true
                            Layout.minimumHeight: parent.height
                            verticalAlignment: Text.AlignVCenter
                            Layout.alignment: Qt.AlignRight
                            font.pixelSize: Style.fontSize
                            font.family: Style.fontFamily
                            font.weight: Style.fontWeight
                        }
                    }
                }
            }
        }
    }
}
