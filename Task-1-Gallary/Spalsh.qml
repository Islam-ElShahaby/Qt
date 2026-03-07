import QtQuick
import QtQuick.Controls
import QtMultimedia

Window {
    id: rootWindow
    visible: true
    title: "My Awesome App"
    visibility: Window.FullScreen
    color: "black"

    Shortcut {
        sequence: "Esc"
        onActivated: Qt.quit()
    }

    StackView {
        id: stackView
        anchors.fill: parent
        z: 0
        initialItem: HomeScreen {}

        pushEnter: Transition {
            PropertyAnimation {
                property: "x"
                from: stackView.width
                to: 0
                duration: 400
                easing.type: Easing.OutCubic
            }
        }
        pushExit: Transition {
            PropertyAnimation {
                property: "x"
                from: 0
                to: -stackView.width
                duration: 400
                easing.type: Easing.OutCubic
            }
        }
        popEnter: Transition {
            PropertyAnimation {
                property: "x"
                from: -stackView.width
                to: 0
                duration: 400
                easing.type: Easing.OutCubic
            }
        }
        popExit: Transition {
            PropertyAnimation {
                property: "x"
                from: 0
                to: stackView.width
                duration: 400
                easing.type: Easing.OutCubic
            }
        }
    }

    Rectangle {
        id: splashScreen_p2
        anchors.fill: parent
        color: "black"
        z: 1
        opacity: 1

        Behavior on opacity {
            NumberAnimation {
                duration: 1000
                easing.type: Easing.InOutQuad
            }
        }

        MediaPlayer {
            id: player_p2
            source: "media/splash2.mp4"
            videoOutput: videoOutput_p2

            Component.onCompleted: {
                play();
                pause();
            }

            onPlaybackStateChanged: {
                if (playbackState === MediaPlayer.StoppedState) {
                    splashScreen_p2.opacity = 0;
                }
            }
        }

        VideoOutput {
            id: videoOutput_p2
            anchors.fill: parent
            fillMode: VideoOutput.PreserveAspectFit
        }
    }

    Rectangle {
        id: splashScreen
        anchors.fill: parent
        color: "black"
        z: 2
        visible: true

        MediaPlayer {
            id: player
            source: "media/splash.mkv"
            videoOutput: videoOutput
            loops: 2

            onPlaybackStateChanged: {
                if (playbackState === MediaPlayer.StoppedState) {
                    splashScreen.visible = false;
                    player_p2.play();
                }
            }
        }

        VideoOutput {
            id: videoOutput
            anchors.fill: parent
            fillMode: VideoOutput.PreserveAspectFit
        }

        Component.onCompleted: player.play()
    }
}
