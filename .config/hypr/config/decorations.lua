-- Look and feel configuration

hl.config({
    general = {
        gaps_in = 3,
        gaps_out = 8,
        border_size = 2,
        extend_border_grab_area = 10,
        resize_on_border = true,
        col = {
            active_border = {
                colors = { MOCHA_MAUVE, MOCHA_LAVENDER },
                angle = 45,
            },
            inactive_border = MOCHA_OVERLAY0,
        },
    },
    group = {
        col = {
            border_active = MOCHA_BLUE,
            border_inactive = MOCHA_OVERLAY0,
            border_locked_active = MOCHA_PEACH,
            border_locked_inactive = MOCHA_SURFACE1,
        },
        groupbar = {
            col = {
                active = MOCHA_MAUVE,
                inactive = MOCHA_OVERLAY0,
                locked_active = MOCHA_PEACH,
                locked_inactive = MOCHA_SURFACE1,
            },
        },
    },
    decoration = {
        dim_special = 0.3,
        rounding = 10,
        active_opacity = 0.95,
        inactive_opacity = 0.85,
        fullscreen_opacity = 1,
        blur = {
            size = 5,
            passes = 4,
            special = true,
        },
    },
})
