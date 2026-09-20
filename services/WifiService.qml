pragma Singleton

import Quickshell
import Quickshell.Networking

Singleton {
    // Indexed by NetworkConnectivity::Enum: Unknown, None, Portal, Limited, Full
    readonly property var icons: [
        ["󱛇"],
        ["󰤮"],
        ["󰤬", "󰤡", "󰤤", "󰤧", "󰤪"],
        ["󰤫", "󰤠", "󰤣", "󰤦", "󰤩"],
        ["󰤯", "󰤟", "󰤢", "󰤥", "󰤨"]
    ]
    readonly property WifiDevice device: Networking.devices.values.find(d => d.type === DeviceType.Wifi) ?? null
    readonly property WifiNetwork network: device ? device.networks.values.find(n => n.connected) : null
    readonly property bool connected: !!network
    readonly property string label: connected ? network.name : "Not connected"

    // Set by requestConnect for unknown networks, drives the password dialog in shell.qml
    property WifiNetwork pendingNetwork: null

    readonly property string icon: {
        const iconList = icons[Networking.connectivity]
        if (!connected)
            return iconList[0]
        const index = Math.max(0, Math.min(iconList.length - 1, Math.round(network.signalStrength * iconList.length)))
        return iconList[index]
    }

    function requestConnect(target) {
        if (target.connected)
            target.disconnect()
        else if (target.known)
            target.connect()
        else
            pendingNetwork = target
    }
}
