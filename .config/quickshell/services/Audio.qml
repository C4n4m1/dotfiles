pragma Singleton
import Quickshell.Services.Pipewire

import QtQuick
import Quickshell
import QtQuick.Layouts
import qs.assets

Singleton {
    id: root

    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property PwNode source: Pipewire.defaultAudioSource
    property PwNode setSink: Pipewire.preferredDefaultAudioSink
    property bool ready: Pipewire.defaultAudioSink?.ready ?? false
    property real volume: Pipewire.defaultAudioSink?.audio?.volume ?? 0
    property bool isMuted: Audio.sink?.audio.muted ?? false
    property string icon: volumeIcon()
    property string sinkName: sink?.nickname ?? "..."
    property list<PwNode> outputs: Pipewire.nodes.values.filter(node => (node.isSink && !node.isStream))

    PwObjectTracker {
        objects: [root.sink, root.source, root.setSink, root.ready, root.volume, root.isMuted, root.icon, root.sinkName, root.outputs]
    }

    function volumeIcon() {
        var vol = parseInt(root.volume * 100);
        var icon = "";
        if (root.isMuted) {
            icon = "􀊣";
        } else {
            if (vol < 10) {
                icon = "􀊡";
            } else if (vol < 40) {
                icon = "􀊥";
            } else if (vol < 70) {
                icon = "􀊧";
            } else {
                icon = "􀊩";
            }
        }
        return icon;
    }

    function deviceIcon() {
        var defaultIcon = volumeIcon();
        var deviceInfo = Audio.sink?.description;
        if (deviceInfo.includes("HD 350BT")) {
            if (!isMuted) {
                return "􀑈";
            } else
                return "􂬂";
        }
        return defaultIcon;
    }

    function outputIcon(sinkDescription) {
        var icon = "􀊧";
        switch (sinkDescription) {
        case "Audio Coprocessor Speakers":
            icon = "􀟛";
            break;
        case "HD 350BT":
            icon = "􀑈";
            break;
        case "LE-HD 350BT":
            icon = "􀑈";
            break;
        }

        return icon;
    }
}
