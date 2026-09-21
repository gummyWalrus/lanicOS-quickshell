import QtQuick

import qs.colors
import qs.components
import qs.config
import qs.fonts
import qs.services

Column {
    id: root

    spacing: Config.contentMargin

    Item {
        width: parent.width
        height: 24

        Text {
            id: icon

            anchors {
                verticalCenter: parent.verticalCenter
                left: parent.left
            }
            width: 24
            text: MixerService.icon
            horizontalAlignment: Text.AlignHCenter
            font {
                family: Fonts.mono
                pixelSize: 16
            }
            color: Colors.primary

            MouseArea {
                anchors.fill: parent
                onClicked: MixerService.toggleMute(MixerService.sink)
            }
        }

        ProgressSlider {
            anchors {
                verticalCenter: parent.verticalCenter
                left: icon.right
                leftMargin: Config.contentMargin
                right: level.left
                rightMargin: Config.contentMargin
            }

            value: MixerService.volume
            onMoved: value => MixerService.setVolume(MixerService.sink, value)
        }

        Text {
            id: level

            anchors {
                verticalCenter: parent.verticalCenter
                right: parent.right
            }
            width: 40
            text: Math.round(MixerService.volume * 100) + "%"
            horizontalAlignment: Text.AlignRight
            font {
                family: Fonts.mono
                pixelSize: 12
            }
            color: Colors.primary
        }
    }

    MixerSection {
        width: parent.width
        title: "Devices"
        nodes: MixerService.devices
        selectable: true
    }

    MixerSection {
        width: parent.width
        title: "Applications"
        nodes: MixerService.applications
    }
}
