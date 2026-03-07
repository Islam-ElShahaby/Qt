import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Item {
    id: homeScreen

    // Gradient Background
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop {
                position: 0.0
                color: '#360d5b'
            }
            GradientStop {
                position: 0.5
                color: '#7748a0'
            }
            GradientStop {
                position: 1.0
                color: '#432e54'
            }
        }
    }

    // Subtle animated glow
    Rectangle {
        id: glowOrb
        width: 400
        height: 400
        radius: 200
        color: "transparent"
        anchors.centerIn: parent

        Rectangle {
            anchors.fill: parent
            radius: 200
            opacity: 0.08
            gradient: Gradient {
                GradientStop {
                    position: 0.0
                    color: '#ff1596'
                }
                GradientStop {
                    position: 1.0
                    color: "transparent"
                }
            }
        }

        SequentialAnimation on anchors.verticalCenterOffset {
            loops: Animation.Infinite
            NumberAnimation {
                to: -120
                duration: 3000
                easing.type: Easing.InOutSine
            }
            NumberAnimation {
                to: -80
                duration: 3000
                easing.type: Easing.InOutSine
            }
        }
    }

    // Fade-in animation
    opacity: 0
    Component.onCompleted: fadeIn.start()
    NumberAnimation {
        id: fadeIn
        target: homeScreen
        property: "opacity"
        from: 0
        to: 1
        duration: 800
        easing.type: Easing.OutCubic
    }

    // Timer for clock
    Timer {
        id: clockTimer
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            var now = new Date();
            timeLabel.text = Qt.formatTime(now, "hh:mm:ss AP");
            dateLabel.text = Qt.formatDate(now, "dddd, MMMM d, yyyy");
        }
    }

    // TempReader from C++
    TempReader {
        id: tempReader
    }

    // SCROLLABLE CONTENT
    Flickable {
        anchors.fill: parent
        anchors.margins: 32
        contentHeight: mainColumn.height
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

        ColumnLayout {
            id: mainColumn
            width: parent.width
            spacing: 24

            // HEADER BAR
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 50

                // Date (left-aligned)
                Text {
                    id: dateLabel
                    text: "--"
                    color: "#d8b4fe"
                    font.pixelSize: 14
                    font.weight: Font.Medium
                    font.family: "Segoe UI, Roboto, sans-serif"
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                }

                // App Name (absolutely centered)
                Text {
                    anchors.centerIn: parent
                    text: "✦   L U M I N A   ✦"
                    color: "#ffffff"
                    font.pixelSize: 20
                    font.weight: Font.Bold
                    font.family: "Segoe UI, Roboto, sans-serif"
                }

                // Clock (right-aligned)
                Text {
                    id: timeLabel
                    text: "--:--:--"
                    color: "#d8b4fe"
                    font.pixelSize: 14
                    font.weight: Font.Medium
                    font.family: "Segoe UI, Roboto, sans-serif"
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            // Separator
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: "#ffffff"
                opacity: 0.1
            }

            // HERO SECTION
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 160
                radius: 20
                color: "#2a1245"
                border.color: "#6b3fa0"
                border.width: 1

                // Inner glow
                Rectangle {
                    anchors.fill: parent
                    radius: 20
                    opacity: 0.05
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop {
                            position: 0.0
                            color: "#9333ea"
                        }
                        GradientStop {
                            position: 0.5
                            color: "transparent"
                        }
                        GradientStop {
                            position: 1.0
                            color: "#c084fc"
                        }
                    }
                }

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 12

                    Text {
                        text: "Lumina"
                        color: "#ffffff"
                        font.pixelSize: 42
                        font.weight: Font.Bold
                        font.family: "Segoe UI, Roboto, sans-serif"
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Text {
                        text: "Your personal dashboard — monitor, explore, and discover."
                        color: "#d8b4fe"
                        font.pixelSize: 14
                        font.weight: Font.Normal
                        font.family: "Segoe UI, Roboto, sans-serif"
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Rectangle {
                        Layout.preferredWidth: 60
                        Layout.preferredHeight: 3
                        radius: 2
                        color: "#9333ea"
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Text {
                        text: "A sleek Qt-powered app for live system stats, image gallery browsing,\nand a beautifully crafted dashboard experience."
                        color: "#a78bfa"
                        font.pixelSize: 12
                        font.family: "Segoe UI, Roboto, sans-serif"
                        horizontalAlignment: Text.AlignHCenter
                        lineHeight: 1.4
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
            }

            // info cards row
            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 130
                spacing: 16

                // CPU Temperature Card
                Rectangle {
                    Layout.preferredWidth: 260
                    Layout.fillHeight: true
                    radius: 16
                    color: "#2a1245"
                    border.color: "#6b3fa0"
                    border.width: 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 16

                        Rectangle {
                            width: 52
                            height: 52
                            radius: 26
                            color: "#3d1d60"

                            Text {
                                anchors.centerIn: parent
                                text: "🌡"
                                font.pixelSize: 24
                            }
                        }

                        ColumnLayout {
                            spacing: 6
                            Text {
                                text: "CPU TEMP"
                                color: "#c084fc"
                                font.pixelSize: 11
                                font.weight: Font.Bold
                                font.letterSpacing: 2
                            }
                            Text {
                                text: tempReader.temperature
                                color: "#ffffff"
                                font.pixelSize: 28
                                font.weight: Font.Bold
                            }
                            Text {
                                text: "Live reading"
                                color: "#a78bfa"
                                font.pixelSize: 10
                            }
                        }
                    }

                    // Hover glow
                    Rectangle {
                        anchors.fill: parent
                        radius: 16
                        color: "#9333ea"
                        opacity: tempCardMa.containsMouse ? 0.08 : 0
                        Behavior on opacity {
                            NumberAnimation {
                                duration: 200
                            }
                        }
                    }

                    MouseArea {
                        id: tempCardMa
                        anchors.fill: parent
                        hoverEnabled: true
                    }
                }

                // Gallery Card
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: 16
                    color: "#2a1245"
                    border.color: "#6b3fa0"
                    border.width: 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 20
                        ColumnLayout {
                            spacing: 4
                            Layout.fillWidth: true

                            Text {
                                text: "GALLERY"
                                color: "#c084fc"
                                font.pixelSize: 11
                                font.weight: Font.Bold
                                font.letterSpacing: 2
                            }
                            Text {
                                text: "Browse your image collection"
                                color: "#ffffff"
                                font.pixelSize: 16
                                font.weight: Font.Medium
                            }
                            Text {
                                text: "Tap to explore →"
                                color: "#a78bfa"
                                font.pixelSize: 11
                            }
                        }

                        Text {
                            text: "→"
                            color: "#c084fc"
                            font.pixelSize: 28
                            font.weight: Font.Bold
                            Layout.alignment: Qt.AlignVCenter
                        }
                    }

                    // Hover glow
                    Rectangle {
                        anchors.fill: parent
                        radius: 16
                        color: "#9333ea"
                        opacity: galleryCardMa.containsMouse ? 0.12 : 0
                        Behavior on opacity {
                            NumberAnimation {
                                duration: 200
                            }
                        }
                    }

                    MouseArea {
                        id: galleryCardMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            homeScreen.StackView.view.push("GalleryScreen.qml");
                        }
                    }

                    scale: galleryCardMa.containsMouse ? 1.01 : 1.0
                    Behavior on scale {
                        NumberAnimation {
                            duration: 150
                            easing.type: Easing.OutCubic
                        }
                    }
                }
            }

            // about section
            Text {
                text: "About"
                color: "#d8b4fe"
                font.pixelSize: 18
                font.weight: Font.Bold
                font.family: "Segoe UI, Roboto, sans-serif"
                Layout.topMargin: 8
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 16

                // App Info Card
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 220
                    radius: 16
                    color: "#2a1245"
                    border.color: "#6b3fa0"
                    border.width: 1

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 24
                        spacing: 12

                        Row {
                            spacing: 10
                            Text {
                                text: "App Info"
                                color: "#ffffff"
                                font.pixelSize: 16
                                font.weight: Font.Bold
                                font.family: "Segoe UI, Roboto, sans-serif"
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 1
                            color: "#6b3fa0"
                            opacity: 0.5
                        }

                        ColumnLayout {
                            spacing: 8
                            Layout.fillWidth: true

                            Row {
                                spacing: 8
                                Text {
                                    text: "Name:"
                                    color: "#a78bfa"
                                    font.pixelSize: 12
                                    font.weight: Font.Bold
                                }
                                Text {
                                    text: "Lumina"
                                    color: "#ffffff"
                                    font.pixelSize: 12
                                }
                            }
                            Row {
                                spacing: 8
                                Text {
                                    text: "Version:"
                                    color: "#a78bfa"
                                    font.pixelSize: 12
                                    font.weight: Font.Bold
                                }
                                Text {
                                    text: "1.0.0"
                                    color: "#ffffff"
                                    font.pixelSize: 12
                                }
                            }
                            Row {
                                spacing: 8
                                Text {
                                    text: "Framework:"
                                    color: "#a78bfa"
                                    font.pixelSize: 12
                                    font.weight: Font.Bold
                                }
                                Text {
                                    text: "Qt 6 / QML"
                                    color: "#ffffff"
                                    font.pixelSize: 12
                                }
                            }
                            Row {
                                spacing: 8
                                Text {
                                    text: "Platform:"
                                    color: "#a78bfa"
                                    font.pixelSize: 12
                                    font.weight: Font.Bold
                                }
                                Text {
                                    text: "Linux / Embedded"
                                    color: "#ffffff"
                                    font.pixelSize: 12
                                }
                            }
                            Row {
                                spacing: 8
                                Text {
                                    text: "License:"
                                    color: "#a78bfa"
                                    font.pixelSize: 12
                                    font.weight: Font.Bold
                                }
                                Text {
                                    text: "MIT"
                                    color: "#ffffff"
                                    font.pixelSize: 12
                                }
                            }
                        }
                    }

                    // Hover glow
                    Rectangle {
                        anchors.fill: parent
                        radius: 16
                        color: "#9333ea"
                        opacity: appInfoMa.containsMouse ? 0.06 : 0
                        Behavior on opacity {
                            NumberAnimation {
                                duration: 200
                            }
                        }
                    }
                    MouseArea {
                        id: appInfoMa
                        anchors.fill: parent
                        hoverEnabled: true
                    }
                }

                // Author Card
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 220
                    radius: 16
                    color: "#2a1245"
                    border.color: "#6b3fa0"
                    border.width: 1

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 24
                        spacing: 12

                        Row {
                            spacing: 10
                            Text {
                                text: "Author"
                                color: "#ffffff"
                                font.pixelSize: 16
                                font.weight: Font.Bold
                                font.family: "Segoe UI, Roboto, sans-serif"
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 1
                            color: "#6b3fa0"
                            opacity: 0.5
                        }

                        ColumnLayout {
                            spacing: 8
                            Layout.fillWidth: true

                            Row {
                                spacing: 8
                                Text {
                                    text: "Name:"
                                    color: "#a78bfa"
                                    font.pixelSize: 12
                                    font.weight: Font.Bold
                                }
                                Text {
                                    text: "Islam ElShahaby"
                                    color: "#ffffff"
                                    font.pixelSize: 12
                                }
                            }
                            Row {
                                spacing: 8
                                Text {
                                    text: "GitHub:"
                                    color: "#a78bfa"
                                    font.pixelSize: 12
                                    font.weight: Font.Bold
                                }
                                Text {
                                    text: "Islam-ElShahaby"
                                    color: "#c084fc"
                                    font.pixelSize: 12
                                }
                            }
                            Row {
                                spacing: 8
                                Text {
                                    text: "Program:"
                                    color: "#a78bfa"
                                    font.pixelSize: 12
                                    font.weight: Font.Bold
                                }
                                Text {
                                    text: "ITI Embedded Systems"
                                    color: "#ffffff"
                                    font.pixelSize: 12
                                }
                            }
                            Row {
                                spacing: 8
                                Text {
                                    text: "Year:"
                                    color: "#a78bfa"
                                    font.pixelSize: 12
                                    font.weight: Font.Bold
                                }
                                Text {
                                    text: "2026"
                                    color: "#ffffff"
                                    font.pixelSize: 12
                                }
                            }
                        }

                        Item {
                            Layout.fillHeight: true
                        }

                        Text {
                            text: "Built with ♥ using Qt & C++"
                            color: "#c084fc"
                            font.pixelSize: 10
                            font.italic: true
                            Layout.alignment: Qt.AlignRight
                        }
                    }

                    // Hover glow
                    Rectangle {
                        anchors.fill: parent
                        radius: 16
                        color: "#9333ea"
                        opacity: authorMa.containsMouse ? 0.06 : 0
                        Behavior on opacity {
                            NumberAnimation {
                                duration: 200
                            }
                        }
                    }
                    MouseArea {
                        id: authorMa
                        anchors.fill: parent
                        hoverEnabled: true
                    }
                }
            }

            // Bottom padding
            Item {
                Layout.preferredHeight: 16
            }
        }
    }
}
