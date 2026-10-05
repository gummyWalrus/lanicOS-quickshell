import QtQuick

import qs.colors
import qs.types

// NeonBean without a border, filled with color. Its glow takes the fill color.
NeonBean {
    glowColor: color

    colors: ColorScheme {
        background: Colors.primary
        text: Colors.primaryText
    }

    border.width: 0
}
