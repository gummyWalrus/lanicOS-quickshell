// ClipboardHistory.qml
// cliphist picker styled like the launcher: entries are reloaded on each open,
// and the chosen one is decoded back into the clipboard through wl-copy.
import Quickshell
import Quickshell.Io
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
    property var entries: []
    property var pendingEntries: []

    readonly property int maxLabelLength: 64
    readonly property string imageDir: Quickshell.cachePath("clipboard")

    onOpenChanged: if (open) listProcess.running = true

    function copy(entry) {
        Quickshell.execDetached(["sh", "-c", "cliphist decode \"$1\" | wl-copy", "sh", entry.id]);
        r.open = false;
    }

    function isImage(preview) {
        return /^\[\[ binary data .* (png|jpe?g|gif|bmp|webp) /.test(preview);
    }

    function label(text) {
        return text.length > maxLabelLength ? text.slice(0, maxLabelLength - 1) + "…" : text;
    }

    GlobalShortcut {
        name: "clipboard_history"
        description: "Toggle clipboard history"
        onPressed: r.open = !r.open
    }

    Process {
        id: listProcess
        command: ["cliphist", "list"]
        stdout: StdioCollector {
            onStreamFinished: {
                r.pendingEntries = text.split("\n")
                    .filter(line => line.includes("\t"))
                    .map(line => {
                        const tab = line.indexOf("\t");
                        const id = line.slice(0, tab);
                        const preview = line.slice(tab + 1);
                        return {
                            id: id,
                            text: preview,
                            binary: preview.startsWith("[[ binary data"),
                            image: r.isImage(preview) ? "file://" + r.imageDir + "/" + id : ""
                        };
                    });
                const imageIds = r.pendingEntries.filter(e => e.image !== "").map(e => e.id);
                imageProcess.command = ["sh", "-c", imageProcess.script, "sh", r.imageDir].concat(imageIds);
                imageProcess.running = true;
            }
        }
    }

    // Decodes images missing from the cache and drops the ones no longer in history.
    Process {
        id: imageProcess
        readonly property string script: 'dir=$1; shift; mkdir -p "$dir"\n'
            + 'for f in "$dir"/*; do case " $* " in *" ${f##*/} "*) ;; *) rm -f "$f" ;; esac; done\n'
            + 'for id; do [ -s "$dir/$id" ] || cliphist decode "$id" > "$dir/$id"; done'
        onExited: r.entries = r.pendingEntries
    }

    LazyLoader {
        active: r.open

        PanelWindow {
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
            exclusionMode: ExclusionMode.Ignore
            color: "transparent"
            implicitWidth: 610
            implicitHeight: 610

            NeonRectangle {
                anchors.fill: parent
                color: Colors.surface
                anchors.margins: 5
                border {
                    color: Colors.primary
                    width: 1
                }

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
                        placeholderText: "Search clipboard..."
                        onTextChanged: list.currentIndex = 0
                        Keys.onEscapePressed: r.open = false
                        Keys.onUpPressed: list.decrementCurrentIndex()
                        Keys.onDownPressed: list.incrementCurrentIndex()
                        Keys.onReturnPressed: if (list.currentItem) r.copy(list.currentItem.modelData)
                        Keys.onEnterPressed: if (list.currentItem) r.copy(list.currentItem.modelData)
                        color: Colors.primary
                        selectionColor: Colors.primary
                        selectedTextColor: Colors.primaryText
                        placeholderTextColor: Colors.primaryText
                        height: 32
                        font {
                            pixelSize: 14
                            family: Fonts.mono
                        }

                        background: NeonRectangle {
                            color: Colors.surface

                            border {
                                color: Colors.primaryContainer
                                width: 1
                            }
                        }
                    }

                    ListView {
                        id: list
                        width: parent.width
                        currentIndex: 0
                        height: parent.height - search.height - 8
                        clip: true
                        model: ScriptModel {
                            values: r.entries
                                .filter(e => e.text.toLowerCase().includes(search.text.toLowerCase()))
                        }

                        spacing: Config.contentMargin

                        delegate: Loader {
                            id: entry
                            required property var modelData
                            width: ListView.view.width - 4
                            anchors.horizontalCenter: parent.horizontalCenter
                            sourceComponent: modelData.image !== "" ? imageRow : textRow

                            Component {
                                id: textRow

                                NeonMenuItem {
                                    selected: entry.ListView.isCurrentItem
                                    leftIcons: entry.modelData.binary ? "󰋩" : "󰅍"
                                    labelText: r.label(entry.modelData.text)
                                    onClicked: r.copy(entry.modelData)
                                    height: 42
                                    colors: ColorScheme {
                                        selected: Colors.primaryContainer
                                        textSelected: Colors.primary
                                    }

                                    border {
                                        color: selected || hovered ? Colors.primary : "transparent"
                                        width: 1
                                    }
                                }
                            }

                            Component {
                                id: imageRow

                                NeonImageMenuItem {
                                    selected: entry.ListView.isCurrentItem
                                    source: entry.modelData.image
                                    onClicked: r.copy(entry.modelData)
                                    colors: ColorScheme {
                                        selected: Colors.primaryContainer
                                        textSelected: Colors.primary
                                    }

                                    border {
                                        color: selected || hovered ? Colors.primary : "transparent"
                                        width: 1
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
