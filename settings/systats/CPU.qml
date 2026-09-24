import QtQuick

import qs.colors
import qs.fonts
import qs.services

Row {
    id: root

    spacing: 8

    Text {
        anchors.verticalCenter: parent.verticalCenter
        text: ""
        font {
            family: Fonts.mono
            pixelSize: 16
        }
        color: Colors.primary
    }

    Text {
        anchors.verticalCenter: parent.verticalCenter
        text: CPUService.summary
        font {
            family: Fonts.mono
            pixelSize: 12
        }
        color: Colors.primary
    }

    Component.onCompleted: CPUService.acquire()

    Component.onDestruction: CPUService.release()
}
