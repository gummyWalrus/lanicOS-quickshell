import QtQuick

import qs.colors
import qs.fonts
import qs.services
import qs.components

// Battery row. Below the critical threshold it blinks between error and surface colors,
// mimicking waybar's blink_error animation (0.5s, steps(12), infinite, alternate).
Rectangle {
    id: root

    property bool hovered: false 

    readonly property bool blinking: BatteryService.critical
    readonly property int steps: 12

    // 0 is the error look, 1 the normal look; quantized like CSS steps().
    property real phase: 1
    readonly property real steppedPhase: Math.round(phase * steps) / steps

    readonly property color foreground: blinking ? mix(Colors.errorText, Colors.primary, steppedPhase) : Colors.primary

    function mix(a, b, t) {
        return Qt.rgba(a.r + (b.r - a.r) * t, a.g + (b.g - a.g) * t, a.b + (b.b - a.b) * t, a.a + (b.a - a.a) * t)
    }

    visible: BatteryService.available
    implicitWidth: row.implicitWidth + (blinking ? radius * 2 : 0)
    implicitHeight: row.implicitHeight
    radius: 0
    color: blinking ? mix(Colors.error, Colors.surface, steppedPhase) : "transparent"

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
                family: Fonts.mono
                pixelSize: 20
            }
            color: root.foreground
        }
    }

    SequentialAnimation {
        running: root.blinking && root.visible
        loops: Animation.Infinite

        onRunningChanged: if (!running)
            root.phase = 1

        NumberAnimation {
            target: root
            property: "phase"
            from: 0
            to: 1
            duration: 500
        }
        NumberAnimation {
            target: root
            property: "phase"
            from: 1
            to: 0
            duration: 500
        }
    }
}
