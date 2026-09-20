pragma Singleton

import Quickshell
import Quickshell.Bluetooth

Singleton {

    readonly property var icons: [
        "󰂲", "󰂯", "󰂳", "󰂳", "󰂲" 
    ]

    readonly property var batteryIcon: [
        "󰤾", "󰤿", "󰥀", "󰥁", "󰥂", "󰥃", "󰥄", "󰥅", "󰥈"
    ]

    readonly property list<BluetoothDevice> connectedDevices: Bluetooth.devices.values.filter(d => d.connected)

    readonly property BluetoothAdapter defaultAdapter: Bluetooth.defaultAdapter

    readonly property string icon: {
        if (connectedDevices.length > 0)
            return "󰂱"
        return defaultAdapter ? icons[defaultAdapter.state] : icons[0]
    }

    readonly property string label: {
        if (connectedDevices.length > 0)
            return connectedDevices[0].name || connectedDevices[0].deviceName
        return "No connection"
    }

    function requestConnect(device) {
        if (device.connected)
            device.disconnect()
        else if (device.paired)
            device.connect()
        else
            device.pair()
    }

    function batteryGlyph(level) {
        const index = Math.max(0, Math.min(batteryIcon.length - 1, Math.round(level * (batteryIcon.length - 1))))
        return batteryIcon[index]
    }
}