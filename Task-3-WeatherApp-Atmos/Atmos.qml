import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import Main

Window {
    id: root
    width: 420
    height: 820
    visible: true
    title: qsTr("Atmos")
    color: "transparent"

    // ── Backend ──────────────────────────────────────────────────────────
    WeatherBackend { id: backend }

    // ── Helpers ──────────────────────────────────────────────────────────
    readonly property bool isDay: backend.currentWeather.isDay !== undefined
                                  ? backend.currentWeather.isDay : true

    function fmtTime(iso) {
        if (!iso) return "--:--"
        var d = new Date(iso)
        var h = d.getHours()
        var m = d.getMinutes()
        var ampm = h >= 12 ? "PM" : "AM"
        var h12 = h % 12
        if (h12 === 0) h12 = 12
        return h12 + ":" + (m < 10 ? "0" : "") + m + " " + ampm
    }
    function fmtHour(iso) {
        if (!iso) return "--"
        var d = new Date(iso)
        var h = d.getHours()
        if (h === 0) return "12 AM"
        if (h < 12) return h + " AM"
        if (h === 12) return "12 PM"
        return (h - 12) + " PM"
    }
    function fmtDay(dateStr) {
        if (!dateStr) return ""
        var d = new Date(dateStr + "T00:00:00")
        var days = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]
        var months = ["Jan","Feb","Mar","Apr","May","Jun",
                      "Jul","Aug","Sep","Oct","Nov","Dec"]
        return days[d.getDay()] + ", " + months[d.getMonth()] + " " + d.getDate()
    }
    function weatherIcon(code, day) {
        // WMO weather codes → emoji
        if (code === undefined || code === null) return day ? "☀️" : "🌙"
        if (code <= 1)  return day ? "☀️" : "🌙"
        if (code <= 3)  return day ? "⛅" : "☁️"
        if (code <= 48) return "🌫️"
        if (code <= 55) return "🌦️"
        if (code <= 57) return "🌧️"
        if (code <= 65) return "🌧️"
        if (code <= 67) return "🌧️"
        if (code <= 77) return "❄️"
        if (code <= 82) return "🌧️"
        if (code <= 86) return "❄️"
        if (code <= 99) return "⛈️"
        return day ? "☀️" : "🌙"
    }
    function weatherDesc(code) {
        if (code === undefined || code === null) return "Clear"
        if (code === 0)  return "Clear Sky"
        if (code === 1)  return "Mainly Clear"
        if (code === 2)  return "Partly Cloudy"
        if (code === 3)  return "Overcast"
        if (code <= 48)  return "Fog"
        if (code <= 55)  return "Drizzle"
        if (code <= 57)  return "Freezing Drizzle"
        if (code <= 65)  return "Rain"
        if (code <= 67)  return "Freezing Rain"
        if (code <= 77)  return "Snow"
        if (code <= 82)  return "Rain Showers"
        if (code <= 86)  return "Snow Showers"
        if (code <= 99)  return "Thunderstorm"
        return "Unknown"
    }
    function sunshineFmt(secs) {
        if (secs === undefined || secs === null) return "—"
        var h = Math.floor(secs / 3600)
        var m = Math.round((secs % 3600) / 60)
        return h + "h " + m + "m"
    }
    function visFmt(meters) {
        if (meters === undefined || meters === null) return "—"
        if (meters >= 1000) return (meters / 1000).toFixed(1) + " km"
        return Math.round(meters) + " m"
    }

    // ── Background gradient ─────────────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: root.isDay ? "#1a73e8" : "#0d1b2a" }
            GradientStop { position: 0.5; color: root.isDay ? "#4fc3f7" : "#1b2838" }
            GradientStop { position: 1.0; color: root.isDay ? "#b3e5fc" : "#253344" }
        }
        Behavior on gradient { ColorAnimation { duration: 800 } }
    }

    // ── Main scrollable content ─────────────────────────────────────────
    Flickable {
        id: mainFlick
        anchors.fill: parent
        contentHeight: mainCol.height + 40
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        ColumnLayout {
            id: mainCol
            width: parent.width - 32
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 16
            spacing: 16

            // ── Search bar ──────────────────────────────────────────────
            Rectangle {
                Layout.fillWidth: true
                height: 48
                radius: 24
                color: Qt.rgba(1, 1, 1, 0.15)
                border.color: Qt.rgba(1, 1, 1, 0.25)
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    anchors.rightMargin: 16
                    spacing: 8

                    Text {
                        text: "🔍"
                        font.pixelSize: 18
                        verticalAlignment: Text.AlignVCenter
                    }

                    TextField {
                        id: searchField
                        Layout.fillWidth: true
                        placeholderText: "Search city…"
                        placeholderTextColor: Qt.rgba(1,1,1,0.5)
                        color: "white"
                        font.pixelSize: 15
                        background: Item {}
                        onTextChanged: {
                            searchTimer.restart()
                        }
                        onAccepted: {
                            searchTimer.stop()
                            backend.searchCity(text)
                        }
                    }
                }

                Timer {
                    id: searchTimer
                    interval: 500
                    onTriggered: backend.searchCity(searchField.text)
                }
            }

            // Search results dropdown
            Rectangle {
                id: searchPopup
                Layout.fillWidth: true
                visible: backend.searchResults.length > 0 && searchField.activeFocus
                height: visible ? Math.min(backend.searchResults.length * 48, 288) : 0
                radius: 16
                color: Qt.rgba(0, 0, 0, 0.75)
                border.color: Qt.rgba(1,1,1,0.15)
                clip: true

                Behavior on height { NumberAnimation { duration: 200; easing.type: Easing.OutQuad } }

                ListView {
                    anchors.fill: parent
                    anchors.margins: 4
                    model: backend.searchResults
                    delegate: ItemDelegate {
                        width: parent ? parent.width : 0
                        height: 46
                        contentItem: Column {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: 12
                            Text {
                                text: modelData.name || ""
                                color: "white"
                                font.pixelSize: 15
                                font.weight: Font.Medium
                            }
                            Text {
                                text: (modelData.admin1 || "") +
                                      (modelData.admin1 && modelData.country ? ", " : "") +
                                      (modelData.country || "")
                                color: Qt.rgba(1,1,1,0.55)
                                font.pixelSize: 12
                            }
                        }
                        background: Rectangle {
                            color: parent.hovered ? Qt.rgba(1,1,1,0.1) : "transparent"
                            radius: 12
                        }
                        onClicked: {
                            searchField.text = modelData.name
                            searchField.focus = false
                            backend.searchResults = []
                            backend.fetchWeather(modelData.latitude, modelData.longitude)
                        }
                    }
                }
            }

            // ── Loading indicator ───────────────────────────────────────
            BusyIndicator {
                Layout.alignment: Qt.AlignHCenter
                running: backend.loading
                visible: backend.loading
                palette.dark: "white"
            }

            // ── Error banner ────────────────────────────────────────────
            Rectangle {
                Layout.fillWidth: true
                height: 44
                radius: 12
                color: "#cc3333"
                visible: backend.errorString.length > 0
                Text {
                    anchors.centerIn: parent
                    text: backend.errorString
                    color: "white"
                    font.pixelSize: 13
                }
            }

            // ── Hero card ───────────────────────────────────────────────
            Rectangle {
                Layout.fillWidth: true
                height: heroCol.height + 40
                radius: 24
                color: Qt.rgba(1, 1, 1, 0.12)
                border.color: Qt.rgba(1, 1, 1, 0.18)
                border.width: 1

                ColumnLayout {
                    id: heroCol
                    anchors {
                        left: parent.left; right: parent.right
                        top: parent.top
                        margins: 20
                    }
                    spacing: 4

                    Text {
                        text: weatherIcon(backend.currentWeather.weatherCode,
                                          root.isDay)
                        font.pixelSize: 56
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Text {
                        text: backend.currentWeather.temperature !== undefined
                              ? Math.round(backend.currentWeather.temperature) + "°"
                              : "—"
                        font.pixelSize: 72
                        font.weight: Font.Light
                        color: "white"
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Text {
                        text: weatherDesc(backend.currentWeather.weatherCode)
                        font.pixelSize: 18
                        color: Qt.rgba(1,1,1,0.8)
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Text {
                        text: backend.currentWeather.apparentTemperature !== undefined
                              ? "Feels like " + Math.round(backend.currentWeather.apparentTemperature) + "°"
                              : ""
                        font.pixelSize: 14
                        color: Qt.rgba(1,1,1,0.6)
                        Layout.alignment: Qt.AlignHCenter
                    }

                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.topMargin: 8
                        spacing: 16

                        Text {
                            text: "🌅 " + fmtTime(backend.currentWeather.sunrise)
                            color: Qt.rgba(1,1,1,0.75)
                            font.pixelSize: 14
                        }
                        Text {
                            text: "🌇 " + fmtTime(backend.currentWeather.sunset)
                            color: Qt.rgba(1,1,1,0.75)
                            font.pixelSize: 14
                        }
                        Text {
                            text: root.isDay ? "☀️ Day" : "🌙 Night"
                            color: Qt.rgba(1,1,1,0.6)
                            font.pixelSize: 13
                        }
                    }
                }
            }

            // ── Details grid ────────────────────────────────────────────
            Rectangle {
                Layout.fillWidth: true
                height: detailGrid.height + 32
                radius: 20
                color: Qt.rgba(1, 1, 1, 0.10)
                border.color: Qt.rgba(1, 1, 1, 0.14)
                border.width: 1

                GridLayout {
                    id: detailGrid
                    anchors {
                        left: parent.left; right: parent.right
                        top: parent.top
                        margins: 16
                    }
                    columns: 2
                    columnSpacing: 12
                    rowSpacing: 12

                    // Each detail tile
                    Repeater {
                        model: [
                            { icon: "💧", label: "Humidity",
                              value: (backend.currentWeather.humidity ?? "—") + "%" },
                            { icon: "🌡️", label: "Dew Point",
                              value: (backend.currentWeather.dewpoint !== undefined
                                      ? backend.currentWeather.dewpoint.toFixed(1) + "°C" : "—") },
                            { icon: "💨", label: "Wind",
                              value: (backend.currentWeather.windSpeed !== undefined
                                      ? backend.currentWeather.windSpeed.toFixed(1) + " km/h" : "—")
                                     + " " + (backend.currentWeather.windDirectionStr ?? "") },
                            { icon: "☀️", label: "UV Index",
                              value: backend.currentWeather.uvIndex !== undefined
                                     ? backend.currentWeather.uvIndex.toFixed(1) : "—" },
                            { icon: "👁️", label: "Visibility",
                              value: visFmt(backend.currentWeather.visibility) },
                            { icon: "🌊", label: "Sea Pressure",
                              value: (backend.currentWeather.seaLevelPressure !== undefined
                                      ? backend.currentWeather.seaLevelPressure.toFixed(0) + " hPa" : "—") },
                            { icon: "⏱️", label: "Sfc Pressure",
                              value: (backend.currentWeather.surfacePressure !== undefined
                                      ? backend.currentWeather.surfacePressure.toFixed(0) + " hPa" : "—") },
                            { icon: "🌧️", label: "Precip Prob",
                              value: (backend.currentWeather.precipProbability ?? "—") + "%" },
                            { icon: "🌧️", label: "Precipitation",
                              value: (backend.currentWeather.precipitation !== undefined
                                      ? backend.currentWeather.precipitation.toFixed(1) + " mm" : "—") },
                            { icon: "🌤️", label: "Sunshine",
                              value: sunshineFmt(backend.currentWeather.sunshineDuration) }
                        ]

                        Rectangle {
                            Layout.fillWidth: true
                            height: 64
                            radius: 14
                            color: Qt.rgba(1, 1, 1, 0.08)

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 12
                                anchors.rightMargin: 12
                                spacing: 10

                                Text {
                                    text: modelData.icon
                                    font.pixelSize: 22
                                }
                                ColumnLayout {
                                    spacing: 2
                                    Text {
                                        text: modelData.label
                                        font.pixelSize: 11
                                        color: Qt.rgba(1,1,1,0.5)
                                        font.weight: Font.Medium
                                        font.capitalization: Font.AllUppercase
                                    }
                                    Text {
                                        text: modelData.value
                                        font.pixelSize: 16
                                        color: "white"
                                        font.weight: Font.DemiBold
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // ── Hourly forecast ─────────────────────────────────────────
            Rectangle {
                Layout.fillWidth: true
                height: hourlyCol.height + 28
                radius: 20
                color: Qt.rgba(1, 1, 1, 0.10)
                border.color: Qt.rgba(1, 1, 1, 0.14)
                border.width: 1

                ColumnLayout {
                    id: hourlyCol
                    anchors {
                        left: parent.left; right: parent.right
                        top: parent.top; margins: 14
                    }
                    spacing: 8

                    Text {
                        text: "Hourly Forecast"
                        font.pixelSize: 14
                        font.weight: Font.DemiBold
                        color: Qt.rgba(1,1,1,0.65)
                        font.capitalization: Font.AllUppercase
                        Layout.leftMargin: 4
                    }

                    ListView {
                        id: hourlyList
                        Layout.fillWidth: true
                        height: 110
                        orientation: ListView.Horizontal
                        spacing: 10
                        clip: true
                        model: backend.hourlyModel
                        delegate: Rectangle {
                            width: 68
                            height: 106
                            radius: 16
                            color: index === 0 ? Qt.rgba(1,1,1,0.18)
                                               : Qt.rgba(1,1,1,0.06)
                            border.color: Qt.rgba(1,1,1,0.12)

                            ColumnLayout {
                                anchors.centerIn: parent
                                spacing: 4

                                Text {
                                    text: index === 0 ? "Now" : fmtHour(modelData.time)
                                    font.pixelSize: 12
                                    color: Qt.rgba(1,1,1,0.7)
                                    Layout.alignment: Qt.AlignHCenter
                                    font.weight: index === 0 ? Font.Bold : Font.Normal
                                }
                                Text {
                                    text: modelData.isDay ? "☀️" : "🌙"
                                    font.pixelSize: 22
                                    Layout.alignment: Qt.AlignHCenter
                                }
                                Text {
                                    text: modelData.temperature !== undefined
                                          ? Math.round(modelData.temperature) + "°"
                                          : "—"
                                    font.pixelSize: 17
                                    font.weight: Font.DemiBold
                                    color: "white"
                                    Layout.alignment: Qt.AlignHCenter
                                }
                                Text {
                                    text: (modelData.precipProbability ?? 0) + "%"
                                    font.pixelSize: 11
                                    color: Qt.rgba(0.5, 0.8, 1, 0.8)
                                    Layout.alignment: Qt.AlignHCenter
                                }
                            }
                        }
                    }
                }
            }

            // ── Daily forecast ──────────────────────────────────────────
            Rectangle {
                id: dailyCard
                Layout.fillWidth: true
                implicitHeight: dailyInnerCol.height + 28
                radius: 20
                color: Qt.rgba(1, 1, 1, 0.10)
                border.color: Qt.rgba(1, 1, 1, 0.14)
                border.width: 1

                // Compute global min/max once for the temp bars
                property real globalMinTemp: {
                    var m = 100
                    for (var i = 0; i < backend.dailyModel.length; i++) {
                        var v = backend.dailyModel[i].tempMin
                        if (v !== undefined && v < m) m = v
                    }
                    return m
                }
                property real globalMaxTemp: {
                    var m = -100
                    for (var i = 0; i < backend.dailyModel.length; i++) {
                        var v = backend.dailyModel[i].tempMax
                        if (v !== undefined && v > m) m = v
                    }
                    return m
                }
                property real tempRange: globalMaxTemp - globalMinTemp > 0 ? globalMaxTemp - globalMinTemp : 1

                Column {
                    id: dailyInnerCol
                    anchors {
                        left: parent.left; right: parent.right
                        top: parent.top
                        margins: 14
                    }
                    spacing: 6

                    Text {
                        text: "12-Day Forecast"
                        font.pixelSize: 14
                        font.weight: Font.DemiBold
                        color: Qt.rgba(1,1,1,0.65)
                        font.capitalization: Font.AllUppercase
                        leftPadding: 4
                        bottomPadding: 4
                    }

                    Repeater {
                        model: backend.dailyModel
                        delegate: Rectangle {
                            property bool isToday: modelData.date === Qt.formatDate(new Date(), "yyyy-MM-dd")
                            width: dailyInnerCol.width
                            height: 56
                            radius: 12
                            color: isToday ? Qt.rgba(1, 1, 1, 0.20) : Qt.rgba(1, 1, 1, 0.05)
                            border.color: isToday ? Qt.rgba(1, 1, 1, 0.35) : "transparent"
                            border.width: isToday ? 1.5 : 0

                            // Accent bar on the left for today
                            Rectangle {
                                visible: isToday
                                width: 4
                                height: parent.height - 16
                                radius: 2
                                anchors.left: parent.left
                                anchors.leftMargin: 4
                                anchors.verticalCenter: parent.verticalCenter
                                color: "#4fc3f7"
                            }

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 12
                                anchors.rightMargin: 12
                                spacing: 6

                                Text {
                                    text: fmtDay(modelData.date)
                                    font.pixelSize: 13
                                    color: Qt.rgba(1,1,1,0.8)
                                    Layout.preferredWidth: 100
                                }

                                Text {
                                    text: weatherIcon(modelData.weatherCode, true)
                                    font.pixelSize: 22
                                }

                                Item { Layout.fillWidth: true }

                                Text {
                                    text: (modelData.precipProbability ?? 0) + "%"
                                    font.pixelSize: 12
                                    color: Qt.rgba(0.5, 0.8, 1, 0.8)
                                }

                                Text {
                                    text: modelData.tempMax !== undefined
                                          ? Math.round(modelData.tempMax) + "°"
                                          : "—"
                                    font.pixelSize: 16
                                    font.weight: Font.DemiBold
                                    color: "white"
                                    horizontalAlignment: Text.AlignRight
                                    Layout.preferredWidth: 36
                                }

                                // temperature range bar
                                Rectangle {
                                    Layout.preferredWidth: 60
                                    height: 6
                                    radius: 3
                                    color: Qt.rgba(1,1,1,0.12)

                                    Rectangle {
                                        property real barW: parent.width
                                        x: barW * ((modelData.tempMin ?? dailyCard.globalMinTemp) - dailyCard.globalMinTemp) / dailyCard.tempRange
                                        width: Math.max(6, barW * (((modelData.tempMax ?? dailyCard.globalMaxTemp) - (modelData.tempMin ?? dailyCard.globalMinTemp)) / dailyCard.tempRange))
                                        height: parent.height
                                        radius: 3
                                        gradient: Gradient {
                                            orientation: Gradient.Horizontal
                                            GradientStop { position: 0.0; color: "#4fc3f7" }
                                            GradientStop { position: 1.0; color: "#ff8a65" }
                                        }
                                    }
                                }

                                Text {
                                    text: modelData.tempMin !== undefined
                                          ? Math.round(modelData.tempMin) + "°"
                                          : "—"
                                    font.pixelSize: 14
                                    color: Qt.rgba(1,1,1,0.5)
                                    horizontalAlignment: Text.AlignRight
                                    Layout.preferredWidth: 30
                                }
                            }
                        }
                    }
                }
            }

            // Bottom spacer
            Item { height: 24; Layout.fillWidth: true }
        }
    }
}