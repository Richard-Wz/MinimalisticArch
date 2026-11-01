pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

// Windows-style projection modes for Hyprland (Lua config, 0.55+).
// Replaces the old monitor-switching script: it also handles hotplug.
Singleton {
    id: root

    // ---- your setup (same values as the old script) ----
    readonly property string externalName: "HDMI-A-1"
    readonly property string laptopName: "eDP-1"
    readonly property string externalMode: "2560x1080@75.00Hz"
    readonly property string externalSide: "right"   // "right" | "left": where the external sits in Extend
    readonly property bool autoOnHotplug: true       // plug in -> second screen only, unplug -> laptop

    property bool panelOpen: false
    property int selected: 0
    property string current: "laptop"                // laptop | mirror | extend | external
    property bool externalConnected: false

    property bool pendingAuto: false
    property real suppressUntil: 0                   // ignore monitor events caused by our own changes

    readonly property var modes: [
        { id: "laptop",   title: "PC screen only",     subtitle: "Laptop display only" },
        { id: "mirror",   title: "Duplicate",          subtitle: "Show the same on both" },
        { id: "extend",   title: "Extend",             subtitle: "Use both as one desktop" },
        { id: "external", title: "Second screen only", subtitle: "External monitor only" }
    ]

    function modeAvailable(id) {
        return id === "laptop" || externalConnected;
    }

    // ---- Lua monitor rules (sent with `hyprctl eval`) ----
    function lapOn(pos) {
        return "hl.monitor({ output = '" + laptopName + "', mode = 'preferred', position = '"
            + pos + "', scale = 1, disabled = false })";
    }
    function lapOff() {
        return "hl.monitor({ output = '" + laptopName + "', disabled = true })";
    }
    function extOn(pos, mirror) {
        return "hl.monitor({ output = '" + externalName + "', mode = '" + externalMode
            + "', position = '" + pos + "', scale = 1"
            + (mirror ? ", mirror = '" + mirror + "'" : "") + ", disabled = false })";
    }
    function extOff() {
        return "hl.monitor({ output = '" + externalName + "', disabled = true })";
    }

    // Enable first, disable last, so there is never a moment with no screen.
    function steps(id) {
        const right = externalSide !== "left";
        switch (id) {
        case "laptop":   return [lapOn("auto"), extOff()];
        case "external": return [extOn("auto", ""), lapOff()];
        case "extend":   return [lapOn(right ? "auto-left" : "auto-right"),
                                 extOn(right ? "auto-right" : "auto-left", "")];
        case "mirror":   return [lapOn("auto"), extOn("auto", laptopName)];
        }
        return [];
    }

    function apply(id) {
        if (!modeAvailable(id))
            return;
        const s = steps(id);
        if (s.length === 0)
            return;
        suppressUntil = Date.now() + 3000;
        current = id;
        applier.command = ["hyprctl", "--batch", s.map(x => "eval " + x).join(" ; ")];
        applier.running = true;
        panelOpen = false;
        refreshTimer.restart();
    }

    // ---- panel navigation ----
    function open() {
        selected = Math.max(0, modes.findIndex(m => m.id === current));
        panelOpen = true;
        refresh();
    }

    function step(dir) {
        const n = modes.length;
        for (let i = 1; i <= n; i++) {
            const idx = (((selected + dir * i) % n) + n) % n;
            if (modeAvailable(modes[idx].id)) {
                selected = idx;
                return;
            }
        }
    }

    // Alt+P: open; pressed again while open: next mode (like Win+P)
    function toggle() {
        if (panelOpen)
            step(1);
        else
            open();
    }

    // ---- state detection ----
    function refresh() {
        if (!lister.running)
            lister.running = true;
    }

    function parse(text) {
        let list = [];
        try {
            list = JSON.parse(text);
        } catch (e) {
            return;
        }
        const ext = list.find(m => m.name === externalName);
        const lap = list.find(m => m.name === laptopName);
        const isOn = m => !!m && !m.disabled;
        const isMirror = m => !!m && m.mirrorOf !== undefined && m.mirrorOf !== null
            && m.mirrorOf !== "none" && m.mirrorOf !== -1;

        externalConnected = !!ext;
        const extActive = isOn(ext);
        const lapActive = isOn(lap);

        // external unplugged while the laptop screen was off: bring it back
        if (!extActive && !lapActive) {
            apply("laptop");
            return;
        }

        current = extActive && lapActive ? (isMirror(ext) || isMirror(lap) ? "mirror" : "extend")
                : extActive ? "external" : "laptop";

        if (pendingAuto) {
            pendingAuto = false;
            apply(externalConnected ? "external" : "laptop");
        }
    }

    Process { id: applier }

    Process {
        id: lister
        command: ["hyprctl", "monitors", "all", "-j"]
        stdout: StdioCollector {
            onStreamFinished: root.parse(text)
        }
    }

    // First start of this login session: apply the automatic layout once
    // (not on every config reload, so a manual choice survives editing QML).
    Process {
        running: true
        command: ["sh", "-c",
            'f="$XDG_RUNTIME_DIR/qs-projection-init"; [ -e "$f" ] && exit 0; touch "$f"; exit 10']
        onExited: (exitCode, exitStatus) => {
            root.pendingAuto = exitCode === 10 && root.autoOnHotplug;
            root.refresh();
        }
    }

    Timer {
        id: refreshTimer
        interval: 1000
        onTriggered: root.refresh()
    }

    Timer {
        id: settle
        interval: 600
        onTriggered: {
            root.pendingAuto = root.autoOnHotplug;
            root.refresh();
        }
    }

    // Monitor hotplug (replaces the socat loop of the old script)
    Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (event.name !== "monitoradded" && event.name !== "monitorremoved")
                return;
            if (Date.now() < root.suppressUntil)
                refreshTimer.restart();
            else
                settle.restart();
        }
    }

    // qs ipc call projection toggle | open | set <laptop|mirror|extend|external>
    IpcHandler {
        target: "projection"
        function toggle(): void { root.toggle(); }
        function open(): void { root.open(); }
        function set(mode: string): void { root.apply(mode); }
    }
}
