import QtQuick
import qs.fonts
import qs.components

TextNeon {
    font.family: Fonts.orbitron
    font.pixelSize: 16
    
    text: Time.time
    glowStrength: 0.5
}
