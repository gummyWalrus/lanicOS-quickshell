pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

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
        cursorShape: Qt.PointingHandCursor
        onClicked: mouse => {
            if (mouse.button === Qt.RightButton)
                root.showMenu = !root.showMenu;
            else
                KeyboardService.next();
        }
    }

    LazyLoader {
        active: root.showMenu

        PopupWindow {
            implicitWidth: menu.implicitWidth + 10
            implicitHeight: menu.implicitHeight + 10
            color: "transparent"
            visible: true

            anchor {
                item: root
                rect.y: root.height
                edges: Edges.Bottom
                gravity: Edges.Bottom
                adjustment: PopupAdjustment.Slide
                margins.top: 8
            }

            grabFocus: true
            onClosed: root.showMenu = false

            NeonRectangle {
                id: menu

                implicitWidth: 160
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
                        model: KeyboardService.layouts

                        delegate: NeonMenuItem {
                            id: entry
                            required property int index
                            required property string modelData

                            readonly property string variant: KeyboardService.variants[entry.index] ?? ""
                            selected: KeyboardService.activeIndex === entry.index

                            labelText: entry.modelData.toUpperCase() + (entry.variant !== "" ? " (" + entry.variant + ")" : "")

                            onClicked: {
                                KeyboardService.setLayout(entry.index);
                                root.showMenu = false;
                            }
                        }
                    }
                }
            }
        }
    }
}
