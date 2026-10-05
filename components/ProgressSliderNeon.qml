import QtQuick

import qs.config
import qs.types

// Click or drag anywhere on the track to set a 0.0 - 1.0 value.
Item {
    id: root

    property real value: 0
    property ColorScheme colors: ColorScheme {}

    signal moved(real value)

    implicitHeight: 8

    function positionToValue(x) {
        return Math.max(0, Math.min(1, x / root.width))
    }

    Behavior on value {
        NumberAnimation { duration: Config.msAnimationDuration; easing.type: Easing.OutCubic }
    }

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: root.colors.track

        NeonRectangle {
            width: parent.width * Math.max(0, Math.min(1, root.value))
            height: parent.height
            radius: height / 2
            colors: root.colors
            color: root.colors.selected
            border.width: 0
            glowRadius: mouseArea.containsMouse ? 6 : 4
            animated: mouseArea.containsMouse
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent

        onPressed: mouse => root.moved(root.positionToValue(mouse.x))
        onPositionChanged: mouse => {
            if (pressed)
                root.moved(root.positionToValue(mouse.x))
        }
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
    }
}
