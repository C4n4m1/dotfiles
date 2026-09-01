import qs.services
import QtQuick.Effects
import qs.assets
import qs.modules
import qs.modules.styledControls
import QtQuick
import Quickshell
import QtQuick.Layouts
import Quickshell.Widgets
import Quickshell.Io
import Quickshell.Wayland

Item {
    id: root
    property bool running: false
    property int time: 0
    property int precision: 10 // max : 1000 for a sec

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
        // implicitWidth: 450
        // implicitHeight: 100
        radius: root.radius
        border.width: 1
        border.color: Style._borderOut
        margin: 0
        anchors.centerIn: parent
        color: 'transparent'

        WrapperRectangle {
            color: Style._bg
            // implicitWidth: 170
            // implicitHeight: 300
            anchors.centerIn: parent
            radius: root.radius
            border.width: root.borderSize + 1
            border.color: Style._borderIn
            margin: root.margin

            ColumnLayout {
                // implicitHeight: parent.height - root.margin
                Layout.fillHeight: true
                Layout.fillWidth: true

                RowLayout {
                    Layout.topMargin: -5
                    Text {
                        text: "Stopwatch"
                        font.pixelSize: Style.fontSize + 2
                        color: Style.textMuted
                    }
                }

                ColumnLayout {
                    Layout.alignment: Qt.AlignVCenter
                    anchors.centerIn: parent
                    Text {
                        text: root.durationFormatting(root.time)[0]
                        font.pixelSize: 60
                        font.family: "Pixelon"
                        color: Style.textMuted
                        font.weight: 300
                        Layout.fillWidth: true
                        // Layout.fillHeight: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        opacity: 0.95
                    }

                    Text {
                        text: root.durationFormatting(root.time)[1]
                        font.pixelSize: 60
                        font.family: "Pixelon"
                        color: Style.textMuted
                        font.weight: 300
                        Layout.fillWidth: true
                        // Layout.fillHeight: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        opacity: 0.5
                    }
                }
                RowLayout {
                    Layout.fillWidth: true
                    Layout.bottomMargin: -8
                    WrapperMouseArea {
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        enabled: true
                        onClicked: {
                            root.toggleRunning();
                        }
                        child: Text {
                            text: !root.running ? "􀊄" : "􀊆"
                            color: Style.textMuted
                            horizontalAlignment: Text.AlignLeft
                            verticalAlignment: Text.AlignVCenter
                            font.pixelSize: Style.iconFontSize + 4
                            font.family: Style.iconFontFamily
                            opacity: 0.9
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    WrapperMouseArea {
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        enabled: true
                        onClicked: {
                            root.reset();
                        }
                        child: Text {
                            text: "􀐯"
                            color: Style.textMuted
                            horizontalAlignment: Text.AlignRight
                            verticalAlignment: Text.AlignVCenter
                            font.pixelSize: Style.iconFontSize + 4
                            font.family: Style.iconFontFamily
                        }
                    }
                }
            }

            Timer {
                id: stopWatchTimer
                running: root.running
                repeat: true
                interval: 1000 / root.precision
                onTriggered: {
                    root.time++;
                }
            }
        }
    }
    function toggleRunning() {
        root.running = !root.running;
    }

    function reset() {
        root.running = false;
        root.time = 0;
    }

    function durationFormatting(duration) {
        var time = parseInt(duration / root.precision);
        var hundredth = duration % root.precision;
        var hours = Math.floor(time / 3600);
        var mins = Math.floor((time % 3600) / 60);
        var sec = time % 60;

        return [String(hours).padStart(2, '0') + ":" + String(mins).padStart(2, '0'), String(sec).padStart(2, '0') + ":" + String(hundredth).padStart(2, '0')];
    }
}
