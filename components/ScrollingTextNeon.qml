import QtQuick

import qs.config

// ScrollingText whose glyphs carry a neon glow.
// Height is padded by glowRadius so the halo is not clipped vertically.
Item {
    id: root

    required property string text
    property font font
    required property color color
    required property real maxWidth

    property color glowColor: root.color
    property int glowRadius: 1
    property real glowStrength: 0.55

    property bool animated: false
    property real pulseMin: 0.35
    property int pulseDuration: 1600

    readonly property bool overflowing: label.implicitWidth > root.maxWidth

    implicitWidth: Math.min(label.implicitWidth, root.maxWidth)
    implicitHeight: label.implicitHeight + root.glowRadius * 2

    clip: true

    TextNeon {
        id: label

        anchors.verticalCenter: parent.verticalCenter

        text: root.text
        font: root.font
        color: root.color

        glowColor: root.glowColor
        glowRadius: root.glowRadius
        glowStrength: root.glowStrength
        animated: root.animated
        pulseMin: root.pulseMin
        pulseDuration: root.pulseDuration

        SequentialAnimation {
            running: root.overflowing
            loops: Animation.Infinite

            onRunningChanged: if (!running)
                label.x = 0

            PauseAnimation { duration: Config.msPauseText }
            NumberAnimation {
                target: label
                property: "x"
                from: 0
                to: root.maxWidth - label.implicitWidth
                duration: Config.msPerCharacter * root.text.length
                easing.type: Easing.Linear
            }
            PauseAnimation { duration: 1000 }
            PropertyAction { target: label; property: "x"; value: 0 }
        }
    }
}
