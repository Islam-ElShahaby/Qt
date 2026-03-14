#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "Wifi-Manager.h"
#include "Bluetooth-Manager.h"

int main(int argc, char *argv[]) {
    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine;

    // Create managers and expose them to QML
    WifiManager wifi;
    BluetoothManager bt;
    engine.rootContext()->setContextProperty("wifiManager", &wifi);
    engine.rootContext()->setContextProperty("btManager", &bt);

    engine.load(QUrl(QStringLiteral("qrc:/Main.qml")));
    return app.exec();
}