// Launcher.qml
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import QtQuick.Controls

import qs.fonts
import qs.components
import qs.colors
import qs.config
import qs.types

Scope {
    id: r
    property bool open: false

    function launch(entry) {
        entry.execute();
        r.open = false;
    }

    GlobalShortcut {
        name: "launcher"
        description: "Toggle launcher"
        onPressed: r.open = !r.open
    }

    LazyLoader {
        active: r.open

        PanelWindow {
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
            exclusionMode: ExclusionMode.Ignore
            color: "transparent"
            implicitWidth: 610
            implicitHeight: 410

            // No anchors = centered on the screen

            NeonRectangle {
                anchors.fill: parent
                anchors.margins: 5

                animated: true

                Column {
                    anchors.fill: parent
                    anchors.margins: Config.contentMargin
                    spacing: 8

                    TextField {
                        id: search
                        width: parent.width - 4
                        anchors.horizontalCenter: parent.horizontalCenter
                        focus: true
                        placeholderText: "Search apps..."
                        onTextChanged: list.currentIndex = 0
                        Keys.onEscapePressed: r.open = false
                        Keys.onUpPressed: list.decrementCurrentIndex()
                        Keys.onDownPressed: list.incrementCurrentIndex()
                        Keys.onReturnPressed: if (list.currentItem) r.launch(list.currentItem.modelData)
                        Keys.onEnterPressed: if (list.currentItem) r.launch(list.currentItem.modelData)
                        color: Colors.primary
                        selectionColor: Colors.primary
                        selectedTextColor: Colors.primaryText
                        placeholderTextColor: Colors.primaryText
                        height: 32
                        font {
                            pixelSize: 14
                            family: Fonts.mono
                        }

                        background : NeonRectangle {
                            colors.border: Colors.primaryContainer
                        }
                    }

                    ListView {
                        id: list
                        width: parent.width
                        currentIndex: 0
                        height: parent.height - search.height - 8
                        clip: true
                        model: ScriptModel {
                            values: DesktopEntries.applications.values
                                .filter(a => a.name.toLowerCase().includes(search.text.toLowerCase()))
                        }

                        spacing: Config.contentMargin

                        delegate: NeonMenuItem {
                            id: row
                            required property var modelData
                            width: ListView.view.width - 4
                            anchors.horizontalCenter: parent.horizontalCenter
                            selected: ListView.isCurrentItem
                            labelText: modelData.name
                            onClicked: r.launch(modelData)
                            height: 42
                            colors: ColorScheme {
                                selected: Colors.primaryContainer
                                textSelected: Colors.primary
                            }

                            border {
                                color: selected || hovered ? Colors.primary : "transparent"
                                width: 1
                            }

                            leftItem: Icon {
                                anchors.verticalCenter: parent.verticalCenter
                                name: row.modelData.icon
                                size: 32
                            }
                        }
                    }
                }
            }
        }
    }
}