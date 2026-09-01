pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.services

Singleton {
    id: root

    readonly property var dpmsCmds: ({
            on: ["niri", "msg", "action", "power-on-monitors"],
            off: ["niri", "msg", "action", "power-off-monitors"]
        })
    property bool dpmsOff: false
    readonly property bool effectiveInhibited: !!settings?.videoAutoInhibit && MprisService.anyVideoPlaying
    readonly property bool ready: !!settings
    readonly property bool respectInhibitors: !LockService.locked && (settings?.respectInhibitors ?? true)
    readonly property var settings: Settings.idleService
    property QsWindow window
    property bool hideOSD: false
    property real lastBrightnessLv: 0

    // setDpms( false ) = DpmsOff : true
    // setDpms( true ) = DpmsOff : false
    function setDpms(state: bool): void {
        if (root.dpmsOff === !state)
            return;
        root.dpmsOff = !state;
        const cmd = root.dpmsCmds[state ? "on" : "off"];
        if (cmd) {
            // if (!state) { reduceBrightness(); }
            Quickshell.execDetached(cmd);
        }
        else
            console.log("DPMS commmand failed");
    }

    function suspend(): void {
        Quickshell.execDetached(["systemctl", "suspend"]);
    }

    function wake(): void {
        if (root.dpmsOff)
            root.setDpms(true);
        root.restoreBrightness();
    }

    IdleInhibitor {
        enabled: root.effectiveInhibited
        window: root.window
    }

    IdleMonitor {
        enabled: root.ready && !!root.settings.enabled && !root.dpmsOff && root.settings.backlightEnabled
        respectInhibitors: root.respectInhibitors
        timeout: root.settings?.backlightTimeoutSec ?? 0

        onIsIdleChanged: isIdle ? root.reduceBrightness() : root.restoreBrightness()
    }

    // IdleMonitor {
    //     enabled: root.ready && !!root.settings.enabled && root.settings.lockEnabled && LockService.locked
    //     respectInhibitors: root.respectInhibitors
    //     timeout: root.settings?.lockTimeoutSec ?? 0

    //     onIsIdleChanged: {
    //         if (isIdle) {
    //             LockService.locked = true;
    //         } else {
    //             // LockService.locked = false;
    //             // root.wake();
    //         }
    //     }
    // }

    IdleMonitor {
        enabled: root.ready && !!root.settings.enabled && root.settings.lockEnabled
        respectInhibitors: root.respectInhibitors
        timeout: root.settings?.lockTimeoutSec ?? 0

        onIsIdleChanged: {
            if (isIdle) {
                LockService.active = true;
            } else {
                LockService.active = false;
                root.wake();
            }
        }
    }

    IdleMonitor {
        enabled: root.ready && !!root.settings.enabled && root.settings.dpmsEnabled && (LockService.locked || !root.settings.lockEnabled)
        respectInhibitors: root.respectInhibitors
        timeout: root.settings?.dpmsTimeoutSec ?? 0

        onIsIdleChanged: {
            if (isIdle) {
                setbrightness.exec(["brightnessctl", "-s", "set", "10"]);
                root.setDpms(false);
            } else {
                root.wake();
            }
        }
    }

    IdleMonitor {
        enabled: root.ready && !!root.settings.enabled && root.settings.suspendEnabled && root.dpmsOff
        respectInhibitors: root.respectInhibitors
        timeout: root.settings?.suspendTimeoutSec ?? 0

        onIsIdleChanged: isIdle ? root.suspend() : root.wake()
    }

    // Connections {
    //     function onLockedChanged(): void {
    //         if (!LockService.locked)
    //             root.wake();
    //     }

    //     target: LockService
    // }

    Process {
        id: setbrightness
    }

    function reduceBrightness() {
        root.hideOSD = true;
        hideBrightnessOsd.start();
        root.lastBrightnessLv = Brightness.brightnessLv;
    }

    function restoreBrightness() {
        showOSD.start();
        // setbrightness.exec(["brightnessctl","-r"]);
        Brightness.setBrightnessLevel(root.lastBrightnessLv);
    }

    Timer {
        id: showOSD
        interval: 10
        running: false
        repeat: false
        onTriggered: {
            root.hideOSD = false;
            // console.log("[IdleService] Restoring brightness --- hideOSD = ", root.hideOSD);
        }
    }

    Timer {
        id: hideBrightnessOsd
        interval: 10
        repeat: false
        onTriggered: {
            setbrightness.exec(["brightnessctl", "-s", "set", "10"]);
            // console.log("[IdleService] Reducing brightness --- hideOSD = ", root.hideOSD);
        }
    }

    Component.onCompleted: {
        root.lastBrightnessLv = Brightness.brightnessLv;
    }
}
