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
    // Transparent keeps the icon's own colors
    property color iconColor: "transparent"
    property color hoverIconColor: "transparent"
    
    property color textColor: "transparent"
    property color hoverTextColor: "transparent"

    property color bgColor: "transparent"
    property color hoverColor: "transparent"

    property int iconSize: 64
    
    implicitWidth: Math.max(content.implicitWidth, content.implicitHeight) + Config.padding * 2
    implicitHeight: implicitWidth

    color: mouseArea.containsMouse ? hoverColor : bgColor

    glowRadius: mouseArea.containsMouse ? 6 : 0

    border {
        width: 1
        color: mouseArea.containsMouse ? iconColor : "transparent"
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

            // Brightness first turns the icon white so colorization lands exactly on iconColor
            layer.enabled: r.iconColor.a > 0
            layer.effect: MultiEffect {
                brightness: 1.0
                colorization: 1.0
                colorizationColor: r.iconColor
            }
        }

        TextNeon {
            anchors.horizontalCenter: parent.horizontalCenter
            visible: r.label !== ""
            text: r.label
            color: mouseArea.containsMouse ? r.hoverTextColor : r.textColor

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
