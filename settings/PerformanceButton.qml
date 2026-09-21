import QtQuick
import Quickshell.Services.UPower
import qs.services

StateButton {
    anchors.fill: parent

    label: PowerService.label
    icon: PowerService.icon
    activated: PowerProfiles.profile === PowerProfile.Performance

    menu: Component { PerformanceMenu {} }
}
