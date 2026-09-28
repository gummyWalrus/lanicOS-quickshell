import QtQuick
import Quickshell.Bluetooth

import qs.colors
import qs.config
import qs.services
import qs.components

// Bluetooth device picker. Discovery runs only while this is loaded.
Rectangle {
    id: root

    implicitHeight: Math.min(list.contentHeight + Config.contentMargin * 2, 240)
    color: Colors.surface

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
        spacing: Config.contentMargin
        model: Bluetooth.devices

        delegate: NeonMenuItem {
            id: row
            required property BluetoothDevice modelData

            function buildLeftIcons() {
                if (row.modelData.connected) {
                    return "󰂱"
                }
                if (!row.modelData.paired) {
                    return "󰌾"
                }
                return ""
            }

            selected: row.modelData.connected

            onClicked: BluetoothService.requestConnect(row.modelData)

            readonly property bool busy: row.modelData.pairing
            || row.modelData.state === BluetoothDeviceState.Connecting
            || row.modelData.state === BluetoothDeviceState.Disconnecting
            rightIcons: (row.modelData.batteryAvailable ? BluetoothService.batteryGlyph(row.modelData.battery) : "")
            + (busy ? "󰔟" : "")

            leftIcons: row.modelData.connected ? "󰂱" : !row.modelData.paired ? "󰌾" : ""
            labelText: row.modelData.name || row.modelData.deviceName
        }
    }
}
