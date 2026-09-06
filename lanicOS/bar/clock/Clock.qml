import QtQuick
import qs.colors

Text {
    id: clock

    anchors.centerIn: parent
    color: Colors.primary
    font.pixelSize: 14

    text: Qt.formatDateTime(new Date(), "ddd d MMM  hh:mm:ss")

    Timer {
        interval: 1000
        running: true
        repeat: true
        // onTriggered: clock.text = Qt.formatDateTime(new Date(), "ddd d MMM  hh:mm:ss")
        onTriggered: clock.text = Qt.formatDateTime(new Date(), "ddd d MMM  hh:mm:ss")
    }
}