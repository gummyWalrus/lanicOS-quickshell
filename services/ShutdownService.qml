pragma Singleton

import Quickshell

// Session and power actions, same order as the waybar custom/power menu.
// hyprshutdown closes apps and exits Hyprland before running the -p command.
Singleton {
    id: root

    readonly property string icon: "⏻"

    // separatorBefore draws a divider above the entry, like the waybar GtkSeparatorMenuItem.
    readonly property var actions: [
        { id: "lock", label: "Lock", icon: "", command: "loginctl lock-session", separatorBefore: false },
        { id: "suspend", label: "Suspend", icon: "", command: "systemctl suspend", separatorBefore: false },
        { id: "hibernate", label: "Hibernate", icon: "󰒲", command: "systemctl hibernate", separatorBefore: false },
        { id: "shutdown", label: "Shutdown", icon: "⏻", command: "hyprshutdown -p 'systemctl poweroff'", separatorBefore: false },
        { id: "logout", label: "Logout", icon: "󰍃", command: "hyprshutdown -t 'Logging out...'", separatorBefore: true },
        { id: "reboot", label: "Reboot", icon: "", command: "hyprshutdown -t 'Rebooting...' -p 'systemctl reboot'", separatorBefore: false }
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
    function logout() { run("logout") }
    function reboot() { run("reboot") }
}
