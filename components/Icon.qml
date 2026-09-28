// Icon.qml
// Resolves an icon string from a .desktop file (or anywhere else) into a
// displayable image, handling the usual edge cases.
import Quickshell
import QtQuick

Item {
    id: root

    // Raw value: theme name, absolute path, or URL
    property string name: ""
    // Theme icon used when `name` is empty or can't be resolved
    property string fallback: "application-x-executable"
    property int size: 32

    implicitWidth: size
    implicitHeight: size

    // Set to true after the primary source fails to load
    property bool _failed: false
    onNameChanged: _failed = false

    function _resolve(raw) {
        const s = (raw ?? "").trim();
        if (s === "")
            return "";

        // Already a URL (file://, image://, qrc:, http(s)://)
        if (/^[a-zA-Z][a-zA-Z0-9+.-]*:\/\//.test(s) || s.startsWith("qrc:"))
            return s;

        // Absolute path
        if (s.startsWith("/"))
            return "file://" + s;

        // Relative path such as "./icon.png" or "icons/foo.svg": can't resolve
        if (s.includes("/"))
            return "";

        // Theme name. Some .desktop files write "foo.png" instead of "foo"
        const bare = s.replace(/\.(png|svg|xpm|jpg|jpeg)$/i, "");

        // check=true returns "" when the theme has no such icon
        const found = Quickshell.iconPath(bare, true);
        return found !== "" ? found : "";
    }

    readonly property string _primary: _resolve(name)
    readonly property string _fallbackSource: {
        const f = Quickshell.iconPath(fallback, true);
        return f !== "" ? f : "";
    }

    readonly property string source: (_primary !== "" && !_failed) ? _primary : _fallbackSource

    Image {
        anchors.fill: parent
        source: root.source
        sourceSize: Qt.size(root.size, root.size)
        fillMode: Image.PreserveAspectFit
        asynchronous: true
        smooth: true
        mipmap: true

        // If the primary source fails (broken path, bad file), switch to fallback once
        onStatusChanged: {
            if (status === Image.Error && root.source === root._primary && root._fallbackSource !== "")
                root._failed = true;
        }
    }
}
