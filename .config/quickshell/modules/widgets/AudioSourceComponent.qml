import qs.bar
import QtQuick.Effects
import qs.services
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
    property bool debugMode: false
    property bool asciiStyle: true
    property bool showParent: true
    property var player: MprisService.activePlayer

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
            radius: root.radius
            border.width: root.borderSize + 1
            border.color: Style._borderIn
            margin: root.margin

            ColumnLayout {
                implicitHeight: parent.height - root.margin
                Layout.fillWidth: true

                RowLayout {
                    Layout.alignment: Qt.AlignTop
                    Layout.topMargin: -5
                    Text {
                        visible: root.asciiStyle
                        text: "Audio Output"
                        color: Style.textMuted
                        font.weight: Style.fontWeight
                        font.pixelSize: 21
                        font.family: Style.fontFamily

                        horizontalAlignment: Text.AlignLeft
                        Layout.alignment: Qt.AlignLeft
                        Layout.fillWidth: true
                    }

                    Text {
                        text: "􀍟"
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
                                moreInfo.exec("pavucontrol");
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
                    id: sourceSelect
                    Layout.alignment: Qt.AlignBottom
                    property int margins: -8
                    property int optionHeight: 25
                    visible: true
                    // implicitHeight: 100

                    implicitHeight: {
                        var optsLength;
                        if (Audio.outputs.length() <= 0) {
                            optsLength = 0;
                        } else if (Audio.outputs.length() == 1) {
                            optsLength = sourceSelect.optionHeight;
                        } else {
                            return Audio.outputs.length() * sourceSelect.optionHeight + (Audio.outputs.length() - 1) * sourceSelect.margin * 0;
                        }
                        return Math.max(playerHeight * 0.4, optsLength);
                    }
                    Layout.fillWidth: true
                    color: Style._bgLight
                    radius: root.radius + margins
                    margin: root.margin * 0.5

                    ColumnLayout {
                        Repeater {
                            id: audioOutputs
                            model: Audio.outputs

                            RowLayout {
                                id: output
                                required property PwNode modelData
                                Layout.fillWidth: true
                                Rectangle {
                                    color: clickArea.containsMouse ? Qt.rgba(5, 5, 5, 0.05) : "transparent"
                                    implicitHeight: sourceSelect.optionHeight
                                    Layout.fillWidth: true
                                    radius: sourceSelect.radius - sourceSelect.margin * 0.5

                                    MouseArea {
                                        id: clickArea
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            Pipewire.preferredDefaultAudioSink = output.modelData;
                                        }
                                    }

                                    RowLayout {
                                        spacing: root.margin
                                        // implicitWidth: sourceSelect.width - sourceSelect.margin * 2
                                        implicitWidth: root.width - sourceSelect.margin * 2 - root.margin * 2
                                        Rectangle {
                                            color: "transparent"
                                            height: parent.parent.height
                                            width: 30
                                            Text {
                                                text: Audio.outputIcon(modelData.description)
                                                color: Audio.sink == modelData ? "white" : Style.textMuted
                                                font.pixelSize: Style.iconFontSize - 1
                                                opacity: Audio.sink == modelData ? 0.85 : 0.5
                                                font.family: Style.iconFontFamily
                                                anchors.centerIn: parent
                                                Layout.fillWidth: true
                                                // font.bold: Audio.sink == modelData
                                            }
                                        }

                                        Text {
                                            text: modelData.description
                                            color: Audio.sink == modelData ? "white" : Style.textMuted
                                            font.pixelSize: Style.fontSize - 1
                                            opacity: Audio.sink == modelData ? 0.85 : 0.5
                                            horizontalAlignment: Text.AlignLeft
                                            Layout.fillWidth: true
                                            // font.bold: Audio.sink == modelData
                                        }

                                        Text {
                                            visible: false
                                            text: Audio.sink == modelData ? "􀃳" : "􀂓"
                                            // visible: Audio.sink == modelData
                                            color: Audio.sink == modelData ? Style.textMuted : Style._bg
                                            font.pixelSize: Style.iconFontSize - 6
                                            font.family: Style.iconFontFamily
                                            Layout.fillWidth: true
                                            horizontalAlignment: Text.AlignRight
                                            Layout.rightMargin: 10
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
