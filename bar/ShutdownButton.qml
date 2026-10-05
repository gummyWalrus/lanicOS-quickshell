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
    // Any object shaped like ShutdownService: icon, actions and run(id)
    property var service: ShutdownService

    readonly property int padding: 16

    implicitWidth: label.implicitWidth + padding * 2
    implicitHeight: label.implicitHeight

    colors.hover: Colors.surfaceContainerHigh
    colors.border: Colors.surface

    border.color: showMenu ? colors.selected : colors.border
    glowRadius: showMenu ? 6 : 0
    color: showMenu ? colors.selected : button.containsMouse ? colors.hover : colors.background
        
    TextNeon {
        id: label

        anchors.centerIn: parent
        text: r.service.icon
        color: r.showMenu ? r.colors.textSelected : r.colors.text
        font {
            pixelSize: 16
            family: Fonts.icon
        }

        glowRadius: button.containsMouse ? 1 : 0
        animated: button.containsMouse
    }

    MouseArea {
        id: button

        anchors.fill: parent
        hoverEnabled: true
        onClicked: r.showMenu = !r.showMenu
        cursorShape: Qt.PointingHandCursor
    }

    LazyLoader {
        active: r.showMenu

        PopupWindow {
            implicitWidth: menu.implicitWidth + 10
            implicitHeight: menu.implicitHeight + 10
            color: "transparent"
            visible: true

            anchor {
                item: r
                rect.y: r.height
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

                anchors.centerIn: parent

                Column {
                    id: list

                    anchors {
                        fill: parent
                        margins: Config.contentMargin
                    }
                    spacing: Config.contentMargin

                    Repeater {
                        model: r.service.actions

                        delegate: NeonMenuItem {
                            id: entry

                            required property var modelData
                            
                            onClicked: {
                                r.showMenu = false;
                                r.service.run(entry.modelData.id);
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
