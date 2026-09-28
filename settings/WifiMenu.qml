import QtQuick
import Quickshell.Networking

import qs.colors
import qs.config
import qs.services
import qs.components

// Wifi network picker. Scanning runs only while this is loaded.
Rectangle {
    id: root

    implicitHeight: Math.min(list.contentHeight + Config.contentMargin * 2, 240)
    color: Colors.surface

    border {
        color: Colors.primary
        width: 1
    }

    Component.onCompleted: if (WifiService.device)
        WifiService.device.scannerEnabled = true

    Component.onDestruction: if (WifiService.device)
        WifiService.device.scannerEnabled = false

    ListView {
        id: list

        anchors.fill: parent
        anchors.margins: Config.contentMargin
        clip: true
        spacing: Config.contentMargin
        model: WifiService.device ? WifiService.device.networks : null
        
        
        delegate: NeonMenuItem {
            id: row

            required property WifiNetwork modelData

            readonly property var iconList: WifiService.icons[WifiService.icons.length - 1]

            selected: row.modelData.connected
            
            onClicked: WifiService.requestConnect(row.modelData)
            
            readonly property string signalStrengthIcon: row.iconList[Math.max(0, Math.min(row.iconList.length - 1, Math.round(row.modelData.signalStrength * row.iconList.length)))]

            leftIcons: signalStrengthIcon + row.modelData.security !== WifiSecurityType.Open ? " 󰌾" : ""
            labelText: row.modelData.name
            rightIcons: row.modelData.stateChanging ? "󰔟" : ""
        }
    }
}
