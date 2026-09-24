import QtQuick

import qs.components
import qs.services

NeonBeanFilled {
    icon: ""
    text: MemoryService.usedFormatted
    fontSize: 16

    Component.onCompleted: MemoryService.acquire()

    Component.onDestruction: MemoryService.release()
}
