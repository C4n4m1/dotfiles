pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.UPower

Singleton {
    id: root
    property int percentageValue: {
        var capacity = UPower.displayDevice.percentage;
        return parseInt(capacity * 100);
    }

    property var isCharging: (UPower.displayDevice.state == UPowerDeviceState.Charging || UPower.displayDevice.state == UPowerDeviceState.FullyCharged )

    property string percentage: {
        return root.percentageValue + "%";
    }

    property string batteryIcon: {
        var available = UPower.displayDevice.isLaptopBattery;
        var capacity = parseInt(UPower.displayDevice.percentage * 100);

        function BatteryIcon(available,capacity,isCharging) {
        if (available) {
            if (isCharging) {
                return "􀢋";
            } else {
            if (root.percentageValue > 90) {
                return "􀛨";
            } else if (root.percentageValue > 60) {
                return "􀺸";
            } else if (root.percentageValue > 40) {
                return "􀺶";
            } else if (root.percentageValue > 10) {
                return "􀛩";
            } else {
                return "􀛪";
            }
        }
        }
        return "→";
        }
    return BatteryIcon(available,capacity,isCharging)
    }

    property var health: {
        if (UPower.displayDevice.healthSupported) {
            return UPower.displayDevice.healthPercentage;
        } else return UPower.displayDevice.healthSupported;
    }

    property list<int> timeToFull: durationFormatting(UPower.displayDevice.timeToFull)
    property list<int> timeToEmpty: durationFormatting(UPower.displayDevice.timeToEmpty)

    function durationFormatting(time) {
      var hours = Math.floor(time / 3600);
      var mins = Math.floor((time % 3600) / 60);
      var sec = time % 60;

      return [hours,mins,sec];
    }

    property var battery: UPower.displayDevice;
    property string powerProfile: {
        var profile = PowerProfiles.profile
        var stringProfile
        if (profile == PowerProfiles.PowerSaver) {
            stringProfile = "power-saver";
        } else if (profile == PowerProfiles.Balanced) {
            stringProfile = "balanced";
        } else if (profile == PowerProfiles.Performance) {
            stringProfile = "performance";
        }

        return stringProfile;
    }
}
