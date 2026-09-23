import QtQuick

import qs.colors
import qs.components
import qs.config
import qs.fonts
import qs.services

Item {
    id: root

    visible: BrightnessService.available
    implicitHeight: 24

    Text {
        id: icon

        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
        }
        width: 24
        text: BrightnessService.icon
        horizontalAlignment: Text.AlignHCenter
        font {
            family: Fonts.mono
            pixelSize: 16
        }
        color: Colors.primary
    }

    ProgressSliderNeon {
        anchors {
            verticalCenter: parent.verticalCenter
            left: icon.right
            leftMargin: Config.contentMargin
            right: root.right
            rightMargin: Config.contentMargin
        }

        value: BrightnessService.brightness
        onMoved: value => BrightnessService.setBrightness(value)
    }

    // Text {
    //     id: level

    //     anchors {
    //         verticalCenter: parent.verticalCenter
    //         right: parent.right
    //     }
    //     width: 40
    //     text: Math.round(BrightnessService.brightness * 100) + "%"
    //     horizontalAlignment: Text.AlignRight
    //     font {
    //         family: Fonts.mono
    //         pixelSize: 12
    //     }
    //     color: Colors.primary
    // }
}
