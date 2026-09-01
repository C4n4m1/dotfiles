import qs.bar
import qs.services
import qs.assets
import QtQuick.Effects
import qs.modules
import qs.modules.styledControls
import QtQuick
import Quickshell
import QtQuick.Layouts
import Quickshell.Widgets
import Quickshell.Wayland
import QtQuick.Controls
import Quickshell.Io

Item {
    id: root
    property int bigIconSize: Style.iconFontSize + 10
    property bool debugMode: false
    property bool asciiStyle: true

    property int radius: Style.cornerRadius
    property int borderSize: Style.borderSize
    property color borderColor: Style._borderIn
    property int margin: 10

    function displayDuration(time, details) {
        // time is a [hh,mm,ss] array
        var text = "";
        if (time[0] != 0) {
            text += (time[0] + "h.");
        }
        if (time[1] != 0) {
            text += (time[1] + "m.");
        }
        if (time[2] != 0) {
            text += (time[2] + "s");
        }
        if (time[0] == 0 && time[1] == 0 && time[2] == 0) {
            return "...";
        }
        return text + details;
    }

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
        // implicitHeight: 170
        radius: root.radius
        border.width: 1
        border.color: Style._borderOut
        margin: 0
        anchors.centerIn: parent
        color: 'transparent'

        WrapperRectangle {
            id: rootBg
            color: Style._bg
            radius: root.radius
            border.width: root.borderSize + 1
            border.color: Style._borderIn
            margin: root.margin
            anchors.centerIn: parent
            // implicitWidth: 450
            // implicitHeight: 170

            ColumnLayout {
                implicitHeight: parent.height - root.margin
                implicitWidth: parent.width - root.margin

                RowLayout {
                    id: row1
                    Layout.alignment: Qt.AlignTop
                    Layout.fillWidth: true
                    Layout.rightMargin: 5
                    Layout.leftMargin: 2

                    RowLayout {
                        // debug
                        // Rectangle {
                        //     visible: root.debugMode
                        //     color: Qt.rgba(100, 0, 0, 0.1)
                        //     // anchors.fill: parent
                        // }

                        Text {
                            visible: root.asciiStyle
                            text: "Battery"
                            color: Style.textMuted
                            // font.bold: false
                            font.weight: Style.fontWeight
                            font.pixelSize: root.bigIconSize - 5
                            font.family: Style.fontFamily

                            horizontalAlignment: Text.AlignLeft
                            Layout.alignment: Qt.AlignLeft
                            Layout.fillWidth: true
                            Layout.topMargin: -6
                        }

                        Text {
                            visible: !root.asciiStyle
                            text: Battery.batteryIcon
                            color: Battery.isCharging ? Style.green : Battery.percentageValue > 20 ? Style.textMuted : Style.orange
                            font.pixelSize: root.bigIconSize
                            font.family: Style.iconFontFamily
                            font.weight: Style.iconFontWeight

                            horizontalAlignment: Text.AlignLeft
                            Layout.alignment: Qt.AlignLeft
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignRight
                        ClippingWrapperRectangle {
                            visible: root.asciiStyle
                            color: "transparent"
                            radius: 5
                            implicitHeight: 27
                            AsciiProgressBar {
                                anchors.fill: parent
                                visible: root.asciiStyle
                                value: Battery.percentageValue
                                color: Battery.isCharging ? Style.green : Battery.percentageValue > 20 ? Style.textMuted : Style.orange
                                max: (100)//450 ) * root.implicitWidth
                                lineNb: 2
                                maxNbChars: 70
                                character: '|'
                                fontWeight: 700
                                fontSize: 10.5
                            }
                        }

                        Text {
                            text: Battery.percentage
                            color: Battery.isCharging ? Style.textMuted : Battery.percentageValue > 20 ? Style.textMuted : Style.orange
                            Layout.alignment: Qt.AlignRight
                            horizontalAlignment: Text.AlignRight
                            verticalAlignment: Text.AlignTop

                            font.pixelSize: root.bigIconSize - 5
                            font.weight: Style.fontWeight
                            font.family: Style.monospaceFont
                        }
                    }
                }

                RowLayout {
                    id: row2
                    Layout.topMargin: (30 / 170) * root.implicitHeight
                    ButtonGroup {
                        id: radioGroup
                    }

                    ColumnLayout {
                        RowLayout {
                            Layout.rightMargin: 5
                            Layout.leftMargin: 5
                            Text {
                                text: "Power Profile"
                                color: Style.textMuted
                                // font.bold: false
                                font.weight: Style.fontWeight
                                font.pixelSize: Style.fontSize + 4
                                font.family: Style.fontFamily
                            }

                            Text {
                                text: Battery.isCharging ? displayDuration(Battery.timeToFull, " to 100%") : displayDuration(Battery.timeToEmpty, " left")
                                color: Style.textMuted
                                Layout.fillWidth: true
                                horizontalAlignment: Text.AlignRight
                                verticalAlignment: Text.AlignTop
                                Layout.alignment: Qt.AlignRight

                                font.pixelSize: Style.fontSize
                                font.weight: Style.fontWeight
                                font.family: Style.monospaceFont
                            }
                        }
                        WrapperRectangle {
                            id: powerProfiles
                            radius: Style.cornerRadius - 5
                            color: "transparent" //Style._bgLight
                            // border.width: Style.borderSize
                            // border.color: Style.borderMuted
                            margin: 0
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            Layout.topMargin: 5

                            RowLayout {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                uniformCellSizes: true
                                spacing: 1

                                WrapperRectangle {
                                    // Layout.fillWidth: true
                                    implicitWidth: parent.width / 3
                                    Layout.fillHeight: true
                                    radius: Style.cornerRadius
                                    color: "transparent"
                                    margin: 1
                                    RadioButton {
                                        id: powerSaver
                                        checked: Battery.powerProfile == "power-saver"
                                        MouseArea {
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: powerSaver.checked = true
                                            enabled: true
                                        }
                                        ButtonGroup.group: radioGroup
                                        onCheckedChanged: () => {
                                            if (checked == true) {
                                                if (root.activePowerProfile != "power-saver") {
                                                    changePowerProfile.exec(["powerprofilesctl", "set", "power-saver"]);
                                                } else {
                                                    root.activePowerProfile = "power-saver";
                                                }
                                            }
                                        }
                                        indicator: Item {}
                                        background: Rectangle {
                                            color: powerSaver.checked ? Style.text : Style._bgLight
                                            border.width: 1
                                            border.color: powerSaver.checked ? Style.textMuted : Style._bg
                                            opacity: powerSaver.checked ? 0.8 : 1
                                            radius: 10
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                        }
                                        contentItem: Text {
                                            text: "Power Saver"
                                            color: powerSaver.checked ? Style.bgDark : Style.textMuted
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                        }
                                    }
                                }

                                WrapperRectangle {
                                    // Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    implicitWidth: parent.width / 3
                                    radius: Style.cornerRadius
                                    color: "transparent"
                                    margin: 1
                                    RadioButton {
                                        id: balanced
                                        MouseArea {
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: balanced.checked = true
                                            enabled: true
                                        }
                                        checked: Battery.powerProfile == "balanced"
                                        ButtonGroup.group: radioGroup
                                        onCheckedChanged: () => {
                                            if (checked == true) {
                                                if (root.activePowerProfile != "balanced") {
                                                    changePowerProfile.exec(["powerprofilesctl", "set", "balanced"]);
                                                } else {
                                                    root.activePowerProfile = "balanced";
                                                }
                                            }
                                        }
                                        indicator: Item {}
                                        background: Rectangle {
                                            color: balanced.checked ? Style.text : Style._bgLight
                                            border.width: 1
                                            border.color: balanced.checked ? Style.textMuted : Style._bg
                                            opacity: balanced.checked ? 0.8 : 1
                                            radius: 10
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                        }
                                        contentItem: Text {
                                            text: "Balanced"
                                            color: balanced.checked ? Style.bgDark : Style.textMuted
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                        }
                                    }
                                }

                                WrapperRectangle {
                                    // Layout.fillWidth: true
                                    implicitWidth: parent.width / 3
                                    Layout.fillHeight: true
                                    radius: Style.cornerRadius
                                    color: "transparent"
                                    margin: 1
                                    RadioButton {
                                        id: performance
                                        MouseArea {
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: performance.checked = true
                                            enabled: true
                                        }
                                        checked: Battery.powerProfile == "performance"
                                        ButtonGroup.group: radioGroup
                                        onCheckedChanged: () => {
                                            if (checked == true) {
                                                if (root.activePowerProfile != "performance") {
                                                    changePowerProfile.exec(["powerprofilesctl", "set", "performance"]);
                                                } else {
                                                    root.activePowerProfile = "performance";
                                                }
                                            }
                                        }
                                        indicator: Item {}
                                        background: Rectangle {
                                            color: performance.checked ? Style.text : Style._bgLight
                                            border.width: 1
                                            border.color: performance.checked ? Style.textMuted : Style._bg
                                            opacity: performance.checked ? 0.8 : 1
                                            radius: 10
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                        }
                                        contentItem: Text {
                                            text: "Performance"
                                            color: performance.checked ? Style.bgDark : Style.textMuted
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            Process {
                id: changePowerProfile
            }
        }
    }
}
