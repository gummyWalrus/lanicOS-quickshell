import QtQuick
import qs.fonts
import qs.colors
import qs.components

TextNeon {
    color: Colors.primary
    font.family: Fonts.orbitron
    font.pixelSize: 16
    
    text: Time.time
    glowStrength: 0.5
}
