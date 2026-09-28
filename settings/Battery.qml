import QtQuick

import qs.colors
import qs.fonts
import qs.services

// Battery row. Blinks between error and surface colors when critical.
Rectangle {
    id: root

    readonly property bool blinking: BatteryService.critical

    property color blinkForeground: Colors.primary
    property color blinkBackground: Colors.surface

    readonly property color foreground: blinking ? blinkForeground : Colors.primary

    visible: BatteryService.available
    implicitWidth: row.implicitWidth + (blinking ? radius * 2 : 0)
    implicitHeight: row.implicitHeight
    radius: 4
    color: blinking ? blinkBackground : "transparent"

    Row {
        id: row

        anchors.centerIn: parent
        spacing: 8

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: BatteryService.icon
            font {
                family: Fonts.mono
                pixelSize: 20
            }
            color: root.foreground
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: BatteryService.level + "%"
            font {
                family: Fonts.mono
                pixelSize: 16
                bold: true
            }
            color: root.foreground
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            visible: BatteryService.timeRemaining !== ""
            text: BatteryService.timeRemaining + (BatteryService.charging ? " to full" : " left")
            font {
                family: Fonts.mono
                pixelSize: 12
            }
            color: root.blinking ? root.foreground : Colors.primaryText
        }
    }

    SequentialAnimation {
        running: root.blinking && root.visible
        loops: Animation.Infinite

        ParallelAnimation {
            ColorAnimation {
                target: root
                property: "blinkForeground"
                from: Colors.errorText
                to: Colors.primary
                duration: 500
            }
            ColorAnimation {
                target: root
                property: "blinkBackground"
                from: Colors.error
                to: Colors.surface
                duration: 500
            }
        }
        ParallelAnimation {
            ColorAnimation {
                target: root
                property: "blinkForeground"
                from: Colors.primary
                to: Colors.errorText
                duration: 500
            }
            ColorAnimation {
                target: root
                property: "blinkBackground"
                from: Colors.surface
                to: Colors.error
                duration: 500
            }
        }
    }
}
