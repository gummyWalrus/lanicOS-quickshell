import QtQuick
import Quickshell.Bluetooth

import qs.colors
import qs.config
import qs.fonts
import qs.services

// Bluetooth device picker. Discovery runs only while this is loaded.
Rectangle {
    id: root

    implicitHeight: Math.min(list.contentHeight + Config.contentMargin * 2, 240)
    color: Colors.surfaceContainerHigh

    border {
        color: Colors.primary
        width: 1
    }

    Component.onCompleted: if (BluetoothService.defaultAdapter)
        BluetoothService.defaultAdapter.discovering = true

    Component.onDestruction: if (BluetoothService.defaultAdapter)
        BluetoothService.defaultAdapter.discovering = false

    ListView {
        id: list

        anchors.fill: parent
        anchors.margins: Config.contentMargin
        clip: true
        spacing: 2
        model: Bluetooth.devices

        delegate: Rectangle {
            id: row

            required property BluetoothDevice modelData

            width: list.width
            height: 32
            color: {
                if (row.modelData.connected) {
                    return Colors.primary
                }
                return mouseArea.containsMouse ? Colors.primaryContainer : "transparent"
            }

            Behavior on color {
                ColorAnimation { duration: Config.msAnimationDuration }
            }

            Row {
                anchors {
                    verticalCenter: parent.verticalCenter
                    left: parent.left
                    leftMargin: Config.contentMargin
                }
                spacing: 8

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "󰂱"
                    font {
                        family: Fonts.mono
                        pixelSize: 16
                    }
                    color: row.modelData.connected ? Colors.primaryText : Colors.primary
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    visible: !row.modelData.paired
                    text: "󰌾"
                    font {
                        family: Fonts.mono
                        pixelSize: 12
                    }
                    color: row.modelData.connected ? Colors.primaryText : Colors.primary
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: row.modelData.name || row.modelData.deviceName
                    font {
                        family: Fonts.mono
                        pixelSize: 14
                        bold: row.modelData.connected
                    }
                    color: row.modelData.connected ? Colors.primaryText : Colors.primary
                }
            }

            Row {
                anchors {
                    verticalCenter: parent.verticalCenter
                    right: parent.right
                    rightMargin: Config.contentMargin
                }
                spacing: 8

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    visible: row.modelData.batteryAvailable
                    text: BluetoothService.batteryGlyph(row.modelData.battery)
                    font {
                        family: Fonts.mono
                        pixelSize: 14
                    }
                    color: row.modelData.connected ? Colors.primaryText : Colors.primary
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    visible: row.modelData.pairing || row.modelData.state === BluetoothDeviceState.Connecting || row.modelData.state === BluetoothDeviceState.Disconnecting
                    text: "󰔟"
                    font {
                        family: Fonts.mono
                        pixelSize: 14
                    }
                    color: row.modelData.connected ? Colors.primaryText : Colors.primary
                }
            }

            MouseArea {
                id: mouseArea
                anchors.fill: parent
                onClicked: BluetoothService.requestConnect(row.modelData)
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
            }
        }
    }
}
