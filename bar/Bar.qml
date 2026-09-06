import Quickshell // for PanelWindow
import qs.colors

Scope {
    // Spawn one Bar per connected monitor.
    Variants {
        model: Quickshell.screens
        PanelWindow {
            required property var modelData
            screen: modelData

            anchors {
                top: true
                left: true
                right: true
            }

            implicitHeight: 30
            color: Colors.background

            Clock {
                anchors.centerIn: parent
            }
        }
    }
}
