import QtQuick

import qs.fonts
import qs.colors
import qs.components

Rectangle {
    id: r
    required property bool activated
    required property string label
    required property string icon

    property Component menu: null
    property bool menuOpen: false
    signal menuToggled()

    readonly property int padding: 12

    border {
        color: Colors.primary
        width: 1
    }

    function getBackgroundColor() {

    }

    function getBorderColor() {

    }

    function getTextColor() {
        // return activated
    }

    color: activated ? Colors.primary : Colors.surface

    Row {
        id: content

        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
            leftMargin: r.padding
        }
        spacing: 16

        Text {
            id: icon
            anchors.verticalCenter: parent.verticalCenter
            text: r.icon
            font {
                family: Fonts.mono
                pixelSize: 24
            }
            color: r.activated ? Colors.primaryText : Colors.primary
        }

        ScrollingText {
            anchors.verticalCenter: parent.verticalCenter

            text: r.label
            font {
                family: Fonts.mono
                pixelSize: 16
            }
            color: r.activated ? Colors.primaryText : Colors.primary
            maxWidth: r.width - r.padding * 2 - icon.implicitWidth - content.spacing - (menuToggle.visible ? menuToggle.width : 0)
        }
    }

    Rectangle {
        id: menuToggle

        anchors {
            right: parent.right
            top: parent.top
            bottom: parent.bottom
        }
        width: 32
        visible: r.menu !== null
        color: "transparent"

        Text {
            anchors.centerIn: parent
            text: "󰅀"
            rotation: r.menuOpen ? 180 : 0
            font {
                family: Fonts.mono
                pixelSize: 16
            }
            color: r.activated ? Colors.primaryText : Colors.primary

            Behavior on rotation {
                NumberAnimation { duration: 150 }
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: r.menuToggled()
        }
    }
}
