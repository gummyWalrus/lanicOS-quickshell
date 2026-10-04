import Quickshell

import qs.widgets
import qs.greeter

// Greeter entry point, installed as /usr/share/greeter/shell.qml by copy-greeter.sh so that
// qs.* imports resolve against the shared folders copied next to it.
Scope {
    Wallpaper {}

    GreeterWarnText {}

    Clock {
        position {
            top: true
        }

        margin: 200
    }

    StatusBar {}

    LoginWindow {}

    PowerActions {}

    Sessions {}
}
