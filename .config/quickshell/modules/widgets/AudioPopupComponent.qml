pragma ComponentBehavior: Bound
import qs.bar
import qs.services
import qs.assets
import QtQuick.Effects
import qs.modules
import qs.modules.styledControls
import QtQuick
import QtQuick.Controls
import Quickshell
import QtQuick.Layouts
import Quickshell.Widgets
import Quickshell.Wayland
import Quickshell.Services.Mpris
import Quickshell.Services.Pipewire
import Quickshell.Io

Item {
    id: root
    property bool debugMode: false
    property bool hasPopup: true
    property int imageSize: root.playerHeight - (root.margin * 2) - (2 * root.borderSize)
    property int controlSize: 24
    property var player: MprisService.activePlayer
    property int playerWidth: 480
    property int playerHeight: 175
    property real fontSize: 14
    property int playerArtistLenght: 0

    property int radius: Style.cornerRadius - 5
    property int borderSize: Style.borderSize
    property color borderColor: Style.borderMuted
    property int margin: 9

    RectangularShadow {
        id: shadow
        z: -1
        visible: true
        anchors.fill: rootbgwrapper
        radius: rootbgwrapper.radius
        color: Style.ctrlCenterShadow.color
        offset: Style.ctrlCenterShadow.offset
        blur: Style.ctrlCenterShadow.blur
        spread: Style.ctrlCenterShadow.spread
        scale: rootbgwrapper.scale
    }

    WrapperRectangle {
        id: rootbgwrapper
        implicitWidth: root.playerWidth
        implicitHeight: root.playerHeight
        radius: root.radius
        border.width: 1
        border.color: Style._borderOut
        margin: 0
        // anchors.centerIn: parent
        color: 'transparent'

        WrapperRectangle {
            id: rootBg
            color: Style._bg
            // implicitWidth: playerWidth
            // implicitHeight: sourceSelect.visible ? (playerHeight + sourceSelect.height + 2 * margin) : playerHeight

            radius: root.radius
            border.width: root.borderSize + 1
            border.color: Style._borderIn
            margin: root.margin
            anchors.centerIn: parent

            WrapperRectangle {
                id: mediaPlayer
                color: "transparent" //Style._bgLight
                radius: Style.cornerRadius - 5
                border.width: 0 //Style.borderSize
                border.color: Style.borderMuted
                margin: 0

                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignCenter
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: root.margin

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: root.margin

                        Item {
                            Layout.preferredWidth: root.imageSize
                            Layout.fillHeight: true
                            RectangularShadow {
                                id: osdShadow
                                z: -1
                                visible: MprisService.activePlayer != null
                                anchors.fill: imageWrapper
                                radius: osdBackground.radius
                                color: Qt.rgba(0, 0, 0, 0.7)
                                offset: Qt.point(0, 5)
                                blur: 13
                                spread: 1.3
                                scale: osdBackground.scale
                            }
                            ClippingWrapperRectangle {
                                id: imageWrapper
                                anchors.centerIn: parent
                                property real aspect: (audioCover.implicitWidth > 0 && audioCover.implicitHeight > 0) ? (audioCover.implicitWidth / audioCover.implicitHeight) : 1.0

                                implicitWidth: aspect >= 1 ? root.imageSize : root.imageSize * aspect
                                implicitHeight: aspect <= 1 ? root.imageSize : root.imageSize / aspect
                                radius: Style.cornerRadius - 5

                                color: Style._bgLight

                                Image {
                                    id: audioCover
                                    width: root.imageSize
                                    anchors.centerIn: parent
                                    height: root.imageSize
                                    visible: MprisService.activePlayer != null
                                    source: MprisService.activePlayer?.trackArtUrl
                                    fillMode: Image.PreserveAspectFit
                                }
                            }
                        }

                        ColumnLayout {
                            Layout.alignment: Qt.AlignTop
                            // Layout.margins: root.margin * 0.2
                            RowLayout {
                                Layout.alignment: Qt.AlignTop
                                spacing: root.margin
                                ColumnLayout {
                                    Layout.fillHeight: true

                                    MarqueeText {
                                        // with this setup font family and size 33 characters are needed to fill a rectangle of width 270
                                        visible: true
                                        text: (MprisService.activePlayer == null || player.trackTitle == "") ? "_ _" : MprisService.activePlayer.trackTitle
                                        textColor: Style.textMuted
                                        Layout.alignment: Qt.AlignTop
                                        weight: 600
                                        pixelSize: root.fontSize - 1
                                        Layout.fillWidth: true
                                        // width: 300
                                        // color: "salmon"
                                        height: 16
                                        spacing: 20
                                        pauseDuration: 3000
                                    }
                                    MarqueeText {
                                        text: (MprisService.activePlayer == null || player.trackTitle == "") ? "_" : MprisService.activePlayer.trackArtist
                                        textColor: Style.textMuted
                                        Layout.alignment: Qt.AlignTop
                                        weight: 600
                                        pixelSize: root.fontSize - 2
                                        Layout.fillWidth: true
                                        // width: 300
                                        // color: "salmon"
                                        height: 16
                                        spacing: 20
                                        pauseDuration: 5000
                                        opacity: 0.7
                                    }
                                }

                                WrapperRectangle {
                                    id: audioSource
                                    visible: false
                                    // Layout.fillWidth: true
                                    color: sourceSelect.visible ? Style.textMuted : Style._bgLight
                                    implicitHeight: 30
                                    implicitWidth: 30
                                    margin: 0
                                    radius: Style.cornerRadius
                                    Layout.alignment: Qt.AlignTop

                                    Text {
                                        text: Audio.outputIcon(Audio.sink?.description)
                                        font.pixelSize: Style.iconFontSize - 4
                                        font.family: Style.iconFontFamily
                                        font.weight: Style.iconFontWeight + 400
                                        opacity: 0.8

                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                        color: sourceSelect.visible ? Style._bg : Style.textMuted

                                        MouseArea {
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                sourceSelect.visible = !sourceSelect.visible;
                                                // console.log("audio outputs", Audio.outputs.map(item => item.name));
                                            }
                                        }
                                    }
                                }

                                RowLayout {
                                    id: waveform
                                    Repeater {
                                        model: Cava.array.length
                                        Rectangle {
                                            required property int index
                                            width: 2
                                            height: {
                                                const rawLevel = Cava.array[index] || 0;
                                                const scaledLevel = Math.sqrt(Math.min(Math.max(rawLevel, 0), 100) / 100) * 100;
                                                const minHeight = width;
                                                const maxHeight = 35;
                                                const height = Math.max(minHeight, Math.min(maxHeight, scaledLevel));
                                                return minHeight + (scaledLevel / 100) * (maxHeight - minHeight);
                                            }
                                            color: Style.textMuted
                                            anchors.verticalCenter: parent.verticalCenter
                                            radius: Style.cornerRadius
                                            Layout.leftMargin: -2

                                            Behavior on height {
                                                NumberAnimation {
                                                    duration: 200
                                                    easing.type: Easing.InOutQuad
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            Item {
                                Layout.fillHeight: true
                            }

                            // Controls
                            RowLayout {
                                id: controls
                                // Layout.topMargin: 20
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignVCenter

                                // Shuffle button

                                Item {
                                    Layout.fillWidth: true
                                }

                                RowLayout {
                                    spacing: 20 * rootBg.implicitWidth / 480
                                    // Previous button
                                    Text {
                                        Layout.alignment: Qt.AlignLeft
                                        text: "􀊝"
                                        color: Style.highlight
                                        font.pixelSize: root.controlSize * 0.7
                                        // Layout.leftMargin: root.margin * 2
                                        font.family: Style.iconFontFamily
                                        font.weight: shuffle.checked ? 800 : 600
                                        opacity: shuffle.checked ? 1 : 0.5
                                        MouseArea {
                                            id: shuffle
                                            property bool checked: {
                                                if (MprisService.activePlayer?.canControl && MprisService.activePlayer.shuffleSupported) {
                                                    return MprisService.activePlayer.shuffle;
                                                } else {
                                                    return false;
                                                }
                                            }
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                if (MprisService.activePlayer.canControl && MprisService.activePlayer.shuffleSupported) {
                                                    MprisService.activePlayer.shuffle = !MprisService.activePlayer.shuffle;
                                                }
                                            }
                                        }
                                    }
                                    Text {
                                        text: "􀊊" // previous
                                        color: Style.highlight
                                        font.pixelSize: root.controlSize
                                        font.family: Style.iconFontFamily
                                        MouseArea {
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                MprisService.activePlayer.previous();
                                            }
                                        }
                                    }

                                    // Play/Pause button
                                    Text {
                                        text: !playPause.clicked ? "􀊄" : "􀊆"
                                        color: Style.highlight
                                        font.pixelSize: root.controlSize * 1.4
                                        font.family: Style.iconFontFamily
                                        MouseArea {
                                            id: playPause
                                            property bool clicked: MprisService.activePlayer?.isPlaying
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                MprisService.activePlayer.togglePlaying();
                                            }
                                        }
                                    }

                                    // Next button
                                    Text {
                                        text: "􀊌" // next
                                        color: Style.highlight
                                        font.pixelSize: root.controlSize
                                        font.family: Style.iconFontFamily
                                        MouseArea {
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                MprisService.activePlayer.next();
                                            }
                                        }
                                    }

                                    Text {
                                        Layout.alignment: Qt.AlignRight
                                        text: "􀊞" // repeat
                                        color: Style.highlight
                                        // Layout.rightMargin: root.margin * 2
                                        font.pixelSize: root.controlSize * 0.7
                                        font.family: Style.iconFontFamily
                                        opacity: repeat.checked ? 1 : 0.5
                                        font.weight: repeat.checked ? 800 : 600
                                        MouseArea {
                                            id: repeat
                                            property bool checked: {
                                                if (MprisService.activePlayer?.canControl && MprisService.activePlayer.loopSupported) {
                                                    return MprisService.activePlayer.loopState;
                                                } else {
                                                    return false;
                                                }
                                            }
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                // if (MprisService.activePlayer.canControl && MprisService.activePlayer.loopSupported) {
                                                MprisService.activePlayer.loopState = !MprisService.activePlayer.loopState;
                                                // }
                                            }
                                        }
                                    }
                                }

                                Item {
                                    Layout.fillWidth: true
                                }

                                // Repeat button
                            }

                            Item {
                                Layout.fillHeight: true
                            }

                            // progressBar
                            RowLayout {
                                id: sliderZone
                                ClippingWrapperRectangle {
                                    Layout.fillWidth: true
                                    implicitHeight: Math.min((8 / 24) * root.controlSize, 10)
                                    radius: Style.cornerRadius
                                    // Layout.leftMargin: root.margin * 0.5
                                    // Layout.rightMargin: root.margin * 0.5
                                    color: Style._bgLight

                                    WrapperMouseArea {
                                        onClicked: {
                                            console.log("[ volumeMouseArea clicked ]", mouseX);
                                            if (player.canSeek) {
                                                player.position = (Math.max(0, Math.min(1, mouseX / 321))) * player.length;
                                            }
                                        }
                                        // onPositionChanged: {
                                        // console.log("[ volumeMouseArea pressed ]", mouseX);
                                        //     if (player.canSeek) {
                                        //     player.position = (Math.max(0, Math.min(1, mouseX / 321))) * player.length;
                                        //     }
                                        // }
                                        child: Rectangle {
                                            id: progressBar
                                            color: "transparent"
                                            property real ratio: calculateRatio()
                                            function calculateRatio() {
                                                if (player?.canSeek && player.positionSupported) {
                                                    return player.position / player.length;
                                                }
                                                return 0;
                                            }

                                            Rectangle {
                                                id: progressFill
                                                color: Style.highlight
                                                width: (player != null || player?.trackTitle != "") ? progressBar.ratio * progressBar.width : 0
                                                height: parent.height
                                                opacity: 0.85

                                                FrameAnimation {
                                                    // only emit the signal when the position is actually changing.
                                                    running: (player?.playbackState == MprisPlaybackState.Playing && (BarPopupManager.showAudioPopup || Settings.showControlCenter))
                                                    // emit the positionChanged signal every frame.
                                                    onTriggered: player.positionChanged()
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            RowLayout {
                                id: sliderZoneInfo
                                // Layout.leftMargin: root.margin * 0.6
                                // Layout.rightMargin: root.margin * 0.6
                                Layout.fillWidth: true
                                Text {
                                    text: {
                                        var duration;
                                        var display = "";
                                        if (player == null || player.trackTitle == "") {
                                            display = "__:__";
                                        } else {
                                            var time = parseInt(player.position);
                                            if (player.canSeek && player.positionSupported) {
                                                duration = root.durationFormatting(time);
                                            }
                                            if (duration[0] > 0) {
                                                display += String(duration[0]).padStart(2, '0') + ":";
                                            }
                                            display += String(duration[1]).padStart(2, '0') + ":" + String(duration[2]).padStart(2, '0');
                                        }
                                        return display;
                                    }
                                    color: Style.textMuted
                                    font.pixelSize: Style.fontSize - 3
                                    opacity: 0.6
                                    font.family: Style.monospaceFont
                                }

                                Text {
                                    Layout.fillWidth: true
                                    text: {
                                        var duration;
                                        var display = "";
                                        if (player == null || player.trackTitle == "") {
                                            display = "__:__";
                                        } else {
                                            var time = parseInt(player.length);
                                            if (player.canSeek && player.positionSupported) {
                                                duration = root.durationFormatting(time);
                                            }
                                            if (duration[0] > 0) {
                                                display += String(duration[0]).padStart(2, '0') + ":";
                                            }
                                            display += String(duration[1]).padStart(2, '0') + ":" + String(duration[2]).padStart(2, '0');
                                        }
                                        return display;
                                    }
                                    color: Style.textMuted
                                    font.pixelSize: Style.fontSize - 3
                                    horizontalAlignment: Text.AlignRight
                                    opacity: 0.6
                                    font.family: Style.monospaceFont
                                }
                            }
                        }
                    }

                    WrapperRectangle {
                        id: sourceSelect
                        property int margins: -root.margin * 0.6
                        property int optionHeight: 27
                        visible: false
                        // implicitHeight: 100

                        implicitHeight: {
                            var optsLength;
                            if (Audio.outputs.length() <= 0) {
                                optsLength = 0;
                            } else if (Audio.outputs.length() == 1) {
                                optsLength = sourceSelect.optionHeight;
                            } else {
                                return Audio.outputs.length() * sourceSelect.optionHeight + (Audio.outputs.length() - 1) * sourceSelect.margin * 0;
                            }
                            return Math.max(playerHeight * 0.4, optsLength);
                        }
                        Layout.fillWidth: true
                        color: Style._bgLight
                        radius: root.radius + margins
                        margin: root.margin * 0.8

                        ColumnLayout {
                            Repeater {
                                id: audioOutputs
                                model: Audio.outputs

                                RowLayout {
                                    id: output
                                    required property PwNode modelData
                                    Layout.fillWidth: true
                                    Rectangle {
                                        color: clickArea.containsMouse ? Qt.rgba(5, 5, 5, 0.05) : "transparent"
                                        implicitHeight: sourceSelect.optionHeight
                                        Layout.fillWidth: true
                                        radius: sourceSelect.radius - sourceSelect.margin * 0.5

                                        MouseArea {
                                            id: clickArea
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                Pipewire.preferredDefaultAudioSink = output.modelData;
                                            }
                                        }

                                        RowLayout {
                                            spacing: root.margin
                                            // implicitWidth: sourceSelect.width - sourceSelect.margin * 2
                                            Layout.fillWidth: true
                                            Rectangle {
                                                color: "transparent"
                                                height: parent.parent.height
                                                width: 30
                                                Text {
                                                    text: Audio.outputIcon(modelData.description)
                                                    color: Style.textMuted
                                                    font.pixelSize: Style.iconFontSize - 1
                                                    opacity: 0.8
                                                    font.family: Style.iconFontFamily
                                                    anchors.centerIn: parent
                                                }
                                            }

                                            Text {
                                                text: modelData.description
                                                color: Style.textMuted
                                                font.pixelSize: Style.fontSize - 1
                                                opacity: 0.8
                                                horizontalAlignment: Text.AlignLeft
                                            }

                                            Text {
                                                text: "􀁣"
                                                visible: Audio.sink == modelData
                                                color: Style.textMuted
                                                font.pixelSize: Style.iconFontSize - 6
                                                opacity: 0.8
                                                font.family: Style.iconFontFamily
                                                Layout.fillWidth: true
                                                horizontalAlignment: Text.AlignRight
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // Behavior on implicitHeight {
            //     NumberAnimation {
            //         duration: 50
            //     }
            // }

        }
    }
    function durationFormatting(time) {
        var hours = Math.floor(time / 3600);
        var mins = Math.floor((time % 3600) / 60);
        var sec = time % 60;

        return [hours, mins, sec];
    }
}
