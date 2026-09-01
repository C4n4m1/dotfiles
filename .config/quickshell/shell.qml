//@ pragma UseQApplication
// shell.qml
import QtQuick
import Quickshell
import qs.bar
import qs.assets
import qs.modules
import qs.modules.widgets
import qs.services

Scope {
    property bool enableScreenCorners: true
    property bool enableNotificationManager: true
    property bool enableVolumeOsd: true
    property bool enableBrightnessOsd: true

    LazyLoader {
        active: Settings.enableBar
        component: Barv2 {}
    }
    LazyLoader {
        active: enableScreenCorners
        component: ScreenCorners {}
    }
    LazyLoader {
        active: enableNotificationManager
        component: NotificationManagerv2 {}
    }
    // LazyLoader {
    //     active: true
    //     component: IdleService {
    //         id: idleService
    //     }
    // }
    LazyLoader {
        active: enableVolumeOsd
        component: VolumeOsd {}
    }
    LazyLoader {
        active: enableBrightnessOsd
        component: BrightnessOsd {
            id: brightnessOsd
            externSourceHideOSD: idleService.hideOSD
        }
    }

    LazyLoader {
        active: BarPopupManager.enableBatteryPopup
        BatteryPopup {
            showPopup: BarPopupManager.showBatteryPopup
        }
    }

    LazyLoader {
        active: BarPopupManager.enableAudioPopup
        AudioPopup {
            showPopup: BarPopupManager.showAudioPopup
        }
    }

    LazyLoader {
        active: BarPopupManager.enableRessourcePopup
        RessourcePopup {
            showPopup: BarPopupManager.showRessourcePopup
        }
    }

    LazyLoader {
        active: true
        ControlCenter {
            showControlCenter: Settings.showControlCenter
        }
    }

    LazyLoader {
        active: true
        LockScreen {}
    }
}
