import QtQuick
import qs.services

StateButtonNeon {
    anchors.fill: parent

    label: WifiService.label
    icon: WifiService.icon
    activated: WifiService.connected

    menu: Component { WifiMenu {} }
}
