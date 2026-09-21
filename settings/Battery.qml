import QtQuick

import qs.colors
import qs.fonts
import qs.services

Row {
    id: root

    visible: BatteryService.available
    spacing: 8

    Text {
        anchors.verticalCenter: parent.verticalCenter
        text: BatteryService.icon
        font {
            family: Fonts.mono
            pixelSize: 20
        }
        color: Colors.primary
    }

    Text {
        anchors.verticalCenter: parent.verticalCenter
        text: BatteryService.level + "%"
        font {
            family: Fonts.mono
            pixelSize: 16
            bold: true
        }
        color: Colors.primary
    }

    Text {
        anchors.verticalCenter: parent.verticalCenter
        visible: BatteryService.timeRemaining !== ""
        text: BatteryService.timeRemaining + (BatteryService.charging ? " to full" : " left")
        font {
            family: Fonts.mono
            pixelSize: 12
        }
        color: Colors.primaryText
    }
}
