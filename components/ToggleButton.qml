import QtQuick

import qs.config
import qs.fonts
import qs.types

// Icon button with an on/off state. checked is owned by the caller: a click emits
// toggled() with the requested state, so bindings on checked are never broken.
NeonRectangle {
    id: r

    property bool checked: false
    property string icon: ""
    property int fontSize: 16
    property ColorScheme colors: ColorScheme {}

    readonly property bool hovered: mouseArea.containsMouse
    readonly property int padding: 8

    signal toggled(bool checked)

    implicitWidth: label.implicitWidth + padding * 2
    implicitHeight: label.implicitHeight + padding

    radius: height / 2
    color: checked ? colors.selected : /* hovered ? colors.hover : */ colors.background
    glowRadius: checked ? 6 : 0
    animated: hovered

    border {
        width: 1
        color: r.checked ? r.colors.border : "transparent"
    }

    Behavior on color {
        ColorAnimation {
            duration: Config.msAnimationDuration
        }
    }
    Behavior on border.color {
        ColorAnimation {
            duration: Config.msAnimationDuration
        }
    }

    TextNeon {
        id: label

        anchors.centerIn: parent
        text: r.icon
        color: r.checked ? r.colors.textSelected : r.colors.text
        glowRadius: r.hovered && !r.checked ? 1 : 0
        font {
            family: Fonts.icon
            pixelSize: r.fontSize
        }
    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: r.toggled(!r.checked)
    }
}
