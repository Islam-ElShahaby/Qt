#ifndef WEATHERBACKEND_H
#define WEATHERBACKEND_H

#include <QObject>
#include <QVariantList>
#include <QVariantMap>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QQmlEngine>

class WeatherBackend : public QObject
{
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(QVariantMap  currentWeather READ currentWeather NOTIFY dataChanged)
    Q_PROPERTY(QVariantList hourlyModel    READ hourlyModel    NOTIFY dataChanged)
    Q_PROPERTY(QVariantList dailyModel     READ dailyModel     NOTIFY dataChanged)
    Q_PROPERTY(QVariantList searchResults  READ searchResults  NOTIFY searchResultsChanged)
    Q_PROPERTY(bool         loading        READ loading        NOTIFY loadingChanged)
    Q_PROPERTY(QString      errorString    READ errorString    NOTIFY errorChanged)
    Q_PROPERTY(QString      cityName       READ cityName       NOTIFY dataChanged)
    Q_PROPERTY(double       latitude       READ latitude       NOTIFY dataChanged)
    Q_PROPERTY(double       longitude      READ longitude      NOTIFY dataChanged)

public:
    explicit WeatherBackend(QObject *parent = nullptr);

    QVariantMap  currentWeather() const { return m_currentWeather; }
    QVariantList hourlyModel()    const { return m_hourlyModel; }
    QVariantList dailyModel()     const { return m_dailyModel; }
    QVariantList searchResults()  const { return m_searchResults; }
    bool         loading()        const { return m_loading; }
    QString      errorString()    const { return m_errorString; }
    QString      cityName()       const { return m_cityName; }
    double       latitude()       const { return m_latitude; }
    double       longitude()      const { return m_longitude; }

    Q_INVOKABLE void fetchWeather(double lat, double lon);
    Q_INVOKABLE void searchCity(const QString &name);

signals:
    void dataChanged();
    void loadingChanged();
    void errorChanged();
    void searchResultsChanged();

private slots:
    void onWeatherReply(QNetworkReply *reply);
    void onGeoReply(QNetworkReply *reply);

private:
    void parseWeatherJson(const QJsonObject &root);
    QString windDirectionString(double degrees) const;

    QNetworkAccessManager *m_weatherNam;
    QNetworkAccessManager *m_geoNam;

    QVariantMap  m_currentWeather;
    QVariantList m_hourlyModel;
    QVariantList m_dailyModel;
    QVariantList m_searchResults;

    bool    m_loading = false;
    QString m_errorString;
    QString m_cityName;
    double  m_latitude  = 30.0444;
    double  m_longitude = 31.2357;
};

#endif // WEATHERBACKEND_H
