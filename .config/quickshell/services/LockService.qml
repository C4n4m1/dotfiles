pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import qs.services

Singleton {
    id: root
    property bool active: false

    onActiveChanged: {
        if (root.active) {
            // console.log("[Test] Locked");
            // IdleService.setDpms(false);
        } else {
            // console.log("[test] Unlocked");
            // IdleService.setDpms(true);
        }
    }
}
