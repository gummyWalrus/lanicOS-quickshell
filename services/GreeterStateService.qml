pragma Singleton

import Quickshell
import Quickshell.Io

import qs.greeter

// Last picked user and session, written back as soon as either changes.
Singleton {
    property alias user: adapter.user
    property alias session: adapter.session

    // Not persisted, the virtual keyboard starts hidden on every boot
    property bool virtualKeyboard: false

    FileView {
        path: GreeterConfig.stateFile
        onAdapterUpdated: writeAdapter()

        adapter: JsonAdapter {
            id: adapter

            property string user: ""
            property string session: ""
        }
    }
}
