import QtQuick
import QtQuick.Effects

import qs.components
import qs.fonts
import qs.config

NeonRectangle {
    id: r

    signal clicked

    property string iconName: ""
    property string label: ""
    // false keeps the icon's own colors
    property bool tintIcon: true

    property int iconSize: 64
    
    implicitWidth: Math.max(content.implicitWidth, content.implicitHeight) + Config.padding * 2
    implicitHeight: implicitWidth

    color: mouseArea.containsMouse ? colors.hover : colors.background

    glowRadius: mouseArea.containsMouse ? 6 : 0

    border {
        width: 1
        color: mouseArea.containsMouse ? colors.border : "transparent"
    }

    Behavior on color {
        ColorAnimation {
            duration: Config.msAnimationDuration
        }
    }

    Behavior on border.color {
        ColorAnimation {
            duration: Config.msAnimationDuration
        }
    }

    Column {
        id: content

        anchors.centerIn: parent
        spacing: Config.contentMargin

        Icon {
            name: r.iconName
            anchors.horizontalCenter: parent.horizontalCenter
            size: r.iconSize

            // Brightness first turns the icon white so colorization lands exactly on colors.text
            layer.enabled: r.tintIcon
            layer.effect: MultiEffect {
                brightness: 1.0
                colorization: 1.0
                colorizationColor: r.colors.text
            }
        }

        TextNeon {
            anchors.horizontalCenter: parent.horizontalCenter
            visible: r.label !== ""
            text: r.label
            colors: r.colors

            font {
                family: Fonts.mono
                pixelSize: 10
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: r.clicked()
    }
}
