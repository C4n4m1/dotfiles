import qs.services
import qs.assets
// pragma Singleton

import QtQuick
import Quickshell
import QtQuick.Layouts
import Quickshell.Widgets

Item {
    id: root
    implicitWidth: workspacesLayout.implicitWidth
    implicitHeight: workspacesLayout.implicitHeight

    required property var bar
    property int currentWorkspace: getDisplayActiveWorkspace()
    property var workspaceList: getDisplayWorkspaces()

    function getDisplayWorkspaces() {
        if (!NiriService.niriAvailable || NiriService.allWorkspaces.length === 0)
            return [1, 2];

        if (!root.screenName)
            return NiriService.getCurrentOutputWorkspaceNumbers();

        var displayWorkspaces = [];
        for (var i = 0; i < NiriService.allWorkspaces.length; i++) {
            var ws = NiriService.allWorkspaces[i];
            if (ws.output === root.screenName)
                displayWorkspaces.push(ws.idx + 1);
        }
        return displayWorkspaces.length > 0 ? displayWorkspaces : [1, 2];
    }

    function getDisplayActiveWorkspace() {
        if (!NiriService.niriAvailable || NiriService.allWorkspaces.length === 0)
            return 1;

        if (!root.screenName)
            return NiriService.getCurrentWorkspaceNumber();

            for (var i = 0; i < NiriService.allWorkspaces.length; i++) {
                var ws = NiriService.allWorkspaces[i];
            if (ws.output === root.screenName && ws.is_active)
                if (ws.is_active) {
                    // console.log("active workspace: " + parseInt(ws.idx + 1))
                    return ws.idx + 1;
                }
        }
        return 1;
    }
    // Lire connections
    Connections {
        function onAllWorkspacesChanged() {
            root.workspaceList = root.getDisplayWorkspaces();
            root.currentWorkspace = root.getDisplayActiveWorkspace();
        }

        function onFocusedWorkspaceIndexChanged() {
            root.currentWorkspace = root.getDisplayActiveWorkspace();
        }

        function onNiriAvailableChanged() {
            if (NiriService.niriAvailable) {
                root.workspaceList = root.getDisplayWorkspaces();
                root.currentWorkspace = root.getDisplayActiveWorkspace();
            }
        }

        target: NiriService
    }

    RowLayout {
        id: workspacesLayout

        Repeater {
            model: root.workspaceList

            Rectangle {
                id: workspace
                property int size: 9
                property bool isActive: {
                    var isActive = modelData === root.currentWorkspace;
                    console.log("is active", isActive)
                    return isActive;
                }
                property bool isHovered: mouseArea.containsMouse
                property int sequentialNumber: index + 1
                property bool isPlaceholder: modelData === -1 // ask DankShellMaterial of you have a question about this line
                property var workspaceData: {
                    if (isPlaceholder || !NiriService.niriAvailable)
                        return null;
                    for (var i = 0; i < NiriService.allWorkspaces.length; i++) {
                        var ws = NiriService.allWorkspaces[i];
                        if (ws.idx + 1 === modelData)
                            return ws;
                    }
                    return null;
                }
                // Set explicit size for workspace indicators
                implicitHeight: workspace.isActive && !workspace.isPlaceholder ? workspace.size * 1.2 : workspace.size
                implicitWidth: workspace.isActive && !workspace.isPlaceholder ? workspace.size * 1.5 : workspace.size
                radius: Style.cornerRadius
                border {
                    color: Style.bgDark
                    width: 0
                }
                color: Style.textMuted
                Layout.leftMargin: size * 0.5
                opacity: workspace.isActive && !workspace.isPlaceholder ? 1 : 0.4

                MouseArea {
                    // required property var ws
                    id: mouseArea

                    anchors.fill: parent
                    width: parent.width + size
                    hoverEnabled: !workspace.isPlaceholder
                    cursorShape: workspace.isPlaceholder ? Qt.ArrowCursor : Qt.PointingHandCursor
                    enabled: !workspace.isPlaceholder
                    onClicked: {
                        if (!workspace.isPlaceholder)
                            NiriService.switchToWorkspace(modelData - 1);
                    }

                    // Text {
                    //     text: workspace.isActive && !workspace.isPlaceholder ? "􁷟" : "􁷟"  //"􁅃"
                    //     anchors.fill: parent

                    //     color: Style.textMuted
                    //     verticalAlignment: Text.AlignVCenter
                    //     horizontalAlignment: Text.AlignHCenter

                    //     font.pixelSize: workspace.isActive && !workspace.isPlaceholder ? Style.fontSize - 3 : Style.fontSize - 10
                    //     font.family: Style.iconFontFamily
                    //     font.weight: Style.iconFontWeight

                    //     Layout.alignment: Qt.AlignLeft
                    //     Layout.fillHeight: true
                    //     Layout.minimumHeight: parent.height
                    // }

                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: 150
                    }
                }

                Behavior on implicitWidth {
                    NumberAnimation {
                        duration: 50
                    }
                }

                Behavior on implicitHeight {
                    NumberAnimation {
                        duration: 50
                    }
                }
            }
        }
    }
}
