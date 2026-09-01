import qs.assets
import qs.services
import qs.modules
import qs.modules.widgets
import QtQuick
import QtQuick.Controls
import Quickshell
import QtQuick.Effects
import Quickshell.Io
import QtQuick.Layouts
import Quickshell.Widgets
import Quickshell.Wayland
import Quickshell.Services.Mpris
import Quickshell.Services.Pipewire
import Qt5Compat.GraphicalEffects

Scope {
    id: root
    property bool showControlCenter: true
    property int spacing: 10
    property color borderColor: root.darker ? "#303033" : Qt.rgba(0.5, 0.5, 0.5, 0.40)
    property bool darker: false

    IpcHandler {
        id: ipcHandler
        target: "controlCenter"

        function toggleDarkMode(): void {
            root.darker = !root.darker;
        }
    }

    PanelWindow {
        id: window
        visible: root.showControlCenter
        color: Qt.rgba(0 / 255, 0 / 255, 0 / 255, 0.6)
        // color: root.darker ? Qt.rgba(0, 0, 0, 0.8) : Qt.rgba(0.2, 0.2, 0.2, 0.3)
        WlrLayershell.namespace: "quickshell:ControlCenter"
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
        WlrLayershell.layer: WlrLayer.Overlay
        exclusionMode: ExclusionMode.Ignore

        anchors {
            top: true
            left: true
            right: true
            bottom: true
        }

        MouseArea {
            anchors.fill: parent
            onClicked: () => {}
        }

        Rectangle {
            id: backgroundRectangle
            anchors.centerIn: parent
            color: "transparent"
            // color: root.darker ? Qt.rgba(0, 0, 0, 0.6) : "transparent"
            implicitHeight: 540 + 120
            implicitWidth: 1285
            property int margin: 20
            property int innerWidth: implicitWidth - margin * 2
            property int innerHeight: implicitHeight - margin * 2
            radius: Style.screenCornerRadius + 10
            scale: 0.8

            focus: true

            Keys.onPressed: event => {
                switch (event.key) {
                case Qt.Key_Escape:
                    Settings.showControlCenter = false;
                    break;
                case Qt.Key_Q:
                    Settings.showControlCenter = false;
                    break;
                case Qt.Key_Return:
                    stopwatch.toggleRunning();
                    break;
                case Qt.Key_Space:
                    MprisService.activePlayer.togglePlaying();
                    break;
                case Qt.Key_N:
                    MprisService.activePlayer.next();
                    break;
                case Qt.Key_P:
                    MprisService.activePlayer.previous();
                    break;
                case Qt.Key_L:
                    MprisService.activePlayer.loopState = !MprisService.activePlayer.loopState;
                    break;
                case Qt.Key_S:
                    if (MprisService.activePlayer.canControl && MprisService.activePlayer.shuffleSupported) {
                        MprisService.activePlayer.shuffle = !MprisService.activePlayer.shuffle;
                    }
                    break;
                case Qt.Key_R:
                    stopwatch.reset();
                    break;
                }
            }

            ParallelAnimation {
                id: bounceAnimation

                // Scale up past target size
                NumberAnimation {
                    target: backgroundRectangle
                    property: "scale"
                    to: 1.02
                    duration: 150
                    // easing.type: Easing.Linear
                    easing.type: Easing.OutCubic
                }
                // NumberAnimation {
                //     target: backgroundRectangle
                //     property: "y"
                //     to: 0
                //     duration: 200
                //     easing.type: Easing.InCubic
                // }
            }

            ParallelAnimation {
                id: bounceAnimationClose

                // Scale up past target size
                NumberAnimation {
                    target: backgroundRectangle
                    property: "scale"
                    to: 0.8
                    duration: 1
                    // easing.type: Easing.OutCubic
                }
                NumberAnimation {
                    target: backgroundRectangle
                    property: "y"
                    to: 250
                    duration: 200
                    easing.type: Easing.InCubic
                }
            }

            // Trigger animation when parent becomes visible
            Connections {
                target: window
                function onVisibleChanged() {
                    if (window.visible) {
                        backgroundRectangle.scale = 0.8;
                        bounceAnimation.restart();
                    }
                }
            }

            RowLayout {
                anchors.centerIn: parent
                spacing: root.spacing
                Layout.alignment: Qt.AlignTop

                ColumnLayout {
                    spacing: root.spacing
                    implicitWidth: 550
                    RowLayout {
                        Layout.alignment: Qt.AlignTop
                        AudioPopupComponent {
                            id: audio
                            Layout.preferredWidth: playerWidth
                            Layout.preferredHeight: playerHeight
                            playerWidth: 550
                            // imageSize: 185
                            playerHeight: 210
                            hasPopup: true
                            radius: 20
                            margin: 15
                            controlSize: 29
                            fontSize: 16
                            borderColor: root.borderColor
                        }
                    }

                    RowLayout {
                        Layout.alignment: Qt.AlignBottom
                        AgendaComponent {
                            id: agenda
                            implicitWidth: 550
                            // implicitHeight: 300
                            // Layout.fillWidth: true
                            Layout.fillHeight: true
                            radius: 20
                            margin: 15
                            borderColor: root.borderColor
                        }
                    }
                }

                ColumnLayout {
                    Layout.alignment: Qt.AlignTop
                    spacing: root.spacing
                    RowLayout {
                        Layout.alignment: Qt.AlignTop
                        spacing: root.spacing
                        ColumnLayout {
                            implicitHeight: backgroundRectangle.innerHeight
                            Layout.alignment: Qt.AlignTop
                            spacing: root.spacing
                            // implicitWidth: (500 / backgroundRectangle.innerWidth) * backgroundRectangle.innerWidth
                            RowLayout {
                                BatteryPopupComponent {
                                    id: battery
                                    implicitWidth: (475 / backgroundRectangle.innerWidth) * backgroundRectangle.innerWidth
                                    // Layout.fillWidth: true
                                    implicitHeight: (180 / backgroundRectangle.innerHeight) * backgroundRectangle.innerHeight
                                    radius: 20
                                    margin: 15
                                    borderColor: root.borderColor
                                }
                            }

                            RowLayout {
                                SlidersComponent {
                                    id: sliders
                                    demo: true
                                    radius: 20
                                    margin: 15
                                    borderColor: root.borderColor
                                    // implicitWidth: 500
                                    // Layout.fillWidth: true
                                    implicitWidth: (475 / backgroundRectangle.innerWidth) * backgroundRectangle.innerWidth
                                    // implicitHeight: (100 / backgroundRectangle.innerHeight) * backgroundRectangle.innerHeight
                                    Layout.fillHeight: true
                                }
                            }

                            RowLayout {
                                AudioSourceComponent {
                                    id: audioSrc
                                    radius: 20
                                    margin: 15
                                    borderColor: root.borderColor
                                    // implicitWidth: 500
                                    implicitWidth: (475 / backgroundRectangle.innerWidth) * backgroundRectangle.innerWidth
                                    // Layout.fillWidth: true
                                    implicitHeight: (170 / backgroundRectangle.innerHeight) * backgroundRectangle.innerHeight
                                }
                            }

                            RowLayout {
                                RessourceComponent {
                                    id: ressource
                                    // implicitWidth: 500
                                    // Layout.fillWidth: true
                                    implicitWidth: (475 / backgroundRectangle.innerWidth) * backgroundRectangle.innerWidth
                                    implicitHeight: (150 / backgroundRectangle.innerHeight) * backgroundRectangle.innerHeight
                                    radius: 20
                                    margin: 15
                                    borderColor: root.borderColor
                                }
                            }
                        }

                        ColumnLayout {
                            implicitHeight: backgroundRectangle.innerHeight
                            spacing: root.spacing
                            RowLayout {
                                Layout.fillHeight: true
                                StopWatchComponent {
                                    id: stopwatch
                                    implicitWidth: (220 / backgroundRectangle.innerWidth) * backgroundRectangle.innerWidth
                                    implicitHeight: backgroundRectangle.implicitHeight - (170 + 150 + 3 * root.spacing)
                                    // implicitHeight: 320
                                    // Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    radius: 20
                                    margin: 15
                                    borderColor: root.borderColor
                                }
                            }
                            RowLayout {
                                WeatherComponent {
                                    id: weather
                                    implicitWidth: (220 / backgroundRectangle.innerWidth) * backgroundRectangle.innerWidth
                                    // implicitHeight: implicitWidth
                                    implicitHeight: (170 / backgroundRectangle.innerHeight) * backgroundRectangle.innerHeight
                                    radius: 20
                                    margin: 15
                                    borderColor: root.borderColor
                                }
                            }

                            RowLayout {
                                SystemInfoComponent {
                                    id: sliders4
                                    radius: 20
                                    margin: 15
                                    borderColor: root.borderColor
                                    // implicitWidth: 500
                                    // Layout.fillWidth: true
                                    implicitWidth: (220 / backgroundRectangle.innerWidth) * backgroundRectangle.innerWidth
                                    implicitHeight: (150 / backgroundRectangle.innerHeight) * backgroundRectangle.innerHeight
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
