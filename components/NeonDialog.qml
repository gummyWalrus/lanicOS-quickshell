import QtQuick
import QtQuick.Controls

import Quickshell
import Quickshell.Wayland

import qs.colors
import qs.config
import qs.fonts
import qs.components

// Screen centered modal
PanelWindow {
    id: dialog

    default property alias content : contentArea.data

    property bool showButtons : true

    signal accepted ()
    signal rejected ()
    signal canceled ()

    function accept () {
        accepted()
    }
    
    function reject() {
        rejected()
        canceled()
    }

    function cancel() {
        canceled()
    }

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    color: "transparent"

    Rectangle {
        anchors.fill: parent
        color: Colors.scrim
        opacity: 0.4

        MouseArea {
            anchors.fill: parent
            onClicked: dialog.cancel()
        }
    }

    NeonRectangle {
        readonly property int padding: 20

        anchors.centerIn: parent
        implicitWidth: 340
        implicitHeight: body.implicitHeight + padding * 2
        color: Colors.surface
        animated: true
        // focus: !dialog.secured
        Keys.onEscapePressed: dialog.cancel()

        border {
            color: Colors.primary
            width: 1
        }

        Column {
            id: body

            anchors {
                left: parent.left
                right: parent.right
                verticalCenter: parent.verticalCenter
                margins: parent.padding
            }
            spacing: 16

            Item {
                id: contentArea
                width: parent.width
                height: childrenRect.height
            }

            Row {
                anchors.right: parent.right
                spacing: Config.contentMargin
                
                visible: dialog.showButtons
                
                NeonButton {
                    implicitHeight: 30

                    onClicked: dialog.reject()

                    text: "Cancel"
                }

                NeonButton {
                    implicitHeight: 30

                    bgColor: Colors.primary
                    hoverColor: Colors.primary
                    textColor: Colors.primaryText

                    onClicked: dialog.accept()

                    text: "OK"
                }
            }
        }
    }
}
