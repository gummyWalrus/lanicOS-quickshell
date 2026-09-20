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
        for (device in connectedDevices) {
            if (device.icon) {
                return device.icon
            }
            return "󰂱"
        }
        return icons[defaultAdapter.state]
    }

    readonly property string label: {
        for (device in connectedDevices) {
            if (device.name) {
                return device.name
            }
            return device.deviceName
        }
        return "No connection"
    }
}