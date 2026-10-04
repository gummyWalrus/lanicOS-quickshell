import QtQuick
import Quickshell
import Quickshell.Wayland

import qs.services
import qs.colors
import qs.types

PanelWindow {
    id: window

    signal sessionChanged

    screen: GreeterConfig.screen

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

        function changeSession(index) {
            SessionsService.select(index);
            window.sessionChanged();
        }

        anchors.centerIn: parent
        menuOnTop: true

        colors: ColorScheme {
            background: Qt.rgba(Colors.surfaceContainerLowest.r, Colors.surfaceContainerLowest.g, Colors.surfaceContainerLowest.b, 0.65)
        }

        icon: ""
        model: SessionsService.list.map(s => s.name)
        currentIndex: SessionsService.currentIndex
        onActivated: changeSession
    }
}
