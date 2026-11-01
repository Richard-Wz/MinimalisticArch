--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- and https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/

-- Example window rules that are useful

local suppressMaximizeRule = hl.window_rule({
    -- Ignore maximize requests from all apps. You'll probably like this.
    name  = "suppress-maximize-events",
    match = { class = ".*" },

    suppress_event = "maximize",
})

suppressMaximizeRule:set_enabled(true)

hl.window_rule({
    -- Fix some dragging issues with XWayland
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },

    no_focus = true,
})

hl.workspace_rule({workspace = "1", persistent = true })
hl.workspace_rule({workspace = "2", persistent = true })
hl.workspace_rule({workspace = "3", persistent = true })
hl.workspace_rule({workspace = "4", persistent = true })
hl.workspace_rule({workspace = "5", persistent = true })

hl.layer_rule({
    match = {namespace = "wofi"},
    blur = true,
    ignore_alpha = 0.2
})
