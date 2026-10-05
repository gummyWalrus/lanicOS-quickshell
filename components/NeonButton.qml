import QtQuick

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

    property string text: ""

    property int fontSize: 14

    color: mouseArea.containsMouse ? colors.hover : colors.background
    animated: mouseArea.containsMouse

    Behavior on color {
        ColorAnimation { duration: Config.msAnimationDuration }
    }

    Text {
        id: textLabel
        anchors.centerIn: parent
        text: r.text
        color: r.colors.text
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
