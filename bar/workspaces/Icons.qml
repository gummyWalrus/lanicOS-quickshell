pragma Singleton

import QtQuick
import Quickshell

Singleton {
    property ListModel items: ListModel {
        ListElement { icon: "" }
        ListElement { icon: "󰈹" }
        ListElement { icon: "󰨞" }
        ListElement { icon: "" }
        ListElement { icon: "󰣇" }
    }

    function iconFor(id) {
        return ((id < 0 || id > items.count - 1) ? "󰣇" : items.get(id - 1).icon);
    }
}
