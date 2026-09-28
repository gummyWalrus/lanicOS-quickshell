// shell.qml
import Quickshell
import Quickshell.Wayland
import QtQuick

import qs.fonts
import qs.colors
import qs.components

Variants {
    model: Quickshell.screens          // one clock per monitor

    PanelWindow {
        required property var modelData
        screen: modelData

        // Put the window under all normal windows
        WlrLayershell.layer: WlrLayer.Background   // or WlrLayer.Bottom
        WlrLayershell.namespace: "desktop-clock"

        // Don't reserve space like a bar would
        exclusionMode: ExclusionMode.Ignore

        // Transparent, click-through
        color: "transparent"
        mask: Region {}                // empty region = input passes to what's below

        // Position: anchor + margins (omit anchors to center on screen)
        anchors {
            bottom: true
            right: true
            // margins: 80
        }
        margins { bottom: 80; right: 80 }

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