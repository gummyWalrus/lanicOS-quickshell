pragma Singleton

import Quickshell
import Quickshell.Io

import qs.greeter

// Human accounts from /etc/passwd: uid in the login.defs range and a real login shell.
Singleton {
    id: root

    readonly property var list: parse(passwd.text())
    readonly property int currentIndex: Math.max(0, list.findIndex(u => u.name === GreeterStateService.user))
    readonly property var current: list[currentIndex] ?? null

    function select(index) {
        if (index >= 0 && index < list.length)
            GreeterStateService.user = list[index].name;
    }

    function parse(text) {
        return text.split("\n")
            .map(line => line.split(":"))
            .filter(f => f.length >= 7)
            .filter(f => {
                const uid = parseInt(f[2]);
                return uid >= GreeterConfig.minUid && uid < GreeterConfig.maxUid && !/(nologin|false)$/.test(f[6]);
            })
            .map(f => ({
                name: f[0],
                label: f[4].split(",")[0] || f[0]
            }));
    }

    FileView {
        id: passwd
        path: "/etc/passwd"
    }
}
