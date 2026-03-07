#include "TempReader.h"
#include <QTextStream>
#include <QDebug>
#include <QDirIterator>

TempReader::TempReader(QObject *parent)
    : QObject(parent)
    , m_temperature("--°C")
{
    m_thermalPath = findThermalZone();

    if (!m_thermalPath.isEmpty()) {
        readTemperature();
    } else {
        qWarning() << "TempReader: No thermal zone found";
    }

    connect(&m_timer, &QTimer::timeout, this, &TempReader::readTemperature);
    m_timer.start(2000);
}

QString TempReader::temperature() const
{
    return m_temperature;
}

QString TempReader::findThermalZone()
{
    // Try /sys/class/thermal/thermal_zone*/temp
    QDir thermalDir("/sys/class/thermal");
    QStringList zones = thermalDir.entryList(QStringList() << "thermal_zone*", QDir::Dirs);

    for (const QString &zone : zones) {
        QString typePath = thermalDir.filePath(zone + "/type");
        QString tempPath = thermalDir.filePath(zone + "/temp");

        QFile typeFile(typePath);
        if (typeFile.open(QIODevice::ReadOnly)) {
            QString type = typeFile.readAll().trimmed();
            typeFile.close();

            // Prefer CPU-related zones
            if (type.contains("cpu", Qt::CaseInsensitive) ||
                type.contains("x86_pkg", Qt::CaseInsensitive) ||
                type.contains("coretemp", Qt::CaseInsensitive) ||
                type.contains("k10temp", Qt::CaseInsensitive) ||
                type.contains("zenpower", Qt::CaseInsensitive)) {

                QFile tempFile(tempPath);
                if (tempFile.exists()) {
                    return tempPath;
                }
            }
        }
    }

    // Fallback: try /sys/class/hwmon/hwmon*/temp1_input
    QDir hwmonDir("/sys/class/hwmon");
    QStringList hwmons = hwmonDir.entryList(QStringList() << "hwmon*", QDir::Dirs);

    for (const QString &hwmon : hwmons) {
        QString namePath = hwmonDir.filePath(hwmon + "/name");
        QFile nameFile(namePath);
        if (nameFile.open(QIODevice::ReadOnly)) {
            QString name = nameFile.readAll().trimmed();
            nameFile.close();

            if (name.contains("coretemp", Qt::CaseInsensitive) ||
                name.contains("k10temp", Qt::CaseInsensitive) ||
                name.contains("zenpower", Qt::CaseInsensitive)) {

                QString tempPath = hwmonDir.filePath(hwmon + "/temp1_input");
                QFile tempFile(tempPath);
                if (tempFile.exists()) {
                    return tempPath;
                }
            }
        }
    }

    // Last resort: first available thermal zone
    if (!zones.isEmpty()) {
        QString tempPath = thermalDir.filePath(zones.first() + "/temp");
        QFile tempFile(tempPath);
        if (tempFile.exists()) {
            return tempPath;
        }
    }

    return QString();
}

void TempReader::readTemperature()
{
    if (m_thermalPath.isEmpty())
        return;

    QFile file(m_thermalPath);
    if (file.open(QIODevice::ReadOnly)) {
        QString raw = file.readAll().trimmed();
        file.close();

        bool ok;
        int millideg = raw.toInt(&ok);
        if (ok) {
            double celsius = millideg / 1000.0;
            QString newTemp = QString::number(celsius, 'f', 1) + "°C";
            if (newTemp != m_temperature) {
                m_temperature = newTemp;
                emit temperatureChanged();
            }
        }
    }
}
