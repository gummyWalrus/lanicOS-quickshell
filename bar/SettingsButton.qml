import QtQuick
import qs.colors
import qs.fonts
import qs.components
import qs.services

NeonBean {
    id: r

    property bool showSettings: false

    readonly property int padding: 16

    implicitWidth: content.implicitWidth + padding * 2
    implicitHeight: content.implicitHeight

    colors.hover: Colors.surfaceContainerHigh
    colors.border: Colors.surface

    border.color: showSettings ? colors.selected : colors.border

    glowRadius: showSettings ? 6 : 0
    color: showSettings ? colors.selected : button.containsMouse ? colors.hover : colors.background
    animated: showSettings

    Row {
        id: content

        anchors.centerIn: parent
        spacing: 12

        TextNeon {
            anchors.verticalCenter: parent.verticalCenter
            color: r.showSettings ? r.colors.textSelected : r.colors.text
            font {
                pixelSize: 16
                family: Fonts.icon
            }

            text: WifiService.icon

            glowRadius: button.containsMouse ? 1 : 0
            animated: button.containsMouse
        }

        Battery {
            hovered: button.containsMouse
            anchors.verticalCenter: parent.verticalCenter

            colors.text: r.showSettings ? r.colors.textSelected : r.colors.text
        }
    }

    MouseArea {
        id: button
        anchors.fill: parent
        onClicked: r.showSettings = !r.showSettings
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
    }
}
