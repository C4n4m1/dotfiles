pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick
import qs.assets

Singleton {
    id: root
    property real brightnessLv: calculBrightnessLevel()
    property real _prev_brightnessLv: 0
    property double brightnessLvMax: parseFloat(fileView2.text())
    property string icon: brightnessIcon()
    // property int iconSize: brightnessIconSize()

    function calculBrightnessLevel() {
        var lv = parseFloat(fileView.text());
        lv = lv / brightnessLvMax;
        return lv;
    // return parseInt(lv * 100);
    }

    function brightnessIcon() {
        var lv = root.brightnessLv;
        if (lv <= 0.5) {
            return "􀆬";
        } else
            return "􀆮";
    }

    function brightnessIconSize() {
        var lv = parseInt(root.brightnessLv * 100);
        var size = Style.iconFontSize + 3;
        if (lv <= 20) {
            return size - 3;
        } else if (lv <= 45) {
            return size - 2;
        } else if (lv <= 70) {
            return size - 1;
        } else {
            return size;
        }
    }

    function setBrightnessLevel(level) {
        var value = Math.min(Math.max(level * brightnessLvMax, 0), brightnessLvMax);
        setbrightness.exec(["brightnessctl", "set", value.toString()]);
    }

    FileView {
        id: fileView
        watchChanges: true
        path: "/sys/class/backlight/amdgpu_bl1/brightness"

        onFileChanged: () => {
            reload();
        }
    }

    FileView {
        id: fileView2
        watchChanges: false
        path: "/sys/class/backlight/amdgpu_bl1/max_brightness"
    }

    Process {
        id: setbrightness
    }

    // Custom signals
    signal brightnessIncreased(real newValue, real oldValue, real delta)
    signal brightnessDecreased(real newValue, real oldValue, real delta)

    onBrightnessLvChanged: {
        if (brightnessLv > _prev_brightnessLv) {
            brightnessIncreased(brightnessLv, _prev_brightnessLv, brightnessLv - _prev_brightnessLv);
        } else if (brightnessLv < _prev_brightnessLv) {
            brightnessDecreased(brightnessLv, _prev_brightnessLv, _prev_brightnessLv - brightnessLv);
        }
        // Update previous value for next comparison
        _prev_brightnessLv = brightnessLv;
    }

    Component.onCompleted: {
        _prev_brightnessLv = brightnessLv;
    }
}
