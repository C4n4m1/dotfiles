import qs.services
import qs.assets
import qs.modules
import QtQuick.Effects
import qs.modules.styledControls
import QtQuick
import Quickshell
import QtQuick.Layouts
import Quickshell.Widgets
import Quickshell.Io
import Quickshell.Wayland

Item {
    id: root
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
            // implicitHeight: 170
            anchors.centerIn: parent
            radius: root.radius
            border.width: root.borderSize + 1
            border.color: Style._borderIn
            margin: root.margin

            ColumnLayout {
                Layout.fillHeight: true
                anchors.centerIn: parent

                RowLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignCenter
                    Layout.fillHeight: true
                    Text {
                        text: "Lomé, Togo"
                        color: Style.textMuted
                        font.weight: Style.fontWeight
                        font.pixelSize: 20
                        font.family: Style.fontFamily

                        horizontalAlignment: Text.AlignHCenter
                        Layout.alignment: Qt.AlignCenter
                        // verticalAlignment: Text.AlignVCenter
                        Layout.bottomMargin: -20
                        Layout.fillWidth: true
                        Layout.topMargin: 10
                    }
                }

                RowLayout {
                    Layout.alignment: Qt.AlignCenter
                    RowLayout {
                        Text {
                            text: Weather.icon + " " + (Weather.temperature > 0 ? Weather.temperature : "")
                            color: Style.textMuted
                            font.pixelSize: 40
                            font.family: Style.iconFontFamily
                            font.weight: 900

                            horizontalAlignment: Text.AlignHCenter
                            Layout.alignment: Qt.AlignCenter
                            verticalAlignment: Text.AlignVCenter
                            // Layout.fillWidth: true
                            // Layout.topMargin: -30
                        }

                        Text {
                            visible: Weather.temperature > 0
                            text: "°C"
                            color: Style.textMuted
                            font.pixelSize: Style.fontSize + 5
                            font.family: Style.iconFontFamily
                            font.weight: 900

                            horizontalAlignment: Text.AlignLeft
                            Layout.alignment: Qt.AlignTop
                            verticalAlignment: Text.AlignTop
                            // Layout.fillWidth: true
                            // Layout.leftMargin: -20
                        }
                    }

                    Text {
                        visible: false
                        text: Weather.icon
                        color: Style.textMuted
                        font.weight: Style.fontWeight
                        font.pixelSize: 46
                        font.family: Style.fontFamily

                        horizontalAlignment: Text.AlignRight
                        Layout.alignment: Qt.AlignTop
                        verticalAlignment: Text.AlignTop
                        Layout.fillWidth: true
                        // Layout.leftMargin: -10
                        // Layout.bottomMargin: 30
                    }
                }
            }
        }
    }
}
