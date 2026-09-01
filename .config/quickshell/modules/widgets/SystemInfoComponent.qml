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
import QtQuick.Effects

Item {
    id: root
    property var infos: [
        {
            "icon": "",
            "value": "NixOS x86_64"
        },
        {
            "icon": "",
            "value": root.kernel
        },
        {
            "icon": "󱑍",
            "value": "up " + root.uptime
        },
        {
            "icon": "",
            "value": root.shell
        },
    ]
    property string kernel: ""
    property string uptime: ""
    property string shell: ""

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
            // implicitHeight: 155
            anchors.centerIn: parent
            radius: root.radius
            border.width: root.borderSize + 1
            border.color: Style._borderIn
            margin: root.margin

            ColumnLayout {
                implicitHeight: parent.height - root.margin
                Layout.fillWidth: true
                Layout.margins: root.margin
                spacing: -10

                Repeater {
                    model: root.infos
                    RowLayout {
                        required property var modelData
                        Layout.alignment: Qt.AlignVCenter
                        WrapperRectangle {
                            implicitHeight: 15
                            implicitWidth: 14
                            color: "transparent"
                            Layout.rightMargin: modelData.icon == "" ? 6.5 : 10
                            Layout.leftMargin: modelData.icon == "" ? 7 : 5
                            Layout.bottomMargin: -15
                            Text {
                                text: modelData.icon
                                color: "white" //Style.textMuted
                                font.weight: Style.fontWeight + 400
                                font.pixelSize: Style.fontSize
                                font.family: Style.monospaceFont

                                horizontalAlignment: Text.AlignHCenter
                                Layout.alignment: Qt.AlignLeft
                                lineHeight: 0.6
                                // Layout.fillWidth: true
                            }
                        }

                        Text {
                            text: modelData.value
                            color: Style.textMuted
                            horizontalAlignment: Text.AlignLeft
                            verticalAlignment: Text.AlignVCenter
                            font.pixelSize: Style.fontSize
                            font.family: Style.monospaceFont
                            Layout.bottomMargin: -15
                            lineHeight: 0.6
                        }
                    }
                }
            }

            Process {
                id: kernelProcess
                command: ["uname", "-r"]
                running: true
                stdout: StdioCollector {
                    onStreamFinished: {
                        root.kernel = this.text;
                    }
                }
            }

            Timer {
                running: true
                repeat: true
                interval: 1000 * 60
                onTriggered: {
                    uptimeProcess.running = true;
                }
            }

            Process {
                id: uptimeProcess
                command: ["sh","-c",`awk '{print strftime("%Y-%m-%d %H:%M:%S", systime() - $1)}' /proc/uptime`]
                running: true
                stdout: StdioCollector {
                    onStreamFinished: {
                        root.uptime = root.calculateUptime(this.text);
                    }
                }
            }

            Process {
                id: shellProcess
                command: ["fish", "--version"]
                running: true
                stdout: StdioCollector {
                    onStreamFinished: {
                        root.shell = this.text.replace(", version", "");
                    }
                }
            }
        }
    }

    function calculateUptime(bootString) {
        // uptime -s output looks like: 2025-10-24 09:17:12
        const bootTime = new Date(bootString.trim().replace(" ", "T")); // ISO format
        const now = new Date();
        const diffMs = now - bootTime;
        const diffSec = Math.floor(diffMs / 1000);
        const hours = Math.floor(diffSec / 3600);
        const minutes = Math.floor((diffSec % 3600) / 60);

        // You can switch between numeric and formatted:
        // return diffSec.toString() + " sec"
        return hours + "h " + minutes + "m";
    }
}
