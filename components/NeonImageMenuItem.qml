import QtQuick

import qs.config

// NeonMenuItem that shows an image fitted inside it instead of a label.
NeonMenuItem {
    id: r

    property alias source: image.source

    height: 128

    Image {
        id: image
        anchors.fill: parent
        anchors.margins: Config.contentMargin
        fillMode: Image.PreserveAspectFit
        sourceSize {
            width: image.width
            height: image.height
        }
        asynchronous: true
        smooth: true
    }
}
