pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import qs.services

Singleton {
   id: root
   property bool locked: false
   onLockedChanged: {
      if (locked) {
         // console.log("[LockService] Locked")
         // IdleService.setDpms(false);
      } else {
         // console.log("[LockService] Unlocked")
         // IdleService.setDpms(true);
      }
   }

   function lock() {
      locked = true;
   }

   function unlock() {
      locked = false;
   }
}
