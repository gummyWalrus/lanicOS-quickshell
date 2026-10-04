pragma Singleton

import Quickshell

// Login screen power actions, shaped like ShutdownService so bar/ShutdownButton can show them.
Singleton {
    readonly property string icon: "⏻"

    readonly property var actions: [
        { id: "suspend", label: "Suspend", icon: "", iconPath: Quickshell.shellDir + "/assets/Suspend.svg", command: ["systemctl", "suspend"] },
        { id: "hibernate", label: "Hibernate", icon: "󰒲", iconPath: Quickshell.shellDir + "/assets/Hibernate.svg", command: ["systemctl", "hibernate"] },
        { id: "reboot", label: "Reboot", icon: "", iconPath: Quickshell.shellDir + "/assets/Reboot.svg", command: ["systemctl", "reboot"] },
        { id: "shutdown", label: "Shutdown", icon: "⏻", iconPath: Quickshell.shellDir + "/assets/Shutdown.svg", command: ["systemctl", "poweroff"] }
    ]

    function run(id) {
        const action = actions.find(a => a.id === id)
        if (action)
            Quickshell.execDetached(action.command)
    }
}
