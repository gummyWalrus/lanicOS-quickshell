pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

import qs.colors
import qs.components
import qs.config
import qs.fonts
import qs.services

// Current keyboard layout. Left click cycles to the next layout, right click opens a picker.
Item {
    id: root

    property bool showMenu: false

    readonly property int padding: 16

    visible: KeyboardService.available
    implicitWidth: content.implicitWidth + padding * 2
    implicitHeight: content.implicitHeight

    Row {
        id: content

        anchors.centerIn: parent
        spacing: 8

        TextNeon {
            anchors.verticalCenter: parent.verticalCenter
            text: KeyboardService.label
            color: Colors.primary
            font {
                pixelSize: 16
                family: Fonts.mono
                bold: true
            }

            glowRadius: button.containsMouse ? 1 : 0
            animated: button.containsMouse
        }

        TextNeon {
            anchors.verticalCenter: parent.verticalCenter
            text: KeyboardService.icon
            color: Colors.primary
            font {
                pixelSize: 16
                family: Fonts.icon
                bold: true
            }

            glowRadius: button.containsMouse ? 1 : 0
            animated: button.containsMouse
        }
    }

    MouseArea {
        id: button

        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: mouse => {
            if (mouse.button === Qt.RightButton)
                root.showMenu = !root.showMenu
            else
                KeyboardService.next()
        }
    }

    LazyLoader {
        active: root.showMenu

        PopupWindow {
            implicitWidth: menu.implicitWidth
            implicitHeight: menu.implicitHeight
            color: "transparent"
            visible: true

            anchor {
                item: root
                rect.y: root.height + 8
                edges: Edges.Bottom
                gravity: Edges.Bottom
                adjustment: PopupAdjustment.Slide
                margins.top: 8
            }

            grabFocus: true
            onClosed: root.showMenu = false

            Rectangle {
                id: menu

                implicitWidth: 160
                implicitHeight: list.implicitHeight + Config.contentMargin * 2
                color: Colors.surfaceContainerHigh

                border {
                    color: Colors.primary
                    width: 1
                }

                Column {
                    id: list

                    anchors {
                        fill: parent
                        margins: Config.contentMargin
                    }
                    spacing: 2

                    Repeater {
                        model: KeyboardService.layouts

                        delegate: Rectangle {
                            id: entry

                            required property int index
                            required property string modelData

                            readonly property bool selected: KeyboardService.activeIndex === entry.index
                            readonly property string variant: KeyboardService.variants[entry.index] ?? ""

                            width: list.width
                            height: 32
                            color: {
                                if (entry.selected)
                                    return Colors.primary
                                return entryArea.containsMouse ? Colors.primaryContainer : "transparent"
                            }

                            Text {
                                anchors {
                                    verticalCenter: parent.verticalCenter
                                    left: parent.left
                                    leftMargin: Config.contentMargin
                                }
                                text: entry.modelData.toUpperCase() + (entry.variant !== "" ? " (" + entry.variant + ")" : "")
                                font {
                                    family: Fonts.mono
                                    pixelSize: 14
                                    bold: entry.selected
                                }
                                color: entry.selected ? Colors.primaryText : Colors.primary
                            }

                            Text {
                                anchors {
                                    verticalCenter: parent.verticalCenter
                                    right: parent.right
                                    rightMargin: Config.contentMargin
                                }
                                visible: entry.selected
                                text: "󰄬"
                                font {
                                    family: Fonts.icon
                                    pixelSize: 16
                                }
                                color: Colors.primaryText
                            }

                            MouseArea {
                                id: entryArea

                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: {
                                    KeyboardService.setLayout(entry.index)
                                    root.showMenu = false
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
