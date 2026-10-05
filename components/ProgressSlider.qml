import QtQuick

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

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: root.colors.track

        Rectangle {
            width: parent.width * Math.max(0, Math.min(1, root.value))
            height: parent.height
            radius: height / 2
            color: root.colors.selected
        }
    }

    MouseArea {
        anchors.fill: parent

        onPressed: mouse => root.moved(root.positionToValue(mouse.x))
        onPositionChanged: mouse => {
            if (pressed)
                root.moved(root.positionToValue(mouse.x))
        }
        cursorShape: Qt.PointingHandCursor
        // hoverEnabled: true
    }
}
