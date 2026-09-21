import QtQuick

import qs.colors

// Click or drag anywhere on the track to set a 0.0 - 1.0 value.
Item {
    id: root

    property real value: 0
    property color fillColor: Colors.primary
    property color trackColor: Colors.primaryText

    signal moved(real value)

    implicitHeight: 8

    function positionToValue(x) {
        return Math.max(0, Math.min(1, x / root.width))
    }

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: root.trackColor

        Rectangle {
            width: parent.width * Math.max(0, Math.min(1, root.value))
            height: parent.height
            radius: height / 2
            color: root.fillColor
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
