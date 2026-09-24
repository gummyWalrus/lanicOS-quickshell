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

    // Battery percent thresholds, same as the waybar battery states
    readonly property int batteryGoodThreshold: 95
    readonly property int batteryCriticalThreshold: 15

    // System stats alert thresholds, usage as a 0-1 fraction and temperature in °C
    readonly property real cpuUsageAlertThreshold: 0.95
    readonly property real memoryUsageAlertThreshold: 0.95
    readonly property real temperatureAlertThreshold: 80

    // Backlight device under /sys/class/backlight
    readonly property string backlightDevice: "intel_backlight"
}