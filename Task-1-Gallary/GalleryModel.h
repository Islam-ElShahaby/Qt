#ifndef GALLERYMODEL_H
#define GALLERYMODEL_H

#include <QAbstractListModel>
#include <QQmlEngine>
#include <QJsonArray>

struct GalleryItem {
    QString image;
    QString name;
    QString age;
    QString sex;
    QString size;
    QString compatDogs;
    QString compatCats;
    QString compatKids;
    QString vaccinations;
    QString activityLevel;
    QString pottyTraining;
    bool spayedNeutered;
};

class GalleryModel : public QAbstractListModel
{
    Q_OBJECT
    QML_ELEMENT

public:
    enum Roles {
        ImageRole = Qt::UserRole + 1,
        NameRole,
        AgeRole,
        SexRole,
        SizeRole,
        CompatDogsRole,
        CompatCatsRole,
        CompatKidsRole,
        VaccinationsRole,
        ActivityLevelRole,
        PottyTrainingRole,
        SpayedNeuteredRole
    };

    explicit GalleryModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE void reload();
    Q_INVOKABLE QVariantMap get(int index) const;

private:
    void loadFromJson();
    QList<GalleryItem> m_items;
};

#endif // GALLERYMODEL_H
