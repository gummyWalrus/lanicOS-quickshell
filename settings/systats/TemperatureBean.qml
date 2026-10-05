import QtQuick

import qs.colors
import qs.components
import qs.config
import qs.services

NeonBeanFilled {
    readonly property bool alert: TemperatureService.temperature > Config.temperatureAlertThreshold

    colors.background: alert ? Colors.error : Colors.primary
    colors.text: alert ? Colors.errorText : Colors.primaryText
    icon: TemperatureService.icon
    text: Math.round(TemperatureService.temperature) + "°C"
    fontSize: 16

    Component.onCompleted: TemperatureService.acquire()

    Component.onDestruction: TemperatureService.release()
}
