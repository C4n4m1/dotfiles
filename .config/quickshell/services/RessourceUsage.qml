pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

/**
 * Simple polled resource usage service with RAM, Swap, and CPU usage.
 */
Singleton {
    property double memoryTotal: 1
    property double memoryFree: 1
    property double memoryUsed: memoryTotal - memoryFree
    property double memoryUsedPercentage: memoryUsed / memoryTotal
    property double swapTotal: 1
    property double swapFree: 1
    property double swapUsed: swapTotal - swapFree
    property double swapUsedPercentage: swapTotal > 0 ? (swapUsed / swapTotal) : 0
    property double cpuUsage: 0
    property var previousCpuStats

    Timer {
        interval: 1
        running: true
        repeat: true
        onTriggered: {
            // Reload files
            fileMeminfo.reload();
            fileStat.reload();

            // Parse memory and swap usage
            const textMeminfo = fileMeminfo.text();
            memoryTotal = Number(textMeminfo.match(/MemTotal: *(\d+)/)?.[1] ?? 1);
            memoryFree = Number(textMeminfo.match(/MemAvailable: *(\d+)/)?.[1] ?? 0);
            swapTotal = Number(textMeminfo.match(/SwapTotal: *(\d+)/)?.[1] ?? 1);
            swapFree = Number(textMeminfo.match(/SwapFree: *(\d+)/)?.[1] ?? 0);

            // Parse CPU usage
            const textStat = fileStat.text();
// Capture more fields — up to steal
const cpuLine = textStat.match(
    /^cpu\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)/
);
if (cpuLine) {
    const stats = cpuLine.slice(1).map(Number);
    // [0]=user [1]=nice [2]=system [3]=idle [4]=iowait [5]=irq [6]=softirq [7]=steal
    const idle = stats[3] + stats[4];           // idle + iowait
    const total = stats.reduce((a, b) => a + b, 0);
    if (previousCpuStats) {
        const totalDiff = total - previousCpuStats.total;
        const idleDiff  = idle  - previousCpuStats.idle;
        cpuUsage = totalDiff > 0 ? (1 - idleDiff / totalDiff) : 0;
    }
    previousCpuStats = { total, idle };
}
            interval = 3000;
        }
    }

    FileView {
        id: fileMeminfo
        path: "/proc/meminfo"
    }
    FileView {
        id: fileStat
        path: "/proc/stat"
    }
}
