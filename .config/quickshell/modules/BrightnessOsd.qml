pragma ComponentBehavior: Bound
import qs.services
import qs.assets
import QtQuick
import QtQuick.Effects
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland

Scope {
    id: root
    property bool externSourceHideOSD: false
    // sorry but it's different than the function hideOsd()
    property bool showOsdValues: false && !Settings.showControlCenter && !externSourceHideOSD
    function triggerOsd() {
        showOsdValues = true && !Settings.showControlCenter;
        osdTimeout.restart();
    }

    function hideOsd() {
        showOsdValues = false && !Settings.showControlCenter;
    }

    Connections {
        target: Brightness
        function onBrightnessLvChanged() {
            if (!IdleService.hideOSD) {
                root.triggerOsd();
            }
        }
    }

    Connections {
        // Listen to volume changes
        target: Audio.sink?.audio ?? null
        function onVolumeChanged() {
            if (!Audio.ready)
                return;
            hideOsd();
        }
        function onMutedChanged() {
            if (!Audio.ready)
                return;
            hideOsd();
        }
    }

    Timer {
        id: osdTimeout
        interval: 2000
        repeat: false
        running: false
        onTriggered: {
            root.hideOsd();
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
                item: osdBackground_wrapper
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

                        // icon
                        Text {
                            id: britghtnessIcon
                            text: Brightness.icon
                            font.pixelSize: Style.iconFontSize + 2
                            font.family: Style.iconFontFamily
                            font.weight: Style.iconFontWeight + 400

                            Layout.fillHeight: true
                            // Layout.minimumHeight: parent.height
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignLeft
                            // Layout.alignment: Qt.AlignRight
                            color: Style.textMuted
                            rotation: 0

                            Behavior on rotation {
                                NumberAnimation {
                                    duration: 150
                                }
                            }

                            Connections {
                                target: Brightness
                                function onbrightnessIncreased(brightnessLv, prevBrightnessLv, brightnessChange) {
                                    britghtnessIcon.rotation += 45;
                                }

                                function onbrightnessDecreased(brightnessLv, prevBrightnessLv, brightnessChange) {
                                    britghtnessIcon.rotation -= 45;
                                }
                            }
                        }

                        ClippingWrapperRectangle {
                            // Layout.fillWidth: true
                            id: progressBar
                            Layout.alignment: Qt.AlignRight
                            implicitHeight: 15
                            implicitWidth: osdBackground.width - (osdBackground.margin * 2) - 45
                            radius: Style.cornerRadius
                            color: Qt.rgba(40, 40, 40, 0.2)
                            property real ratio: Brightness.brightnessLv

                            Rectangle {
                                // Or Rectangle with transparent color
                                color: "transparent"
                                anchors.fill: parent
                                Rectangle {
                                    id: progressFill
                                    color: Style.textMuted
                                    width: progressBar.ratio * progressBar.width
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
