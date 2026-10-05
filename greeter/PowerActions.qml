import Quickshell
import Quickshell.Wayland
import QtQuick

import qs.config
import qs.colors
import qs.components

Variants {
    id: root
    model: Quickshell.screens

    PanelWindow {
        id: window

        required property var modelData
        screen: modelData

        // Under all normal windows but above the wallpaper
        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.namespace: "greeter-actions"

        // Don't reserve space like a bar would
        exclusionMode: ExclusionMode.Ignore

        color: "transparent"

        anchors {
            bottom: true
        }

        margins {
            bottom: 256
        }

        implicitWidth: rect.implicitWidth + 10
        implicitHeight: rect.implicitHeight + 10

        Item {
            id: rect

            anchors.centerIn: parent
            implicitHeight: row.implicitHeight + Config.padding * 2
            implicitWidth: row.implicitWidth + Config.padding * 2

            // color: "transparent" // Colors.surface
            // border {
            //     width: 1
            //     color: Colors.primary
            // }
            

            Row {
                anchors {
                    left: parent.left
                    leftMargin: Config.padding
                    verticalCenter: parent.verticalCenter
                }

                id: row

                Repeater {
                    model: Power.actions

                    delegate: IconButton {
                        required property var modelData

                        iconName: modelData.iconPath
                        label: modelData.label

                        iconSize: 48

                        colors.background: "transparent"
                        colors.hover: Qt.rgba(Colors.surfaceContainerLowest.r, Colors.surfaceContainerLowest.g, Colors.surfaceContainerLowest.b, 0.65)

                        onClicked: Power.run(modelData.id)
                    }
                }
            }
        }
    }
}
