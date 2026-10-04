import QtQuick

import qs.colors
import qs.fonts
import qs.config

NeonRectangle {
    id: r

    signal clicked()

    function onClicked() {
        clicked()
    }

    implicitWidth: textLabel.implicitWidth + 32
    implicitHeight: 30
    // TODO : signal hovered()

    property color hoverColor: Colors.primaryContainer
    property color bgColor: Colors.surface
    property color borderColor: Colors.primary
    property color textColor: Colors.primary

    property string text: ""

    property int fontSize: 14

    color: mouseArea.containsMouse ? hoverColor : bgColor
    animated: mouseArea.containsMouse

    Behavior on color {
        ColorAnimation { duration: Config.msAnimationDuration }
    }

    border {
        color: borderColor
        width: 1
    }

    Text {
        id: textLabel
        anchors.centerIn: parent
        text: r.text
        color: r.textColor
        font {
            family: Fonts.mono
            pixelSize: r.fontSize
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked: r.onClicked()
        hoverEnabled: true
    }
}
