pragma Singleton

import Quickshell

Singleton {
    // Layout properties
    readonly property int contentMargin: 6

    // Settings panel properties
    readonly property int settingsPanelWidth: 400
    readonly property int settingsPanelHeight: 600


    // Animation properties
    readonly property int msPerCharacter: 100
    readonly property int msPauseText: 1000

    readonly property int msAnimationDuration: 150


    // Network properties
    readonly property string defaultNetworkDeviceType: "Wifi"

    // Backlight device under /sys/class/backlight
    readonly property string backlightDevice: "intel_backlight"
}