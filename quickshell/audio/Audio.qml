pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

// Audio output state (PipeWire). Shared by the bar button and the popup.
Singleton {
    id: root

    property bool panelOpen: false

    readonly property var sink: Pipewire.defaultAudioSink
    // real output devices only: sinks that are not application streams
    readonly property var sinks: Pipewire.nodes.values.filter(n => n.isSink && !n.isStream && n.audio)

    // readonly property var sinks: Pipewire.nodes.values.filter(n =>
    //     n.isSink &&
    //     !n.isStream &&
    //     n.audio &&
    //     !(n.name || "").toLowerCase().match(displayport)
    // )

    function select(node) {
        Pipewire.preferredDefaultAudioSink = node;
    }

    function nodeName(n) {
        return n.description || n.nickname || n.name;
    }

    // bluetooth / HDMI / generic speaker
    function nodeIcon(n) {
        const id = (n.name || "").toLowerCase();
        if (id.startsWith("bluez"))
            return "\uDB80\uDCB0";                 // nf-md-bluetooth_audio (U+F00B0)
        if (id.includes("hdmi") || id.includes("displayport"))
            return "\uDB80\uDF79";                 // nf-md-monitor (U+F0379)
        return "\uDB81\uDCC3";                     // nf-md-speaker (U+F04C3)
    }

    // volume-mute / low / medium / high (U+F075F, F057F, F0580, F057E)
    function volumeIcon(v, muted) {
        if (muted || v === 0) return "\uDB81\uDF5F";
        if (v < 0.34) return "\uDB81\uDD7F";
        if (v < 0.67) return "\uDB81\uDD80";
        return "\uDB81\uDD7E";
    }

    // volume / mute only work on nodes that are "bound"
    PwObjectTracker {
        objects: [root.sink, ...root.sinks]
    }
}
