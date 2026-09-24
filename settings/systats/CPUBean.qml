import QtQuick

import qs.components
import qs.services

NeonBeanFilled {
    icon: ""
    text: CPUService.usagePercent
    fontSize: 16

    Component.onCompleted: CPUService.acquire()

    Component.onDestruction: CPUService.release()
}
