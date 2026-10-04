import QtQuick
import Quickshell
import Quickshell.Networking
import Quickshell.Wayland

import qs.colors
import qs.config
import qs.fonts
import qs.services
import qs.components

// Screen centered modal shown when connecting to a network quickshell doesn't know yet.
PanelWindow {
    id: dialog

    readonly property WifiNetwork network: WifiService.pendingNetwork
    readonly property bool secured: !!network && network.security !== WifiSecurityType.Open

    function accept() {
        if (dialog.secured)
            dialog.network.connectWithPsk(password.text)
        else
            dialog.network.connect()

        WifiService.pendingNetwork = null
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
            onClicked: WifiService.pendingNetwork = null
        }
    }

    NeonRectangle {
        readonly property int padding: 20

        anchors.centerIn: parent
        implicitWidth: 340
        implicitHeight: body.implicitHeight + padding * 2
        color: Colors.surfaceContainerHigh
        animated: true
        focus: !dialog.secured
        Keys.onEscapePressed: WifiService.pendingNetwork = null

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

            Text {
                width: parent.width
                text: dialog.secured ? "Password for " + (dialog.network?.name ?? "") : "Connect to " + (dialog.network?.name ?? "") + " ?"
                wrapMode: Text.Wrap
                color: Colors.primary
                font {
                    family: Fonts.mono
                    pixelSize: 14
                }
            }

            Rectangle {
                width: parent.width
                height: 32
                visible: dialog.secured
                color: Colors.surface

                border {
                    color: password.activeFocus ? Colors.primary : Colors.outline
                    width: 1
                }

                TextInput {
                    id: password

                    anchors {
                        fill: parent
                        leftMargin: 8
                        rightMargin: 8
                    }
                    verticalAlignment: TextInput.AlignVCenter
                    echoMode: TextInput.Password
                    focus: dialog.secured
                    color: Colors.primary
                    selectionColor: Colors.primary
                    selectedTextColor: Colors.primaryText
                    font {
                        family: Fonts.mono
                        pixelSize: 14
                    }

                    onAccepted: dialog.accept()
                    Keys.onEscapePressed: WifiService.pendingNetwork = null
                }
            }

            Row {
                anchors.right: parent.right
                spacing: Config.contentMargin

                NeonRectangle {
                    implicitWidth: cancelLabel.implicitWidth + 32
                    implicitHeight: 30
                    color: Colors.surface

                    border {
                        color: Colors.outline
                        width: 1
                    }

                    Text {
                        id: cancelLabel
                        anchors.centerIn: parent
                        text: "Cancel"
                        color: Colors.primaryText
                        font {
                            family: Fonts.mono
                            pixelSize: 14
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: WifiService.pendingNetwork = null
                    }
                }

                Rectangle {
                    implicitWidth: okLabel.implicitWidth + 32
                    implicitHeight: 30
                    color: Colors.primary

                    Text {
                        id: okLabel
                        anchors.centerIn: parent
                        text: "OK"
                        color: Colors.primaryText
                        font {
                            family: Fonts.mono
                            pixelSize: 14
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: dialog.accept()
                    }
                }
            }
        }
    }
}
