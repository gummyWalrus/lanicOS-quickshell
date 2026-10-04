pragma ComponentBehavior: Bound
// shell.qml
import Quickshell
import Quickshell.Wayland
import QtQuick

import qs.fonts
import qs.colors
import qs.types
import qs.components

Variants {
    id: r
    model: Quickshell.screens          // one clock per monitor

    property Position position: Position {}
    property int margin: 80

    PanelWindow {
        required property var modelData
        screen: modelData

        // Under all normal windows but above the wallpaper
        WlrLayershell.layer: WlrLayer.Bottom
        WlrLayershell.namespace: "desktop-clock"

        // Don't reserve space like a bar would
        exclusionMode: ExclusionMode.Ignore

        // Transparent, click-through
        color: "transparent"
        mask: Region {}                // empty region = input passes to what's below

        // Position: anchor + margins (omit anchors to center on screen)
        anchors {
            bottom: r.position.bottom && !r.position.top
            top: r.position.top && !r.position.bottom
            right: r.position.right && !r.position.left
            left: r.position.left && !r.position.right
        }

        margins {
            bottom: r.position.bottom ? r.margin : 0;
            top: r.position.top ? r.margin : 0;
            right: r.position.right ? r.margin : 0;
            left: r.position.left ? r.margin : 0;
        }

        implicitWidth: 320
        implicitHeight: 140

        SystemClock {
            id: clock
            precision: SystemClock.Minutes
        }

        Column {
            anchors.centerIn: parent
            spacing: 4

            TextNeon {
                anchors.horizontalCenter: parent.horizontalCenter
                text: Qt.formatDateTime(clock.date, "hh:mm")
                color: Colors.primary
                font {
                    pixelSize: 72
                    family: Fonts.orbitron
                }
                glowRadius: 0
            }
            TextNeon {
                anchors.horizontalCenter: parent.horizontalCenter
                text: Qt.formatDateTime(clock.date, "dddd d MMMM")
                color: Colors.primary
                font {
                    family: Fonts.orbitron
                    pixelSize: 20
                }
                glowRadius: 0
            }
        }
    }
}