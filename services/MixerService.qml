pragma Singleton

import Quickshell
import Quickshell.Services.Pipewire

Singleton {
    id: root

    readonly property var icons: ["", "", "", ""]
    readonly property string mutedIcon: "󰝟"

    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property real volume: sink && sink.audio ? sink.audio.volume : 0
    readonly property bool muted: !!sink && !!sink.audio && sink.audio.muted

    // Streams report isSink false, hardware outputs report isStream false.
    readonly property var devices: Pipewire.nodes.values.filter(n => n.audio && n.isSink && !n.isStream)
    readonly property var applications: Pipewire.nodes.values.filter(n => n.audio && n.isStream && !n.isSink)

    readonly property string icon: nodeIcon(sink)

    function nodeIcon(node) {
        if (!node || !node.audio || node.audio.muted)
            return mutedIcon
        const index = Math.max(0, Math.min(icons.length - 1, Math.round(node.audio.volume * (icons.length - 1))))
        return icons[index]
    }

    function isDefaultSink(node) {
        return !!node && Pipewire.defaultAudioSink === node
    }

    function setDefaultSink(node) {
        if (node && node.isSink && !node.isStream)
            Pipewire.preferredDefaultAudioSink = node
    }

    function setVolume(node, value) {
        if (node && node.audio)
            node.audio.volume = Math.max(0, Math.min(1, value))
    }

    function toggleMute(node) {
        if (node && node.audio)
            node.audio.muted = !node.audio.muted
    }

    function nodeLabel(node) {
        return node.description || node.nickname || node.name
    }

    // Volume and properties are only live for objects bound here.
    PwObjectTracker {
        objects: [root.sink].concat(root.devices, root.applications).filter(n => !!n)
    }
}
