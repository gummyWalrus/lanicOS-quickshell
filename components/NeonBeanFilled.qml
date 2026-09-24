import QtQuick

import qs.colors

// NeonBean without a border, filled with color. Its glow takes the fill color.
NeonBean {
    glowColor: color
    color: Colors.primary
    textColor: Colors.primaryText

    border.width: 0
}
