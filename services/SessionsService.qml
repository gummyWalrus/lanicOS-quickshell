pragma Singleton

import Quickshell
import Quickshell.Io

import qs.greeter

// Wayland sessions read from their .desktop files, the same list SDDM offered.
Singleton {
    id: root

    property var list: []

    readonly property int currentIndex: {
        const saved = list.findIndex(s => s.id === GreeterStateService.session);
        if (saved >= 0)
            return saved;
        return Math.max(0, list.findIndex(s => s.id === GreeterConfig.defaultSession));
    }
    readonly property var current: list[currentIndex] ?? null

    function select(index) {
        if (index >= 0 && index < list.length)
            GreeterStateService.session = list[index].id;
    }

    // greetd joins argv into a sh command when sourcing profiles, so a plain split is enough.
    function command(session) {
        return session.exec.replace(/%[a-zA-Z]/g, "").trim().split(/\s+/);
    }

    function environment(session) {
        const env = ["XDG_SESSION_TYPE=wayland"];
        const names = session.desktopNames.split(";").filter(n => n !== "");
        if (names.length > 0) {
            env.push("XDG_CURRENT_DESKTOP=" + names.join(":"));
            env.push("XDG_SESSION_DESKTOP=" + names[0]);
        }
        return env;
    }

    function parse(text) {
        const byFile = {};
        for (const line of text.split("\n")) {
            const colon = line.indexOf(":");
            const equal = line.indexOf("=", colon);
            if (colon < 0 || equal < 0)
                continue;
            const file = line.slice(0, colon);
            const entry = byFile[file] ?? (byFile[file] = {
                id: file.replace(/^.*\//, "").replace(/\.desktop$/, ""),
                name: "",
                exec: "",
                desktopNames: "",
                hidden: false
            });
            const key = line.slice(colon + 1, equal);
            const value = line.slice(equal + 1).trim();
            if (key === "Name")
                entry.name = value;
            else if (key === "Exec")
                entry.exec = value;
            else if (key === "DesktopNames")
                entry.desktopNames = value;
            else if (value === "true")
                entry.hidden = true;
        }
        return Object.values(byFile).filter(s => !s.hidden && s.exec !== "").map(s => ({
            id: s.id,
            name: s.name || s.id,
            exec: s.exec,
            desktopNames: s.desktopNames
        }));
    }

    Process {
        running: true
        command: ["sh", "-c", "for d; do grep -sHE '^(Name|Exec|DesktopNames|Hidden|NoDisplay)=' \"$d\"/*.desktop; done; true", "sh"].concat(GreeterConfig.sessionDirs)
        stdout: StdioCollector {
            onStreamFinished: root.list = root.parse(text)
        }
    }
}
