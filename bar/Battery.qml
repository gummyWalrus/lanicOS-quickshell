import QtQuick

import qs.colors
import qs.fonts
import qs.services
import qs.components
import qs.types

// Battery row. Blinks between error and surface colors when critical.
Rectangle {
    id: root

    property bool hovered: false

    readonly property bool blinking: BatteryService.critical

    property color blinkForeground: Colors.primary
    property color blinkBackground: Colors.surface

    property ColorScheme colors: ColorScheme {}

    readonly property color foreground: blinking ? blinkForeground : colors.text

    visible: BatteryService.available
    implicitWidth: row.implicitWidth + (blinking ? radius * 2 : 0)
    implicitHeight: row.implicitHeight
    radius: 4
    color: blinking ? blinkBackground : "transparent"

    Row {
        id: row

        anchors.centerIn: parent
        spacing: 8

        TextNeon {
            glowRadius: root.hovered ? 1 : 0
            animated: root.hovered
            anchors.verticalCenter: parent.verticalCenter
            text: BatteryService.icon
            font {
                family: Fonts.icon
                pixelSize: 20
            }
            color: root.foreground
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
