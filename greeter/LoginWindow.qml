pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland

import qs.colors
import qs.services
import qs.components
import qs.config
import qs.fonts
import qs.types

// Centered login card on the main screen, it owns the keyboard. Escape quits when greetd
// is missing so `copy-greeter.sh --preview` can be closed.
PanelWindow {
    id: window

    screen: GreeterConfig.screen

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "greeter-login"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"

    // Room for the glow and the shake
    implicitWidth: card.implicitWidth + 40
    implicitHeight: card.implicitHeight + 10

    // No anchors = centered on the screen

    function submit() {
        AuthService.submit(UsersService.current?.name ?? "", SessionsService.current, password.text);
        password.clear();
    }

    function restart() {
        AuthService.cancel();
        password.clear();
        password.forceActiveFocus();
    }

    Connections {
        target: AuthService

        function onRejected() {
            shake.restart();
            password.forceActiveFocus();
        }
    }

    Item { // NeonRectangle
        id: card

        readonly property int padding: 12
        property real shakeOffset: 0

        anchors.centerIn: parent
        anchors.horizontalCenterOffset: shakeOffset
        implicitWidth: 400
        implicitHeight: body.implicitHeight + padding * 2
        // color: Colors.surface
        // animated: AuthService.busy
        // opacity: AuthService.launching ? 0 : 1

        // border {
        //     color: Colors.primaryContainer
        //     width: 1
        // }

        Behavior on opacity {
            NumberAnimation {
                duration: Config.msAnimationDuration * 2
            }
        }

        SequentialAnimation {
            id: shake

            loops: 2

            NumberAnimation {
                target: card
                property: "shakeOffset"
                to: 12
                duration: 40
            }
            NumberAnimation {
                target: card
                property: "shakeOffset"
                to: -12
                duration: 80
            }
            NumberAnimation {
                target: card
                property: "shakeOffset"
                to: 0
                duration: 40
            }
        }

        Column {
            id: body
            spacing: card.padding
            anchors {
                fill: parent
                margins: card.padding
            }

            Selector {
                id: userSelector
                icon: ""
                model: UsersService.list.map(u => u.label)
                width: parent.width
                currentIndex: UsersService.currentIndex
                onActivated: index => {
                    UsersService.select(index);
                    window.restart();
                }

                colors: ColorScheme {
                    background: Qt.rgba(Colors.surfaceContainerLowest.r, Colors.surfaceContainerLowest.g, Colors.surfaceContainerLowest.b, 0.65)
                }

                // border.color: hovered ? Colors.primary : Colors.primaryText
            }

            NeonRectangle {
                
                implicitWidth: parent.implicitWidth
                implicitHeight: userSelector.implicitHeight

                color: Qt.rgba(Colors.surfaceContainerLowest.r, Colors.surfaceContainerLowest.g, Colors.surfaceContainerLowest.b, 0.65) // Colors.surface

                border {
                    width: 1
                    color: Colors.primary
                }

                RowLayout {

                    anchors {
                        left: parent.left
                        leftMargin: card.padding
                        verticalCenter: parent.verticalCenter
                    }

                    id: passwordRow

                    implicitWidth: parent.implicitWidth - card.padding
                    spacing: card.padding

                    TextNeon {

                        color: Colors.primary
                        text: AuthService.echo ? "󰈈" : "󰈉"
                        font {
                            pixelSize: GreeterConfig.fontSize
                            family: Fonts.mono
                        }

                        glowRadius: mouseArea.containsMouse ? 1 : 0
                        animated: mouseArea.containsMouse

                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: () =>
                            {
                                AuthService.echo = !AuthService.echo
                                console.log("Authservie::echo set to ", AuthService.echo)
                            }
                            cursorShape: Qt.PointingHandCursor
                        }
                    }

                    TextField {
                        id: password

                        Layout.fillWidth: true
                        focus: true
                        
                        implicitWidth: card.implicitWidth - login.implicitWidth
                        enabled: !AuthService.launching
                        readOnly: AuthService.busy
                        echoMode: AuthService.echo ? TextInput.Normal : TextInput.Password
                        inputMethodHints: Qt.ImhSensitiveData | Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase
                        placeholderText: AuthService.prompt !== "" ? AuthService.prompt : "Password"
                        onAccepted: window.submit()
                        Keys.onEscapePressed: AuthService.available ? window.restart() : Qt.quit()
                        color: Colors.primary
                        selectionColor: Colors.primary
                        selectedTextColor: Colors.primaryText
                        placeholderTextColor: Colors.primaryText
                        font {
                            pixelSize: GreeterConfig.fontSize
                            family: Fonts.mono
                        }

                        background: Rectangle {
                            color: "transparent" //Qt.rgba(Colors.surfaceContainerLowest.r, Colors.surfaceContainerLowest.g, Colors.surfaceContainerLowest.b, 0.65) // Colors.surface
                        }
                    }

                    NeonButton {
                        id: login

                        implicitHeight: userSelector.implicitHeight - 2

                        bgColor: Colors.primary
                        hoverColor: Colors.primary
                        textColor: Colors.primaryText
                        enabled: AuthService.available && !AuthService.busy && SessionsService.current !== null

                        onClicked: window.submit()

                        text: "󰅂"
                        fontSize: 24
                    }
                }
            }
        }
    }
}
