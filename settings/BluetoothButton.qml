import QtQuick
import qs.services

StateButton {
    anchors.fill: parent

    label: BluetoothService.label
    icon: BluetoothService.icon
    activated: BluetoothService.connectedDevices.length > 0

    menu: Component { BluetoothMenu {} }
}
