pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Polled memory usage from /proc/meminfo and pressure stall info from /proc/pressure/memory.
Singleton {
    id: root

    // Polling runs while at least one consumer holds a reference (see acquire() / release()).
    property int _users: 0
    readonly property bool active: _users > 0

    property int interval: 1000

    // Sizes are in kiB, as reported by the kernel.
    property real total: 0
    property real free: 0
    property real available: 0
    property real buffers: 0
    property real cached: 0
    property real swapTotal: 0
    property real swapFree: 0

    readonly property real used: total - available
    readonly property real usage: total > 0 ? used / total : 0
    readonly property real swapUsed: swapTotal - swapFree
    readonly property real swapUsage: swapTotal > 0 ? swapUsed / swapTotal : 0

    // { avg10, avg60, avg300, total } in % and microseconds, or null when PSI is unavailable.
    property var pressureSome: null
    property var pressureFull: null

    readonly property string summary: Math.round(usage * 100) + "% · " + formatKib(used) + " / " + formatKib(total)
    
    readonly property string summaryShort: Math.round(usage * 100) + "% · " + formatKib(used)
    
    readonly property string usedFormatted: formatKib(used)

    function acquire() {
        root._users++
    }

    function release() {
        root._users = Math.max(0, root._users - 1)
    }

    function formatKib(kib) {
        const units = ["KiB", "MiB", "GiB", "TiB"]
        let i = 0
        while (kib >= 1024 && i < units.length - 1) {
            kib /= 1024
            i++
        }
        return kib.toFixed(i === 0 ? 0 : 1) + " " + units[i]
    }

    function parseMeminfo(text) {
        const values = {}
        for (const line of text.split("\n")) {
            const match = line.match(/^(\w+):\s+(\d+)/)
            if (match)
                values[match[1]] = Number(match[2])
        }

        root.total = values.MemTotal ?? 0
        root.free = values.MemFree ?? 0
        root.available = values.MemAvailable ?? 0
        root.buffers = values.Buffers ?? 0
        root.cached = values.Cached ?? 0
        root.swapTotal = values.SwapTotal ?? 0
        root.swapFree = values.SwapFree ?? 0
    }

    function parsePressure(text) {
        const result = { some: null, full: null }
        for (const line of text.split("\n")) {
            const [kind, ...fields] = line.trim().split(" ")
            if (kind !== "some" && kind !== "full")
                continue

            const entry = {}
            for (const field of fields) {
                const [key, value] = field.split("=")
                entry[key] = Number(value)
            }
            result[kind] = entry
        }

        root.pressureSome = result.some
        root.pressureFull = result.full
    }

    Timer {
        interval: root.interval
        running: root.active
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            meminfoFile.reload()
            pressureFile.reload()
        }
    }

    FileView {
        id: meminfoFile
        path: "/proc/meminfo"
        onLoaded: root.parseMeminfo(text())
    }

    FileView {
        id: pressureFile
        path: "/proc/pressure/memory"
        onLoaded: root.parsePressure(text())
    }
}
