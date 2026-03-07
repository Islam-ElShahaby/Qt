#ifndef TEMPREADER_H
#define TEMPREADER_H

#include <QObject>
#include <QTimer>
#include <QFile>
#include <QDir>
#include <QQmlEngine>

class TempReader : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    Q_PROPERTY(QString temperature READ temperature NOTIFY temperatureChanged)

public:
    explicit TempReader(QObject *parent = nullptr);
    QString temperature() const;

signals:
    void temperatureChanged();

private slots:
    void readTemperature();

private:
    QString findThermalZone();
    QString m_temperature;
    QString m_thermalPath;
    QTimer m_timer;
};

#endif // TEMPREADER_H
