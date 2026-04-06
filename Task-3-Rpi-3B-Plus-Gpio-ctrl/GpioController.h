#ifndef GPIOCONTROLLER_H
#define GPIOCONTROLLER_H

#include <QObject>
#include <QQmlEngine>
#include <QTimer>
#include <QMap>

class GpioController : public QObject
{
    Q_OBJECT
    QML_ELEMENT

public:
    explicit GpioController(QObject *parent = nullptr);
    ~GpioController();

    // GPIO base offset for RPi 3B+ (gpiochip*/base = 512)
    static constexpr int GPIO_BASE = 512;

    // Export / Unexport
    Q_INVOKABLE bool exportPin(int gpioPin);
    Q_INVOKABLE bool unexportPin(int gpioPin);

    // Direction: "in" or "out"
    Q_INVOKABLE bool setDirection(int gpioPin, const QString &direction);
    Q_INVOKABLE QString getDirection(int gpioPin) const;

    // Value: 0 or 1
    Q_INVOKABLE bool setValue(int gpioPin, int value);
    Q_INVOKABLE int  getValue(int gpioPin) const;

    // Check if pin is exported
    Q_INVOKABLE bool isExported(int gpioPin) const;

    // Unexport all currently exported pins (cleanup)
    Q_INVOKABLE void unexportAll();

signals:
    void pinValueChanged(int gpioPin, int value);
    void pinDirectionChanged(int gpioPin, const QString &direction);
    void pinExportChanged(int gpioPin, bool exported);
    void errorOccurred(int gpioPin, const QString &message);

private slots:
    void pollInputPins();

private:
    int toSysfsPin(int gpioPin) const { return gpioPin + GPIO_BASE; }

    bool writeToFile(const QString &path, const QString &value) const;
    QString readFromFile(const QString &path) const;

    QSet<int> m_exportedPins;
    QTimer    m_pollTimer;
    QMap<int, int> m_lastValues; // cache last-read values for input pins
};

#endif // GPIOCONTROLLER_H
