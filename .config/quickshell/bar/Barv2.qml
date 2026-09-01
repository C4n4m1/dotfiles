import qs.assets
import qs.services
import qs.modules
import qs.modules.widgets
import QtQuick
import QtQuick.Effects
import Quickshell
import QtQuick.Layouts
import Quickshell.Widgets
import Quickshell.Wayland

Scope {
    id: bar
    property int height: root_bar.barHeight

    PanelWindow {
        id: root_bar
        property int barHeight: 35
        property int screenRounding: 18
        property bool showBarShadow: true

        implicitHeight: root_bar.barHeight
        WlrLayershell.namespace: "quickshell:bar"
        exclusiveZone: root_bar.barHeight

        anchors {
            top: true
            left: true
            right: true
        }

        color: "transparent"

        Item {
            id: barContent
            anchors {
                right: parent.right
                left: parent.left
                top: parent.top
            }
            implicitHeight: root_bar.barHeight
            height: root_bar.barHeight

            WrapperRectangle {
                id: barBackground
                leftMargin: 10
                rightMargin: 10
                border {
                    color: Style.borderMuted
                    width: 0
                }
                color: {
                    if (NiriService.inOverview) {
                        Qt.rgba(13 / 255, 13 / 255, 14 / 255, 0.6);
                    } else if (!NiriService.activeToplevelMaximized) {
                        Qt.rgba(13 / 255, 13 / 255, 14 / 255, 0.88);
                    } else {
                        Style.bgDark;
                    }
                }

                layer.enabled: true
                anchors {
                    fill: parent
                }

                Item {
                    id: barLayout
                    anchors.fill: parent

                    // Left section
                    RowLayout {
                        id: leftSection
                        anchors {
                            left: parent.left
                            leftMargin: 10
                            verticalCenter: parent.verticalCenter
                        }
                        spacing: 15

                        WrapperRectangle {
                            color: "transparent"
                            Layout.fillHeight: true

                            RowLayout {
                                id: leftContent
                                spacing: 15
                                ClockWidget {
                                    color: Style.textMuted
                                    Layout.fillHeight: true
                                    Layout.minimumHeight: parent.height
                                    verticalAlignment: Text.AlignVCenter
                                    Layout.alignment: Qt.AlignLeft
                                    font.pixelSize: Style.fontSize
                                    font.family: Style.fontFamily
                                    font.weight: Style.fontWeight
                                }

                                WrapperRectangle {
                                    id: recordIndicator
                                    color: Qt.darker(Style.red, 1.9)
                                    radius: 10
                                    visible: MprisService.pipewireVideoActive
                                    rightMargin: 5
                                    leftMargin: 5
                                    bottomMargin: 1
                                    topMargin: 1
                                    border.color: Style.red
                                    border.width: 1
                                    height: recordIndicator.height * 0.9

                                    Text {
                                        text: MprisService.recordDurationFormatting(MprisService.recordDuration)
                                        font.family: "Geist"
                                        font.pixelSize: Style.fontSize - 1.5
                                        font.weight: 900
                                        verticalAlignment: Text.AlignVCenter
                                        horizontalAlignment: Text.AlignHCenter
                                        anchors.verticalCenter: parent.verticalCenter
                                        color: Qt.lighter("white", 1.9)
                                    }
                                }

                                Text {
                                    id: dndIndicator
                                    property bool dnd: Settings.dnd
                                    text: "􀋞"
                                    font.pixelSize: Style.iconFontSize - 6
                                    font.family: Style.iconFontFamily
                                    font.weight: Style.iconFontWeight
                                    visible: false
                                    opacity: 0
                                    scale: 0

                                    Layout.fillHeight: true
                                    Layout.minimumHeight: parent.height
                                    verticalAlignment: Text.AlignVCenter
                                    color: Style.orange

                                    MouseArea {
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: Settings.dnd = !Settings.dnd
                                    }

                                    ParallelAnimation {
                                        id: dndSpawn
                                        NumberAnimation {
                                            target: dndIndicator
                                            property: "opacity"
                                            to: 1
                                            duration: 300
                                            easing.type: Easing.OutBack
                                        }
                                        NumberAnimation {
                                            target: dndIndicator
                                            property: "scale"
                                            to: 1
                                            duration: 300
                                            easing.type: Easing.OutBack
                                        }
                                    }

                                    SequentialAnimation {
                                        id: dndDispawn
                                        ParallelAnimation {
                                            NumberAnimation {
                                                target: dndIndicator
                                                property: "opacity"
                                                to: 0
                                                duration: 250
                                                easing.type: Easing.InCubic
                                            }
                                            NumberAnimation {
                                                target: dndIndicator
                                                property: "scale"
                                                to: 0
                                                duration: 250
                                                easing.type: Easing.InCubic
                                            }
                                        }
                                        PropertyAnimation {
                                            target: dndIndicator
                                            property: "visible"
                                            to: false
                                            duration: 1
                                        }
                                    }

                                    onDndChanged: {
                                        if (dnd) {
                                            dndIndicator.visible = true;
                                            dndSpawn.restart();
                                        } else {
                                            dndDispawn.restart();
                                        }
                                    }
                                }

                                Text {
                                    id: caffeineIndicator
                                    property bool caffeine: Settings.idleService.respectInhibitors
                                    text: "􀸙 "
                                    font.pixelSize: Style.iconFontSize - 6
                                    font.family: Style.iconFontFamily
                                    font.weight: Style.iconFontWeight
                                    visible: false
                                    opacity: 0
                                    scale: 0

                                    Layout.fillHeight: true
                                    Layout.minimumHeight: parent.height
                                    verticalAlignment: Text.AlignVCenter
                                    color: Style.textMuted

                                    MouseArea {
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: settings.idleService.respectInhibitors = !settings.idleService.respectInhibitors
                                    }

                                    ParallelAnimation {
                                        id: caffeineSpawn
                                        NumberAnimation {
                                            target: caffeineIndicator
                                            property: "opacity"
                                            to: 1
                                            duration: 300
                                            easing.type: Easing.OutBack
                                        }
                                        NumberAnimation {
                                            target: caffeineIndicator
                                            property: "scale"
                                            to: 1
                                            duration: 300
                                            easing.type: Easing.OutBack
                                        }
                                    }

                                    SequentialAnimation {
                                        id: caffeineDispawn
                                        ParallelAnimation {
                                            NumberAnimation {
                                                target: caffeineIndicator
                                                property: "opacity"
                                                to: 0
                                                duration: 250
                                                easing.type: Easing.InCubic
                                            }
                                            NumberAnimation {
                                                target: caffeineIndicator
                                                property: "scale"
                                                to: 0
                                                duration: 250
                                                easing.type: Easing.InCubic
                                            }
                                        }
                                        PropertyAnimation {
                                            target: caffeineIndicator
                                            property: "visible"
                                            to: false
                                            duration: 1
                                        }
                                    }

                                    onCaffeineChanged: {
                                        if (!caffeine) {
                                            caffeineIndicator.visible = true;
                                            caffeineSpawn.restart();
                                        } else {
                                            caffeineDispawn.restart();
                                        }
                                    }
                                }

                                Workspaces {
                                    bar: barBackground
                                    Layout.alignment: Qt.AlignLeft
                                }
                            }
                        }
                    }

                    // Middle section - TRULY CENTERED
                    WrapperRectangle {
                        id: middleSection
                        color: "transparent"
                        anchors {
                            horizontalCenter: parent.horizontalCenter
                            verticalCenter: parent.verticalCenter
                        }
                        width: parent.width - leftContent.implicitWidth - rightContent.implicitWidth - 200
                        height: parent.height

                        Text {
                            anchors.centerIn: parent
                            text: !NiriService.inOverview ? NiriService.focusedWindowTitle || "" : ""
                            color: Style.textMuted
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter

                            font.pixelSize: Style.fontSize
                            font.family: Style.fontFamily
                            font.weight: Style.fontWeight

                            width: parent.width
                            wrapMode: Text.Wrap
                            elide: Text.ElideRight
                            maximumLineCount: 1
                        }
                    }

                    // Right section
                    RowLayout {
                        id: rightSection
                        anchors {
                            right: parent.right
                            rightMargin: 10
                            verticalCenter: parent.verticalCenter
                        }
                        spacing: 14

                        WrapperRectangle {
                            color: "transparent"
                            Layout.fillHeight: true

                            RowLayout {
                                id: rightContent
                                spacing: 15

                                SysTray {
                                    bar: root_bar
                                    visible: true
                                    Layout.fillWidth: false
                                    Layout.fillHeight: true
                                    Layout.rightMargin: -5
                                }

                                Text {
                                    id: separator
                                    text: "|"
                                    color: Style.textMuted
                                    verticalAlignment: Text.AlignVCenter
                                    horizontalAlignment: Text.AlignHCenter

                                    font.pixelSize: Style.fontSize - 5
                                    font.family: Style.fontFamily
                                    font.weight: Style.fontWeight

                                    Layout.alignment: Qt.AlignLeft
                                    Layout.fillHeight: true
                                    Layout.minimumHeight: parent.height
                                }

                                // audio icon and value
                                RowLayout {
                                    id: audio
                                    WrapperMouseArea {
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        enabled: true
                                        onClicked: {
                                            BarPopupManager.toggleAudioPopup();
                                        }
                                        child: RowLayout {
                                            Text {
                                                text: Audio.icon
                                                font.pixelSize: Style.iconFontSize - 5
                                                font.family: Style.iconFontFamily
                                                font.weight: Style.iconFontWeight + 400

                                                Layout.fillHeight: true
                                                Layout.minimumHeight: parent.height
                                                verticalAlignment: Text.AlignVCenter
                                                color: (Audio.volume > 100) ? Style.red : Style.textMuted
                                            }

                                            Text {
                                                text: parseInt(Audio.volume * 100) + "%"
                                                Layout.fillHeight: true
                                                Layout.minimumHeight: parent.height
                                                verticalAlignment: Text.AlignVCenter
                                                Layout.alignment: Qt.AlignRight

                                                font.pixelSize: 14
                                                font.weight: Style.fontWeight
                                                font.family: Style.fontFamily
                                                color: (Audio.volume > 100) ? Style.red : Style.textMuted
                                            }
                                        }
                                    }
                                }

                                BatteryIcon {
                                    Layout.rightMargin: 31
                                }

                                // ressource usage
                                RowLayout {
                                    id: ressourceUsage
                                    property var color: (memory.text > 95) ? Style.red : Style.textMuted
                                    WrapperMouseArea {
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        enabled: true
                                        onClicked: {
                                            BarPopupManager.toggleRessourcePopup();
                                            // console.log("show ressourceUsage", BarPopupManager.showRessourcePopup);
                                        }
                                        child: RowLayout {
                                            Text {
                                                text: "􀫦"
                                                font.pixelSize: Style.iconFontSize - 5
                                                font.family: Style.iconFontFamily
                                                font.weight: Style.iconFontWeight + 400

                                                Layout.fillHeight: true
                                                Layout.minimumHeight: parent.height
                                                verticalAlignment: Text.AlignVCenter
                                                color: ressourceUsage.color
                                            }

                                            Text {
                                                id: memory
                                                text: parseInt(RessourceUsage.memoryUsedPercentage * 100) + "%"
                                                Layout.fillHeight: true
                                                Layout.minimumHeight: parent.height
                                                verticalAlignment: Text.AlignVCenter
                                                Layout.alignment: Qt.AlignRight

                                                font.pixelSize: 14
                                                font.weight: Style.fontWeight
                                                font.family: Style.fontFamily
                                                color: ressourceUsage.color
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
}
