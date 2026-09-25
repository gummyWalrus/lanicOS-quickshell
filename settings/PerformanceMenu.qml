import QtQuick
import Quickshell.Services.UPower

import qs.colors
import qs.config
import qs.fonts
import qs.services

// Power profile picker. Fixed option list, so nothing to scan.
Rectangle {
    id: root

    implicitHeight: Math.min(list.contentHeight + Config.contentMargin * 2, 240)
    color: Colors.surfaceContainerHigh

    border {
        color: Colors.primary
        width: 1
    }

    ListView {
        id: list

        anchors.fill: parent
        anchors.margins: Config.contentMargin
        clip: true
        spacing: 2
        model: PowerService.profiles

        delegate: Rectangle {
            id: row

            required property int modelData

            readonly property bool selected: PowerProfiles.profile === row.modelData

            width: list.width
            height: 32
            color: {
                if (row.selected) {
                    return Colors.primary
                }
                return mouseArea.containsMouse ? Colors.primaryContainer : "transparent"
            }

            Behavior on color {
                ColorAnimation { duration: Config.msAnimationDuration }
            }

            Row {
                anchors {
                    verticalCenter: parent.verticalCenter
                    left: parent.left
                    leftMargin: Config.contentMargin
                }
                spacing: 8

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: PowerService.icons[row.modelData]
                    font {
                        family: Fonts.mono
                        pixelSize: 16
                    }
                    color: row.selected ? Colors.primaryText : Colors.primary
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: PowerService.labels[row.modelData]
                    font {
                        family: Fonts.mono
                        pixelSize: 14
                        bold: row.selected
                    }
                    color: row.selected ? Colors.primaryText : Colors.primary
                }
            }

            Text {
                anchors {
                    verticalCenter: parent.verticalCenter
                    right: parent.right
                    rightMargin: Config.contentMargin
                }
                visible: row.selected
                text: "󰄬"
                font {
                    family: Fonts.mono
                    pixelSize: 14
                }
                color: Colors.primaryText
            }

            MouseArea {
                id: mouseArea
                anchors.fill: parent
                onClicked: PowerService.setProfile(row.modelData)
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
            }
        }
    }
}
