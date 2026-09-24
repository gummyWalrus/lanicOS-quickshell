pragma Singleton

import QtQuick
import QtQml
import Quickshell
import Quickshell.Io

// Polled CPU usage (/proc/stat), frequency (cpufreq) and load (/proc/loadavg).
// Usage is a 0-1 fraction, frequencies are in MHz.
Singleton {
    id: root

    // Polling runs while at least one consumer holds a reference (see acquire() / release()).
    property int _users: 0
    readonly property bool active: _users > 0

    property int interval: 2000

    property real usage: 0
    property var coreUsage: []
    readonly property int coreCount: coreUsage.length

    property var coreFrequencies: []
    readonly property real frequency: coreFrequencies.length > 0 ? coreFrequencies.reduce((a, b) => a + b, 0) / coreFrequencies.length : 0
    readonly property real maxFrequency: coreFrequencies.length > 0 ? Math.max(...coreFrequencies) : 0

    property real load1: 0
    property real load5: 0
    property real load15: 0
    property int runningTasks: 0
    property int totalTasks: 0
    property int lastPid: 0

    readonly property string summary: {
        return Math.round(usage * 100) + "% · " + (frequency / 1000).toFixed(1) + " GHz"
    }

    readonly property string usagePercent: Math.round(usage * 100) + "%"

    property var _previous: ({})
    property var _frequencyPaths: []
    property var _frequencies: []

    // A stale sample would make the first usage after resuming an average over the whole pause.
    onActiveChanged: {
        if (!active)
            root._previous = {}
    }

    function acquire() {
        root._users++
    }

    function release() {
        root._users = Math.max(0, root._users - 1)
    }

    function parseStat(text) {
        const previous = root._previous
        const current = {}
        const usages = {}

        for (const line of text.split("\n")) {
            if (!line.startsWith("cpu"))
                continue

            const [name, ...rest] = line.trim().split(/\s+/)
            // guest and guest_nice are already counted in user and nice
            const fields = rest.slice(0, 8).map(Number)
            const idle = fields[3] + fields[4]
            const total = fields.reduce((a, b) => a + b, 0)

            current[name] = { idle, total }

            const old = previous[name]
            if (old && total > old.total)
                usages[name] = 1 - (idle - old.idle) / (total - old.total)
        }

        root._previous = current

        if (usages.cpu !== undefined)
            root.usage = usages.cpu

        const cores = Object.keys(current).filter(n => n !== "cpu").sort((a, b) => parseInt(a.slice(3)) - parseInt(b.slice(3)))
        if (cores.every(n => usages[n] !== undefined))
            root.coreUsage = cores.map(n => usages[n])
    }

    function parseLoadavg(text) {
        const [l1, l5, l15, tasks, pid] = text.trim().split(" ")
        const [running, total] = tasks.split("/")
        root.load1 = Number(l1)
        root.load5 = Number(l5)
        root.load15 = Number(l15)
        root.runningTasks = parseInt(running)
        root.totalTasks = parseInt(total)
        root.lastPid = parseInt(pid)
    }

    function parseDiscovery(text) {
        const coreIndex = path => parseInt(path.match(/cpu(\d+)\//)[1])
        root._frequencyPaths = text.trim().split("\n").filter(l => l).sort((a, b) => coreIndex(a) - coreIndex(b))
    }

    function setFrequency(index, mhz) {
        root._frequencies[index] = mhz
        frequencyCommit.restart()
    }

    Timer {
        interval: root.interval
        running: root.active
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            statFile.reload()
            loadFile.reload()
            for (let i = 0; i < frequencyFiles.count; i++)
                frequencyFiles.objectAt(i).reload()
        }
    }

    // Coalesces the per-core reads into a single update of coreFrequencies.
    Timer {
        id: frequencyCommit
        interval: 50
        onTriggered: root.coreFrequencies = root._frequencies.slice()
    }

    FileView {
        id: statFile
        path: "/proc/stat"
        onLoaded: root.parseStat(text())
    }

    FileView {
        id: loadFile
        path: "/proc/loadavg"
        onLoaded: root.parseLoadavg(text())
    }

    Instantiator {
        id: frequencyFiles
        model: root._frequencyPaths

        FileView {
            required property int index
            required property string modelData

            path: modelData
            onLoaded: root.setFrequency(index, (parseInt(text()) || 0) / 1000)
        }
    }

    Process {
        running: true
        command: ["sh", "-c", "ls -1 /sys/devices/system/cpu/cpu[0-9]*/cpufreq/scaling_cur_freq"]
        stdout: StdioCollector {
            onStreamFinished: root.parseDiscovery(text)
        }
    }
}
