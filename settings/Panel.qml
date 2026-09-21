import QtQuick
import qs.colors
import qs.config
import qs.components

Rectangle {
    id: panel

    readonly property int padding: 16

    property Component openMenu: null

    implicitWidth: Config.settingsPanelWidth
    implicitHeight: Config.settingsPanelHeight
    color: Colors.surface

    border {
        color: Colors.primaryText
        width: 3
    }

    Battery {
        id: battery

        anchors {
            top: parent.top
            left: parent.left
            margins: 10 // Config.contentMargin
        }
    }

    Grid {
        id: grid

        anchors {
            top: battery.visible ? battery.bottom : parent.top
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

            WifiButton {
                id: wifiButton
                menuOpen: panel.openMenu === wifiButton.menu
                onMenuToggled: panel.openMenu = panel.openMenu ? null : wifiButton.menu
            }
        }
            
        WiredButton {}
        
        Item {
            width: parent.slotWidth
            height: parent.slotHeight

            BluetoothButton {
                id: bluetoothButton
                menuOpen: panel.openMenu === bluetoothButton.menu
                onMenuToggled: panel.openMenu = panel.openMenu ? null : bluetoothButton.menu
            }
        }

        Item {
            width: parent.slotWidth
            height: parent.slotHeight

            PerformanceButton {
                id: performanceButton
                menuOpen: panel.openMenu === performanceButton.menu
                onMenuToggled: panel.openMenu = panel.openMenu ? null : performanceButton.menu
            }
        }
    }


    Column {
        anchors {
            top: grid.bottom
            left: parent.left
            right: parent.right
            margins: 10 // Config.contentMargin
        }
        spacing: Config.contentMargin

        Brightness {
            width: parent.width
        }

        Mixer {
            width: parent.width
        }
    }

    Rectangle {
        anchors.fill: parent
        visible: panel.openMenu !== null
        color: Colors.scrim
        opacity: 0.4

        MouseArea {
            anchors.fill: parent
            onClicked: panel.openMenu = null
        }
    }

    Loader {
        sourceComponent: panel.openMenu
        width: grid.width

        anchors {
            top: grid.bottom
            left: grid.left
            topMargin: Config.contentMargin
        }
    }
}
