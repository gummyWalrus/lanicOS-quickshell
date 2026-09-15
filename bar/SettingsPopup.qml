pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import qs.settings

LazyLoader {
    id: root

    required property SettingsButton anchorItem

    active: root.anchorItem.showSettings

    PopupWindow {
        implicitWidth: panel.implicitWidth
        implicitHeight: panel.implicitHeight
        color: "transparent"
        visible: true

        anchor {
            item: root.anchorItem
            rect.y: root.anchorItem.height + 8
            edges: Edges.Bottom
            gravity: Edges.Bottom
            adjustment: PopupAdjustment.Slide
            margins.top: 8
        }

        grabFocus: true
        onClosed: root.anchorItem.showSettings = false

        SettingsPanel {
            id: panel
        }
    }
}
