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
    output   = "DP-2",
    mode     = "1920x1200@59.95Hz",
    position = "auto",
    scale    = "1.0",
    disabled = false
})
