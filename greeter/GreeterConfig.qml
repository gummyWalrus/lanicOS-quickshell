pragma Singleton

import Quickshell

// Greeter-only settings. Shared look and timings still come from qs.config.
Singleton {
    // Desktop file basename picked when nothing was remembered yet
    readonly property string defaultSession: "hyprland-uwsm"
    readonly property var sessionDirs: ["/usr/share/wayland-sessions", "/usr/local/share/wayland-sessions"]

    // Same range as login.defs UID_MIN / UID_MAX
    readonly property int minUid: 1000
    readonly property int maxUid: 60000

    readonly property int fontSize: 16

    // Created by copy-greeter.sh, owned by the greeter user
    readonly property string stateFile: "/var/lib/lanicos-greeter/state.json"
    readonly property string wallpaper: Quickshell.shellDir + "/assets/wallpaper"
}
