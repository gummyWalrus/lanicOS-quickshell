import Quickshell // for PanelWindow
import QtQuick
import qs.colors
import qs.bar.workspaces
import qs.config


Scope {
    // Spawn one Bar per connected monitor.
    Variants {
        model: Quickshell.screens
        PanelWindow {
            id: bar
            required property var modelData
            screen: modelData

            readonly property int topPadding: 6
            readonly property int contentMargin: 6
            readonly property int separatorHeight: 3

            anchors {
                top: true
                left: true
                right: true
            }

            implicitHeight: /* bar.topPadding + */ Math.max(workspaces.implicitHeight, clock.implicitHeight) + bar.contentMargin + bar.separatorHeight
            color: Colors.background

            Item {
                id: content
                anchors {
                    top: parent.top
                    topMargin: bar.topPadding
                    left: parent.left
                    right: parent.right
                    bottom: separator.top
                    bottomMargin: 3 // bar.contentMargin
                }

                Workspaces {
                    id: workspaces
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                }

                Clock {
                    id: clock
                    anchors.centerIn: parent
                }

                SettingsButton {
                    id: settingsButton

                    anchors {
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                    }

                    Component.onCompleted: console.log("loaded item ", bar.modelData.name)
                }
            }

            SettingsPopup {
                anchorItem: settingsButton
            }

            Rectangle {
                id: separator
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height: bar.separatorHeight
                color: Colors.primaryText
            }

            Rectangle {
                visible: workspaces.focusedItem !== null
                anchors.bottom: parent.bottom
                height: bar.separatorHeight
                color: Colors.primary
                x: workspaces.x + (workspaces.focusedItem?.x ?? 0)
                width: workspaces.focusedItem?.width ?? 0

                Behavior on x {
                    NumberAnimation { duration: Config.msAnimationDuration; easing.type: Easing.OutCubic }
                }
                Behavior on width {
                    NumberAnimation { duration: Config.msAnimationDuration; easing.type: Easing.OutCubic }
                }
            }
        }
    }
}
