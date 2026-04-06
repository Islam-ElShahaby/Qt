import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Window {
    id: rootWindow
    visible: true
    title: "RPi GPIO Control"
    width: 900
    height: 700
    color: "#1a0a2e"

    Shortcut {
        sequence: "Esc"
        onActivated: Qt.quit()
    }

    // C++ backend
    GpioController {
        id: gpioCtrl
    }

    // Cleanup on window close
    onClosing: {
        gpioCtrl.unexportAll();
    }

    // Available GPIO pins on RPi 3B+ (BCM numbering)
    property var gpioPins: [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27]

    // Track pin states in JS
    property var pinStates: ({})

    Component.onCompleted: {
        var states = {};
        for (var i = 0; i < gpioPins.length; i++) {
            var pin = gpioPins[i];
            states[pin] = { exported: false, direction: "in", value: 0 };
        }
        pinStates = states;
        fadeIn.start();
    }

    // Listen for live value updates from polling
    Connections {
        target: gpioCtrl
        function onPinValueChanged(gpioPin, value) {
            var s = pinStates;
            if (s[gpioPin]) {
                s[gpioPin].value = value;
                pinStates = s; // trigger binding update
            }
        }
        function onErrorOccurred(gpioPin, message) {
            errorText.text = "⚠ GPIO " + gpioPin + ": " + message;
            errorFadeOut.restart();
        }
    }

    // Gradient Background
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: '#360d5b' }
            GradientStop { position: 0.5; color: '#7748a0' }
            GradientStop { position: 1.0; color: '#432e54' }
        }
    }

    // Subtle animated glow orb
    Rectangle {
        id: glowOrb
        width: 500
        height: 500
        radius: 250
        color: "transparent"
        anchors.centerIn: parent

        Rectangle {
            anchors.fill: parent
            radius: 250
            opacity: 0.06
            gradient: Gradient {
                GradientStop { position: 0.0; color: '#ff1596' }
                GradientStop { position: 1.0; color: "transparent" }
            }
        }

        SequentialAnimation on anchors.verticalCenterOffset {
            loops: Animation.Infinite
            NumberAnimation { to: -100; duration: 4000; easing.type: Easing.InOutSine }
            NumberAnimation { to: -60 ; duration: 4000; easing.type: Easing.InOutSine }
        }
    }

    // Fade-in
    opacity: 0
    NumberAnimation {
        id: fadeIn
        target: rootWindow
        property: "opacity"
        from: 0; to: 1; duration: 600
        easing.type: Easing.OutCubic
    }

    // MAIN LAYOUT
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 0

        // ── HEADER ──
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 56

            RowLayout {
                anchors.fill: parent
                spacing: 14

                // Accent bar
                Rectangle {
                    width: 4; height: 30; radius: 2
                    color: "#9333ea"
                    Layout.alignment: Qt.AlignVCenter
                }

                ColumnLayout {
                    spacing: 2
                    Text {
                        text: "RPi 3B+ GPIO Control"
                        color: "#ffffff"
                        font.pixelSize: 22
                        font.weight: Font.Bold
                        font.family: "Segoe UI, Roboto, sans-serif"
                    }
                    Text {
                        text: "sysfs · base offset 512 · live polling"
                        color: "#a78bfa"
                        font.pixelSize: 11
                        font.family: "Segoe UI, Roboto, sans-serif"
                    }
                }

                Item { Layout.fillWidth: true }

                // Error banner
                Text {
                    id: errorText
                    color: "#f87171"
                    font.pixelSize: 12
                    font.weight: Font.Medium
                    opacity: 0
                    Behavior on opacity { NumberAnimation { duration: 300 } }

                    Timer {
                        id: errorFadeOut
                        interval: 4000
                        onTriggered: errorText.opacity = 0
                    }

                    onTextChanged: opacity = 1
                }

                // Unexport All button
                Rectangle {
                    width: unexportAllRow.width + 24
                    height: 36
                    radius: 18
                    color: unexportAllMa.containsMouse ? "#7f1d1d" : "#2a1245"
                    border.color: "#f87171"
                    border.width: 1
                    Layout.alignment: Qt.AlignVCenter

                    Behavior on color { ColorAnimation { duration: 200 } }

                    Row {
                        id: unexportAllRow
                        anchors.centerIn: parent
                        spacing: 6
                        Text { text: "⏻"; color: "#f87171"; font.pixelSize: 14 }
                        Text { text: "Unexport All"; color: "#fca5a5"; font.pixelSize: 12; font.weight: Font.Medium }
                    }

                    MouseArea {
                        id: unexportAllMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            gpioCtrl.unexportAll();
                            // Reset all states
                            var s = {};
                            for (var i = 0; i < gpioPins.length; i++) {
                                var pin = gpioPins[i];
                                s[pin] = { exported: false, direction: "in", value: 0 };
                            }
                            pinStates = s;
                        }
                    }

                    scale: unexportAllMa.pressed ? 0.95 : 1.0
                    Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.OutCubic } }
                }
            }
        }

        // Separator
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            Layout.topMargin: 8
            Layout.bottomMargin: 12
            color: "#ffffff"
            opacity: 0.1
        }

        // ── PIN GRID ──
        Flickable {
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentHeight: pinGrid.height
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AsNeeded
                contentItem: Rectangle {
                    implicitWidth: 5
                    radius: 3
                    color: "#9333ea"
                    opacity: 0.5
                }
            }

            GridLayout {
                id: pinGrid
                width: parent.width
                columns: Math.max(1, Math.floor(parent.width / 280))
                columnSpacing: 12
                rowSpacing: 12

                Repeater {
                    model: gpioPins.length

                    // ── SINGLE PIN CARD ──
                    Rectangle {
                        id: pinCard
                        required property int index

                        property int gpioPin: gpioPins[index]
                        property var pinState: pinStates[gpioPin] || { exported: false, direction: "in", value: 0 }
                        property bool isExported: pinState.exported
                        property string pinDirection: pinState.direction
                        property int pinValue: pinState.value

                        Layout.fillWidth: true
                        Layout.preferredHeight: isExported ? 180 : 64
                        radius: 16
                        color: "#2a1245"
                        border.color: isExported ? (pinDirection === "out" && pinValue === 1 ? "#22c55e" : "#6b3fa0") : "#4a2870"
                        border.width: 1

                        Behavior on Layout.preferredHeight {
                            NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
                        }
                        Behavior on border.color {
                            ColorAnimation { duration: 300 }
                        }

                        // Hover glow
                        Rectangle {
                            anchors.fill: parent
                            radius: 16
                            color: "#9333ea"
                            opacity: cardMa.containsMouse ? 0.06 : 0
                            Behavior on opacity { NumberAnimation { duration: 200 } }
                        }

                        MouseArea {
                            id: cardMa
                            anchors.fill: parent
                            hoverEnabled: true
                        }

                        // Active glow for HIGH output pins
                        Rectangle {
                            anchors.fill: parent
                            radius: 16
                            color: "#22c55e"
                            opacity: (pinCard.isExported && pinCard.pinDirection === "out" && pinCard.pinValue === 1) ? 0.08 : 0
                            Behavior on opacity { NumberAnimation { duration: 400 } }
                        }

                        clip: true

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 14
                            spacing: 10

                            // ── Row 1: Pin header + Export toggle ──
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 10

                                // Pin number badge
                                Rectangle {
                                    width: 36; height: 36; radius: 18
                                    color: pinCard.isExported ? "#3d1d60" : "#251040"

                                    Behavior on color { ColorAnimation { duration: 200 } }

                                    Text {
                                        anchors.centerIn: parent
                                        text: pinCard.gpioPin
                                        color: pinCard.isExported ? "#c084fc" : "#7c5aa0"
                                        font.pixelSize: 14
                                        font.weight: Font.Bold

                                        Behavior on color { ColorAnimation { duration: 200 } }
                                    }
                                }

                                ColumnLayout {
                                    spacing: 1
                                    Text {
                                        text: "GPIO " + pinCard.gpioPin
                                        color: pinCard.isExported ? "#ffffff" : "#8b7aab"
                                        font.pixelSize: 14
                                        font.weight: Font.Bold

                                        Behavior on color { ColorAnimation { duration: 200 } }
                                    }
                                    Text {
                                        text: pinCard.isExported
                                              ? (pinCard.pinDirection === "out" ? "Output" : "Input")
                                              : "Not exported"
                                        color: pinCard.isExported ? "#a78bfa" : "#5c4880"
                                        font.pixelSize: 10

                                        Behavior on color { ColorAnimation { duration: 200 } }
                                    }
                                }

                                Item { Layout.fillWidth: true }

                                // ── Export toggle switch ──
                                Rectangle {
                                    id: exportToggleBg
                                    width: 50; height: 26; radius: 13
                                    color: pinCard.isExported ? "#9333ea" : "#3d1d60"
                                    border.color: pinCard.isExported ? "#a855f7" : "#5c4880"
                                    border.width: 1

                                    Behavior on color { ColorAnimation { duration: 300 } }
                                    Behavior on border.color { ColorAnimation { duration: 300 } }

                                    Rectangle {
                                        id: exportToggleKnob
                                        width: 20; height: 20; radius: 10
                                        y: 3
                                        x: pinCard.isExported ? parent.width - width - 3 : 3
                                        color: "#ffffff"

                                        Behavior on x {
                                            NumberAnimation { duration: 250; easing.type: Easing.OutBack; easing.overshoot: 1.2 }
                                        }

                                        // subtle shadow
                                        Rectangle {
                                            anchors.fill: parent
                                            anchors.margins: -1
                                            radius: 11
                                            color: "transparent"
                                            border.color: "#00000033"
                                            border.width: 1
                                        }
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            var s = pinStates;
                                            var pin = pinCard.gpioPin;
                                            if (pinCard.isExported) {
                                                gpioCtrl.unexportPin(pin);
                                                s[pin] = { exported: false, direction: "in", value: 0 };
                                            } else {
                                                if (gpioCtrl.exportPin(pin)) {
                                                    gpioCtrl.setDirection(pin, "in");
                                                    var val = gpioCtrl.getValue(pin);
                                                    s[pin] = { exported: true, direction: "in", value: val };
                                                }
                                            }
                                            pinStates = s;
                                        }
                                    }
                                }
                            }

                            // ── Expanded content (when exported) ──
                            Item {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                visible: pinCard.isExported
                                opacity: pinCard.isExported ? 1 : 0
                                Behavior on opacity { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }

                                ColumnLayout {
                                    anchors.fill: parent
                                    spacing: 10

                                    // Separator
                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 1
                                        color: "#6b3fa0"
                                        opacity: 0.4
                                    }

                                    // ── Direction selector ──
                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: 8

                                        Text {
                                            text: "Direction"
                                            color: "#c084fc"
                                            font.pixelSize: 11
                                            font.weight: Font.Bold
                                            font.letterSpacing: 1.5
                                            Layout.alignment: Qt.AlignVCenter
                                        }

                                        Item { Layout.fillWidth: true }

                                        // Input button
                                        Rectangle {
                                            width: 64; height: 28; radius: 14
                                            color: pinCard.pinDirection === "in" ? "#9333ea" : "#3d1d60"
                                            border.color: pinCard.pinDirection === "in" ? "#a855f7" : "#5c4880"
                                            border.width: 1

                                            Behavior on color { ColorAnimation { duration: 200 } }

                                            Text {
                                                anchors.centerIn: parent
                                                text: "IN"
                                                color: pinCard.pinDirection === "in" ? "#ffffff" : "#8b7aab"
                                                font.pixelSize: 11
                                                font.weight: Font.Bold
                                            }

                                            MouseArea {
                                                anchors.fill: parent
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: {
                                                    if (pinCard.pinDirection !== "in") {
                                                        var pin = pinCard.gpioPin;
                                                        gpioCtrl.setDirection(pin, "in");
                                                        var s = pinStates;
                                                        var val = gpioCtrl.getValue(pin);
                                                        s[pin] = { exported: true, direction: "in", value: val };
                                                        pinStates = s;
                                                    }
                                                }
                                            }
                                        }

                                        // Output button
                                        Rectangle {
                                            width: 64; height: 28; radius: 14
                                            color: pinCard.pinDirection === "out" ? "#9333ea" : "#3d1d60"
                                            border.color: pinCard.pinDirection === "out" ? "#a855f7" : "#5c4880"
                                            border.width: 1

                                            Behavior on color { ColorAnimation { duration: 200 } }

                                            Text {
                                                anchors.centerIn: parent
                                                text: "OUT"
                                                color: pinCard.pinDirection === "out" ? "#ffffff" : "#8b7aab"
                                                font.pixelSize: 11
                                                font.weight: Font.Bold
                                            }

                                            MouseArea {
                                                anchors.fill: parent
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: {
                                                    if (pinCard.pinDirection !== "out") {
                                                        var pin = pinCard.gpioPin;
                                                        gpioCtrl.setDirection(pin, "out");
                                                        var s = pinStates;
                                                        s[pin] = { exported: true, direction: "out", value: 0 };
                                                        pinStates = s;
                                                    }
                                                }
                                            }
                                        }
                                    }

                                    // ── Value row ──
                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: 8

                                        Text {
                                            text: "Value"
                                            color: "#c084fc"
                                            font.pixelSize: 11
                                            font.weight: Font.Bold
                                            font.letterSpacing: 1.5
                                            Layout.alignment: Qt.AlignVCenter
                                        }

                                        Item { Layout.fillWidth: true }

                                        // ── INPUT MODE: Read-only value indicator ──
                                        Rectangle {
                                            visible: pinCard.pinDirection === "in"
                                            width: 80; height: 32; radius: 16
                                            color: "#3d1d60"
                                            border.color: pinCard.pinValue === 1 ? "#22c55e" : "#6b3fa0"
                                            border.width: 1

                                            Behavior on border.color { ColorAnimation { duration: 300 } }

                                            Row {
                                                anchors.centerIn: parent
                                                spacing: 6

                                                // Indicator dot
                                                Rectangle {
                                                    width: 8; height: 8; radius: 4
                                                    anchors.verticalCenter: parent.verticalCenter
                                                    color: pinCard.pinValue === 1 ? "#22c55e" : "#ef4444"

                                                    Behavior on color { ColorAnimation { duration: 300 } }

                                                    // Pulsing glow for HIGH
                                                    Rectangle {
                                                        anchors.centerIn: parent
                                                        width: 16; height: 16; radius: 8
                                                        color: parent.color
                                                        opacity: pinCard.pinValue === 1 ? 0.3 : 0
                                                        Behavior on opacity { NumberAnimation { duration: 300 } }
                                                    }
                                                }

                                                Text {
                                                    text: pinCard.pinValue === 1 ? "HIGH" : "LOW"
                                                    color: pinCard.pinValue === 1 ? "#4ade80" : "#f87171"
                                                    font.pixelSize: 12
                                                    font.weight: Font.Bold
                                                    anchors.verticalCenter: parent.verticalCenter
                                                }
                                            }
                                        }

                                        // ── OUTPUT MODE: ON/OFF toggle switch ──
                                        Rectangle {
                                            id: valueToggleBg
                                            visible: pinCard.pinDirection === "out"
                                            width: 80; height: 32; radius: 16
                                            color: pinCard.pinValue === 1 ? "#166534" : "#3d1d60"
                                            border.color: pinCard.pinValue === 1 ? "#22c55e" : "#5c4880"
                                            border.width: 1

                                            Behavior on color { ColorAnimation { duration: 300 } }
                                            Behavior on border.color { ColorAnimation { duration: 300 } }

                                            // Label
                                            Text {
                                                anchors.centerIn: parent
                                                anchors.horizontalCenterOffset: pinCard.pinValue === 1 ? -10 : 10
                                                text: pinCard.pinValue === 1 ? "ON" : "OFF"
                                                color: pinCard.pinValue === 1 ? "#86efac" : "#8b7aab"
                                                font.pixelSize: 10
                                                font.weight: Font.Bold
                                                font.letterSpacing: 1

                                                Behavior on anchors.horizontalCenterOffset {
                                                    NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
                                                }
                                                Behavior on color { ColorAnimation { duration: 250 } }
                                            }

                                            // Toggle knob
                                            Rectangle {
                                                id: valueKnob
                                                width: 24; height: 24; radius: 12
                                                y: 4
                                                x: pinCard.pinValue === 1 ? parent.width - width - 4 : 4
                                                color: pinCard.pinValue === 1 ? "#22c55e" : "#6b7280"

                                                Behavior on x {
                                                    NumberAnimation { duration: 250; easing.type: Easing.OutBack; easing.overshoot: 1.2 }
                                                }
                                                Behavior on color { ColorAnimation { duration: 250 } }

                                                // Knob inner glow
                                                Rectangle {
                                                    anchors.centerIn: parent
                                                    width: 12; height: 12; radius: 6
                                                    color: "#ffffff"
                                                    opacity: 0.3
                                                }
                                            }

                                            MouseArea {
                                                anchors.fill: parent
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: {
                                                    var pin = pinCard.gpioPin;
                                                    var newVal = pinCard.pinValue === 1 ? 0 : 1;
                                                    gpioCtrl.setValue(pin, newVal);
                                                    var s = pinStates;
                                                    s[pin] = { exported: true, direction: "out", value: newVal };
                                                    pinStates = s;
                                                }
                                            }
                                        }
                                    }

                                    // ── Read button (re-reads current value) ──
                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 30
                                        radius: 15
                                        color: readMa.containsMouse ? "#3d1d60" : "#2a1245"
                                        border.color: "#6b3fa0"
                                        border.width: 1

                                        Behavior on color { ColorAnimation { duration: 200 } }

                                        Row {
                                            anchors.centerIn: parent
                                            spacing: 6
                                            Text { text: "↻"; color: "#c084fc"; font.pixelSize: 14; font.weight: Font.Bold }
                                            Text { text: "Read Value"; color: "#d8b4fe"; font.pixelSize: 11; font.weight: Font.Medium }
                                        }

                                        MouseArea {
                                            id: readMa
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                var pin = pinCard.gpioPin;
                                                var val = gpioCtrl.getValue(pin);
                                                var dir = gpioCtrl.getDirection(pin);
                                                var s = pinStates;
                                                s[pin] = { exported: true, direction: dir, value: val };
                                                pinStates = s;
                                            }
                                        }

                                        scale: readMa.pressed ? 0.97 : 1.0
                                        Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.OutCubic } }
                                    }
                                }
                            }
                        }

                        // Card entrance animation
                        transform: Translate {
                            y: 0
                        }

                        Component.onCompleted: {
                            cardEntrance.start();
                        }

                        NumberAnimation {
                            id: cardEntrance
                            target: pinCard
                            property: "opacity"
                            from: 0; to: 1
                            duration: 400
                            easing.type: Easing.OutCubic
                        }

                        opacity: 0
                    }
                }
            }
        }

        // ── FOOTER ──
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            Layout.topMargin: 10
            color: "#ffffff"
            opacity: 0.1
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 32
            spacing: 8

            Text {
                text: "⚡ sysfs base: 512"
                color: "#7c5aa0"
                font.pixelSize: 10
            }

            Item { Layout.fillWidth: true }

            Text {
                text: "RPi 3B+ · GPIO Controller v1.0"
                color: "#5c4880"
                font.pixelSize: 10
                font.italic: true
            }
        }
    }
}
