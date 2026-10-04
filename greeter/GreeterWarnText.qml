import QtQuick

import Quickshell
import Quickshell.Wayland

import qs.services
import qs.components
import qs.fonts
import qs.colors

PanelWindow {
    visible: errorText.text !== ""
    screen: GreeterConfig.screen

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "greeter-warn-text"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    exclusionMode: ExclusionMode.Ignore
    color: Colors.surface

    mask: Region {}                // empty region = input passes to what's below
    
    anchors {
        top: true
    }
    margins {
        top: 80
    }


    implicitWidth: errorText.implicitWidth + 16
    implicitHeight: errorText.implicitHeight + 16

    TextNeon {
        id: errorText
        text: AuthService.available ? AuthService.message : "greetd is not running"
        color: AuthService.failed || !AuthService.available ? Colors.error : Colors.primary
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.Wrap
        glowRadius: 0
        font {
            family: Fonts.mono
            pixelSize: GreeterConfig.fontSize
        }

        anchors.centerIn: parent
    }
}
