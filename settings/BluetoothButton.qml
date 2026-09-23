import QtQuick
import qs.services

StateButtonNeon {
    anchors.fill: parent

    label: BluetoothService.label
    icon: BluetoothService.icon
    activated: BluetoothService.connectedDevices.length > 0

    menu: Component { BluetoothMenu {} }
}
