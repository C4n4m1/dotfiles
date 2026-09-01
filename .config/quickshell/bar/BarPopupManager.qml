pragma Singleton

import qs.assets
import qs.services
import qs.modules
import qs.modules.widgets
import QtQuick
import Quickshell
import QtQuick.Layouts
import Quickshell.Widgets
import Quickshell.Wayland

Singleton {
    id: root
    property bool enableAudioPopup: showAudioPopup
    property bool enableBatteryPopup: showBatteryPopup
    property bool enableRessourcePopup: showRessourcePopup

    property bool showAudioPopup: false
    property bool showBatteryPopup: false
    property bool showRessourcePopup: false

    property int nbPopups: {
        var nb = 0;
        if (showAudioPopup)
            nb++;
        if (showBatteryPopup)
            nb++;
        if (showRessourcePopup)
            nb++;
        return nb;
    }

    function toggleAudioPopup() {
        console.log("toggle audio fn");
        if (showAudioPopup) {
            showAudioPopup = false;
        } else {
            if (nbPopups >= 1) {
                showBatteryPopup = false;
                showRessourcePopup = false;
            }
            showAudioPopup = true;
        }
    }

    function toggleBatteryPopup() {
        if (showBatteryPopup) {
            showBatteryPopup = false;
        } else {
            if (nbPopups >= 1) {
                showAudioPopup = false;
                showRessourcePopup = false;
            }
            showBatteryPopup = true;
        }
    }

    function toggleRessourcePopup() {
        if (showRessourcePopup) {
            showRessourcePopup = false;
        } else {
            if (nbPopups >= 1) {
                showAudioPopup = false;
                showBatteryPopup = false;
            }
            showRessourcePopup = true;
        }
    }

    Behavior on showAudioPopup {
        NumberAnimation {
            duration: 50
        }
    }

    Behavior on showBatteryPopup {
        NumberAnimation {
            duration: 50
        }
    }

    Behavior on showRessourcePopup {
        NumberAnimation {
            duration: 50
        }
    }
}
