-- Compositor for the lanicOS greeter, started by greetd as the "greeter" user.
-- No binds on purpose: the only way out is logging in, and Hyprland exits with quickshell.
-- Keep monitors, input and env in sync with ~/.config/hypr/hyprland.lua.

hl.monitor({
    output   = "eDP-1",
    mode     = "1920x1200",
    position = "0x0",
    scale    = "1.0",
})

hl.monitor({ output = "", mode = "1920x1080", position = "1920x0", scale = 1 })

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")

hl.env("QS_DISABLE_FILE_WATCHER", "1")
hl.env("QS_NO_RELOAD_POPUP", "1")

hl.config({
    input = {
        kb_layout    = "us,fr",
        kb_options   = "grp:alt_shift_toggle",

        touchpad     = {
            natural_scroll = true,
        },

        repeat_rate  = 35,
        repeat_delay = 200
    },
    cursor = {
        inactive_timeout = 30,
        no_hardware_cursors = true
    },
    misc = {
        force_default_wallpaper  = 0,
        disable_hyprland_logo    = true,
        disable_splash_rendering = true,
        disable_autoreload       = true,
    },
    ecosystem = {
        no_update_news  = true,
        no_donation_nag = true,
    },
})

hl.on("hyprland.start", function()
    hl.exec_cmd("quickshell -p /usr/share/greeter; hyprctl dispatch 'hl.dsp.exit()'")
end)
