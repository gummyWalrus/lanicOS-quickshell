pragma Singleton

import Quickshell
import Quickshell.Networking

Singleton {
    readonly property string icon: "󰈀" // placeholder glyph, swap to taste

    readonly property NetworkDevice device: Networking.devices.values.find(d => d.type === DeviceType.Wired) ?? null
    readonly property Network network: device ? device.networks.values.find(n => n.connected) : null
    readonly property bool connected: !!network
    readonly property string label: connected ? network.name : "Not connected"
}
