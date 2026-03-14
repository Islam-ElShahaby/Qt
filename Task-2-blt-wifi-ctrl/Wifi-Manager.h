#pragma once
#include <QObject>
#include <QStringList>

class WifiManager : public QObject {
    Q_OBJECT
public:
    explicit WifiManager(QObject *parent = nullptr);

    // Q_INVOKABLE allows QML to call these directly
    Q_INVOKABLE QStringList getAvailableNetworks();
    Q_INVOKABLE QString getConnectedNetwork();
    Q_INVOKABLE void connectToWifi(const QString &ssid, const QString &password);
    Q_INVOKABLE void disconnectWifi();

private:
    QString getWifiDevicePath();
};