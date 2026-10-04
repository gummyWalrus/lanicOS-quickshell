pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Greetd

import qs.config

// greetd conversation. Submitting opens a session and the queued password answers the first
// hidden prompt, any later prompt (OTP, ...) is handed back to the password field.
Singleton {
    id: root

    readonly property bool available: Greetd.available

    property string prompt: ""
    property bool echo: false
    property bool awaitingInput: false
    property string message: ""
    property bool failed: false
    property bool busy: false
    property bool launching: false

    property string queued: ""

    signal rejected()

    function submit(user, session, response) {
        if (!available || launching || busy)
            return;
        if (!session) {
            fail("No session found");
            return;
        }
        failed = false;
        message = "";
        if (Greetd.state === GreetdState.Inactive) {
            queued = response;
            busy = true;
            Greetd.createSession(user);
        } else if (awaitingInput) {
            awaitingInput = false;
            prompt = "";
            echo = false;
            busy = true;
            Greetd.respond(response);
        }
    }

    function cancel() {
        if (launching)
            return;
        if (Greetd.state !== GreetdState.Inactive)
            Greetd.cancelSession();
        reset();
    }

    function reset() {
        queued = "";
        prompt = "";
        echo = false;
        awaitingInput = false;
        busy = false;
    }

    function fail(text) {
        reset();
        message = text;
        failed = true;
        rejected();
    }

    Connections {
        target: Greetd

        function onAuthMessage(message, error, responseRequired, echoResponse) {
            if (responseRequired && !echoResponse && root.queued !== "") {
                Greetd.respond(root.queued);
                root.queued = "";
            } else if (responseRequired) {
                root.prompt = message;
                root.echo = echoResponse;
                root.awaitingInput = true;
                root.busy = false;
            } else {
                root.message = message;
                root.failed = error;
            }
        }

        function onAuthFailure() {
            root.fail("Authentication failed");
        }

        function onError(error) {
            if (Greetd.state !== GreetdState.Inactive)
                Greetd.cancelSession();
            root.fail(error);
        }

        function onReadyToLaunch() {
            root.reset();
            root.launching = true;
            launchTimer.start();
        }
    }

    // Lets the fade out finish first, greetd wants the greeter gone right after launch.
    // The session is read here so a change made during the PAM conversation is honored.
    Timer {
        id: launchTimer
        interval: Config.msAnimationDuration * 2
        onTriggered: Greetd.launch(SessionsService.command(SessionsService.current), SessionsService.environment(SessionsService.current))
    }
}
