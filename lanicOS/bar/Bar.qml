import Quickshell // for PanelWindow
import QtQuick // for Text, Timer
import qs.colors
import qs.bar.clock

PanelWindow {
    id: bar

    anchors {
        top: true
        left: true
        right: true
    }

    implicitHeight: 30
    color: Colors.background

    Clock {}

}
