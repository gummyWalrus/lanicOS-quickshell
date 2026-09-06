import QtQuick
import qs.colors
import qs.fonts

Text {
    id: clock

    anchors.centerIn: parent
    color: Colors.primary
    font.family: Fonts.orbitron
    font.pixelSize: 16

    text: Qt.formatDateTime(new Date(), "mm:ss")

    Timer {
        interval: 60000
        running: true
        repeat: true
        // onTriggered: clock.text = Qt.formatDateTime(new Date(), "ddd d MMM  hh:mm:ss")
        onTriggered: clock.text = Qt.formatDateTime(new Date(), "hh:mm")
    }
}