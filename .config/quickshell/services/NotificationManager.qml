pragma ComponentBehavior: Bound
import Quickshell.Services.Notifications

import qs.assets
import qs.services
import qs.bar

import QtQuick
import Quickshell
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell.Wayland
import Quickshell.Widgets
import Quickshell.Io
import Qt5Compat.GraphicalEffects

Scope {
    id: root
    property var notifs: notifServer.trackedNotifications
    property int notifCount: 0 // notifs.values.length
    property int notifWidth: 400
    property int notifHeight: 85
    property int notifSpacing: 10
    property int notifRadius: Style.cornerRadius

    function panelWindowHeigth() {
        if (root.notifCount <= 0) {
            return 0;
        } else if (root.notifCount == 1) {
            return root.notifHeight;
        } else {
            return root.notifCount * root.notifHeight + (root.notifCount - 1) * root.notifSpacing;
        }
    }

    function notif_y() {
        if (root.notifCount <= 1) {
            return 0;
        } else {
            return root.notifCount * root.notifHeight + (root.notifCount - 1) * root.notifSpacing;
        }
    }

    NotificationServer {
        id: notifServer

        keepOnReload: true
        actionsSupported: false
        actionIconsSupported: false
        bodyHyperlinksSupported: true
        bodyImagesSupported: true
        bodyMarkupSupported: true
        imageSupported: true
        // inlineReplySupported: false
        persistenceSupported: true

        onNotification: notif => {
            notif.tracked = true;
            root.notifCount++;
        }
    }

    PanelWindow {
        id: notifsWindow
        visible: root.notifCount > 0
        color: "transparent"
        WlrLayershell.namespace: "quickshell:notifications"
        exclusionMode: ExclusionMode.Ignore
        anchors {
            top: true
            left: false
            right: true
            bottom: false
        }
        margins {
            top: 40
            right: 6
            left: 6
        }
        implicitHeight: 1080
        implicitWidth: root.notifCount <= 0 ? 0 : root.notifWidth

        mask: Region {
            item: listview.contentItem
        }

        ListView {
            id: listview
            anchors.fill: parent
            model: root.notifs
            spacing: root.notifSpacing

            add: Transition {
                NumberAnimation {
                    target: translate
                    property: "x"
                    from: notifRoot.width / 4
                    to: 0
                    duration: 300
                    easing.type: Easing.OutCubic
                }
                NumberAnimation {
                    target: notifRoot
                    property: "opacity"
                    from: 0
                    to: 1
                    duration: 300
                }
            }

            remove: Transition {
                SequentialAnimation {
                    PropertyAction {
                        property: "listView.delayRemove"
                        value: true
                    }
                    ParallelAnimation {
                        NumberAnimation {
                            property: "opacity"
                            to: 0
                            duration: 300
                        }
                        NumberAnimation {
                            property: "x"
                            to: 400
                            duration: 300
                            easing.type: Easing.InCubic
                        }
                    }
                    PropertyAction {
                        property: "listView.delayRemove"
                        value: false
                    }
                }
            }

            displaced: Transition {
                // Animate items moving to new positions
                NumberAnimation {
                    properties: "y"
                    duration: 300
                    easing.type: Easing.OutCubic
                }
            }

            delegate: Rectangle {
                id: notifRoot
                transform: Translate {
                    id: translate
                }
                x: notifRoot.width
                required property Notification modelData
                visible: true
                implicitHeight: root.notifHeight
                implicitWidth: root.notifWidth
                // color: Style.bg
                // border.color: Style.borderMuted
                color: Style.bgLight
                border.color: Style.border
                border.width: 1.3
                radius: root.notifRadius

                // anchors.fill: parent

                MouseArea {
                    id: notifMouseArea
                    anchors.fill: parent
                    onClicked: {
                        notifRoot.modelData.tracked = false;
                        root.notifCount -= 1;
                    }
                }

                RowLayout {
                    implicitWidth: parent.width
                    implicitHeight: parent.height
                    anchors.fill: parent
                    spacing: 2

                    IconImage {
                        id: notificon
                        visible: notifRoot.modelData.image == "" && notifRoot.modelData.appIcon != ""
                        source: Quickshell.iconPath(notifRoot.modelData.appIcon, "/home/credo/.local/share/icons/WhiteSur-dark/actions/24/preferences-desktop-notification-bell.svg")
                        implicitSize: 30
                        Layout.alignment: Qt.AlignTop
                        Layout.margins: 10
                    }

                    Rectangle {
                        visible: notifRoot.modelData.image != ""
                        implicitHeight: 45//63
                        implicitWidth: 45//63
                        Layout.alignment: Qt.AlignLeft
                        Layout.margins: 10
                        color: Style.bgLight
                        Image {
                            id: notifImage
                            anchors.fill: parent
                            visible: notifRoot.modelData.image != ""
                            source: notifRoot.modelData.image

                            layer.enabled: true
                            layer.effect: OpacityMask {
                                maskSource: Rectangle {
                                    width: notifImage.width
                                    height: notifImage.height
                                    radius: root.notifRadius - 8
                                }
                            }
                        }
                    }

                    ColumnLayout {
                        // Layout.fillWidth: true
                        // Layout.fillHeight: true
                        implicitWidth: parent.width
                        implicitHeight: parent.height
                        Layout.margins: 10
                        RowLayout {
                            Layout.fillWidth: true
                            // Layout.fillHeight: true
                            implicitWidth: parent.width
                            // implicitHeight: parent.height
                            Layout.leftMargin: -10
                            Layout.alignment: Qt.AlignTop
                            RowLayout {
                                Layout.alignment: Qt.AlignLeft
                                Layout.fillWidth: true
                                Text {
                                    text: notifRoot.modelData.appName
                                    color: Style.text
                                    verticalAlignment: Text.AlignTop
                                    horizontalAlignment: Text.AlignLeft

                                    font.pixelSize: Style.fontSize - 1
                                    font.family: Style.fontFamily
                                    // font.weight: Style.fontWeight

                                    Layout.alignment: Qt.AlignTop && Qt.AlignLeft
                                    // Layout.fillHeight: true
                                    Layout.leftMargin: notifRoot.modelData.appIcon == "" ? 19 : 0
                                }
                            }

                            RowLayout {
                                Layout.alignment: Qt.AlignRight
                                Layout.fillWidth: true
                                Text {
                                    text: ""
                                    color: Style.textMuted
                                    verticalAlignment: Text.AlignTop
                                    horizontalAlignment: Text.AlignRight

                                    font.pixelSize: Style.fontSize - 2
                                    font.family: Style.fontFamily
                                    // font.weight: Style.fontWeight

                                    Layout.alignment: Qt.AlignRight
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    // Layout.minimumHeight: parent.height

                                    Component.onCompleted: {
                                        text = Time.time.slice(11);
                                    }
                                }
                            }
                        }
                        RowLayout {
                            implicitHeight: parent.height
                            Layout.fillHeight: true
                            Layout.leftMargin: -10

                            Text {
                                text: notifRoot.modelData.body || ""
                                // text: {
                                //     function truncate(str, maxLength) {
                                //         return str.length > maxLength ? str.slice(0, maxLength) + "..." : str;
                                //     }
                                //     truncate(notifRoot.modelData.body || "", 120);
                                // }
                                // text: notifRoot.modelData.body
                                color: Style.textMuted
                                wrapMode: Text.Wrap
                                elide: Text.ElideRight

                                font.pixelSize: Style.fontSize - 1
                                font.family: Style.fontFamily
                                // font.weight: Style.fontWeight

                                verticalAlignment: Text.AlignTop
                                horizontalAlignment: Text.AlignLeft
                                Layout.alignment: Qt.AlignLeft
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                Layout.leftMargin: notifRoot.modelData.appName == "Spotify" ? 10 : 0
                            }
                        }
                    }
                }

                Component.onCompleted: {
                    notifTimer.start();
                }
                Timer {
                    id: notifTimer
                    interval: {
                        var timeOut = 0;
                        if (notifRoot.modelData.expireTimout == null) {
                            timeOut = 6000;
                        } else {
                            timeOut = notifRoot.modelData.expireTimout;
                        }
                        return timeOut;
                    }
                    repeat: false
                    onTriggered: {
                        notifRoot.modelData.tracked = false;
                        root.notifCount -= 1;
                    }
                }
            }
        }
    }
}
