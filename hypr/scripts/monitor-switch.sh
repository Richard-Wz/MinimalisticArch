#!/usr/bin/env bash

# Automatically switch between the external monitor
# and the laptop screen.

EXTERNAL="HDMI-A-1"
LAPTOP="eDP-1"


apply_layout() {
    if hyprctl monitors -j | jq -e \
        --arg name "$EXTERNAL" \
        'any(.[]; .name == $name)' >/dev/null; then

        # External connected: use it exclusively.
        hyprctl eval 'hl.monitor({
            output = "HDMI-A-1",
            mode = "2560x1080@75.00Hz",
            position = "auto",
            scale = 1.0,
            disabled = false
        })'

        hyprctl eval 'hl.monitor({
            output = "eDP-1",
            disabled = true
        })'

    else
        # External disconnected: use laptop screen.
        hyprctl eval 'hl.monitor({
            output = "HDMI-A-1",
            disabled = true
        })'

        hyprctl eval 'hl.monitor({
            output = "eDP-1",
            mode = "preferred",
            position = "auto",
            scale = 1.0,
            disabled = false
        })'
    fi
}


# Apply the correct layout immediately on startup.
apply_layout

# Listen for monitor hotplug events.
SOCKET="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"

while IFS= read -r event; do
    case "$event" in
        monitoradded\>\>*|monitorremoved\>\>*)
            sleep 0.5
            apply_layout
            ;;
    esac
done < <(socat -U - "UNIX-CONNECT:$SOCKET")