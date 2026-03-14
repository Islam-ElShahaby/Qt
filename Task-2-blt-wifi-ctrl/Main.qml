import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material

ApplicationWindow {
    id: window
    width: 480
    height: 720
    visible: true
    title: "Wireless Manager"
    color: "#0d1117"

    Material.theme: Material.Dark
    Material.accent: "#58a6ff"

    // State
    property var networkList: []
    property string connectedSsid: ""
    property var btDeviceList: []
    property bool btScanning: false

    // Auto-refresh timer (1 s)
    Timer {
        id: refreshTimer
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            networkList = wifiManager.getAvailableNetworks();
            connectedSsid = wifiManager.getConnectedNetwork();
            btDeviceList = btManager.getAvailableDevices();
        }
    }

    // Header
    header: ToolBar {
        id: appToolbar
        height: 56
        Material.background: "#161b22"

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 16
            anchors.rightMargin: 16

            Label {
                text: "Wireless Manager"
                font.pixelSize: 20
                font.bold: true
                color: "#e6edf3"
            }

            Item {
                Layout.fillWidth: true
            }

            // Refresh indicator
            Rectangle {
                width: 10
                height: 10
                radius: 5
                color: refreshTimer.running ? "#3fb950" : "#6e7681"

                SequentialAnimation on opacity {
                    running: refreshTimer.running
                    loops: Animation.Infinite
                    NumberAnimation {
                        to: 0.3
                        duration: 500
                    }
                    NumberAnimation {
                        to: 1.0
                        duration: 500
                    }
                }
            }
        }
    }

    // Tab Bar
    TabBar {
        id: tabBar
        width: parent.width
        y: 0
        Material.background: "#161b22"
        Material.accent: "#58a6ff"

        TabButton {
            text: "Wi-Fi"
            font.pixelSize: 14
            font.bold: tabBar.currentIndex === 0
        }
        TabButton {
            text: "Bluetooth"
            font.pixelSize: 14
            font.bold: tabBar.currentIndex === 1
        }
    }

    // Content
    SwipeView {
        id: swipeView
        anchors.top: tabBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 0
        currentIndex: tabBar.currentIndex
        clip: true

        onCurrentIndexChanged: tabBar.currentIndex = currentIndex

        //  Wi-Fi Page
        Item {
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 12

                // Control Row
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Button {
                        id: scanBtn
                        text: "Scan Now"
                        font.pixelSize: 13
                        Layout.fillWidth: true
                        Material.background: "#21262d"
                        Material.foreground: "#e6edf3"
                        Material.roundedScale: Material.SmallScale

                        onClicked: {
                            networkList = wifiManager.getAvailableNetworks();
                            connectedSsid = wifiManager.getConnectedNetwork();
                        }
                    }

                    Button {
                        text: "Disconnect"
                        font.pixelSize: 13
                        Layout.fillWidth: true
                        Material.background: "#21262d"
                        Material.foreground: "#f85149"
                        Material.roundedScale: Material.SmallScale

                        onClicked: {
                            wifiManager.disconnectWifi();
                            connectedSsid = "";
                        }
                    }
                }

                // Connected banner
                Rectangle {
                    Layout.fillWidth: true
                    height: connectedSsid !== "" ? 48 : 0
                    radius: 10
                    color: "#0d419d"
                    visible: connectedSsid !== ""
                    Behavior on height {
                        NumberAnimation {
                            duration: 200
                        }
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 14
                        anchors.rightMargin: 14

                        Label {
                            text: "Connected to"
                            color: "#8db9ff"
                            font.pixelSize: 13
                        }
                        Label {
                            text: connectedSsid
                            color: "#e6edf3"
                            font.pixelSize: 14
                            font.bold: true
                        }
                        Item {
                            Layout.fillWidth: true
                        }
                    }
                }

                // Section label
                Label {
                    text: "Available Networks (" + networkList.length + ")"
                    color: "#8b949e"
                    font.pixelSize: 13
                    font.bold: true
                    Layout.topMargin: 4
                }

                // WiFi List
                ListView {
                    id: wifiListView
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    spacing: 6
                    model: networkList

                    delegate: Rectangle {
                        id: wifiDelegate
                        required property string modelData
                        required property int index
                        width: wifiListView.width
                        height: 56
                        radius: 10
                        color: wifiDelegateArea.containsMouse ? "#30363d" : "#21262d"
                        border.color: modelData === connectedSsid ? "#3fb950" : "transparent"
                        border.width: modelData === connectedSsid ? 1.5 : 0

                        Behavior on color {
                            ColorAnimation {
                                duration: 150
                            }
                        }

                        MouseArea {
                            id: wifiDelegateArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (modelData !== connectedSsid) {
                                    passwordDialog.selectedSsid = modelData;
                                    passwordDialog.open();
                                }
                            }
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 14
                            anchors.rightMargin: 14
                            spacing: 12

                            // WiFi icon
                            Label {
                                text: "📶"
                                font.pixelSize: 20
                            }

                            // SSID
                            Label {
                                text: wifiDelegate.modelData
                                color: "#e6edf3"
                                font.pixelSize: 15
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                            }

                            // Connected badge OR Connect button
                            Rectangle {
                                visible: wifiDelegate.modelData === connectedSsid
                                width: connectedLabel.implicitWidth + 16
                                height: 26
                                radius: 13
                                color: "#238636"

                                Label {
                                    id: connectedLabel
                                    anchors.centerIn: parent
                                    text: "Connected"
                                    color: "#ffffff"
                                    font.pixelSize: 11
                                    font.bold: true
                                }
                            }

                            Button {
                                visible: wifiDelegate.modelData !== connectedSsid
                                text: "Connect"
                                font.pixelSize: 11
                                Material.background: "#1f6feb"
                                Material.foreground: "#ffffff"
                                Material.roundedScale: Material.SmallScale
                                implicitHeight: 30

                                onClicked: {
                                    passwordDialog.selectedSsid = wifiDelegate.modelData;
                                    passwordDialog.open();
                                }
                            }
                        }
                    }

                    // Empty state
                    Label {
                        anchors.centerIn: parent
                        text: "Scanning for networks..."
                        color: "#6e7681"
                        font.pixelSize: 14
                        visible: wifiListView.count === 0
                    }
                }
            }
        }

        //  Bluetooth Page
        Item {
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 12

                // Control Row
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Button {
                        text: btScanning ? "Stop Scan" : "Scan Devices"
                        font.pixelSize: 13
                        Layout.fillWidth: true
                        Material.background: "#21262d"
                        Material.foreground: "#e6edf3"
                        Material.roundedScale: Material.SmallScale

                        onClicked: {
                            if (btScanning) {
                                btManager.stopDiscovery();
                                btScanning = false;
                            } else {
                                btManager.startDiscovery();
                                btScanning = true;
                            }
                        }
                    }
                }

                // Section label
                Label {
                    text: "Nearby Devices (" + btDeviceList.length + ")"
                    color: "#8b949e"
                    font.pixelSize: 13
                    font.bold: true
                    Layout.topMargin: 4
                }

                // Bluetooth List
                ListView {
                    id: btListView
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    spacing: 6
                    model: btDeviceList

                    delegate: Rectangle {
                        id: btDelegate
                        required property var modelData
                        required property int index
                        width: btListView.width
                        height: 64
                        radius: 10
                        color: btDelegateArea.containsMouse ? "#30363d" : "#21262d"
                        border.color: modelData.connected ? "#58a6ff" : (modelData.paired ? "#8b949e" : "transparent")
                        border.width: (modelData.connected || modelData.paired) ? 1 : 0

                        Behavior on color {
                            ColorAnimation {
                                duration: 150
                            }
                        }

                        MouseArea {
                            id: btDelegateArea
                            anchors.fill: parent
                            hoverEnabled: true
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 14
                            anchors.rightMargin: 14
                            spacing: 12

                            // BT icon
                            Label {
                                text: btDelegate.modelData.connected ? "🔵" : "⚪"
                                font.pixelSize: 20
                            }

                            // Device info
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2

                                Label {
                                    text: btDelegate.modelData.name
                                    color: "#e6edf3"
                                    font.pixelSize: 14
                                    font.bold: true
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }
                                Label {
                                    text: btDelegate.modelData.address
                                    color: "#6e7681"
                                    font.pixelSize: 11
                                }
                            }

                            // Status badges / action buttons
                            Rectangle {
                                visible: btDelegate.modelData.connected
                                width: btConnLabel.implicitWidth + 16
                                height: 26
                                radius: 13
                                color: "#1f6feb"

                                Label {
                                    id: btConnLabel
                                    anchors.centerIn: parent
                                    text: "Connected"
                                    color: "#ffffff"
                                    font.pixelSize: 11
                                    font.bold: true
                                }
                            }

                            Button {
                                visible: btDelegate.modelData.paired && !btDelegate.modelData.connected
                                text: "Unpair"
                                font.pixelSize: 11
                                Material.background: "#da3633"
                                Material.foreground: "#ffffff"
                                Material.roundedScale: Material.SmallScale
                                implicitHeight: 30

                                onClicked: btManager.unpairDevice(btDelegate.modelData.address)
                            }

                            Button {
                                visible: !btDelegate.modelData.paired
                                text: "Pair"
                                font.pixelSize: 11
                                Material.background: "#1f6feb"
                                Material.foreground: "#ffffff"
                                Material.roundedScale: Material.SmallScale
                                implicitHeight: 30

                                onClicked: btManager.pairDevice(btDelegate.modelData.address)
                            }
                        }
                    }

                    // Empty state
                    Label {
                        anchors.centerIn: parent
                        text: btScanning ? "Discovering devices..." : "Tap 'Scan Devices' to start"
                        color: "#6e7681"
                        font.pixelSize: 14
                        visible: btListView.count === 0
                    }
                }
            }
        }
    }

    // Password Dialog
    Dialog {
        id: passwordDialog
        anchors.centerIn: parent
        modal: true
        width: Math.min(parent.width - 48, 360)
        title: "Connect to " + selectedSsid
        standardButtons: Dialog.Ok | Dialog.Cancel
        Material.background: "#21262d"
        Material.roundedScale: Material.MediumScale

        property string selectedSsid: ""

        ColumnLayout {
            width: parent.width
            spacing: 14

            Label {
                text: "Enter Wi-Fi Password"
                color: "#8b949e"
                font.pixelSize: 13
            }

            TextField {
                id: passwordField
                Layout.fillWidth: true
                echoMode: TextInput.Password
                placeholderText: "Password"
                Material.accent: "#58a6ff"
                font.pixelSize: 14
            }
        }

        onAccepted: {
            wifiManager.connectToWifi(selectedSsid, passwordField.text);
            passwordField.text = "";
        }

        onRejected: {
            passwordField.text = "";
        }
    }

    // Initial scan on startup
    Component.onCompleted: {
        networkList = wifiManager.getAvailableNetworks();
        connectedSsid = wifiManager.getConnectedNetwork();
    }
}
