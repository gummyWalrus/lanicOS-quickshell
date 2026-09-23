import QtQuick

import qs.fonts
import qs.colors
import qs.components
import qs.config

// StateButton with a glowing border. Glow knobs (glowColor, glowRadius,
// glowStrength, animated) are inherited from NeonRectangle.
NeonRectangle {
    id: r
    required property bool activated
    required property string label
    required property string icon

    property Component menu: null
    property bool menuOpen: false
    signal menuToggled()

    readonly property int padding: 12

    animated: mouseArea.containsMouse
    border {
        color: Colors.primary
        width: 1
    }

    Behavior on color {
        ColorAnimation { duration: Config.msAnimationDuration }
    }

    color: {
        if (activated) {
            return Colors.primary
        }
        mouseArea.containsMouse ? Colors.primaryContainer : Colors.surface
    }

    Row {
        id: content

        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
            leftMargin: r.padding
        }
        spacing: 16

        TextNeon {
            glowRadius: r.activated ? 0 : 1
            id: icon
            anchors.verticalCenter: parent.verticalCenter
            text: r.icon
            font {
                family: Fonts.mono
                pixelSize: 24
            }
            color: r.activated ? Colors.primaryText : Colors.primary
        }

        ScrollingText {
            anchors.verticalCenter: parent.verticalCenter

            text: r.label
            font {
                family: Fonts.mono
                pixelSize: 16
            }
            color: r.activated ? Colors.primaryText : Colors.primary
            maxWidth: r.width - r.padding * 2 - icon.implicitWidth - content.spacing - (menuToggle.visible ? menuToggle.width : 0)
        }
    }

    Rectangle {
        id: menuToggle

        anchors {
            right: parent.right
            top: parent.top
            bottom: parent.bottom
        }
        width: 32
        visible: r.menu !== null
        color: "transparent"

        TextNeon {
            glowRadius: r.activated ? 0 : 1
            anchors.centerIn: parent
            text: "󰅀"
            rotation: r.menuOpen ? 180 : 0
            font {
                family: Fonts.mono
                pixelSize: 16
            }
            color: r.activated ? Colors.primaryText : Colors.primary

            Behavior on rotation {
                NumberAnimation { duration: Config.msAnimationDuration }
            }
        }
    }
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked: r.menuToggled()
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
    }
}
