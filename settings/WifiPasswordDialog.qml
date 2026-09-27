import QtQuick
import Quickshell.Networking

import qs.colors
import qs.fonts
import qs.services
import qs.components

// Screen centered modal shown when connecting to a network quickshell doesn't know yet.
NeonDialog {
    id: dialog

    readonly property WifiNetwork network: WifiService.pendingNetwork
    readonly property bool secured: !!network && network.security !== WifiSecurityType.Open

    onAccepted: {
        if (dialog.secured) {
            dialog.network.connectWithPsk(password.text);
        } else {
            dialog.network.connect();
        }
        WifiService.pendingNetwork = null;
    }

    onCanceled: {
        WifiService.pendingNetwork = null;
    }

    Column {
        width: parent.width
        
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
                Keys.onEscapePressed: dialog.cancel()
            }
        }
    }
}
