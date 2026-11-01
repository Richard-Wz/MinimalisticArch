------------------
---- MONITORS ----
------------------

-- External monitor
hl.monitor({
    output   = "HDMI-A-1",
    mode     = "2560x1080@75.00Hz",
    position = "auto",
    scale    = "1.0",
    disabled = false
})

-- Laptop screen
hl.monitor({
    output   = "eDP-1",
    mode     = "preferred",
    position = "auto",
    scale    = "1.0",
    disabled = false
})
