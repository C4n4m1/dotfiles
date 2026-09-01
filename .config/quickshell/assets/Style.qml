pragma Singleton

import QtQuick
import Quickshell
import QtQuick.Layouts
import Quickshell.Widgets
import QtQuick.Controls

Singleton {
    // Base palette
    property color bgDark: "#000" //"#101011"
    property color bg: "#161617"
    property color bgLight: "#252528"

    // Blured version
    property color _bg: Qt.rgba(44 / 255, 44 / 255, 46 / 255, 0.7)
    property color _bgLight: Qt.rgba(94 / 255, 94 / 255, 100 / 255, 0.4)
    property color _bgDark: Qt.rgba(0, 0, 0, 0.4)

    property color _borderIn: Qt.rgba(0.45, 0.45, 0.45, 0.45)
    property color _borderOut: Qt.rgba(0, 0, 0, 1)

    property QtObject ctrlCenterShadow: QtObject {
        property color color: Qt.rgba(0, 0, 0, 0.45)
        property var offset: Qt.point(0, 4)
        property var blur: 10
        property var spread: 2
    }

    property color text: "#eeeeee"
    property color textMuted: "#C9C7CD"
    property color textMutedDesaturated: Qt.darker(textMuted, 1.9)

    // property color highlight: "#5B6770"
    property color highlight: "#afb3b6"
    property color border: "#505052"
    property color borderMuted: "#28282A"

    property real borderSize: 1.3

    // Other colors
    property color cyan: "#85B5BA"
    property color green: "#90B99F"
    property color magenta: "#E29ECA"
    property color orange: "#F5A191"
    property color purple: "#ACA1CF"
    property color red: "#EA83A5"
    property color yellow: "#E6B99D"
    property color blue: "#92A2D5"

    // Desaturated colors
    property color greenDesaturated: Qt.darker(green, 1.9)
    property color orangeDesaturated: Qt.darker(orange, 1.9)
    property color purpleDesaturated: Qt.darker(purple, 1.9)
    property color redDesaturated: Qt.darker(red, 1.9)
    property color yellowDesaturated: Qt.darker(yellow, 1.9)
    property color blueDesaturated: Qt.darker(blue, 1.9)

    // Font
    property var fontFamily: "Inter Semibold"
    property var iconFontFamily: "SF Pro Text"
    property var monospaceFont: "IoskeleyMono NerdFont"

    property int iconFontWeight: 300
    property int fontWeight: 600

    // font size could be either in px or pt : those values are used for px
    property int fontSize: 14
    property int iconFontSize: 19

    // Geometry
    property int cornerRadius: 15
    property int screenCornerRadius: 15

    // Extras
    property bool screenCorners: true

    // Components
    property Component radioButton: Component {
        RadioButton {
            id: radioButton
            property color bgColor: Style.text
            property color textColor: Style.bg
            property color checkedBgColor: Style.bg
            property color checkedTextColor: Style.text
            property string contentText: ""
            indicator: {}
            background: Rectangle {
                color: radioButton.checked ? radioButton.checkedBgColor : radioButton.bgColor
                Layout.fillWidth: true
                Layout.fillHeight: true
            }
            contentItem: Text {
                text: radioButton.text
                color: radioButton.checked ? radioButton.checkedTextColor : radioButton.textColor
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }
}
