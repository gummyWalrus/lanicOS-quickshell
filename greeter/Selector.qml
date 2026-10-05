pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

import qs.components
import qs.config
import qs.fonts

// Chip showing the current choice, clicking it opens a neon list of the alternatives.
NeonRectangle {
    id: r

    required property var model
    property int currentIndex: 0
    property bool showMenu: false
    property bool menuOnTop: false

    property int maxWidth: 500

    readonly property int padding: 12
    readonly property real labelWidth: Math.min(r.maxWidth, Math.max(0, ...r.model.map(t => metrics.advanceWidth(t))))

    property int fontSize: 14
    implicitHeight: padding * 2 + fontSize
    implicitWidth: padding * 2 + (iconLabel.visible ? iconLabel.implicitWidth + row.spacing : 0) + labelWidth + row.spacing + chevron.implicitWidth

    readonly property bool choosable: model.length > 1




    readonly property color roTextColor: showMenu ? colors.textSelected : colors.text
    property string font: Fonts.mono

    readonly property bool hovered: mouseArea.containsMouse

    property string icon: ""

    signal activated(int index)

    glowRadius: 6
    animated: showMenu || mouseArea.containsMouse

    color: showMenu ? colors.selected : mouseArea.containsMouse ? colors.hover : colors.background

    Behavior on color {
        ColorAnimation {
            duration: Config.msAnimationDuration
        }
    }

    border {
        width: 1
        color: r.colors.border
    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        enabled: r.choosable
        hoverEnabled: true
        cursorShape: r.choosable ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: r.showMenu = !r.showMenu
    }

    FontMetrics {
        id: metrics

        font {
            pixelSize: r.fontSize
            family: r.font
        }
    }

    Row {
        id: row

        spacing: r.padding

        anchors {
            left: parent.left
            leftMargin: r.padding
            verticalCenter: parent.verticalCenter
        }

        TextNeon {
            id: iconLabel

            visible: r.icon !== ""
            color: r.roTextColor
            text: r.icon
            font {
                pixelSize: r.fontSize
                family: r.font
            }

            anchors {
                verticalCenter: parent.verticalCenter
            }
        }

        ScrollingText {
            maxWidth: r.labelWidth
            text: r.model[r.currentIndex] ?? ""
            color: r.roTextColor

            font {
                pixelSize: r.fontSize
                family: r.font
            }
        }
    }

    TextNeon {
        id: chevron
        
        visible: r.choosable
        glowRadius: r.showMenu ? 0 : 1
        text: "󰅀"
        rotation: (r.showMenu !== r.menuOnTop) ? 180 : 0
        font {
            pixelSize: r.fontSize
            family: r.font
        }
        color: r.roTextColor

        anchors {
            right: parent.right
            rightMargin: r.padding
            verticalCenter: parent.verticalCenter
        }
        Behavior on rotation {
            NumberAnimation {
                duration: Config.msAnimationDuration
            }
        }
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
                rect {
                    x: -1
                    y: r.menuOnTop ? -8 : 8
                    width: r.width
                    height: r.height
                }
                edges: r.menuOnTop ? Edges.Top : Edges.Bottom
                gravity: r.menuOnTop ? Edges.Top : Edges.Bottom
                // adjustment: PopupAdjustment.SlideY
                margins {
                    top: 8
                    bottom: 8
                }
            }

            grabFocus: true
            onClosed: r.showMenu = false

            NeonRectangle {
                id: menu

                implicitWidth: r.width
                implicitHeight: list.implicitHeight + Config.contentMargin * 2
                colors.border: r.colors.border

                anchors.centerIn: parent

                Column {
                    id: list

                    anchors {
                        fill: parent
                        margins: Config.contentMargin
                    }
                    spacing: Config.contentMargin

                    Repeater {
                        model: r.model

                        delegate: NeonMenuItem {
                            id: entry

                            required property int index
                            required property string modelData

                            selected: r.currentIndex === entry.index
                            labelText: entry.modelData
                            colors: r.colors

                            onClicked: {
                                r.showMenu = false;
                                r.activated(entry.index);
                            }
                        }
                    }
                }
            }
        }
    }
}
