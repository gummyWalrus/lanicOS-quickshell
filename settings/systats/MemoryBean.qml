import QtQuick

import qs.colors
import qs.components
import qs.config
import qs.services

NeonBeanFilled {
    readonly property bool alert: MemoryService.usage > Config.memoryUsageAlertThreshold

    colors.background: alert ? Colors.error : Colors.primary
    colors.text: alert ? Colors.errorText : Colors.primaryText
    icon: ""
    text: MemoryService.usedFormatted
    fontSize: 16

    Component.onCompleted: MemoryService.acquire()

    Component.onDestruction: MemoryService.release()
}
