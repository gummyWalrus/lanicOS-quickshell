import QtQuick
import Quickshell
import Quickshell.Wayland

import qs.colors

// Snapshot of the session wallpaper copied by copy-greeter.sh, drawn under everything on each screen.
Variants {
    model: Quickshell.screens

    PanelWindow {
        required property var modelData
        screen: modelData

        WlrLayershell.layer: WlrLayer.Background
        WlrLayershell.namespace: "greeter-wallpaper"
        exclusionMode: ExclusionMode.Ignore
        color: Colors.background

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        Image {
            id: image

            anchors.fill: parent
            source: "file://" + GreeterConfig.wallpaper
            fillMode: Image.PreserveAspectCrop
            sourceSize {
                width: image.width
                height: image.height
            }
            asynchronous: true
            smooth: true
        }
    }
}
