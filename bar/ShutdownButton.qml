pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

import qs.colors
import qs.components
import qs.config
import qs.fonts
import qs.services

// Power icon that opens the session menu (lock, suspend, hibernate, shutdown, reboot).
Item {
    id: root

    property bool showMenu: false

    readonly property int padding: 16

    implicitWidth: label.implicitWidth + padding * 2
    implicitHeight: label.implicitHeight

    TextNeon {
        id: label

        anchors.centerIn: parent
        text: ShutdownService.icon
        color: Colors.primary
        font {
            pixelSize: 16
            family: Fonts.icon
        }

        glowRadius: button.containsMouse || root.showMenu ? 1 : 0
        animated: button.containsMouse
    }

    MouseArea {
        id: button

        anchors.fill: parent
        hoverEnabled: true
        onClicked: root.showMenu = !root.showMenu
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

                implicitWidth: 180
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
                        model: ShutdownService.actions

                        delegate: Column {
                            id: entry

                            required property var modelData

                            width: list.width
                            spacing: 2

                            Rectangle {
                                visible: entry.modelData.separatorBefore
                                width: parent.width
                                height: 1
                                color: Colors.primaryContainer
                            }

                            Rectangle {
                                width: parent.width
                                height: 32
                                color: entryArea.containsMouse ? Colors.primaryContainer : "transparent"

                                Row {
                                    anchors {
                                        verticalCenter: parent.verticalCenter
                                        left: parent.left
                                        leftMargin: Config.contentMargin
                                    }
                                    spacing: 8

                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: entry.modelData.icon
                                        font {
                                            family: Fonts.icon
                                            pixelSize: 16
                                        }
                                        color: Colors.primary
                                    }

                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: entry.modelData.label
                                        font {
                                            family: Fonts.mono
                                            pixelSize: 14
                                        }
                                        color: Colors.primary
                                    }
                                }

                                MouseArea {
                                    id: entryArea

                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: {
                                        root.showMenu = false
                                        ShutdownService.run(entry.modelData.id)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
