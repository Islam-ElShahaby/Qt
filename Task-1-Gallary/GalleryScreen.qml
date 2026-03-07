pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

Item {
    id: galleryScreen

    // Track selected item
    property int selectedIndex: -1
    property var selectedItem: galleryScreen.selectedIndex >= 0 ? galleryModel.get(galleryScreen.selectedIndex) : ({})

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
                    color: '#a115ff'
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
    Component.onCompleted: galleryFadeIn.start()
    NumberAnimation {
        id: galleryFadeIn
        target: galleryScreen
        property: "opacity"
        from: 0
        to: 1
        duration: 500
        easing.type: Easing.OutCubic
    }

    // Gallery data model from C++
    GalleryModel {
        id: galleryModel
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 32
        spacing: 0

        // HEADER
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            spacing: 16

            // Back button
            Rectangle {
                width: 44
                height: 44
                radius: 22
                color: backBtnMa.containsMouse ? "#3d1d60" : "#2a1245"
                border.color: "#6b3fa0"
                border.width: 1
                Layout.alignment: Qt.AlignVCenter

                Behavior on color {
                    ColorAnimation {
                        duration: 200
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: "←"
                    color: "#d8b4fe"
                    font.pixelSize: 22
                    font.weight: Font.Bold
                }

                MouseArea {
                    id: backBtnMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        galleryScreen.selectedIndex = -1;
                        galleryScreen.StackView.view.pop();
                    }
                }

                scale: backBtnMa.pressed ? 0.92 : 1.0
                Behavior on scale {
                    NumberAnimation {
                        duration: 100
                        easing.type: Easing.OutCubic
                    }
                }
            }

            Rectangle {
                width: 4
                height: 28
                radius: 2
                color: "#9333ea"
                Layout.alignment: Qt.AlignVCenter
            }

            Text {
                text: "Gallery"
                color: "#ffffff"
                font.pixelSize: 26
                font.weight: Font.Bold
                font.family: "Segoe UI, Roboto, sans-serif"
                Layout.alignment: Qt.AlignVCenter
            }

            Item {
                Layout.fillWidth: true
            }
        }

        // Separator
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            Layout.topMargin: 8
            Layout.bottomMargin: 16
            color: "#ffffff"
            opacity: 0.1
        }

        // MAIN CONTENT AREA
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            // GRID VIEW (visible when nothing selected)
            Rectangle {
                id: gridContainer
                anchors.fill: parent
                radius: 16
                color: "#2a1245"
                border.color: "#6b3fa0"
                border.width: 1
                opacity: galleryScreen.selectedIndex === -1 ? 1 : 0
                visible: opacity > 0
                Behavior on opacity {
                    NumberAnimation {
                        duration: 300
                        easing.type: Easing.OutCubic
                    }
                }

                // Empty state
                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 16
                    visible: galleryGrid.count === 0

                    Text {
                        text: "🐱"
                        font.pixelSize: 48
                        Layout.alignment: Qt.AlignHCenter
                    }
                    Text {
                        text: "No pets found"
                        color: "#c084fc"
                        font.pixelSize: 18
                        font.weight: Font.Medium
                        Layout.alignment: Qt.AlignHCenter
                    }
                    Text {
                        text: "Add images and entries to gallery/gallery.json"
                        color: "#a78bfa"
                        font.pixelSize: 13
                        Layout.alignment: Qt.AlignHCenter
                    }
                }

                // Image grid — max 4 per row, scrollable
                GridView {
                    id: galleryGrid
                    anchors.fill: parent
                    anchors.margins: 16
                    clip: true

                    // Max 4 per row, auto-fit to width
                    property int columns: Math.min(4, Math.max(1, Math.floor(width / 160)))
                    cellWidth: width / columns
                    cellHeight: cellWidth  // 1:1 ratio

                    model: galleryModel

                    delegate: Item {
                        id: delegateItem
                        required property int index
                        required property string image
                        required property string name

                        width: GridView.view.cellWidth
                        height: GridView.view.cellHeight

                        Rectangle {
                            id: imageCard
                            anchors.fill: parent
                            anchors.margins: 6
                            radius: 12
                            color: "#3d1d60"
                            clip: true

                            Image {
                                anchors.fill: parent
                                source: delegateItem.image
                                fillMode: Image.PreserveAspectCrop
                                asynchronous: true
                            }

                            // Hover overlay
                            Rectangle {
                                anchors.fill: parent
                                radius: 12
                                color: "#9333ea"
                                opacity: imgMa.containsMouse ? 0.2 : 0
                                Behavior on opacity {
                                    NumberAnimation {
                                        duration: 200
                                    }
                                }
                            }

                            // Hover name tooltip
                            Rectangle {
                                anchors.bottom: parent.bottom
                                anchors.left: parent.left
                                anchors.right: parent.right
                                height: 36
                                radius: 12
                                color: "#000000"
                                opacity: imgMa.containsMouse ? 0.7 : 0
                                Behavior on opacity {
                                    NumberAnimation {
                                        duration: 200
                                    }
                                }

                                Rectangle {
                                    anchors.top: parent.top
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    height: 12
                                    color: "#000000"
                                    opacity: parent.opacity > 0 ? 1 : 0
                                }
                            }

                            Text {
                                anchors.bottom: parent.bottom
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.bottomMargin: 10
                                text: delegateItem.name
                                color: "#f3e8ff"
                                font.pixelSize: 13
                                font.weight: Font.Bold
                                opacity: imgMa.containsMouse ? 1 : 0
                                Behavior on opacity {
                                    NumberAnimation {
                                        duration: 200
                                    }
                                }
                            }

                            MouseArea {
                                id: imgMa
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    galleryScreen.selectedIndex = delegateItem.index;
                                }
                            }

                            scale: imgMa.containsMouse ? 1.04 : 1.0
                            Behavior on scale {
                                NumberAnimation {
                                    duration: 150
                                    easing.type: Easing.OutCubic
                                }
                            }
                        }
                    }

                    ScrollBar.vertical: ScrollBar {
                        policy: ScrollBar.AsNeeded
                        contentItem: Rectangle {
                            implicitWidth: 5
                            radius: 3
                            color: "#9333ea"
                            opacity: 0.5
                        }
                    }
                }
            }

            // EXPANDED VIEW (when an image is selected)
            Item {
                id: expandedView
                anchors.fill: parent
                opacity: galleryScreen.selectedIndex !== -1 ? 1 : 0
                visible: opacity > 0
                Behavior on opacity {
                    NumberAnimation {
                        duration: 400
                        easing.type: Easing.OutCubic
                    }
                }

                RowLayout {
                    anchors.fill: parent
                    spacing: 0

                    // LEFT: Expanded image (slides in from left)
                    Item {
                        Layout.preferredWidth: parent.width * 0.45
                        Layout.fillHeight: true

                        Rectangle {
                            id: imagePanel
                            width: parent.width
                            height: width  // 1:1 ratio
                            anchors.verticalCenter: parent.verticalCenter
                            radius: 20
                            color: "#2a1245"
                            border.color: "#6b3fa0"
                            border.width: 1
                            clip: true

                            // Slide-in from left
                            transform: Translate {
                                x: galleryScreen.selectedIndex !== -1 ? 0 : -imagePanel.width * 0.5
                                Behavior on x {
                                    NumberAnimation {
                                        duration: 500
                                        easing.type: Easing.OutCubic
                                    }
                                }
                            }

                            // Rounded image using inner Rectangle with clip
                            Rectangle {
                                anchors.fill: parent
                                anchors.margins: 4
                                radius: 18
                                color: "#3d1d60"

                                Image {
                                    id: expandedImage
                                    anchors.fill: parent
                                    source: galleryScreen.selectedItem.image || ""
                                    fillMode: Image.PreserveAspectCrop
                                    asynchronous: true

                                    layer.enabled: true
                                    layer.effect: OpacityMask {
                                        maskSource: Rectangle {
                                            width: expandedImage.width
                                            height: expandedImage.height
                                            radius: 18
                                        }
                                    }
                                }
                            }

                            // Close button
                            Rectangle {
                                width: 36
                                height: 36
                                radius: 18
                                color: closeMa.containsMouse ? "#9333ea" : "#2a1245"
                                border.color: "#6b3fa0"
                                border.width: 1
                                anchors.top: parent.top
                                anchors.left: parent.left
                                anchors.margins: 12
                                z: 10

                                Behavior on color {
                                    ColorAnimation {
                                        duration: 200
                                    }
                                }

                                Text {
                                    anchors.centerIn: parent
                                    text: "✕"
                                    color: "#d8b4fe"
                                    font.pixelSize: 16
                                    font.weight: Font.Bold
                                }

                                MouseArea {
                                    id: closeMa
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        galleryScreen.selectedIndex = -1;
                                    }
                                }
                            }
                        }
                    }

                    // RIGHT: Info panel (slides up from below)
                    Rectangle {
                        id: infoPanel
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.leftMargin: 16
                        radius: 16
                        color: "#2a1245"
                        border.color: "#6b3fa0"
                        border.width: 1

                        // Slide-up from below
                        transform: Translate {
                            y: galleryScreen.selectedIndex !== -1 ? 0 : infoPanel.height * 0.3
                            Behavior on y {
                                NumberAnimation {
                                    duration: 600
                                    easing.type: Easing.OutCubic
                                }
                            }
                        }

                        Flickable {
                            anchors.fill: parent
                            anchors.margins: 24
                            contentHeight: infoColumn.height
                            clip: true
                            boundsBehavior: Flickable.StopAtBounds

                            ScrollBar.vertical: ScrollBar {
                                policy: ScrollBar.AsNeeded
                                contentItem: Rectangle {
                                    implicitWidth: 4
                                    radius: 2
                                    color: "#9333ea"
                                    opacity: 0.5
                                }
                            }

                            ColumnLayout {
                                id: infoColumn
                                width: parent.width
                                spacing: 16

                                // Pet name header
                                Text {
                                    text: galleryScreen.selectedItem.name || ""
                                    color: "#ffffff"
                                    font.pixelSize: 32
                                    font.weight: Font.Bold
                                    font.family: "Segoe UI, Roboto, sans-serif"
                                }

                                Rectangle {
                                    Layout.preferredWidth: 50
                                    Layout.preferredHeight: 3
                                    radius: 2
                                    color: "#9333ea"
                                }

                                // Info grid
                                GridLayout {
                                    Layout.fillWidth: true
                                    columns: 2
                                    columnSpacing: 12
                                    rowSpacing: 14

                                    Text {
                                        text: "Age"
                                        color: "#a78bfa"
                                        font.pixelSize: 12
                                        font.weight: Font.Bold
                                    }
                                    Text {
                                        text: galleryScreen.selectedItem.age || ""
                                        color: "#ffffff"
                                        font.pixelSize: 14
                                    }

                                    Text {
                                        text: "Sex"
                                        color: "#a78bfa"
                                        font.pixelSize: 12
                                        font.weight: Font.Bold
                                    }
                                    Text {
                                        text: galleryScreen.selectedItem.sex || ""
                                        color: "#ffffff"
                                        font.pixelSize: 14
                                    }

                                    Text {
                                        text: "Size"
                                        color: "#a78bfa"
                                        font.pixelSize: 12
                                        font.weight: Font.Bold
                                    }
                                    Text {
                                        text: galleryScreen.selectedItem.petSize || ""
                                        color: "#ffffff"
                                        font.pixelSize: 14
                                    }

                                    Text {
                                        text: "Vaccinations"
                                        color: "#a78bfa"
                                        font.pixelSize: 12
                                        font.weight: Font.Bold
                                    }
                                    Text {
                                        text: galleryScreen.selectedItem.vaccinations || ""
                                        color: "#ffffff"
                                        font.pixelSize: 14
                                    }

                                    Text {
                                        text: "Potty Training"
                                        color: "#a78bfa"
                                        font.pixelSize: 12
                                        font.weight: Font.Bold
                                    }
                                    Text {
                                        text: galleryScreen.selectedItem.pottyTraining || ""
                                        color: "#ffffff"
                                        font.pixelSize: 14
                                    }

                                    Text {
                                        text: "Spayed/Neutered"
                                        color: "#a78bfa"
                                        font.pixelSize: 12
                                        font.weight: Font.Bold
                                    }
                                    Text {
                                        text: galleryScreen.selectedItem.spayedNeutered ? "Yes ✓" : "No ✗"
                                        color: galleryScreen.selectedItem.spayedNeutered ? "#4ade80" : "#f87171"
                                        font.pixelSize: 14
                                        font.weight: Font.Bold
                                    }
                                }

                                // Separator
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 1
                                    color: "#6b3fa0"
                                    opacity: 0.5
                                }

                                // Compatibility section
                                Text {
                                    text: "Compatibility"
                                    color: "#c084fc"
                                    font.pixelSize: 16
                                    font.weight: Font.Bold
                                }

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 12

                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 70
                                        radius: 12
                                        color: "#3d1d60"

                                        ColumnLayout {
                                            anchors.centerIn: parent
                                            spacing: 4
                                            Text {
                                                text: "Dogs"
                                                font.pixelSize: 20
                                                Layout.alignment: Qt.AlignHCenter
                                            }
                                            Text {
                                                text: galleryScreen.selectedItem.compatDogs || ""
                                                color: "#d8b4fe"
                                                font.pixelSize: 11
                                                Layout.alignment: Qt.AlignHCenter
                                            }
                                        }
                                    }

                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 70
                                        radius: 12
                                        color: "#3d1d60"

                                        ColumnLayout {
                                            anchors.centerIn: parent
                                            spacing: 4
                                            Text {
                                                text: "Cats"
                                                font.pixelSize: 20
                                                Layout.alignment: Qt.AlignHCenter
                                            }
                                            Text {
                                                text: galleryScreen.selectedItem.compatCats || ""
                                                color: "#d8b4fe"
                                                font.pixelSize: 11
                                                Layout.alignment: Qt.AlignHCenter
                                            }
                                        }
                                    }

                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 70
                                        radius: 12
                                        color: "#3d1d60"

                                        ColumnLayout {
                                            anchors.centerIn: parent
                                            spacing: 4
                                            Text {
                                                text: "Kids"
                                                font.pixelSize: 20
                                                Layout.alignment: Qt.AlignHCenter
                                            }
                                            Text {
                                                text: galleryScreen.selectedItem.compatKids || ""
                                                color: "#d8b4fe"
                                                font.pixelSize: 11
                                                Layout.alignment: Qt.AlignHCenter
                                            }
                                        }
                                    }
                                }

                                // Separator
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 1
                                    color: "#6b3fa0"
                                    opacity: 0.5
                                }

                                // Activity Level
                                Text {
                                    text: "Activity Level"
                                    color: "#c084fc"
                                    font.pixelSize: 16
                                    font.weight: Font.Bold
                                }

                                Text {
                                    text: galleryScreen.selectedItem.activityLevel || ""
                                    color: "#d8b4fe"
                                    font.pixelSize: 13
                                    wrapMode: Text.WordWrap
                                    Layout.fillWidth: true
                                }

                                Item {
                                    Layout.preferredHeight: 8
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
