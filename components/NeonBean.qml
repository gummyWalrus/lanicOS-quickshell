import QtQuick

import qs.colors
import qs.fonts

// Pill-shaped neon label with an optional icon. Width follows the content unless set.
// Glow knobs (glowColor, glowRadius, glowStrength, animated) are inherited from NeonRectangle.
NeonRectangle {
    id: root

    property string icon: ""
    property string text: ""
    property color borderColor: Colors.primary
    property color textColor: Colors.primary
    property int fontSize: 14

    readonly property int horizontalPadding: 12
    readonly property int verticalPadding: 4

    implicitWidth: content.implicitWidth + horizontalPadding * 2
    implicitHeight: content.implicitHeight + verticalPadding * 2
    radius: height / 2
    color: Colors.surface

    border {
        color: root.borderColor
        width: 1
    }

    Row {
        id: content

        anchors.centerIn: parent
        spacing: 8

        Text {
            anchors.verticalCenter: parent.verticalCenter
            visible: root.icon !== ""
            text: root.icon
            color: root.textColor
            font {
                family: Fonts.mono
                pixelSize: root.fontSize
            }
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            visible: root.text !== ""
            text: root.text
            color: root.textColor
            font {
                family: Fonts.mono
                pixelSize: root.fontSize
            }
        }
    }
}
