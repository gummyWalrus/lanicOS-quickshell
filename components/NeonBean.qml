import QtQuick

import qs.fonts
import qs.config

// Pill-shaped neon label with an optional icon. Width follows the content unless set.
// Glow knobs (glowColor, glowRadius, glowStrength, animated) are inherited from NeonRectangle.
NeonRectangle {
    id: root

    property string icon: ""
    property string text: ""
    property int fontSize: 14

    readonly property int horizontalPadding: 12
    readonly property int verticalPadding: 4

    implicitWidth: content.implicitWidth + horizontalPadding * 2
    implicitHeight: content.implicitHeight + verticalPadding * 2
    radius: height / 2

    Behavior on border.color {
        ColorAnimation {
            duration: Config.msAnimationDuration
        }
    }

    Behavior on color {
        ColorAnimation {
            duration: Config.msAnimationDuration
        }
    }

    Row {
        id: content

        anchors.centerIn: parent
        spacing: 8

        Text {
            anchors.verticalCenter: parent.verticalCenter
            visible: root.icon !== ""
            text: root.icon
            color: root.colors.text
            font {
                family: Fonts.mono
                pixelSize: root.fontSize
            }
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            visible: root.text !== ""
            text: root.text
            color: root.colors.text
            font {
                family: Fonts.mono
                pixelSize: root.fontSize
            }
        }
    }
}
