#include "Bluetooth-Manager.h"
#include <QtDBus/QtDBus>
#include <QDebug>

BluetoothManager::BluetoothManager(QObject *parent) : QObject(parent) {}

// Helper: default adapter is almost always /org/bluez/hci0
QString BluetoothManager::getAdapterPath() {
    return QStringLiteral("/org/bluez/hci0");
}

// LIST BLUETOOTH DEVICES
QVariantList BluetoothManager::getAvailableDevices() {
    QVariantList deviceList;

    QDBusInterface manager("org.bluez",
                           "/",
                           "org.freedesktop.DBus.ObjectManager",
                           QDBusConnection::systemBus());

    QDBusMessage reply = manager.call("GetManagedObjects");
    if (reply.type() != QDBusMessage::ReplyMessage) {
        qDebug() << "Failed to get BlueZ managed objects:" << reply.errorMessage();
        return deviceList;
    }

    // Response type: a{oa{sa{sv}}}
    const QDBusArgument rootArg = reply.arguments().at(0).value<QDBusArgument>();

    rootArg.beginMap();
    while (!rootArg.atEnd()) {
        rootArg.beginMapEntry();

        QDBusObjectPath objPath;
        rootArg >> objPath;

        // Read interfaces map: a{sa{sv}}
        const QDBusArgument ifacesArg = rootArg.asVariant().value<QDBusArgument>();
        
        QString deviceName;
        QString deviceAddress;
        bool paired = false;
        bool connected = false;
        bool isDevice = false;

        ifacesArg.beginMap();
        while (!ifacesArg.atEnd()) {
            ifacesArg.beginMapEntry();

            QString ifaceName;
            ifacesArg >> ifaceName;

            // Read properties: a{sv}
            const QDBusArgument propsArg = ifacesArg.asVariant().value<QDBusArgument>();

            if (ifaceName == "org.bluez.Device1") {
                isDevice = true;
                propsArg.beginMap();
                while (!propsArg.atEnd()) {
                    propsArg.beginMapEntry();
                    QString key;
                    QDBusVariant dbusVal;
                    propsArg >> key >> dbusVal;
                    propsArg.endMapEntry();

                    QVariant val = dbusVal.variant();
                    if (key == "Name" || (key == "Alias" && deviceName.isEmpty()))
                        deviceName = val.toString();
                    else if (key == "Address")
                        deviceAddress = val.toString();
                    else if (key == "Paired")
                        paired = val.toBool();
                    else if (key == "Connected")
                        connected = val.toBool();
                }
                propsArg.endMap();
            } else {
                // Skip properties of other interfaces
                propsArg.beginMap();
                while (!propsArg.atEnd()) {
                    propsArg.beginMapEntry();
                    QString k;
                    QDBusVariant v;
                    propsArg >> k >> v;
                    propsArg.endMapEntry();
                }
                propsArg.endMap();
            }

            ifacesArg.endMapEntry();
        }
        ifacesArg.endMap();

        rootArg.endMapEntry();

        if (isDevice && !deviceAddress.isEmpty()) {
            QVariantMap device;
            device["name"] = deviceName.isEmpty() ? "Unknown" : deviceName;
            device["address"] = deviceAddress;
            device["paired"] = paired;
            device["connected"] = connected;
            device["path"] = objPath.path();
            deviceList.append(device);
        }
    }
    rootArg.endMap();

    return deviceList;
}

// START DISCOVERY
void BluetoothManager::startDiscovery() {
    QDBusInterface adapter("org.bluez",
                           getAdapterPath(),
                           "org.bluez.Adapter1",
                           QDBusConnection::systemBus());

    QDBusMessage reply = adapter.call("StartDiscovery");
    if (reply.type() == QDBusMessage::ErrorMessage)
        qDebug() << "StartDiscovery error:" << reply.errorMessage();
    else
        qDebug() << "Bluetooth discovery started.";
}

// STOP DISCOVERY
void BluetoothManager::stopDiscovery() {
    QDBusInterface adapter("org.bluez",
                           getAdapterPath(),
                           "org.bluez.Adapter1",
                           QDBusConnection::systemBus());

    QDBusMessage reply = adapter.call("StopDiscovery");
    if (reply.type() == QDBusMessage::ErrorMessage)
        qDebug() << "StopDiscovery error:" << reply.errorMessage();
    else
        qDebug() << "Bluetooth discovery stopped.";
}

// PAIR + CONNECT
void BluetoothManager::pairDevice(const QString &address) {
    QVariantList devices = getAvailableDevices();
    QString devicePath;
    for (const QVariant &dev : devices) {
        QVariantMap m = dev.toMap();
        if (m["address"].toString() == address) {
            devicePath = m["path"].toString();
            break;
        }
    }
    if (devicePath.isEmpty()) {
        qDebug() << "Device not found:" << address;
        return;
    }

    QDBusInterface device("org.bluez",
                          devicePath,
                          "org.bluez.Device1",
                          QDBusConnection::systemBus());

    QDBusMessage pairReply = device.call("Pair");
    if (pairReply.type() == QDBusMessage::ErrorMessage)
        qDebug() << "Pair error:" << pairReply.errorMessage();

    QDBusMessage connectReply = device.call("Connect");
    if (connectReply.type() == QDBusMessage::ErrorMessage)
        qDebug() << "Connect error:" << connectReply.errorMessage();
    else
        qDebug() << "Connected to:" << address;
}

// UNPAIR (Disconnect + Remove)
void BluetoothManager::unpairDevice(const QString &address) {
    QVariantList devices = getAvailableDevices();
    QString devicePath;
    for (const QVariant &dev : devices) {
        QVariantMap m = dev.toMap();
        if (m["address"].toString() == address) {
            devicePath = m["path"].toString();
            break;
        }
    }
    if (devicePath.isEmpty()) {
        qDebug() << "Device not found:" << address;
        return;
    }

    QDBusInterface device("org.bluez",
                          devicePath,
                          "org.bluez.Device1",
                          QDBusConnection::systemBus());
    device.call("Disconnect");

    QDBusInterface adapter("org.bluez",
                           getAdapterPath(),
                           "org.bluez.Adapter1",
                           QDBusConnection::systemBus());
    adapter.call("RemoveDevice", QVariant::fromValue(QDBusObjectPath(devicePath)));
    qDebug() << "Unpaired and removed:" << address;
}
