import QtQuick

import qs.components
import qs.services

NeonBeanFilled {
    icon: TemperatureService.icon
    text: Math.round(TemperatureService.temperature) + "°C"
    fontSize: 16

    Component.onCompleted: TemperatureService.acquire()

    Component.onDestruction: TemperatureService.release()
}
