import QtQuick
import Quickshell.Networking

import qs.services
import qs.config

StateButton {
    id: wifi
    width: (Config.settingsPanelWidth / 2) - Config.contentMargin * 2
    height: 42

    readonly property NetworkDevice currentDevice: NetworkService.getMainDevice()
    readonly property Network currentNetwork: NetworkService.getConnectedNetwork(currentDevice)
    
    label: currentNetwork ? currentNetwork.name : "Not connected"
    
    icon: NetworkService.getIcon()
    activated: currentNetwork ? currentNetwork.connected : false


    Component.onCompleted: console.log("Loaded NetworkButton : ", NetworkService.connectivity)
}