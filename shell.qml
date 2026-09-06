import Quickshell
import qs.bar

// Entry point: quickshell loads this file first.
ShellRoot {
    // Spawn one Bar per connected monitor.
    Variants {
        model: Quickshell.screens

        Bar {
            required property var modelData
            screen: modelData
        }
    }
}
