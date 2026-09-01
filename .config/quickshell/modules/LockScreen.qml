import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import qs.services

Singleton {
    id: root

    WlSessionLock {
        id: lock

        WlSessionLockSurface {}
    }
}
