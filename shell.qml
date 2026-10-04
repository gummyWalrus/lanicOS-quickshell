import Quickshell
import QtQuick // for Timer
import qs.bar
import qs.settings
import qs.services
import qs.widgets
import qs.clipboard_history

// Entry point: quickshell loads this file first.
Scope {
    Bar {}

    // Global so it outlives the settings popup, which dismisses when the dialog grabs focus.
    LazyLoader {
        active: WifiService.pendingNetwork !== null

        WifiPasswordDialog {}

    }

    Launcher {}

    ClipboardHistory {}
    
    Clock {
        position {
            bottom: true
            right: true
        }
    }
}
