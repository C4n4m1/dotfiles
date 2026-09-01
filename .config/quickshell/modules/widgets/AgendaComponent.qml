pragma ComponentBehavior: Bound
import qs.bar
import qs.services
import qs.assets
import qs.modules
import qs.modules.styledControls
import QtQuick
import Quickshell
import QtQuick.Layouts
import Quickshell.Widgets
import Quickshell.Wayland
import QtQuick.Controls
import Quickshell.Io
import QtQuick.Effects

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
        implicitWidth: 450
        implicitHeight: 170
        radius: root.radius
        border.width: 1
        border.color: Style._borderOut
        margin: 0
        // anchors.centerIn: parent
        color: 'transparent'

        WrapperRectangle {
            id: rootBg

            color: Style._bg
            // implicitWidth: 450
            // implicitHeight: 170
            radius: root.radius
            border.width: 2
            border.color: Style._borderIn
            margin: root.margin

            ColumnLayout {
                // implicitHeight: parent.height - root.margin
                // implicitWidth: parent.width - root.margin

                RowLayout {
                    id: row1
                    visible: true
                    Layout.alignment: Qt.AlignTop
                    Layout.fillWidth: true

                    Text {
                        text: Time.date
                        color: Style.textMuted
                        // font.bold: true
                        font.weight: Style.fontWeight
                        font.pixelSize: 22
                        font.family: Style.fontFamily

                        horizontalAlignment: Text.AlignLeft
                        Layout.alignment: Qt.AlignLeft
                        Layout.fillWidth: true
                        // Layout.topMargin: -6
                    }

                    Text {
                        visible: true
                        text: Time.time.slice(11)
                        color: Style.textMuted
                        font.pixelSize: 25
                        font.family: Style.monospaceFont
                        font.weight: Style.fontWeight

                        horizontalAlignment: Text.AlignRight
                        Layout.alignment: Qt.AlignRight
                    }
                }

                ColumnLayout {
                    visible: true
                    Layout.alignment: Qt.AlignTop
                    Layout.fillHeight: true
                    WrapperMouseArea {
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            Agenda.eventsList;
                        }
                        Text {
                            text: "Events"
                            Layout.fillHeight: true
                            color: Style.textMuted
                            font.weight: Style.fontWeight
                            font.pixelSize: 18
                            font.family: Style.fontFamily

                            horizontalAlignment: Text.AlignLeft
                            Layout.alignment: Qt.AlignLeft && Qt.AlignTop
                            verticalAlignment: Text.AlignTop
                            Layout.fillWidth: true
                        }
                    }

                    Text {
                        visible: Agenda.eventsList.length === 0
                        text: "No events scheduled"
                        Layout.fillHeight: true
                        color: Style.textMuted
                        font.weight: Style.fontWeight
                        font.pixelSize: Style.fontSize
                        font.family: Style.fontFamily
                        font.italic: true
                        opacity: 0.8

                        horizontalAlignment: Text.AlignLeft
                        Layout.alignment: Qt.AlignLeft && Qt.AlignTop
                        verticalAlignment: Text.AlignTop
                        Layout.fillWidth: true
                    }

                    Repeater {
                        property int maxEvent: {
                            var nbTasks = Tasks.tasksList.length;
                            if (nbTasks < 3) {
                                if (nbTasks < 2) {
                                    return 4;
                                } else {
                                    return 3;
                                }
                            } else {
                                return 2;
                            }
                        }
                        model: Agenda.eventsList.slice(0, maxEvent)

                        WrapperRectangle {
                            id: eventBg
                            visible: Date.now() < endDate.getTime()
                            required property var modelData
                            property var startDate: {
                                const date = new Date(modelData.start);
                                return date;
                            }

                            property var endDate: {
                                const date = new Date(modelData.end);
                                return date;
                            }
                            color: Style._bgLight
                            Layout.fillWidth: true
                            margin: 10
                            radius: Style.cornerRadius - margin / 2
                            Layout.topMargin: margin / 2
                            implicitHeight: 46

                            ColumnLayout {
                                RowLayout {
                                    Rectangle {
                                        visible: true
                                        implicitHeight: 30
                                        implicitWidth: 8
                                        Layout.bottomMargin: -2
                                        Layout.topMargin: -2
                                        // Layout.leftMargin: -3
                                        // Layout.alignment: Qt.AlignCenter
                                        Layout.rightMargin: eventBg.margin / 2
                                        radius: Style.cornerRadius
                                        color: {
                                            switch (modelData.agenda) {
                                            case "IAI":
                                                return Style.blue;
                                                break;
                                            case "Devoir":
                                                return Style.green;
                                                break;
                                            }
                                        }
                                    }

                                    Text {
                                        text: modelData.label
                                        wrapMode: Text.Wrap
                                        elide: Text.ElideRight
                                        color: Style.textMuted
                                        font.weight: Style.fontWeight
                                        font.pixelSize: Style.fontSize + 0
                                        font.family: Style.fontFamily
                                        Layout.fillHeight: true

                                        horizontalAlignment: Text.AlignLeft
                                        verticalAlignment: Text.AlignVCenter
                                        Layout.alignment: Qt.AlignLeft
                                        Layout.fillWidth: true
                                    }

                                    Text {
                                        text: {
                                            const now = new Date();
                                            if (now.getDate() == startDate.getDate()) {
                                                return "today  " + String(startDate.getHours()).padStart(2, '0') + ":" + String(startDate.getMinutes()).padStart(2, '0') + " - " + String(endDate.getHours()).padStart(2, '0') + ":" + String(endDate.getMinutes()).padStart(2, '0');
                                            } else {
                                                const days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
                                                if ((startDate.getDate() - now.getDate()) < 7) {
                                                    return days[startDate.getDay()].slice(0, 3) + "  " + String(startDate.getHours()).padStart(2, '0') + ":" + String(startDate.getMinutes()).padStart(2, '0') + " - " + String(endDate.getHours()).padStart(2, '0') + ":" + String(endDate.getMinutes()).padStart(2, '0');
                                                } else {
                                                    return String(startDate.getDate()).padStart(2, '0') + startDate.getMonth() + "  " + String(startDate.getHours()).padStart(2, '0') + ":" + String(startDate.getMinutes()).padStart(2, '0') + " - " + String(endDate.getHours()).padStart(2, '0') + ":" + String(endDate.getMinutes()).padStart(2, '0');
                                                }
                                            }
                                        }
                                        color: Style.textMuted
                                        font.weight: Style.fontWeight
                                        font.pixelSize: Style.fontSize - 1
                                        font.family: Style.fontFamily
                                        Layout.fillHeight: true

                                        horizontalAlignment: Text.AlignRight
                                        Layout.alignment: Qt.AlignRight
                                        Layout.fillWidth: true
                                        verticalAlignment: Text.AlignVCenter
                                        opacity: 0.6
                                    }
                                }

                                Text {
                                    visible: modelData.description !== ""
                                    wrapMode: Text.Wrap
                                    elide: Text.ElideRight
                                    text: modelData.description
                                    color: Style.textMuted
                                    font.weight: Style.fontWeight
                                    font.pixelSize: Style.fontSize + 0
                                    font.family: Style.fontFamily
                                    Layout.fillHeight: true

                                    horizontalAlignment: Text.AlignLeft
                                    Layout.alignment: Qt.AlignLeft
                                    Layout.fillWidth: true
                                }
                            }
                        }
                    }
                }

                ColumnLayout {
                    id: tasks
                    visible: true
                    Layout.alignment: Qt.AlignTop
                    Layout.topMargin: Tasks.tasksList.length === 0 ? 10 : 0
                    Layout.fillHeight: true
                    // Layout.topMargin: root.margin
                    WrapperMouseArea {
                        hoverEnabled: true
                        onClicked:
                        // console.log(Tasks.tasksList);
                        {}
                        Text {
                            text: "Tasks"
                            Layout.fillHeight: true
                            color: Style.textMuted
                            font.weight: Style.fontWeight
                            font.pixelSize: 18
                            font.family: Style.fontFamily

                            horizontalAlignment: Text.AlignLeft
                            Layout.alignment: Qt.AlignLeft && Qt.AlignTop
                            verticalAlignment: Text.AlignTop
                            // Layout.topMargin: root.margin
                            Layout.fillWidth: true
                        }
                    }

                    Text {
                        visible: Tasks.tasksList.length === 0
                        text: "No remaining tasks"
                        Layout.fillHeight: true
                        color: Style.textMuted
                        font.weight: Style.fontWeight
                        font.pixelSize: Style.fontSize
                        font.family: Style.fontFamily
                        font.italic: true
                        opacity: 0.8

                        horizontalAlignment: Text.AlignLeft
                        Layout.alignment: Qt.AlignLeft && Qt.AlignTop
                        verticalAlignment: Text.AlignTop
                        Layout.fillWidth: true
                    }

                    Repeater {
                        model: Tasks.tasksList.slice(0, 4)

                        WrapperRectangle {
                            id: taskBg
                            required property var modelData
                            color: Style._bgLight
                            Layout.fillWidth: true
                            margin: 10
                            radius: Style.cornerRadius - margin / 2
                            Layout.topMargin: margin / 2
                            implicitHeight: 36
                            // border.color: Qt.rgba(0.5, 0.5, 0.5, 0.40)

                            ColumnLayout {

                                RowLayout {
                                    WrapperMouseArea {
                                        id: checkbox
                                        property bool isDone: false
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            Tasks.validateTask(modelData.id);
                                            isDone = true;
                                        }
                                        WrapperRectangle {
                                            visible: true
                                            implicitHeight: 18
                                            implicitWidth: 20
                                            Layout.alignment: Qt.AlignLeft
                                            Layout.rightMargin: taskBg.margin * 0.3
                                            radius: 5
                                            color: Style._bgDark
                                            border.color: Style.bgDark
                                            border.width: 1

                                            Text {
                                                text: !checkbox.isDone ? "" : "􀆅"
                                                color: Style.textMuted
                                                font.family: Style.iconFontFamily
                                                font.pixelSize: Style.fontSize
                                                font.bold: true
                                                // Layout.bottomMargin: 10
                                                // horizontalAlignment: Text.AlignLeft
                                                // verticalAlignment: Text.AlignVCenter
                                            }
                                        }

                                        // Text {
                                        //     text: !CheckBox.checked ? "􀂓" : "􀃳"
                                        //     color: CheckBox.checked ? Style.textMuted : Style._bg
                                        //     font.family: Style.iconFontFamily
                                        //     font.pixelSize: Style.fontSize + 9
                                        //     // Layout.bottomMargin: 10
                                        //     horizontalAlignment: Text.AlignLeft
                                        //     verticalAlignment: Text.AlignVCenter
                                        // }
                                    }

                                    Text {
                                        text: modelData.label
                                        wrapMode: Text.Wrap
                                        elide: Text.ElideRight
                                        color: Style.textMuted
                                        font.weight: Style.fontWeight
                                        font.strikeout: checkbox.checked
                                        font.pixelSize: Style.fontSize
                                        font.family: Style.fontFamily
                                        Layout.fillHeight: true

                                        horizontalAlignment: Text.AlignLeft
                                        verticalAlignment: Text.AlignVCenter
                                        Layout.alignment: Qt.AlignLeft
                                        Layout.margins: taskBg.margin / 2
                                        // Layout.fillWidth: true
                                    }

                                    WrapperRectangle {
                                        visible: true
                                        implicitHeight: 18
                                        implicitWidth: 22
                                        Layout.alignment: Qt.AlignLeft
                                        Layout.rightMargin: taskBg.margin / 2
                                        radius: 5
                                        opacity: 0.8
                                        // color: Style._bg
                                        color: {
                                            switch (modelData.priority) {
                                            case 1:
                                                return "transparent";
                                            case 2:
                                                return Style.yellow;
                                            case 3:
                                                return Style.orange;
                                            case 4:
                                                return Style.red;
                                            default:
                                                return Style._bgLight;
                                            }
                                        }

                                        Text {
                                            text: {
                                                switch (modelData.priority) {
                                                case 2:
                                                    return "P3";
                                                case 3:
                                                    return "P2";
                                                case 4:
                                                    return "P1";
                                                }
                                            }
                                            color: Style._bg
                                            // font.weight: Style.fontWeight
                                            font.pixelSize: Style.fontSize - 2
                                            font.family: Style.fontFamily
                                            Layout.fillHeight: true
                                            font.bold: true

                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                            Layout.alignment: Qt.AlignLeft
                                            // Layout.fillWidth: true
                                        }
                                    }

                                    Text {
                                        visible: modelData.due !== null
                                        text: modelData.due.string ?? ""
                                        color: Style.textMuted
                                        font.weight: Style.fontWeight
                                        font.pixelSize: Style.fontSize - 1
                                        font.family: Style.fontFamily
                                        Layout.fillHeight: true

                                        horizontalAlignment: Text.AlignRight
                                        Layout.alignment: Qt.AlignRight
                                        Layout.fillWidth: true
                                        opacity: 0.6
                                    }
                                }

                                Text {
                                    visible: false
                                    // visible: modelData.description !== ""
                                    wrapMode: Text.Wrap
                                    elide: Text.ElideRight
                                    text: modelData.description
                                    color: Style.textMuted
                                    font.weight: Style.fontWeight
                                    font.pixelSize: Style.fontSize
                                    font.family: Style.fontFamily
                                    Layout.fillHeight: true

                                    horizontalAlignment: Text.AlignLeft
                                    verticalAlignment: Text.AlignVCenter
                                    Layout.alignment: Qt.AlignLeft
                                    Layout.fillWidth: true
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
