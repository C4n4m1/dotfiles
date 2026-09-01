import QtQuick
import QtQuick.Layouts
import Quickshell.Services.SystemTray
import Quickshell.Wayland
import Quickshell.Widgets

Item {
    id: root

    property list<string> exception: ["Network", "blueman"]
    required property var bar

    height: parent.height
    implicitWidth: rowLayout.implicitWidth

    RowLayout {
        id: rowLayout

        anchors.fill: parent
        spacing: 5

        Repeater {
            model: SystemTray.items

            SysTrayItem {
                required property SystemTrayItem modelData

                bar: root.bar
                item: modelData
                visible: !root.exception.includes(modelData.title)
            }
        }

        Repeater {
            model: SystemTray.items

            SysTrayItem {
                required property SystemTrayItem modelData

                bar: root.bar
                item: modelData
                Layout.topMargin: {
                    var margin = 0;
                    switch (modelData.title) {
                    case "Network":
                        margin = -2;
                        break;
                    case "blueman":
                        margin = 0;
                        break;
                    }
                    return margin;
                }
                visible: root.exception.includes(modelData.title)
            }
        }
    }
}
