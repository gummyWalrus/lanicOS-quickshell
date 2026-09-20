import QtQuick
import Quickshell.Networking

import qs.colors
import qs.config
import qs.fonts
import qs.services

// Wifi network picker. Scanning runs only while this is loaded.
Rectangle {
    id: root

    implicitHeight: Math.min(list.contentHeight + Config.contentMargin * 2, 240)
    color: Colors.surfaceContainerHigh

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
        spacing: 2
        model: WifiService.device ? WifiService.device.networks : null

        delegate: Rectangle {
            id: row

            required property WifiNetwork modelData

            readonly property var iconList: WifiService.icons[WifiService.icons.length - 1]

            width: list.width
            height: 32
            color: row.modelData.connected ? Colors.primary : "transparent"

            Row {
                anchors {
                    verticalCenter: parent.verticalCenter
                    left: parent.left
                    leftMargin: Config.contentMargin
                }
                spacing: 8

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: row.iconList[Math.max(0, Math.min(row.iconList.length - 1, Math.round(row.modelData.signalStrength * row.iconList.length)))]
                    font {
                        family: Fonts.mono
                        pixelSize: 16
                    }
                    color: row.modelData.connected ? Colors.primaryText : Colors.primary
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    visible: row.modelData.security !== WifiSecurityType.Open
                    text: "󰌾"
                    font {
                        family: Fonts.mono
                        pixelSize: 12
                    }
                    color: row.modelData.connected ? Colors.primaryText : Colors.primary
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: row.modelData.name
                    font {
                        family: Fonts.mono
                        pixelSize: 14
                        bold: row.modelData.connected
                    }
                    color: row.modelData.connected ? Colors.primaryText : Colors.primary
                }
            }

            Text {
                anchors {
                    verticalCenter: parent.verticalCenter
                    right: parent.right
                    rightMargin: Config.contentMargin
                }
                visible: row.modelData.stateChanging
                text: "󰔟"
                font {
                    family: Fonts.mono
                    pixelSize: 14
                }
                color: row.modelData.connected ? Colors.primaryText : Colors.primary
            }

            MouseArea {
                anchors.fill: parent
                onClicked: WifiService.requestConnect(row.modelData)
            }
        }
    }
}
