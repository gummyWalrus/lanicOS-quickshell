import Quickshell.Hyprland
import QtQuick

Item {
    id: root

    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight

    readonly property Item focusedItem: {
        for (let i = 0; i < repeater.count; i++) {
            const item = repeater.itemAt(i) as Workspace
            if (item && item.modelData.focused)
                return item
        }
        return null
    }

    Row {
        id: row
        // spacing: 8

        Repeater {
            id: repeater
            model: Hyprland.workspaces

            delegate: Workspace {
            }
        }
    }
}
