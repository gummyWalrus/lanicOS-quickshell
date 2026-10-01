import QtQuick

import qs.config
import qs.fonts
import qs.types

NeonRectangle {

    id: r

    signal clicked()

    function click() {
        clicked()
    }

    readonly property bool hovered: mouseArea.containsMouse

    required property bool selected

    property ColorScheme colors: ColorScheme {}

    property string leftIcons: ""
    property string labelText: ""
    property string rightIcons: ""

    property alias leftItem: leftSlot.data

    glowRadius: r.selected || mouseArea.containsMouse ? 6 : 0

    animated: r.selected || mouseArea.containsMouse

    width: parent.width
    height: 32

    color: {
        if (selected) {
            return colors.selected;
        }
        return mouseArea.containsMouse ? colors.hover : colors.background;
    }

    border {
        color: r.selected || mouseArea.containsMouse ? colors.selected : "transparent"
        width: 1
    }

    Behavior on color {
        ColorAnimation {
            duration: Config.msAnimationDuration
        }
    }

    Row {
        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
            leftMargin: Config.contentMargin
        }
        spacing: 8

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: r.leftIcons
            font {
                family: Fonts.mono
                pixelSize: 16
            }
            color: r.selected ? r.colors.textSelected : r.colors.text
        }

        Item {
            id: leftSlot
            // anchors.right: parent.left
            width: childrenRect.width; height: r.height
        }

        Text {
            id: label
            anchors.verticalCenter: parent.verticalCenter
            text: r.labelText
            font {
                family: Fonts.mono
                pixelSize: 14
                bold: r.selected
            }
            color: r.selected ? r.colors.textSelected : r.colors.text
        }
    }

    Text {
        anchors {
            verticalCenter: parent.verticalCenter
            right: parent.right
            rightMargin: Config.contentMargin
        }
        text: r.rightIcons
        font {
            family: Fonts.mono
            pixelSize: 14
        }
        color: r.selected ? r.colors.textSelected : r.colors.text
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked: r.click()
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
    }
}
