#include "Wifi-Manager.h"
#include <QtDBus/QtDBus>
#include <QDebug>

WifiManager::WifiManager(QObject *parent) : QObject(parent) {}

// Helper to find the actual Wi-Fi hardware device
QString WifiManager::getWifiDevicePath() {
    QDBusInterface nm("org.freedesktop.NetworkManager", 
                      "/org/freedesktop/NetworkManager", 
                      "org.freedesktop.NetworkManager", 
                      QDBusConnection::systemBus());

    QDBusReply<QList<QDBusObjectPath>> reply = nm.call("GetDevices");
    if (reply.isValid()) {
        for (const QDBusObjectPath &path : reply.value()) {
            QDBusInterface devicePath("org.freedesktop.NetworkManager", 
                                      path.path(), 
                                      "org.freedesktop.NetworkManager.Device", 
                                      QDBusConnection::systemBus());
            
            // represents NM_DEVICE_TYPE_WIFI
            if (devicePath.property("DeviceType").toUInt() == 2) {
                return path.path();
            }
        }
    }
    return QString();
}

// LIST NETWORKS
QStringList WifiManager::getAvailableNetworks() {
    QStringList networkList;
    QString devicePath = getWifiDevicePath();
    if (devicePath.isEmpty()) return networkList;

    QDBusInterface wirelessDev("org.freedesktop.NetworkManager", 
                               devicePath, 
                               "org.freedesktop.NetworkManager.Device.Wireless", 
                               QDBusConnection::systemBus());

    QDBusReply<QList<QDBusObjectPath>> apReply = wirelessDev.call("GetAccessPoints");
    if (apReply.isValid()) {
        for (const QDBusObjectPath &apPath : apReply.value()) {
            QDBusInterface apInterface("org.freedesktop.NetworkManager", 
                                       apPath.path(), 
                                       "org.freedesktop.NetworkManager.AccessPoint", 
                                       QDBusConnection::systemBus());
            
            // NetworkManager returns SSIDs as byte arrays
            QByteArray ssidBytes = apInterface.property("Ssid").toByteArray();
            QString ssid = QString::fromUtf8(ssidBytes);
            
            if (!ssid.isEmpty() && !networkList.contains(ssid)) {
                networkList.append(ssid);
            }
        }
    }
    return networkList;
}

// GET CONNECTED NETWORK
QString WifiManager::getConnectedNetwork() {
    QString devicePath = getWifiDevicePath();
    if (devicePath.isEmpty()) return QString();

    // Read the ActiveConnection property from the device
    QDBusInterface deviceIface("org.freedesktop.NetworkManager",
                               devicePath,
                               "org.freedesktop.DBus.Properties",
                               QDBusConnection::systemBus());

    QDBusReply<QDBusVariant> acReply = deviceIface.call(
        "Get", "org.freedesktop.NetworkManager.Device", "ActiveConnection");
    if (!acReply.isValid()) return QString();

    QDBusObjectPath acPath = acReply.value().variant().value<QDBusObjectPath>();
    if (acPath.path() == "/" || acPath.path().isEmpty()) return QString();

    // Get the connection settings from the active connection
    QDBusInterface acIface("org.freedesktop.NetworkManager",
                           acPath.path(),
                           "org.freedesktop.DBus.Properties",
                           QDBusConnection::systemBus());

    QDBusReply<QDBusVariant> idReply = acIface.call(
        "Get", "org.freedesktop.NetworkManager.Connection.Active", "Id");
    if (idReply.isValid()) {
        return idReply.value().variant().toString();
    }
    return QString();
}

// CONNECT TO WIFI
void WifiManager::connectToWifi(const QString &ssid, const QString &password) {
    QString devicePath = getWifiDevicePath();
    if (devicePath.isEmpty()) {
        qWarning() << "No Wi-Fi device found!";
        return;
    }

    using SettingsMap = QMap<QString, QVariantMap>;

    SettingsMap connection;

    // 802-11-wireless settings
    QVariantMap wifiSettings;
    wifiSettings["ssid"] = ssid.toUtf8();
    wifiSettings["mode"] = QString("infrastructure");
    connection["802-11-wireless"] = wifiSettings;

    // 802-11-wireless-security settings
    QVariantMap securitySettings;
    securitySettings["key-mgmt"] = QString("wpa-psk");
    securitySettings["psk"] = password;
    connection["802-11-wireless-security"] = securitySettings;

    // Connection base settings
    QVariantMap connectionSettings;
    connectionSettings["type"] = QString("802-11-wireless");
    connectionSettings["id"] = ssid;
    connection["connection"] = connectionSettings;

    // IPv4 – use auto (DHCP)
    QVariantMap ipv4Settings;
    ipv4Settings["method"] = QString("auto");
    connection["ipv4"] = ipv4Settings;

    // Serialise to the D-Bus argument with correct type signature a{sa{sv}}
    QDBusArgument dbusArg;
    dbusArg.beginMap(QMetaType(QMetaType::QString), QMetaType::fromType<QVariantMap>());
    for (auto it = connection.constBegin(); it != connection.constEnd(); ++it) {
        dbusArg.beginMapEntry();
        dbusArg << it.key() << it.value();
        dbusArg.endMapEntry();
    }
    dbusArg.endMap();

    QDBusInterface nm("org.freedesktop.NetworkManager",
                      "/org/freedesktop/NetworkManager",
                      "org.freedesktop.NetworkManager",
                      QDBusConnection::systemBus());

    QDBusMessage reply = nm.call("AddAndActivateConnection",
                                  QVariant::fromValue(dbusArg),
                                  QVariant::fromValue(QDBusObjectPath(devicePath)),
                                  QVariant::fromValue(QDBusObjectPath("/")));

    if (reply.type() == QDBusMessage::ErrorMessage) {
        qWarning() << "Wi-Fi connect failed:" << reply.errorName() << reply.errorMessage();
    } else {
        qDebug() << "Connection activated for:" << ssid;
    }
}

// DISCONNECT
void WifiManager::disconnectWifi() {
    QString devicePath = getWifiDevicePath();
    if (devicePath.isEmpty()) return;

    QDBusInterface deviceDev("org.freedesktop.NetworkManager", 
                             devicePath, 
                             "org.freedesktop.NetworkManager.Device", 
                             QDBusConnection::systemBus());
    
    deviceDev.call("Disconnect");
    qDebug() << "Disconnect command sent.";
}