pragma Singleton

import Quickshell
import Quickshell.Services.UPower

// Indexed by PowerProfile::Enum: PowerSaver, Balanced, Performance
Singleton {
    readonly property var icons: ["󰾆", "󰾅", "󰓅"] // placeholder glyphs, swap to taste
    readonly property var labels: ["Power Saver", "Balanced", "Performance"]

    readonly property string label: labels[PowerProfiles.profile]
    readonly property string icon: icons[PowerProfiles.profile]

    readonly property var profiles: {
        const available = [PowerProfile.PowerSaver, PowerProfile.Balanced]
        if (PowerProfiles.hasPerformanceProfile)
            available.push(PowerProfile.Performance)
        return available
    }

    function setProfile(profile) {
        PowerProfiles.profile = profile
    }
}
