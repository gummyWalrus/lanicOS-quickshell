pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io

// Keyboard layouts of Hyprland's main keyboard. State is seeded from `hyprctl devices -j` and
// refreshed on the activelayout / configreloaded IPC events, switching goes through hyprctl.
Singleton {
    id: root

    readonly property string icon: "󰌌"

    property string keyboard: ""
    // xkb layout codes in config order, e.g. ["us", "fr"]
    property var layouts: []
    property var variants: []
    property int activeIndex: 0
    // Human readable xkb name, e.g. "English (US)"
    property string activeKeymap: ""
    property bool capsLock: false
    property bool numLock: false

    readonly property bool available: keyboard !== ""
    readonly property string layout: layouts[activeIndex] ?? ""
    // Short uppercase label, like waybar's format-us / format-fr
    readonly property string label: layout.toUpperCase()

    function next() {
        switchLayout("next")
    }

    function previous() {
        switchLayout("prev")
    }

    function setLayout(index) {
        if (index >= 0 && index < layouts.length)
            switchLayout(String(index))
    }

    function switchLayout(target) {
        switchProcess.command = ["hyprctl", "switchxkblayout", "current", target]
        switchProcess.running = true
    }

    function refresh() {
        devicesProcess.running = true
    }

    function parseDevices(text) {
        let keyboards = []
        try {
            keyboards = JSON.parse(text).keyboards ?? []
        } catch (e) {
            return
        }

        const main = keyboards.find(k => k.main) ?? keyboards[0]
        if (!main)
            return

        root.keyboard = main.name
        root.layouts = main.layout.split(",").map(l => l.trim())
        root.variants = main.variant.split(",").map(v => v.trim())
        root.activeIndex = main.active_layout_index
        root.activeKeymap = main.active_keymap
        root.capsLock = main.capsLock
        root.numLock = main.numLock
    }

    Connections {
        target: Hyprland

        function onRawEvent(event) {
            if (event.name === "activelayout") {
                const [name, keymap] = event.parse(2)
                if (name !== root.keyboard)
                    return
                root.activeKeymap = keymap
                root.refresh()
            } else if (event.name === "configreloaded") {
                root.refresh()
            }
        }
    }

    Process {
        id: devicesProcess
        running: true
        command: ["hyprctl", "devices", "-j"]
        stdout: StdioCollector {
            onStreamFinished: root.parseDevices(text)
        }
    }

    Process {
        id: switchProcess
    }
}
