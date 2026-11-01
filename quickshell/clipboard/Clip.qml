pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Clipboard history backed by cliphist + wl-clipboard.
//   sudo pacman -S cliphist wl-clipboard
// Remove any "wl-paste --watch cliphist store" lines from your compositor autostart,
// this file runs the watchers itself.
Singleton {
    id: root

    property bool panelOpen: false
    property var entries: []        // [{ id, raw, text, isImage }]

    function refresh() {
        if (!lister.running)
            lister.running = true;
    }

    function copy(entry) {
        Quickshell.execDetached(["sh", "-c", 'cliphist decode "$1" | wl-copy', "sh", String(entry.id)]);
    }

    function remove(entry) {
        Quickshell.execDetached(["sh", "-c", 'printf "%s\\n" "$1" | cliphist delete', "sh", entry.raw]);
        entries = entries.filter(e => e.id !== entry.id);
    }

    function wipe() {
        Quickshell.execDetached(["cliphist", "wipe"]);
        entries = [];
    }

    // Watchers: store every new clipboard entry
    Process {
        running: true
        command: ["wl-paste", "--type", "text", "--watch", "cliphist", "store"]
    }
    Process {
        running: true
        command: ["wl-paste", "--type", "image", "--watch", "cliphist", "store"]
    }

    Process {
        id: lister
        command: ["cliphist", "list"]
        stdout: StdioCollector {
            onStreamFinished: {
                const out = [];
                for (const line of text.split("\n")) {
                    const tab = line.indexOf("\t");
                    if (tab < 1)
                        continue;
                    const body = line.slice(tab + 1);
                    out.push({
                        id: parseInt(line.slice(0, tab)),
                        raw: line,
                        text: body,
                        isImage: body.startsWith("[[ binary data")
                    });
                }
                root.entries = out;
            }
        }
    }
}
