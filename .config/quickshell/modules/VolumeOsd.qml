pragma ComponentBehavior: Bound

import qs.services
import qs.bar
import qs.assets
import QtQuick
import QtQuick.Effects
import Qt5Compat.GraphicalEffects
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland

Scope {
    id: root
    property bool showOsdValues: false && !Settings.showControlCenter
    function triggerOsd() {
        showOsdValues = true && !Settings.showControlCenter;
        osdTimeout.restart();
    }

    Connections {
        // Listen to volume changes
        target: Audio.sink?.audio ?? null
        function onVolumeChanged() {
            if (!Audio.ready)
                return;
            root.triggerOsd();
            // console.log("audio device name", Audio.sink?.nickname);
        }
        function onMutedChanged() {
            if (!Audio.ready)
                return;
            root.triggerOsd();
        }
    }

    Connections {
        target: Brightness
        function onBrightnessLvChanged() {
            showOsdValues = false && !Settings.showControlCenter;
        }
    }

    Timer {
        id: osdTimeout
        interval: 2000
        repeat: false
        running: false
        onTriggered: {
            root.showOsdValues = false && !Settings.showControlCenter;
            // root.protectionMessage = ""
        }
    }

    Loader {
        id: osdLoader
        active: true

        sourceComponent: PanelWindow {
            id: osdRoot
            exclusionMode: ExclusionMode.Normal
            WlrLayershell.namespace: "quickshell:onScreenDisplay"
            WlrLayershell.layer: WlrLayer.Overlay
            color: "transparent"

            BackgroundEffect.blurRegion: Region {
                id: blur
                item: osdBackground_wrapper
                radius: osdBackground_wrapper.radius
                x: osdBackground_wrapper.x
                y: osdBackground_wrapper.y
                height: osdBackground_wrapper.height * osdBackground_wrapper.scale
                width: osdBackground_wrapper.width * osdBackground_wrapper.scale
            }

            anchors {
                top: false
                bottom: true
            }
            mask: Region {
                item: osdRoot.osdBackground_wrapper
            }

            property int margin: 64
            implicitWidth: osdBackground_wrapper.implicitWidth + margin
            implicitHeight: osdBackground_wrapper.implicitHeight + margin
            // visible: osdLoader.active

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onClicked: root.showOsdValues = false
            }

            RectangularShadow {
                id: osdShadow
                z: -1
                visible: true
                anchors.fill: osdBackground_wrapper
                radius: osdBackground_wrapper.radius
                color: Style.ctrlCenterShadow.color
                offset: Style.ctrlCenterShadow.offset
                blur: Style.ctrlCenterShadow.blur
                spread: Style.ctrlCenterShadow.spread
                scale: osdBackground_wrapper.scale
            }

            WrapperRectangle {
                id: osdBackground_wrapper
                color: "transparent"
                border.color: Style._borderOut
                border.width: 1
                radius: Style.cornerRadius + 5
                margin: 0
                implicitHeight: 56
                implicitWidth: 250
                // anchors.centerIn: parent

                // initial state
                x: 32
                y: 200
                scale: 0.2

                WrapperRectangle {
                    id: osdBackground
                    color: Qt.rgba(40 / 255, 40 / 255, 42 / 255, 0.7)
                    // border.color: Qt.rgba(0.58, 0.58, 0.58, 0.5)
                    border.color: Qt.lighter(Style._borderIn, 1.3)
                    border.width: Style.borderSize + 1
                    radius: Style.cornerRadius + 5
                    anchors.centerIn: parent
                    margin: 15

                    RowLayout {
                        id: osdContent
                        implicitHeight: osdBackground_wrapper.height - osdBackground_wrapper.margin
                        implicitWidth: osdBackground_wrapper.width - osdBackground_wrapper.margin

                        Text {
                            text: Audio.deviceIcon()
                            font.pixelSize: Style.iconFontSize + 2
                            font.family: Style.iconFontFamily
                            font.weight: Style.iconFontWeight + 400

                            Layout.fillHeight: true
                            Layout.minimumHeight: parent.height
                            verticalAlignment: Text.AlignVCenter
                            // Layout.alignment: Qt.AlignRight
                            color: (Audio.volume > 100) ? Style.red : Style.textMuted
                        }

                        ClippingWrapperRectangle {
                            // Layout.fillWidth: true
                            id: progressBar
                            Layout.alignment: Qt.AlignRight
                            implicitHeight: 15
                            implicitWidth: osdBackground.width - (osdBackground.margin * 2) - 45
                            radius: Style.cornerRadius
                            color: Qt.rgba(0.3, 0.3, 0.3)
                            property real ratio: Audio.volume

                            Rectangle {
                                id: progressFill
                                color: Style.textMuted
                                width: progressBar.ratio * progressBar.width
                                height: parent.height

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

                ParallelAnimation {
                    id: osdSpawn
                    NumberAnimation {
                        target: osdBackground_wrapper
                        property: "y"
                        to: 32
                        duration: 300
                        easing.type: Easing.OutCubic
                    }
                    NumberAnimation {
                        target: osdBackground_wrapper
                        property: "scale"
                        to: 1
                        duration: 600
                        easing.type: Easing.OutBack
                        easing.overshoot: 1.5
                    }
                }

                ParallelAnimation {
                    id: osdDispawn
                    NumberAnimation {
                        target: osdBackground_wrapper
                        property: "y"
                        to: 250
                        duration: 200
                        easing.type: Easing.InCubic
                    }
                    NumberAnimation {
                        target: osdBackground_wrapper
                        property: "scale"
                        to: 0.2
                        duration: 500
                        easing.type: Easing.OutBack
                        easing.overshoot: 1.5
                    }
                }

                Connections {
                    target: root
                    function onShowOsdValuesChanged() {
                        // console.log("[ Volume OSD ] show OSD values changes to : ", root.showOsdValues);
                        if (root.showOsdValues) {
                            osdSpawn.restart();
                        } else {
                            osdDispawn.restart();
                        }
                    }
                }
            }
        }
    }
}
