pragma Singleton

import Quickshell

// Session and power actions, same commands and order as the waybar custom/power menu.
Singleton {
    id: root

    readonly property string icon: "⏻"

    // separatorBefore draws a divider above the entry, like the waybar GtkSeparatorMenuItem.
    readonly property var actions: [
        { id: "lock", label: "Lock", icon: "󰒲", command: "loginctl lock-session", separatorBefore: false },
        { id: "suspend", label: "Suspend", icon: "", command: "systemctl suspend", separatorBefore: false },
        { id: "hibernate", label: "Hibernate", icon: "󰒲", command: "systemctl hibernate", separatorBefore: false },
        { id: "shutdown", label: "Shutdown", icon: "⏻", command: "hyprshutdown --no-exit && sleep 2 && shutdown now", separatorBefore: false },
        { id: "reboot", label: "Reboot", icon: "", command: "hyprshutdown --no-exit && sleep 2 && reboot", separatorBefore: true }
    ]

    function run(id) {
        const action = actions.find(a => a.id === id)
        if (action)
            Quickshell.execDetached(["sh", "-c", action.command])
    }

    function lock() { run("lock") }
    function suspend() { run("suspend") }
    function hibernate() { run("hibernate") }
    function shutdown() { run("shutdown") }
    function reboot() { run("reboot") }
}
