
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

Singleton {
    id: root

    // -----------------------------------------
    // CONFIGURATION
    // -----------------------------------------

    // Leave empty for automatic detection.
    // Example: "eDP-1" or "HDMI-A-1"
    readonly property string preferredDefault: ""

    // Automatically switch to default when the
    // currently selected monitor is disconnected.
    readonly property bool fallbackToDefault: true

    // -----------------------------------------
    // STATE
    // -----------------------------------------

    property bool panelOpen: false

    // All detected monitors
    property var monitors: []

    // Current active monitor
    property string selectedMonitor: ""

    // Default/fallback monitor
    property string defaultMonitor: ""

    // Navigation index
    property int selected: 0

    // -----------------------------------------
    // MONITOR HELPERS
    // -----------------------------------------

    function findMonitor(name) {
        return monitors.find(m => m.name === name);
    }

    function isAvailable(name) {
        return monitors.some(m => m.name === name);
    }

    function isActive(monitor) {
        return monitor && !monitor.disabled;
    }

    function getDefaultMonitor(list) {
        if (preferredDefault !== "") {
            const preferred = list.find(
                m => m.name === preferredDefault
            );

            if (preferred)
                return preferred.name;
        }

        // Prefer an internal laptop display.
        const internal = list.find(m =>
            /^(eDP|LVDS|DSI)-/i.test(m.name)
        );

        if (internal)
            return internal.name;

        // For mini PCs and desktops, use the
        // first detected monitor as the default.
        return list.length > 0 ? list[0].name : "";
    }

    function getResolution(monitor) {
        if (!monitor)
            return "Unknown resolution";

        const width = monitor.width || 0;
        const height = monitor.height || 0;

        if (!width || !height)
            return "Resolution unavailable";

        return width + " × " + height;
    }

    function getRefreshRate(monitor) {
        if (!monitor || !monitor.refreshRate)
            return "";

        return monitor.refreshRate.toFixed(2) + " Hz";
    }

    function getBestMode(monitor) {
        if (!monitor || !monitor.availableModes.length)
            return "preferred";

        const modes = monitor.availableModes
            .map(mode => {
                const match = mode.match(
                    /^(\d+)x(\d+)@([\d.]+)Hz$/
                );

                if (!match)
                    return null;

                return {
                    mode: mode,
                    width: Number(match[1]),
                    height: Number(match[2]),
                    refresh: Number(match[3]),
                    pixels: Number(match[1]) * Number(match[2])
                };
            })
            .filter(m => m !== null);

        if (modes.length === 0)
            return "preferred";

        // Prioritize highest resolution, then refresh rate.
        modes.sort((a, b) =>
            b.pixels - a.pixels ||
            b.refresh - a.refresh
        );

        return modes[0].mode;
    }

    // -----------------------------------------
    // LUA MONITOR COMMANDS
    // -----------------------------------------

    function luaQuote(value) {
        return "'" + value.replace(/\\/g, "\\\\")
                           .replace(/'/g, "\\'") + "'";
    }

    function enableMonitor(name) {
        const monitor = findMonitor(name);
        const mode = getBestMode(monitor);

        return "hl.monitor({ output = " + luaQuote(name)
            + ", mode = " + luaQuote(mode)
            + ", position = 'auto'"
            + ", scale = 1"
            + ", disabled = false })";
    }

    function disableMonitor(name) {
        return "hl.monitor({ output = " + luaQuote(name)
            + ", disabled = true })";
    }

    // -----------------------------------------
    // DISPLAY SWITCHING
    // -----------------------------------------

    function apply(name) {
        if (!isAvailable(name))
            return;

        const commands = [];

        // Enable the selected monitor first.
        commands.push(enableMonitor(name));

        // Disable every other detected monitor.
        for (const monitor of monitors) {
            if (monitor.name !== name)
                commands.push(disableMonitor(monitor.name));
        }

        selectedMonitor = name;
        panelOpen = false;

        applier.command = [
            "hyprctl",
            "--batch",
            commands.map(cmd => "eval " + cmd).join(" ; ")
        ];

        applier.running = true;

        // Refresh after applying the configuration.
        refreshTimer.restart();
    }

    function select(name) {
        apply(name);
    }

    function toggle() {
        if (panelOpen) {
            step(1);
        } else {
            open();
        }
    }

    // -----------------------------------------
    // PANEL NAVIGATION
    // -----------------------------------------

    function open() {
        if (monitors.length === 0) {
            refresh();
            return;
        }

        const index = monitors.findIndex(
            m => m.name === selectedMonitor
        );

        selected = Math.max(0, index);

        panelOpen = true;
    }

    function step(direction) {
        const count = monitors.length;

        if (count === 0)
            return;

        selected = (
            (selected + direction + count) % count
        );
    }

    function applySelected() {
        if (selected < 0 || selected >= monitors.length)
            return;

        apply(monitors[selected].name);
    }

    // -----------------------------------------
    // MONITOR DETECTION
    // -----------------------------------------

    function refresh() {
        if (!lister.running)
            lister.running = true;
    }

    function parse(output) {
        let list;

        try {
            list = JSON.parse(output);
        } catch (error) {
            return;
        }

        if (!Array.isArray(list))
            return;

        // Keep connected monitor information.
        const detected = list.map(m => ({
            name: m.name,
            description: m.description || m.name,
            width: m.width || 0,
            height: m.height || 0,
            refreshRate: m.refreshRate || 0,
            availableModes: m.availableModes || [],
            disabled: !!m.disabled,
            focused: !!m.focused,
            internal: /^(eDP|LVDS|DSI)-/i.test(m.name)
        }));

        monitors = detected;

        if (detected.length === 0) {
            selectedMonitor = "";
            defaultMonitor = "";
            return;
        }

        // Identify the default display.
        defaultMonitor = getDefaultMonitor(detected);

        // Determine which display is currently active.
        const active = detected.filter(m => !m.disabled);

        // If the selected monitor has disappeared,
        // return to the default display.
        if (!isAvailable(selectedMonitor)) {
            const fallback = fallbackToDefault
                ? defaultMonitor
                : "";

            if (fallback !== "") {
                apply(fallback);
                return;
            }
        }

        // Recover active monitor information.
        if (active.length > 0) {
            const focused = active.find(m => m.focused);

            const current = active.find(
                m => m.name === selectedMonitor
            );

            const chosen = current || focused || active[0];

            selectedMonitor = chosen.name;

            // Enforce exclusive display usage if
            // multiple displays were active before.
            if (active.length > 1) {
                apply(chosen.name);
                return;
            }
        } else {
            // No active display: restore default.
            if (defaultMonitor !== "")
                apply(defaultMonitor);
        }

        // Keep keyboard selection within bounds.
        if (selected >= monitors.length)
            selected = Math.max(0, monitors.length - 1);
    }

    // -----------------------------------------
    // PROCESSES
    // -----------------------------------------

    Process {
        id: lister

        command: [
            "hyprctl",
            "monitors",
            "all",
            "-j"
        ]

        stdout: StdioCollector {
            onStreamFinished: root.parse(text)
        }
    }

    Process {
        id: applier
    }

    // -----------------------------------------
    // REFRESH TIMER
    // -----------------------------------------

    Timer {
        id: refreshTimer

        interval: 800

        onTriggered: root.refresh()
    }

    Timer {
        id: settleTimer

        interval: 700

        onTriggered: root.refresh()
    }

    // -----------------------------------------
    // HYPRLAND HOTPLUG EVENTS
    // -----------------------------------------

    Connections {
        target: Hyprland

        function onRawEvent(event) {
            if (
                event.name !== "monitoradded" &&
                event.name !== "monitorremoved"
            )
                return;

            // Wait for Hyprland to finish updating
            // its monitor information.
            settleTimer.restart();
        }
    }

    // -----------------------------------------
    // QUICKSHELL IPC
    // -----------------------------------------

    IpcHandler {
        target: "projection"

        function toggle(): void {
            root.toggle();
        }

        function open(): void {
            root.open();
        }

        function refresh(): void {
            root.refresh();
        }

        function select(output: string): void {
            root.select(output);
        }
    }

    // -----------------------------------------
    // INITIALIZATION
    // -----------------------------------------

    Component.onCompleted: {
        refresh();
    }
}
