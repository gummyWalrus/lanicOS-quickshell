import QtQuick
import qs.colors
import qs.config
import qs.components
import qs.settings.systats

NeonRectangle {
    id: panel

    readonly property int xPadding: 10
    readonly property int topPadding: 10

    property Component openMenu: null

    implicitWidth: Config.settingsPanelWidth
    implicitHeight: Config.settingsPanelHeight
    color: Colors.surface

    border {
        color: Colors.primary
        width: 1
    }

    Column {
        id: content

        anchors {
            fill: parent
            right: parent.right
            left: parent.left
            top: parent.top
            topMargin: panel.topPadding
            leftMargin: panel.xPadding
            rightMargin: panel.xPadding
        }
        spacing: Config.contentMargin

        Battery {}

        Grid {
            id: grid

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

    SysStats {
        anchors {
            bottom: parent.bottom
            bottomMargin: panel.topPadding
            left: parent.left
            leftMargin: panel.xPadding
        }
    }

    Loader {
        sourceComponent: panel.openMenu
        width: grid.width

        x: content.x + grid.x
        y: content.y + grid.y + grid.height + Config.contentMargin
    }
}
