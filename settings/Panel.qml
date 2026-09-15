import QtQuick
import qs.colors
import qs.fonts
import qs.config

Rectangle {
    readonly property int padding: 16

    implicitWidth: Config.settingsPanelWidth
    implicitHeight: Config.settingsPanelWidth
    color: Colors.surface

    border {
        color: Colors.primaryText
        width: 3
    }

    Item {
        anchors {
            top: parent.top
            left: parent.left
            margins:  10 // Config.contentMargin
        }

        NetworkButton {
        }
    }


    Text {
        anchors.centerIn: parent
        text: "Settings"
        color: Colors.primaryText
        font {
            family: Fonts.mono
            pixelSize: 16
        }
    }
}
