import Quickshell
import qs.services
import QtQuick

Item {
    width: parent.slotWidth
    height: parent.slotHeight
    visible: WiredService.connected
    LazyLoader {
        active: WiredService.connected

        StateButton {
            anchors.fill: parent
            label: WiredService.label
            icon: WiredService.icon
            activated: WiredService.connected
        }
    }
}
