
-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function ()
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("quickshell")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("bt-agent -c NoInputNoOutput")
    hl.exec_cmd("~/.config/hypr/scripts/monitor-switch.sh")
end)

