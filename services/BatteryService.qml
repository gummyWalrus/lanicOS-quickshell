pragma Singleton

import Quickshell
import Quickshell.Services.UPower

import qs.config

// Wraps UPower's composite display device: whole-system battery state.
Singleton {
    readonly property var icons: ["󰂎", "󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰁹"]
    readonly property var chargingIcons: ["󰢟","󰢜", "󰂆", "󰂇", "󰂈", "󰢝", "󰂉", "󰢞", "󰂊", "󰂋", "󰂅"]
    readonly property string criticalIcon: "󱃍"
    readonly property string pluggedIcon: "󱠴"
    readonly property string fullIcon: "󱈏"

    readonly property int goodThreshold: Config.batteryGoodThreshold
    readonly property int criticalThreshold: Config.batteryCriticalThreshold

    // Indexed by UPowerDeviceState::Enum
    readonly property var stateLabels: ["Unknown", "Charging", "Discharging", "Empty", "Fully charged", "Pending charge", "Pending discharge"]

    readonly property UPowerDevice device: UPower.displayDevice
    readonly property bool available: !!device && device.isPresent

    // UPower reports percentage as energy / energyCapacity, so 0.0 - 1.0
    readonly property real charge: device ? device.percentage : 0
    readonly property int level: Math.round(charge * 100)

    readonly property bool charging: !!device && device.state === UPowerDeviceState.Charging
    readonly property string stateLabel: device ? stateLabels[device.state] : ""

    readonly property bool full: !!device && device.state === UPowerDeviceState.FullyCharged
    readonly property bool plugged: available && !UPower.onBattery && !charging && !full
    readonly property bool good: level >= goodThreshold
    readonly property bool critical: level <= criticalThreshold && !charging && !plugged && !full

    readonly property string icon: {
        if (full)
            return fullIcon
        if (charging)
            return glyph(chargingIcons)
        if (plugged)
            return pluggedIcon
        if (critical)
            return criticalIcon
        return glyph(icons)
    }

    function glyph(list) {
        const index = Math.max(0, Math.min(list.length - 1, Math.round(charge * (list.length - 1))))
        return list[index]
    }

    // Time until full while charging, until empty otherwise. Empty when unknown.
    readonly property string timeRemaining: {
        if (!device)
            return ""
        const seconds = charging ? device.timeToFull : device.timeToEmpty
        return seconds > 0 ? formatDuration(seconds) : ""
    }

    function formatDuration(seconds) {
        const hours = Math.floor(seconds / 3600)
        const minutes = Math.floor((seconds % 3600) / 60)
        return hours > 0 ? `${hours}h ${minutes}m` : `${minutes}m`
    }
}
