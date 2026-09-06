import QtQuick
import qs.fonts
import qs.colors

Text {
    color: Colors.primary
    font.family: Fonts.orbitron
    font.pixelSize: 16
    
    text: Time.time
}
