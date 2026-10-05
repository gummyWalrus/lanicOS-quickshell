import QtQuick

import qs.config
import qs.types

// Drop-in Rectangle whose border carries a neon glow, outside and in.
// color and border default to the ColorScheme, both stay overridable.
Rectangle {
    id: root

    property ColorScheme colors: ColorScheme {}

    property color glowColor: root.border.color
    property int glowRadius: 6
    property int innerGlowRadius: Math.round(root.glowRadius / 2)
    property real glowStrength: 0.65

    property bool animated: false
    property real pulseMin: 0.7
    property real pulseMax: 1.5
    property int pulseDuration: 1600

    // Multiplied into every layer's opacity, driven by the pulse animation.
    property real pulse: 1.0

    color: colors.background

    border {
        color: colors.border
        width: 1
    }

    readonly property int innerLayers: Math.max(0, Math.min(innerGlowRadius, Math.floor(Math.min(width, height) / 2) - 1))

    Behavior on pulse {
        NumberAnimation { duration: Config.msAnimationDuration; easing.type: Easing.OutCubic }
    }
    Behavior on glowRadius {
        NumberAnimation { duration: Config.msAnimationDuration; easing.type: Easing.OutCubic }
    }
    // Outer halo. Corners round off as it spreads so the glow reads as
    // diffused light rather than a stack of square outlines.
    Repeater {
        model: root.glowStrength > 0 ? root.glowRadius : 0

        delegate: Rectangle {
            required property int index

            readonly property real falloff: 1 - (index + 1) / (root.glowRadius + 1)

            z: -1
            anchors.centerIn: parent
            width: root.width + (index + 1) * 2
            height: root.height + (index + 1) * 2
            radius: root.radius + index + 1
            color: "transparent"
            opacity: root.glowStrength * falloff * falloff * falloff * root.pulse

            // 1px rings at 1px spacing tile exactly, so opacity does not accumulate.
            border {
                width: 1
                color: root.glowColor
            }
        }
    }

    // Inner halo. Declared here so it paints over the fill but under anything
    // a consumer of this component adds, keeping labels legible.
    Repeater {
        model: root.glowStrength > 0 ? root.innerLayers : 0

        delegate: Rectangle {
            required property int index

            readonly property real falloff: 1 - (index + 1) / (root.innerGlowRadius + 1)

            anchors.centerIn: parent
            width: root.width - (index + 1) * 2
            height: root.height - (index + 1) * 2
            radius: Math.max(0, root.radius - index - 1)
            color: "transparent"
            opacity: root.glowStrength * falloff * falloff * root.pulse

            border {
                width: 1
                color: root.glowColor
            }
        }
    }

    SequentialAnimation {
        running: root.animated
        loops: Animation.Infinite

        onRunningChanged: if (!running)
            root.pulse = 1.0

        NumberAnimation {
            target: root
            property: "pulse"
            from: root.pulseMax
            to: root.pulseMin
            duration: root.pulseDuration / 2
            easing.type: Easing.InOutSine
        }
        NumberAnimation {
            target: root
            property: "pulse"
            from: root.pulseMin
            to: root.pulseMax
            duration: root.pulseDuration / 2
            easing.type: Easing.InOutSine
        }
    }
}
