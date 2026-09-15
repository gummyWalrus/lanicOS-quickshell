import QtQuick
import Quickshell.Hyprland
import qs.colors
import qs.fonts

Item {
    id: r

    required property HyprlandWorkspace modelData

    readonly property int padding: 16

    implicitWidth: label.implicitWidth + padding * 2
    implicitHeight: label.implicitHeight

    Text {
        id: label
        anchors.centerIn: parent
        text: r.modelData.name + " " + Icons.iconFor(r.modelData.id)
        color: r.modelData.active ? Colors.primary : Colors.primaryText
        font {
            family: Fonts.mono
            pixelSize: 16
            bold: true
        }
    }

}