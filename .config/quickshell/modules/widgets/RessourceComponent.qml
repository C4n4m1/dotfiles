import qs.bar
import qs.services
import qs.assets
import qs.modules
import qs.modules.styledControls
import QtQuick
import Quickshell
import QtQuick.Layouts
import Quickshell.Widgets
import Quickshell.Io
import QtQuick.Effects
import Quickshell.Wayland

Item {
    id: root
    property bool debugMode: false
    property bool asciiStyle: true
    property bool showParent: true

    property int radius: Style.cornerRadius
    property int borderSize: Style.borderSize
    property color borderColor: Style.borderMuted
    property int margin: 10

    RectangularShadow {
        id: shadow
        z: -1
        visible: true
        anchors.fill: borderRect
        radius: borderRect.radius
        color: Style.ctrlCenterShadow.color
        offset: Style.ctrlCenterShadow.offset
        blur: Style.ctrlCenterShadow.blur
        spread: Style.ctrlCenterShadow.spread
        scale: borderRect.scale
    }

    WrapperRectangle {
        id: borderRect
        anchors.fill: parent
        radius: root.radius
        border.width: 1
        border.color: Style._borderOut
        margin: 0
        anchors.centerIn: parent
        color: 'transparent'

        WrapperRectangle {
            color: Style._bg
            implicitWidth: 450
            implicitHeight: 155
            radius: root.radius
            border.width: 2
            border.color: Style._borderIn
            margin: root.margin

            ColumnLayout {
                implicitHeight: parent.height - root.margin
                // implicitWidth: parent.width - root.margin
                Layout.fillWidth: true

                RowLayout {
                    Layout.alignment: Qt.AlignTop
                    Layout.topMargin: -5
                    Text {
                        visible: root.asciiStyle
                        text: "Ressource Usage"
                        color: Style.textMuted
                        // font.bold: false
                        font.weight: Style.fontWeight
                        font.pixelSize: 21
                        font.family: Style.fontFamily

                        horizontalAlignment: Text.AlignLeft
                        Layout.alignment: Qt.AlignLeft
                        Layout.fillWidth: true
                        // Layout.topMargin: -6
                    }

                    // WrapperRectangle
                    //     id: button
                    //     implicitHeight: 25
                    //     implicitWidth: 60
                    //     // color: Style.highlight
                    //     // radius: Style.cornerRadius
                    //     color: "transparent"

                    Text {
                        text: "􀍢"
                        color: Style.highlight
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: Style.iconFontSize + 3
                        font.family: Style.iconFontFamily
                        Layout.rightMargin: -4
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            enabled: true
                            onClicked: {
                                moreInfo.exec(["ghostty","-e","btop" ]);
                                root.showParent = false;
                                RessourcePopup.showPopup = false;
                                Settings.showControlCenter = false;
                            }
                        }
                        Process {
                            id: moreInfo
                        }
                    }
                    // }
                }

                WrapperRectangle {
                    id: statsWrapper
                    radius: Style.cornerRadius - 5
                    color: "transparent" //Style._bgLight
                    // border.width: Style.borderSize
                    border.color: Style.borderMuted
                    margin: 6
                    // Layout.fillHeight: true
                    Layout.fillWidth: true
                    Layout.topMargin: 5
                    Layout.alignment: Qt.AlignBottom
                    RowLayout {
                        id: stats

                        ColumnLayout {
                            id: labels
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.leftMargin: 5
                            Text {
                                text: "Memory"
                                color: Style.textMuted
                                // font.bold: false
                                font.weight: Style.fontWeight - 400
                                font.pixelSize: Style.fontSize + 1
                                font.family: Style.fontFamily
                            }

                            Text {
                                text: "CPU usage"
                                color: Style.textMuted
                                // font.bold: false
                                font.weight: Style.fontWeight - 400
                                font.pixelSize: Style.fontSize + 1
                                font.family: Style.fontFamily
                            }

                            Text {
                                text: "Swap"
                                color: Style.textMuted
                                // font.bold: false
                                font.weight: Style.fontWeight - 400
                                font.pixelSize: Style.fontSize + 1
                                font.family: Style.fontFamily
                            }
                        }
                        ColumnLayout {
                            id: progressBars
                            Layout.leftMargin: 5
                            AsciiProgressBar {
                                value: parseInt(RessourceUsage.memoryUsedPercentage * 100)
                                color: (value > 95) ? Style.red : Style.textMuted
                                max: 100
                                lineNb: 1
                                maxNbChars: 71
                                character: '|'
                                fontWeight: 600
                                fontSize: 13
                                Layout.margins: 0
                            }

                            AsciiProgressBar {
                                value: parseInt(RessourceUsage.cpuUsage * 100)
                                color: (value > 95) ? Style.red : Style.textMuted
                                max: 100
                                lineNb: 1
                                maxNbChars: 71
                                character: '|'
                                fontWeight: 600
                                fontSize: 13
                                Layout.margins: 0
                            }

                            AsciiProgressBar {
                                value: parseInt(RessourceUsage.swapUsedPercentage * 100)
                                color: (value > 95) ? Style.red : Style.textMuted
                                max: 100
                                lineNb: 1
                                maxNbChars: 71
                                character: '|'
                                fontWeight: 600
                                fontSize: 13
                                Layout.margins: 0
                            }
                        }
                        ColumnLayout {
                            id: values

                            Text {
                                text: parseInt(RessourceUsage.memoryUsed / 1000) + " Mb"
                                color: Style.textMuted
                                Layout.alignment: Qt.AlignRight
                                horizontalAlignment: Text.AlignRight
                                verticalAlignment: Text.AlignTop
                                Layout.rightMargin: 5

                                font.pixelSize: Style.fontSize
                                font.weight: Style.fontWeight
                                font.family: Style.monospaceFont
                            }

                            Text {
                                text: parseInt(RessourceUsage.cpuUsage * 100) + " % "
                                color: Style.textMuted
                                Layout.alignment: Qt.AlignRight
                                horizontalAlignment: Text.AlignRight
                                verticalAlignment: Text.AlignTop
                                Layout.rightMargin: 5

                                font.pixelSize: Style.fontSize
                                font.weight: Style.fontWeight
                                font.family: Style.monospaceFont
                            }

                            Text {
                                text: parseInt(RessourceUsage.swapUsed / 1000) + " Mb"
                                color: Style.textMuted
                                Layout.alignment: Qt.AlignRight
                                horizontalAlignment: Text.AlignRight
                                verticalAlignment: Text.AlignTop
                                Layout.rightMargin: 5

                                font.pixelSize: Style.fontSize
                                font.weight: Style.fontWeight
                                font.family: Style.monospaceFont
                            }
                        }
                    }
                }
            }
        }
    }
}
