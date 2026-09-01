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
import Quickshell.Services.Mpris
import Quickshell.Services.Pipewire

Item {
    id: root
    property var player: MprisService.activePlayer
    property bool demo: false
    property int barMargin: 4

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
            // implicitWidth: 450
            // implicitHeight: 100
            radius: root.radius
            border.width: 2
            border.color: Style._borderIn
            margin: root.margin
            anchors.centerIn: parent

            ColumnLayout {
                spacing: root.margin

                RowLayout {
                    spacing: root.margin

                    WrapperRectangle {
                        id: iconWrapper
                        Layout.fillHeight: true
                        implicitWidth: 36
                        color: "transparent"
                        Text {
                            text: Audio.icon
                            font.pixelSize: Style.iconFontSize + 4
                            font.family: Style.iconFontFamily
                            font.weight: Style.iconFontWeight + 400

                            Layout.fillHeight: true
                            Layout.minimumHeight: parent.height
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                            // Layout.alignment: Qt.AlignRight
                            color: (Audio.volume > 100) ? Style.red : Style.textMuted
                        }
                    }
                    ClippingWrapperRectangle {
                        visible: root.demo
                        Layout.alignment: Qt.AlignRight
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        radius: Style.cornerRadius
                        color: Style._bgLight
                        Layout.topMargin: root.barMargin
                        Layout.bottomMargin: root.barMargin

                        WrapperMouseArea {
                            id: volumeMouseArea
                            property real ratio: Audio.volume
                            Connections {
                                target: Audio
                                function onVolumeChanged() {
                                    ratio = Audio.volume;
                                }
                            }
                            onClicked: {
                                console.log("[ volumeMouseArea clicked ]", mouseX);
                                Pipewire.defaultAudioSink.audio.volume = Math.max(0, Math.min(1, mouseX / 390));
                            }
                            onPositionChanged: {
                                console.log("[ volumeMouseArea pressed ]", mouseX);
                                Pipewire.defaultAudioSink.audio.volume = Math.max(0, Math.min(1, mouseX / 390));
                            }
                            Rectangle {
                                id: progressBar
                                color: "transparent"

                                Rectangle {
                                    id: progressFill
                                    color: Style.textMuted
                                    width: volumeMouseArea.ratio * progressBar.width
                                    height: parent.height
                                    opacity: 0.8

                                    Behavior on width {
                                        NumberAnimation {
                                            duration: 150
                                            easing.type: Easing.OutQuad
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                RowLayout {
                    spacing: root.margin

                    WrapperRectangle {
                        id: iconWrapper2
                        Layout.fillHeight: true
                        implicitWidth: 36
                        color: "transparent"

                        Behavior on rotation {
                            NumberAnimation {
                                duration: 150
                            }
                        }

                        Connections {
                            target: Brightness
                            function onbrightnessIncreased(brightnessLv, prevBrightnessLv, brightnessChange) {
                                iconWrapper2.rotation += 45;
                            }

                            function onbrightnessDecreased(brightnessLv, prevBrightnessLv, brightnessChange) {
                                iconWrapper2.rotation -= 45;
                            }
                        }

                        Text {
                            id: brightnessIcon
                            text: Brightness.icon
                            font.pixelSize: Style.iconFontSize + 4
                            font.family: Style.iconFontFamily
                            font.weight: Style.iconFontWeight + 400

                            Layout.fillHeight: true
                            Layout.minimumHeight: parent.height
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                            // Layout.alignment: Qt.AlignRight
                            color: Style.textMuted
                        }
                    }
                    ClippingWrapperRectangle {
                        visible: root.demo
                        // Layout.fillWidth: true
                        Layout.alignment: Qt.AlignRight
                        // implicitHeight: 15
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        // implicitWidth: osdBackground.width - (osdBackground.margin * 2) - 45
                        radius: Style.cornerRadius
                        // color: Qt.rgba(40, 40, 40, 0.2)
                        color: Style._bgLight
                        Layout.topMargin: root.barMargin
                        Layout.bottomMargin: root.barMargin

                        WrapperMouseArea {
                            onClicked: {
                                console.log("[ volumeMouseArea clicked ]", mouseX);
                                Brightness.setBrightnessLevel(Math.max(0, Math.min(1, mouseX / 390)));
                            }
                            onPositionChanged: {
                                console.log("[ volumeMouseArea pressed ]", mouseX);
                                Brightness.setBrightnessLevel(Math.max(0, Math.min(1, mouseX / 390)));
                            }
                            Rectangle {
                                id: progressBarBr
                                color: "transparent"

                                property real ratio: Brightness.brightnessLv

                                Rectangle {
                                    id: progressFillBr
                                    color: Style.textMuted
                                    opacity: 0.8
                                    width: progressBarBr.ratio * progressBarBr.width
                                    height: parent.height

                                    Behavior on width {
                                        NumberAnimation {
                                            duration: 150
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
