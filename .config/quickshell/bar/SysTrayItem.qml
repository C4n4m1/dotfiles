import qs.assets
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import Qt5Compat.GraphicalEffects

MouseArea {
    id: root

    required property var bar
    required property SystemTrayItem item
    property int nbItems: SystemTray.items.values.length

    acceptedButtons: Qt.LeftButton | Qt.RightButton
    Layout.fillHeight: true
    implicitWidth: Style.iconFontSize + 4
    onClicked: event => {
        // console.log(item.title);
        switch (event.button) {
        case Qt.LeftButton:
            if (item.hasMenu)
                menu.open();
            // console.log("[ SystemTrayItem ] : mouse position", root.mouseX);
            // console.log("[ SystemTrayItem ] : nb items", root.nbItems);
            break;
        case Qt.RightButton:
            item.activate();
            break;
        }
        event.accepted = true;
    }

    QsMenuAnchor {
        id: menu

        menu: root.item.menu
        anchor.window: bar
        anchor.rect.x: 1659 - ( ( root.nbItems * 45 )  - root.mouseX)
        anchor.rect.y: root.y + 20
        anchor.rect.height: root.height
        anchor.edges: Edges.Bottom
    }

    IconImage {
        id: trayIcon
        visible: true
        anchors.centerIn: parent
        width: {
            var w = 17;
            switch (root.item.title) {
            case "Network":
                w = 22;
                break;
            case "blueman":
                w = 19;
                break;
            }
            return w;
        }
        height: width
        opacity: root.containsMouse ? 0.7 : 1.0

        // Handle Spotify and other problematic icons
        source: {
            let iconPath = root.item.icon;

            // Clean up problematic paths
            if (iconPath.includes("spotify")) {
                return Quickshell.iconPath("spotify-launcher");
            }

            return iconPath;
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 150
            }
        }
    }

    Loader {
        active: true
        anchors.fill: trayIcon
        sourceComponent: Item {
            Desaturate {
                id: desaturatedIcon
                visible: true // There's already color overlay
                anchors.fill: parent
                source: trayIcon
                desaturation: 1 // 1.0 means fully grayscale
            }
            //         ColorOverlay {
            //             anchors.fill: desaturatedIcon
            //             source: desaturatedIcon
            //             color: ColorUtils.transparentize(Appearance.colors.colOnLayer0, 0.6)
            //         }
        }
    }
}
