pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Services.Pipewire

import qs.colors
import qs.components
import qs.config
import qs.fonts
import qs.services

// Collapsible list of pipewire nodes, each with its own volume slider.
Column {
    id: root

    required property string title
    required property var nodes

    // Devices can be promoted to the default sink, application streams cannot.
    property bool selectable: false
    property bool expanded: false

    spacing: 4

    Item {
        width: parent.width
        height: 20

        Text {
            id: chevron

            anchors {
                verticalCenter: parent.verticalCenter
                left: parent.left
            }
            width: 24
            text: "󰅀"
            rotation: root.expanded ? 180 : 0
            horizontalAlignment: Text.AlignHCenter
            font {
                family: Fonts.mono
                pixelSize: 12
            }
            color: Colors.primary

            Behavior on rotation {
                NumberAnimation { duration: Config.msAnimationDuration }
            }
        }

        Text {
            anchors {
                verticalCenter: parent.verticalCenter
                left: chevron.right
                leftMargin: Config.contentMargin
            }
            text: root.title + " (" + root.nodes.length + ")"
            font {
                family: Fonts.mono
                pixelSize: 12
                bold: true
            }
            color: Colors.primary
        }

        MouseArea {
            anchors.fill: parent
            onClicked: root.expanded = !root.expanded
        }
    }

    Repeater {
        model: root.expanded ? root.nodes : []

        delegate: Item {
            id: nodeRow

            required property PwNode modelData

            readonly property bool isDefault: root.selectable && MixerService.isDefaultSink(nodeRow.modelData)

            width: root.width
            height: 22

            Text {
                id: nodeIcon

                anchors {
                    verticalCenter: parent.verticalCenter
                    left: parent.left
                    leftMargin: 24
                }
                width: 20
                text: MixerService.nodeIcon(nodeRow.modelData)
                horizontalAlignment: Text.AlignHCenter
                font {
                    family: Fonts.mono
                    pixelSize: 12
                }
                color: Colors.primary

                MouseArea {
                    anchors.fill: parent
                    onClicked: MixerService.toggleMute(nodeRow.modelData)
                }
            }

            Text {
                id: nodeLabel

                anchors {
                    verticalCenter: parent.verticalCenter
                    left: nodeIcon.right
                    leftMargin: Config.contentMargin
                }
                width: 100
                text: (nodeRow.isDefault ? "󰄬 " : "") + MixerService.nodeLabel(nodeRow.modelData)
                elide: Text.ElideRight
                font {
                    family: Fonts.mono
                    pixelSize: 11
                    bold: nodeRow.isDefault
                }
                color: nodeRow.isDefault ? Colors.primary : Colors.primaryText

                MouseArea {
                    anchors.fill: parent
                    enabled: root.selectable
                    onClicked: MixerService.setDefaultSink(nodeRow.modelData)
                }
            }

            ProgressSlider {
                anchors {
                    verticalCenter: parent.verticalCenter
                    left: nodeLabel.right
                    leftMargin: Config.contentMargin
                    right: nodeLevel.left
                    rightMargin: Config.contentMargin
                }

                value: nodeRow.modelData.audio.volume
                onMoved: value => MixerService.setVolume(nodeRow.modelData, value)
            }

            Text {
                id: nodeLevel

                anchors {
                    verticalCenter: parent.verticalCenter
                    right: parent.right
                }
                width: 40
                text: Math.round(nodeRow.modelData.audio.volume * 100) + "%"
                horizontalAlignment: Text.AlignRight
                font {
                    family: Fonts.mono
                    pixelSize: 11
                }
                color: Colors.primary
            }
        }
    }
}
