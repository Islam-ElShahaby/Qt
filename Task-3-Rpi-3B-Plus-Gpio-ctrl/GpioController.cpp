#include "GpioController.h"
#include <QFile>
#include <QDir>
#include <QDebug>
#include <QTextStream>

GpioController::GpioController(QObject *parent)
    : QObject(parent)
{
    // Poll input pins every 100 ms
    m_pollTimer.setInterval(100);
    connect(&m_pollTimer, &QTimer::timeout, this, &GpioController::pollInputPins);
    m_pollTimer.start();
}

GpioController::~GpioController()
{
    unexportAll();
}

// --------------- sysfs helpers ---------------

bool GpioController::writeToFile(const QString &path, const QString &value) const
{
    QFile file(path);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        qWarning() << "GPIO: Cannot open" << path << "for writing:" << file.errorString();
        return false;
    }
    QTextStream stream(&file);
    stream << value;
    file.close();
    return true;
}

QString GpioController::readFromFile(const QString &path) const
{
    QFile file(path);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        return QString();
    }
    QString content = QString::fromUtf8(file.readAll()).trimmed();
    file.close();
    return content;
}

// --------------- Export / Unexport ---------------

bool GpioController::exportPin(int gpioPin)
{
    int sysPin = toSysfsPin(gpioPin);
    QString gpioDir = QStringLiteral("/sys/class/gpio/gpio%1").arg(sysPin);

    // Already exported?
    if (QDir(gpioDir).exists()) {
        m_exportedPins.insert(gpioPin);
        emit pinExportChanged(gpioPin, true);
        return true;
    }

    if (!writeToFile(QStringLiteral("/sys/class/gpio/export"), QString::number(sysPin))) {
        emit errorOccurred(gpioPin, QStringLiteral("Failed to export GPIO %1 (sysfs %2)").arg(gpioPin).arg(sysPin));
        return false;
    }

    m_exportedPins.insert(gpioPin);
    emit pinExportChanged(gpioPin, true);
    qDebug() << "GPIO: Exported pin" << gpioPin << "(sysfs" << sysPin << ")";
    return true;
}

bool GpioController::unexportPin(int gpioPin)
{
    int sysPin = toSysfsPin(gpioPin);
    QString gpioDir = QStringLiteral("/sys/class/gpio/gpio%1").arg(sysPin);

    if (!QDir(gpioDir).exists()) {
        m_exportedPins.remove(gpioPin);
        emit pinExportChanged(gpioPin, false);
        return true;
    }

    if (!writeToFile(QStringLiteral("/sys/class/gpio/unexport"), QString::number(sysPin))) {
        emit errorOccurred(gpioPin, QStringLiteral("Failed to unexport GPIO %1").arg(gpioPin));
        return false;
    }

    m_exportedPins.remove(gpioPin);
    m_lastValues.remove(gpioPin);
    emit pinExportChanged(gpioPin, false);
    qDebug() << "GPIO: Unexported pin" << gpioPin << "(sysfs" << sysPin << ")";
    return true;
}

bool GpioController::isExported(int gpioPin) const
{
    int sysPin = toSysfsPin(gpioPin);
    return QDir(QStringLiteral("/sys/class/gpio/gpio%1").arg(sysPin)).exists();
}

void GpioController::unexportAll()
{
    QSet<int> pins = m_exportedPins; // copy
    for (int pin : pins) {
        unexportPin(pin);
    }
}

// --------------- Direction ---------------

bool GpioController::setDirection(int gpioPin, const QString &direction)
{
    int sysPin = toSysfsPin(gpioPin);
    QString path = QStringLiteral("/sys/class/gpio/gpio%1/direction").arg(sysPin);

    if (!writeToFile(path, direction)) {
        emit errorOccurred(gpioPin, QStringLiteral("Failed to set direction for GPIO %1").arg(gpioPin));
        return false;
    }

    emit pinDirectionChanged(gpioPin, direction);
    return true;
}

QString GpioController::getDirection(int gpioPin) const
{
    int sysPin = toSysfsPin(gpioPin);
    QString path = QStringLiteral("/sys/class/gpio/gpio%1/direction").arg(sysPin);
    return readFromFile(path);
}

// --------------- Value ---------------

bool GpioController::setValue(int gpioPin, int value)
{
    int sysPin = toSysfsPin(gpioPin);
    QString path = QStringLiteral("/sys/class/gpio/gpio%1/value").arg(sysPin);

    if (!writeToFile(path, QString::number(value ? 1 : 0))) {
        emit errorOccurred(gpioPin, QStringLiteral("Failed to set value for GPIO %1").arg(gpioPin));
        return false;
    }

    m_lastValues[gpioPin] = value ? 1 : 0;
    emit pinValueChanged(gpioPin, value ? 1 : 0);
    return true;
}

int GpioController::getValue(int gpioPin) const
{
    int sysPin = toSysfsPin(gpioPin);
    QString path = QStringLiteral("/sys/class/gpio/gpio%1/value").arg(sysPin);
    QString val = readFromFile(path);
    return val.toInt();
}

// --------------- Polling ---------------

void GpioController::pollInputPins()
{
    for (int pin : std::as_const(m_exportedPins)) {
        QString dir = getDirection(pin);
        if (dir == QStringLiteral("in")) {
            int val = getValue(pin);
            if (!m_lastValues.contains(pin) || m_lastValues[pin] != val) {
                m_lastValues[pin] = val;
                emit pinValueChanged(pin, val);
            }
        }
    }
}
