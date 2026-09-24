pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// CPU temperature from /sys/class/thermal, scaled between 0 °C and the critical temperature
// reported by the coretemp hwmon. The zone and that limit are discovered once at startup.
Singleton {
    id: root

    // Polling runs while at least one consumer holds a reference (see acquire() / release()).
    property int _users: 0
    readonly property bool active: _users > 0

    property int interval: 2000

    // Thermal zone types tried in order to find the CPU.
    readonly property var zoneTypes: ["x86_pkg_temp", "cpu-thermal", "cpu_thermal", "TCPU", "acpitz"]
    readonly property real fallbackMaxTemperature: 100

    readonly property var icons: ["", "", "", "", ""]

    property string _zonePath: ""

    readonly property real minTemperature: 0
    property real maxTemperature: fallbackMaxTemperature
    property real temperature: 0
    readonly property bool available: _zonePath !== ""

    // 0-1 position of the temperature between minTemperature and maxTemperature.
    readonly property real ratio: Math.max(0, Math.min(1, (temperature - minTemperature) / (maxTemperature - minTemperature)))
    readonly property string icon: icons[Math.min(icons.length - 1, Math.floor(ratio * icons.length))]

    function acquire() {
        root._users++
    }

    function release() {
        root._users = Math.max(0, root._users - 1)
    }

    function parseDiscovery(text) {
        const zones = []
        let critical = 0

        for (const line of text.trim().split("\n")) {
            const [kind, a, b] = line.split("|")
            if (kind === "zone")
                zones.push({ path: a, type: b })
            else if (kind === "crit")
                critical = Number(a) / 1000
        }

        const zone = root.zoneTypes.map(type => zones.find(z => z.type === type)).find(z => z) ?? zones[0]
        if (!zone)
            return

        if (critical > 0)
            root.maxTemperature = critical
        root._zonePath = zone.path
    }

    Timer {
        interval: root.interval
        running: root.active
        repeat: true
        triggeredOnStart: true
        onTriggered: temperatureFile.reload()
    }

    FileView {
        id: temperatureFile
        path: root._zonePath !== "" ? root._zonePath + "/temp" : ""
        onLoaded: root.temperature = (parseInt(text()) || 0) / 1000
    }

    Process {
        running: true
        command: ["sh", "-c", 'for z in /sys/class/thermal/thermal_zone*; do echo "zone|$z|$(cat $z/type)"; done; for d in /sys/class/hwmon/hwmon*; do case $(cat $d/name) in coretemp|k10temp) echo "crit|$(cat $d/temp1_crit)"; break;; esac; done']
        stdout: StdioCollector {
            onStreamFinished: root.parseDiscovery(text)
        }
    }
}
