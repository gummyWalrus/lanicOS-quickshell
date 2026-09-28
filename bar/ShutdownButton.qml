pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

import qs.colors
import qs.components
import qs.config
import qs.fonts
import qs.services

// Power icon that opens the session menu (lock, suspend, hibernate, shutdown, reboot).
NeonBean {
    id: r

    property bool showMenu: false

    readonly property int padding: 16

    implicitWidth: label.implicitWidth + padding * 2
    implicitHeight: label.implicitHeight

    borderColor: showMenu ? Colors.primary : Colors.surface
    glowRadius: showMenu ? 6 : 0
    color: showMenu ? Colors.primary : button.containsMouse ? Colors.surfaceContainerHigh : Colors.surface
        
    TextNeon {
        id: label

        anchors.centerIn: parent
        text: ShutdownService.icon
        color: r.showMenu ? Colors.primaryText : Colors.primary
        font {
            pixelSize: 16
            family: Fonts.icon
        }

        animated: button.containsMouse
    }

    MouseArea {
        id: button

        anchors.fill: parent
        hoverEnabled: true
        onClicked: r.showMenu = !r.showMenu
    }

    LazyLoader {
        active: r.showMenu

        PopupWindow {
            implicitWidth: menu.implicitWidth
            implicitHeight: menu.implicitHeight
            color: "transparent"
            visible: true

            anchor {
                item: r
                rect.y: r.height + 8
                edges: Edges.Bottom
                gravity: Edges.Bottom
                adjustment: PopupAdjustment.Slide
                margins.top: 8
            }

            grabFocus: true
            onClosed: r.showMenu = false

            NeonRectangle {
                id: menu

                implicitWidth: 180
                implicitHeight: list.implicitHeight + Config.contentMargin * 2
                color: Colors.surface

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
                    spacing: Config.contentMargin

                    Repeater {
                        model: ShutdownService.actions

                        delegate: NeonMenuItem {
                            id: entry

                            required property var modelData
                            
                            onClicked: {
                                r.showMenu = false;
                                ShutdownService.run(entry.modelData.id);
                            }

                            leftIcons: modelData.icon
                            labelText: modelData.label

                            selected: false
                        }
                    }
                }
            }
        }
    }
}
