import QtQuick
import Quickshell
import Quickshell.Wayland

import qs.bar
import qs.colors
import qs.components
import qs.config
import qs.services
import qs.types

// Top right pill reusing the bar's keyboard layout, battery and power menu widgets.
Variants {
    id: root
    model: Quickshell.screens

    PanelWindow {
        required property var modelData
        screen: modelData

        WlrLayershell.namespace: "greeter-status"
        exclusionMode: ExclusionMode.Ignore
        color: "transparent"

        anchors {
            top: true
            right: true
        }
        margins {
            top: 12
            right: 12
        }

        implicitWidth: pill.implicitWidth + 10
        implicitHeight: pill.implicitHeight + 10

        NeonRectangle {
            id: pill

            anchors.centerIn: parent
            implicitWidth: content.implicitWidth + Config.padding * 2
            implicitHeight: content.implicitHeight + Config.contentMargin * 2
            radius: height / 2
            color: Qt.rgba(Colors.surfaceContainerLowest.r, Colors.surfaceContainerLowest.g, Colors.surfaceContainerLowest.b, 0.65)
            opacity: AuthService.launching ? 0 : 1

            border {
                color: Colors.primary
                width: 1
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: Config.msAnimationDuration * 2
                }
            }

            Row {
                id: content

                anchors.centerIn: parent
                spacing: 8

                ToggleButton {
                    anchors.verticalCenter: parent.verticalCenter
                    icon: ""
                    checked: GreeterStateService.virtualKeyboard
                    onToggled: checked => GreeterStateService.virtualKeyboard = checked

                    colors: ColorScheme {
                        background: "transparent"
                    }
                }

                Separator {
                    anchors.verticalCenter: parent.verticalCenter
                }

                KeyboardLayout {
                    id: keyboard

                    anchors.verticalCenter: parent.verticalCenter
                }

                Separator {
                    anchors.verticalCenter: parent.verticalCenter
                    visible: KeyboardService.available
                }

                Item {
                    anchors.verticalCenter: parent.verticalCenter
                    visible: BatteryService.available
                    implicitWidth: battery.implicitWidth + keyboard.padding * 2
                    implicitHeight: battery.implicitHeight

                    Battery {
                        id: battery

                        anchors.centerIn: parent
                    }
                }
            }
        }
    }
}
