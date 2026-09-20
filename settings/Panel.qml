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

    Grid {
        anchors {
            top: parent.top
            left: parent.left
            margins: 10 // Config.contentMargin
        }
        columns: 2
        rowSpacing: Config.contentMargin
        columnSpacing: Config.contentMargin

        readonly property int slotWidth: (Config.settingsPanelWidth / 2) - Config.contentMargin * 2
        readonly property int slotHeight: 42

        Item {
            width: parent.slotWidth
            height: parent.slotHeight
            WifiButton {}
        }
            
        WiredButton {}
        
        Item {
            width: parent.slotWidth
            height: parent.slotHeight
            BluetoothButton {}
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
