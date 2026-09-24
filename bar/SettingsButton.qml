import QtQuick
import qs.colors
import qs.fonts
import qs.components
import qs.services

Item {
    id: root

    property bool showSettings: false

    readonly property int padding: 16

    implicitWidth: content.implicitWidth + padding * 2
    implicitHeight: content.implicitHeight

    Row {
        id: content

        anchors.centerIn: parent
        spacing: 8

        TextNeon {
            anchors.verticalCenter: parent.verticalCenter
            color: Colors.primary
            font {
                pixelSize: 16
                family: Fonts.mono
            }

            text: WifiService.icon

            glowRadius: button.containsMouse ? 1 : 0
            animated: button.containsMouse
        }

        Battery {
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    MouseArea {
        id: button
        anchors.fill: parent
        onClicked: root.showSettings = !root.showSettings
        hoverEnabled: true
    }
}
