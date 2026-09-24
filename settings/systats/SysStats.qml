import QtQuick

import qs.services

Row {
    id: root

    spacing: 8

    // CPU {}
    CPUBean {}

    TemperatureBean {}

    // Text {
    //     text: "|"
    //     color: Colors.primary
    //     font.pixelSize: 16
    //     font.bold: true
    // }

    MemoryBean {}
    // Memory {}
}
