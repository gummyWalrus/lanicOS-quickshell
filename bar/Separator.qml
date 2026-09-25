import QtQuick

import qs.colors
import qs.fonts

// Waybar custom/sep equivalent: a plain "|" in on_primary at the bar's 16px font size.
Text {
    text: "|"
    color: Colors.primaryText
    font {
        family: Fonts.mono
        pixelSize: 16
        bold: true
    }
}
