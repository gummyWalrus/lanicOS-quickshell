import QtQuick
import Quickshell
import Quickshell.Wayland

import qs.services
import qs.colors
import qs.types

Variants {
    id: root
    model: Quickshell.screens

    PanelWindow {
        required property var modelData
        screen: modelData

        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.namespace: "greeter-sessions"

        exclusionMode: ExclusionMode.Ignore
        color: "transparent"

        implicitWidth: 500
        implicitHeight: 50

        anchors {
            bottom: true
        }
        margins {
            bottom: 16
        }

        Selector {
            id: session

            anchors.centerIn: parent
            menuOnTop: true

            colors: ColorScheme {
                background: Qt.rgba(Colors.surfaceContainerLowest.r, Colors.surfaceContainerLowest.g, Colors.surfaceContainerLowest.b, 0.65)
            }

            icon: ""
            model: SessionsService.list.map(s => s.name)
            currentIndex: SessionsService.currentIndex
            onActivated: index => SessionsService.select(index)
        }
    }
}
