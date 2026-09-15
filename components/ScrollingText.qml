import QtQuick

import qs.config

// Displays text at a fixed maxWidth, scrolling it back and forth
// when the content doesn't fit, then restarting from the beginning.
Item {
    id: root

    required property string text
    property font font
    required property color color
    required property real maxWidth

    readonly property bool overflowing: label.implicitWidth > root.maxWidth

    implicitWidth: Math.min(label.implicitWidth, root.maxWidth)
    implicitHeight: label.implicitHeight

    clip: true

    Text {
        id: label
        text: root.text
        font: root.font
        color: root.color

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
