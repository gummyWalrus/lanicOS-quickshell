pragma Singleton

import QtQuick
import QtQml
import Quickshell
import Quickshell.Io

// Polled system info: per-interface network counters and rates, fan speeds and uptime.
Singleton {
    id: root

    property int interval: 1000
    property int fanInterval: 4000

    // { [iface]: { rxBytes, rxPackets, rxErrors, rxDrops, txBytes, txPackets, txErrors, txDrops, rxRate, txRate } }
    property var interfaces: ({})
    readonly property var interfaceNames: Object.keys(interfaces)

    // [{ path, hwmon, rpm }]
    property var fans: []
    property var _fanPaths: []
    property var _fanRpm: []

    property real uptime: 0
    property real idleTime: 0

    // Combined rates of all interfaces except loopback, in bytes per second.
    readonly property real rxRate: interfaceNames.filter(n => n !== "lo").reduce((sum, n) => sum + interfaces[n].rxRate, 0)
    readonly property real txRate: interfaceNames.filter(n => n !== "lo").reduce((sum, n) => sum + interfaces[n].txRate, 0)
    readonly property real maxFanRpm: fans.length > 0 ? Math.max(...fans.map(f => f.rpm)) : 0

    readonly property string summary: {
        const parts = ["↓ " + formatBytes(rxRate) + "/s ↑ " + formatBytes(txRate) + "/s"]
        if (fans.length > 0)
            parts.push(maxFanRpm + " rpm")
        parts.push("up " + formatUptime(uptime))
        return parts.join(" · ")
    }

    function formatBytes(bytes) {
        const units = ["B", "KiB", "MiB", "GiB", "TiB"]
        let i = 0
        while (bytes >= 1024 && i < units.length - 1) {
            bytes /= 1024
            i++
        }
        return bytes.toFixed(i === 0 ? 0 : 1) + " " + units[i]
    }

    function formatUptime(seconds) {
        const d = Math.floor(seconds / 86400)
        const h = Math.floor(seconds % 86400 / 3600)
        const m = Math.floor(seconds % 3600 / 60)
        return (d > 0 ? d + "d " : "") + h + "h " + m + "m"
    }

    function setFanRpm(index, rpm) {
        root._fanRpm[index] = rpm
        fanCommit.restart()
    }

    function parseNetDev(text) {
        const now = Date.now()
        const elapsed = (now - netDevFile.lastUpdate) / 1000
        const previous = root.interfaces
        const result = {}

        for (const line of text.split("\n").slice(2)) {
            const [name, data] = line.split(":")
            if (!data)
                continue

            const f = data.trim().split(/\s+/).map(Number)
            const iface = name.trim()
            const old = previous[iface]

            result[iface] = {
                rxBytes: f[0], rxPackets: f[1], rxErrors: f[2], rxDrops: f[3],
                txBytes: f[8], txPackets: f[9], txErrors: f[10], txDrops: f[11],
                rxRate: old && elapsed > 0 ? Math.max(0, (f[0] - old.rxBytes) / elapsed) : 0,
                txRate: old && elapsed > 0 ? Math.max(0, (f[8] - old.txBytes) / elapsed) : 0
            }
        }

        netDevFile.lastUpdate = now
        root.interfaces = result
    }

    Timer {
        interval: root.interval
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            netDevFile.reload()
            uptimeFile.reload()
        }
    }

    Timer {
        interval: root.fanInterval
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            for (let i = 0; i < fanFiles.count; i++)
                fanFiles.objectAt(i).reload()
        }
    }

    // Coalesces the per-fan reads into a single update of fans.
    Timer {
        id: fanCommit
        interval: 50
        onTriggered: root.fans = root._fanPaths.map((path, i) => ({
            path: path,
            hwmon: path.split("/")[4],
            rpm: root._fanRpm[i] ?? 0
        }))
    }

    FileView {
        id: netDevFile
        path: "/proc/net/dev"

        property double lastUpdate: 0
        onLoaded: root.parseNetDev(text())
    }

    FileView {
        id: uptimeFile
        path: "/proc/uptime"
        onLoaded: {
            const [up, idle] = text().trim().split(" ").map(Number)
            root.uptime = up
            root.idleTime = idle
        }
    }

    Instantiator {
        id: fanFiles
        model: root._fanPaths

        FileView {
            required property int index
            required property string modelData

            path: modelData
            onLoaded: root.setFanRpm(index, parseInt(text()) || 0)
        }
    }

    Process {
        running: true
        command: ["sh", "-c", "ls -1 /sys/class/hwmon/hwmon*/fan*_input 2>/dev/null"]
        stdout: StdioCollector {
            onStreamFinished: root._fanPaths = text.trim().split("\n").filter(l => l)
        }
    }
}
