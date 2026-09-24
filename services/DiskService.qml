pragma Singleton

import QtQuick
import QtQml
import Quickshell
import Quickshell.Io

// Polled I/O stats (/proc/diskstats) and NVMe temperature per physical disk, plus filesystem usage
// fetched on demand through refreshFilesystems(). Rates are in bytes per second, busy is a 0-1 fraction.
Singleton {
    id: root

    property int interval: 1000
    property int temperatureInterval: 5000

    property var _stats: ({})
    property var models: ({})
    property var temperatures: ({})
    property var _temperaturePaths: []
    property var _temperatureValues: ({})

    // [{ name, model, temperature, readBytes, writeBytes, readOps, writeOps, readRate, writeRate, busy }]
    readonly property var disks: Object.keys(_stats).map(name => Object.assign({
        name: name,
        model: models[name] ?? "",
        temperature: temperatureOf(name)
    }, _stats[name]))

    readonly property real readRate: disks.reduce((sum, d) => sum + d.readRate, 0)
    readonly property real writeRate: disks.reduce((sum, d) => sum + d.writeRate, 0)
    readonly property real busy: disks.reduce((max, d) => Math.max(max, d.busy), 0)
    readonly property real maxTemperature: disks.reduce((max, d) => Math.max(max, d.temperature), 0)

    // [{ device, mount, size, used, available, usage }] in bytes, empty until refreshFilesystems() completes.
    property var filesystems: []
    readonly property bool filesystemsLoading: filesystemProcess.running

    readonly property string summary: {
        const parts = ["R " + SysinfoService.formatBytes(readRate) + "/s W " + SysinfoService.formatBytes(writeRate) + "/s"]
        if (maxTemperature > 0)
            parts.push(Math.round(maxTemperature) + "°C")
        return parts.join(" · ")
    }

    property double _lastUpdate: 0

    function refreshFilesystems() {
        if (filesystemProcess.running)
            return
        filesystemProcess.running = true
    }

    // NVMe sensors belong to the controller (nvme0), disks are named after the namespace (nvme0n1).
    function temperatureOf(name) {
        for (const controller of Object.keys(temperatures)) {
            if (name.startsWith(controller + "n"))
                return temperatures[controller]
        }
        return 0
    }

    function setTemperature(path, celsius) {
        root._temperatureValues[path.split("/")[4]] = celsius
        temperatureCommit.restart()
    }

    function parseDiskstats(text) {
        const now = Date.now()
        const elapsed = (now - root._lastUpdate) / 1000
        const previous = root._stats
        const result = {}

        for (const line of text.split("\n")) {
            const parts = line.trim().split(/\s+/)
            const name = parts[2]
            if (!name || !/^(nvme\d+n\d+|sd[a-z]+|vd[a-z]+|xvd[a-z]+|hd[a-z]+|mmcblk\d+)$/.test(name))
                continue

            const f = parts.slice(3).map(Number)
            const old = previous[name]
            const rate = (value, oldValue) => old && elapsed > 0 ? Math.max(0, (value - oldValue) / elapsed) : 0

            // sectors are always 512 bytes in diskstats
            result[name] = {
                readOps: f[0],
                readBytes: f[2] * 512,
                writeOps: f[4],
                writeBytes: f[6] * 512,
                ioMs: f[9],
                readRate: rate(f[2] * 512, old?.readBytes),
                writeRate: rate(f[6] * 512, old?.writeBytes),
                busy: old && elapsed > 0 ? Math.min(1, Math.max(0, (f[9] - old.ioMs) / (elapsed * 1000))) : 0
            }
        }

        root._lastUpdate = now
        root._stats = result
    }

    Timer {
        interval: root.interval
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: diskstatsFile.reload()
    }

    Timer {
        interval: root.temperatureInterval
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            for (let i = 0; i < temperatureFiles.count; i++)
                temperatureFiles.objectAt(i).reload()
        }
    }

    // Coalesces the per-controller reads into a single update of temperatures.
    Timer {
        id: temperatureCommit
        interval: 50
        onTriggered: root.temperatures = Object.assign({}, root._temperatureValues)
    }

    FileView {
        id: diskstatsFile
        path: "/proc/diskstats"
        onLoaded: root.parseDiskstats(text())
    }

    Instantiator {
        id: temperatureFiles
        model: root._temperaturePaths

        FileView {
            required property string modelData

            path: modelData
            onLoaded: root.setTemperature(modelData, (parseInt(text()) || 0) / 1000)
        }
    }

    Process {
        running: true
        command: ["sh", "-c", "ls -1 /sys/class/nvme/nvme*/hwmon*/temp1_input 2>/dev/null"]
        stdout: StdioCollector {
            onStreamFinished: root._temperaturePaths = text.trim().split("\n").filter(l => l)
        }
    }

    Process {
        id: modelProcess
        running: true
        command: ["sh", "-c", 'for d in /sys/block/*/device/model; do n=${d#/sys/block/}; echo "${n%%/*}|$(cat $d)"; done']
        stdout: StdioCollector {
            onStreamFinished: {
                const result = {}
                for (const line of text.trim().split("\n")) {
                    const [name, model] = line.split("|")
                    if (name)
                        result[name] = (model ?? "").trim()
                }
                root.models = result
            }
        }
    }

    Process {
        id: filesystemProcess
        command: ["df", "-B1", "--output=source,size,used,avail,target",
            "-x", "tmpfs", "-x", "devtmpfs", "-x", "efivarfs", "-x", "squashfs", "-x", "overlay"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.filesystems = text.trim().split("\n").slice(1).map(line => {
                    const [device, size, used, available, ...mount] = line.trim().split(/\s+/)
                    return {
                        device: device,
                        mount: mount.join(" "),
                        size: Number(size),
                        used: Number(used),
                        available: Number(available),
                        usage: Number(size) > 0 ? Number(used) / Number(size) : 0
                    }
                })
            }
        }
    }
}
