pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    readonly property string time: {
        Qt.formatDateTime(clock.date, "ddd dd MMM hh:mm");
    }

    readonly property string date: {
        Qt.formatDateTime(clock.date, "dddd dd MMMM");
    }

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }

    // Process {
    //     id: dateProc
    //     command: ["/home/credo/.config/quickshell/bar/time.sh"]
    //     running: true
    //     stdout: StdioCollector {
    //         onStreamFinished: {
    //             root.time = this.text;
    //         }
    //     }
    // }

    // Timer {
    //     interval: 1000
    //     running: true
    //     repeat: true
    //     onTriggered: dateProc.running = true
    // }
}
