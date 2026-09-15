pragma Singleton

import Quickshell
import Quickshell.Networking

import qs.config

Singleton {
    // Indexed by NetworkConnectivity::Enum: Unknown, None, Portal, Limited, Full
    readonly property var wifiIcons: [
        ["󱛇"],                             // Unknown
        ["󰤮"],                             // None
        ["󰤬", "󰤡", "󰤤", "󰤧", "󰤪"],         // Portal
        ["󰤫", "󰤠", "󰤣", "󰤦", "󰤩"],         // Limited
        ["󰤯", "󰤟", "󰤢", "󰤥", "󰤨"]          // Full
    ]
    
    function getIcon() {
        if (connectivity === NetworkConnectivity.Unknown) {
            return "󱛇"
        }
        if (connectivity === NetworkConnectivity.None) {
            return "󰤮"
        }
        const mainDevice = getMainDevice()

        if (mainDevice.type == DeviceType.Wired) {

        }

        if (mainDevice.type == DeviceType.Wifi) {
            const iconList = wifiIcons[connectivity]
            const iconIndex = Math.max(0, Math.round((getConnectedNetwork(mainDevice) as WifiNetwork).signalStrength * iconList.length))
            return iconList[iconIndex]
        }

        return "caca"

    }

    function getConnectedNetwork(device : NetworkDevice) : Network {
        return device.networks.values.find(n => n.connected)
    }

    function getMainDevice() {
        for (const device of Networking.devices.values) {
            console.log("Found networking device :", device)

            if (device.type == "Wired" && device.connected) {
                return device
            }
            if (device.connected) {
                return device
            }
        };
        return Networking.devices.values.find((dev) => dev.type == Config.defaultNetworkDeviceType)
    }

    readonly property string connectivity : Networking.connectivity
    // readonly property string icon : 
}