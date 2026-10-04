pragma Singleton

import Quickshell
import Quickshell.Io

import qs.greeter

// Last picked user and session, written back as soon as either changes.
Singleton {
    property alias user: adapter.user
    property alias session: adapter.session

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
