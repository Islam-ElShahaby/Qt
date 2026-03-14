#pragma once
#include <QObject>
#include <QVariantList>
#include <QString>

class BluetoothManager : public QObject {
    Q_OBJECT
public:
    explicit BluetoothManager(QObject *parent = nullptr);

    // Q_INVOKABLE allows QML to call these directly
    Q_INVOKABLE QVariantList getAvailableDevices();
    Q_INVOKABLE void pairDevice(const QString &address);
    Q_INVOKABLE void unpairDevice(const QString &address);
    Q_INVOKABLE void startDiscovery();
    Q_INVOKABLE void stopDiscovery();

private:
    QString getAdapterPath();
};
