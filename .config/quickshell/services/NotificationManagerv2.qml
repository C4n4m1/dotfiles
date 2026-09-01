pragma ComponentBehavior: Bound
import Quickshell.Services.Notifications

import qs.assets
import qs.services
import qs.bar

import QtQuick
import Quickshell
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Effects
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
    property int notifSpacing: 5
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
        actionsSupported: true
        actionIconsSupported: false
        bodyHyperlinksSupported: true
        bodyImagesSupported: true
        bodyMarkupSupported: true
        imageSupported: true
        inlineReplySupported: false
        persistenceSupported: true

        onNotification: notif => {
            notif.tracked = true;
            root.notifCount++;
            if (notifCount == 1) {
                firstNotifAnim.restart();
            }
        }
    }

    PanelWindow {
        id: notifsWindow
        // visible: ( root.notifCount > 0 ) && !Settings.dnd
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
            right: 0
        }
        implicitHeight: 1080
        implicitWidth: root.notifCount <= 0 ? 0 : root.notifWidth + 13

        mask: Region {
            item: listview.contentItem
        }

        // Wrapper Item applies left margin so ListView layout/transitions are unaffected
        // Item {
        //     id: listViewWrapper
        //     anchors.fill: parent
        //     anchors.leftMargin: 7

        ListView {
            id: listview
            anchors.fill: parent
            model: root.notifs
            anchors.leftMargin: 7
            spacing: root.notifSpacing
            visible: (root.notifCount > 0) && !Settings.dnd

            add: Transition {
                NumberAnimation {
                    target: notifRoot
                    property: "x"
                    from: notifRoot.width
                    to: 0
                    duration: 300
                    easing.type: Easing.OutCubic
                }
                NumberAnimation {
                    target: notifRoot
                    property: "scale"
                    to: 1
                    duration: 500
                    // easing.type: Easing.OutCubic
                    easing.type: Easing.OutBack
                    easing.overshoot: 1.5
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
                NumberAnimation {
                    property: "opacity"
                    to: 0
                    duration: 200
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
                required property Notification modelData
                required property int index
                property list<NotificationAction> notifActions: modelData.actions
                // those variables hold the current state of the value during the remove animation
                // exiting → we are running the remove animation
                // pending[ var ] → values of the parameters of the running remove animation fn
                property bool exiting: false
                property bool pendingExpire: false
                property bool pendingInvokeIfPossible: false
                transform: Translate {
                    id: translate
                }
                x: notifRoot.width
                scale: 0.8
                visible: true

                function removeWithAnimation(expire, invokeIfPossible) {
                    // parameters say what to do after remove animation ( expire or invoke notif action if exists )
                    if (notifRoot.exiting)
                        return;
                    notifRoot.pendingExpire = expire;
                    notifRoot.pendingInvokeIfPossible = invokeIfPossible;
                    notifRoot.exiting = true;
                    exitAnim.restart();
                }

                ParallelAnimation {
                    id: exitAnim
                    NumberAnimation {
                        target: notifRoot
                        property: "opacity"
                        to: 0
                        duration: 100
                    }
                    NumberAnimation {
                        target: notifRoot
                        property: "x"
                        to: notifRoot.width
                        duration: 100
                        easing.type: Easing.InCubic
                    }
                    onStopped: {
                        if (notifRoot.pendingExpire)
                            notifRoot.modelData.expire();
                        else if (notifRoot.pendingInvokeIfPossible && notifRoot.notifActions.length > 0)
                            notifRoot.notifActions[0].invoke();
                        else
                            notifRoot.modelData.dismiss();
                        notifRoot.modelData.tracked = false;
                        root.notifCount -= 1;
                    }
                }

                Component.onCompleted: {
                    // ListView add transition often doesn't run for the first item; run it manually
                    if (index === 0 && root.notifCount === 1) {
                        notifRoot.x = notifRoot.width;
                        notifRoot.opacity = 0;
                        root.firstNotifAnimTarget = notifRoot;
                        root.firstNotifAnim.restart();
                    }
                }
                implicitHeight: root.notifHeight + 5
                implicitWidth: root.notifWidth
                color: "transparent"
                radius: root.notifRadius
                // margin: 5

                RectangularShadow {
                    id: notifShadow
                    visible: true
                    // z: 0
                    anchors.fill: notifBody
                    radius: root.notifRadius
                    color: Qt.rgba(0, 0, 0, 0.45)
                    offset: Qt.point(0, 4)
                    blur: 5
                    spread: 3
                }

                Rectangle {
                    id: notifBody
                    // x: notifRoot.width
                    visible: true
                    implicitHeight: root.notifHeight
                    implicitWidth: root.notifWidth
                    color: Style.bg
                    border.color: Qt.lighter(Style.borderMuted, 1.2)
                    border.width: 1.3
                    radius: root.notifRadius
                    // anchors.fill: parent

                    MouseArea {
                        id: notifMouseArea
                        anchors.fill: parent
                        onClicked: event => {
                            switch (event.button) {
                            case Qt.LeftButton:
                                notifRoot.removeWithAnimation(false, true);  // invoke if possible else dismiss
                                break;
                            case Qt.RightButton:
                                notifRoot.removeWithAnimation(false, false); // dismiss only
                                break;
                            }
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
                            implicitSize: 20
                            Layout.alignment: Qt.AlignTop
                            Layout.margins: 10
                        }

                        Rectangle {
                            visible: notifRoot.modelData.image != ""
                            implicitHeight: 45//63
                            implicitWidth: 45//63
                            Layout.alignment: Qt.AlignLeft
                            Layout.margins: 10
                            color: Style.bg
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
                                        color: modelData.urgency == NotificationUrgency.Critical ? Style.red : Style.text
                                        verticalAlignment: Text.AlignTop
                                        horizontalAlignment: Text.AlignLeft

                                        font.pixelSize: Style.fontSize - 1
                                        font.family: Style.fontFamily
                                        // font.weight: Style.fontWeight

                                        Layout.alignment: Qt.AlignTop && Qt.AlignLeft
                                        // Layout.fillHeight: true
                                        Layout.leftMargin: notifRoot.modelData.appIcon == "" ? 0 : -3
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
                                    Layout.leftMargin: {
                                        if (notifRoot.modelData.appName == "Spotify") {
                                            10;
                                        } else {
                                            notifRoot.modelData.appIcon == "" ? 0 : -3;
                                        }
                                    }
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
                        onTriggered: notifRoot.removeWithAnimation(true, false)  // expire
                    }
                }
            }
            // }
        }
    }

    // First-item add animation (ListView add transition often doesn't run for the first item)
    property Item firstNotifAnimTarget: null
    ParallelAnimation {
        id: firstNotifAnim
        onStopped: root.firstNotifAnimTarget = null
        NumberAnimation {
            target: root.firstNotifAnimTarget
            property: "x"
            from: root.firstNotifAnimTarget ? root.firstNotifAnimTarget.width / 4 : 0
            to: 0
            duration: 300
            easing.type: Easing.OutCubic
        }
        NumberAnimation {
            target: root.firstNotifAnimTarget
            property: "scale"
            to: 1
            duration: 500
            easing.type: Easing.OutBack
            easing.overshoot: 1.2
        }
        NumberAnimation {
            target: root.firstNotifAnimTarget
            property: "opacity"
            from: 0
            to: 1
            duration: 300
        }
    }
}
