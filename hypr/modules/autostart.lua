
-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function ()
    hl.exec_cmd("awww-daemon")
    hl.exec_cmd("quickshell")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("bt-agent -c NoInputNoOutput")
    hl.exec_cmd("~/.config/hypr/scripts/monitor-switch.sh")
end)

-- -- Recheck monitors when an external display is connected
-- hl.on("monitor.added", function (monitor)
--     hl.exec_cmd("sleep 1 && ~/.config/hypr/scripts/monitor-switch.sh")
-- end)

-- -- Recheck monitors when an external display is disconnected
-- hl.on("monitor.removed", function (monitor)
--     hl.exec_cmd("sleep 1 && ~/.config/hypr/scripts/monitor-switch.sh")
-- end)
