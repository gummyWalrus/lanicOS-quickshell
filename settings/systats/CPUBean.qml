import QtQuick

import qs.colors
import qs.components
import qs.config
import qs.services

NeonBeanFilled {
    readonly property bool alert: CPUService.usage > Config.cpuUsageAlertThreshold

    color: alert ? Colors.error : Colors.primary
    textColor: alert ? Colors.errorText : Colors.primaryText
    icon: ""
    text: CPUService.usagePercent
    fontSize: 16

    Component.onCompleted: CPUService.acquire()

    Component.onDestruction: CPUService.release()
}
