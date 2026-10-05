pragma ComponentBehavior: Bound

import QtQuick

import qs.types

// Drop-in Text whose glyphs carry a neon glow.
// color defaults to the ColorScheme text, the rest behaves as on a plain Text.
Text {
    id: root

    property ColorScheme colors: ColorScheme {}

    color: colors.text

    property color glowColor: root.color
    property int glowRadius: 1
    property real glowStrength: 0.55

    property bool animated: false
    property real pulseMin: 0.35
    property real pulseMax: 1.0
    property int pulseDuration: 1600

    // Multiplied into every copy's opacity, driven by the pulse animation.
    property real pulse: 1.0

    readonly property var directions: [[1, 0], [1, 1], [0, 1], [-1, 1], [-1, 0], [-1, -1], [0, -1], [1, -1]]

    // The glyphs are redrawn offset in 8 directions per ring, fading outwards.
    Repeater {
        model: root.glowStrength > 0 ? root.glowRadius * root.directions.length : 0

        delegate: Text {
            required property int index

            readonly property int ring: Math.floor(index / root.directions.length) + 1
            readonly property var direction: root.directions[index % root.directions.length]
            readonly property real falloff: 1 - ring / (root.glowRadius + 1)

            z: -1
            x: ring * direction[0]
            y: ring * direction[1]
            width: root.width
            height: root.height

            text: root.text
            font: root.font
            color: root.glowColor
            opacity: root.glowStrength * falloff * falloff * root.pulse

            horizontalAlignment: root.horizontalAlignment
            verticalAlignment: root.verticalAlignment
            elide: root.elide
            wrapMode: root.wrapMode
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
