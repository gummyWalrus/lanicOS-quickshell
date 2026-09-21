pragma Singleton

import Quickshell
import Quickshell.Io

import qs.config

// Backlight level read from sysfs and written through brightnessctl.
Singleton {
    id: root

    readonly property var icons: ["󰃟"]

    readonly property string devicePath: "/sys/class/backlight/" + Config.backlightDevice

    readonly property int max: parseInt(maxFile.text()) || 0
    readonly property int current: parseInt(currentFile.text()) || 0
    readonly property bool available: max > 0
    readonly property real brightness: available ? current / max : 0

    readonly property string icon: {
        const index = Math.max(0, Math.min(icons.length - 1, Math.round(brightness * (icons.length - 1))))
        return icons[index]
    }

    // Never goes to 0, which would leave the screen unreadable.
    function setBrightness(value) {
        const percent = Math.round(Math.max(0.01, Math.min(1, value)) * 100)
        setProcess.running = false
        setProcess.command = ["brightnessctl", "--device", Config.backlightDevice, "set", `${percent}%`]
        setProcess.running = true
    }

    FileView {
        id: currentFile
        path: root.devicePath + "/brightness"
        watchChanges: true
    }

    FileView {
        id: maxFile
        path: root.devicePath + "/max_brightness"
    }

    Process {
        id: setProcess
        onExited: currentFile.reload()
    }
}
