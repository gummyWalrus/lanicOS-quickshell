import QtQuick
import qs.colors
import qs.fonts

Item {
    id: root

    property bool showSettings: false

    readonly property int padding: 16

    implicitWidth: label.implicitWidth + padding * 2
    implicitHeight: label.implicitHeight

    Text {
        id: label
        text: "click"
        color: Colors.primary
        font {
            pixelSize: 16
            family: Fonts.mono
        }
    }

    MouseArea {
        id: button
        anchors.fill: parent
        onClicked: root.showSettings = !root.showSettings
    }
}