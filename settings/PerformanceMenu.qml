import QtQuick
import Quickshell.Services.UPower

import qs.colors
import qs.config
import qs.components
import qs.services

// Power profile picker. Fixed option list, so nothing to scan.
Rectangle {
    id: root

    implicitHeight: Math.min(list.contentHeight + Config.contentMargin * 2, 240)
    color: Colors.surface

    border {
        color: Colors.primary
        width: 1
    }

    ListView {
        id: list

        anchors.fill: parent
        anchors.margins: Config.contentMargin
        clip: true
        spacing: Config.contentMargin
        model: PowerService.profiles

        delegate: NeonMenuItem {
            id: row

            required property int modelData

            selected: PowerProfiles.profile === row.modelData

            width: list.width
            height: 32

            leftIcons: PowerService.icons[row.modelData]
            labelText: PowerService.labels[row.modelData]

            onClicked: PowerService.setProfile(row.modelData)
        }
    }
}
