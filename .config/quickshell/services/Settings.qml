pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import QtQuick.Layouts
import qs.assets
import qs.services

Singleton {
    id: settings
    property bool showControlCenter: false
    property bool enableBar: true
    property bool dnd: false

    Component.onCompleted: settings.dnd = false

    property JsonObject idleService: JsonObject {

        property bool dpmsEnabled: true
        property int dpmsTimeoutSec: 300
        property bool enabled: true
        property bool lockEnabled: false
        property int lockTimeoutSec: 30
        property bool respectInhibitors: true
        property bool suspendEnabled: true
        property int suspendTimeoutSec: 1800
        property bool backlightEnabled: true
        property int backlightTimeoutSec: 250
        property bool videoAutoInhibit: true

        // property bool dpmsEnabled: true
        // property int dpmsTimeoutSec: 60
        // property bool enabled: true
        // property bool lockEnabled: true
        // property int lockTimeoutSec: 20
        // property bool respectInhibitors: true
        // property bool suspendEnabled: false
        // property int suspendTimeoutSec: 1800
        // property bool backlightEnabled: true
        // property int backlightTimeoutSec: 10
        // property bool videoAutoInhibit: true

    }

    IpcHandler {
        id: ipcHandler
        target: "settings"

        function toggleControlCenter(): void {
            settings.showControlCenter = !settings.showControlCenter;
        }

        function togglebar(): void {
            settings.enablebar = !settings.enablebar;
        }

        function toggleDND(): void {
            settings.dnd = !settings.dnd;
        }

        function toggleCaffeine() {
            settings.idleService.respectInhibitors = !settings.idleService.respectInhibitors;
        }

        function reload(): void {
            Quickshell.reload(true);
        }
    }
}
