#include "GalleryModel.h"
#include <QFile>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QDir>
#include <QDebug>

GalleryModel::GalleryModel(QObject *parent)
    : QAbstractListModel(parent)
{
    loadFromJson();
}

void GalleryModel::loadFromJson()
{
    beginResetModel();
    m_items.clear();

    const QString jsonPath = QStringLiteral("gallery/gallery.json");
    QFile file(jsonPath);
    if (!file.open(QIODevice::ReadOnly)) {
        qWarning() << "GalleryModel: Could not open" << jsonPath;
        endResetModel();
        return;
    }

    QJsonParseError parseError;
    QJsonDocument doc = QJsonDocument::fromJson(file.readAll(), &parseError);
    file.close();

    if (parseError.error != QJsonParseError::NoError) {
        qWarning() << "GalleryModel: JSON parse error:" << parseError.errorString();
        endResetModel();
        return;
    }

    const QJsonArray arr = doc.array();
    const QDir galleryDir(QStringLiteral("gallery"));

    for (const QJsonValue &val : arr) {
        if (!val.isObject())
            continue;

        QJsonObject obj = val.toObject();
        QString imageName = obj.value("image").toString();

        // Skip entries without an image field
        if (imageName.isEmpty())
            continue;

        // Skip entries whose image file doesn't exist on disk
        if (!galleryDir.exists(imageName)) {
            qDebug() << "GalleryModel: Skipping" << imageName << "(file not found)";
            continue;
        }

        GalleryItem item;
        item.image = QStringLiteral("file:gallery/") + imageName;
        item.name = obj.value("name").toString();
        item.age = obj.value("age").toString();
        item.sex = obj.value("sex").toString();
        item.size = obj.value("size").toString();

        QJsonObject compat = obj.value("compatibility").toObject();
        item.compatDogs = compat.value("dogs").toString();
        item.compatCats = compat.value("cats").toString();
        item.compatKids = compat.value("kids").toString();

        item.vaccinations = obj.value("vaccinations").toString();

        // Join activity level array into a single string
        QJsonArray actArr = obj.value("activityLevel").toArray();
        QStringList activities;
        for (const QJsonValue &a : actArr)
            activities << a.toString();
        item.activityLevel = activities.join(", ");

        item.pottyTraining = obj.value("pottyTraining").toString();
        item.spayedNeutered = obj.value("spayedNeutered").toBool();

        m_items.append(item);
    }

    qDebug() << "GalleryModel: Loaded" << m_items.size() << "items";
    endResetModel();
}

void GalleryModel::reload()
{
    loadFromJson();
}

QVariantMap GalleryModel::get(int index) const
{
    QVariantMap map;
    if (index < 0 || index >= m_items.size())
        return map;

    const GalleryItem &item = m_items.at(index);
    map["image"] = item.image;
    map["name"] = item.name;
    map["age"] = item.age;
    map["sex"] = item.sex;
    map["petSize"] = item.size;
    map["compatDogs"] = item.compatDogs;
    map["compatCats"] = item.compatCats;
    map["compatKids"] = item.compatKids;
    map["vaccinations"] = item.vaccinations;
    map["activityLevel"] = item.activityLevel;
    map["pottyTraining"] = item.pottyTraining;
    map["spayedNeutered"] = item.spayedNeutered;
    return map;
}

int GalleryModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;
    return m_items.size();
}

QVariant GalleryModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() < 0 || index.row() >= m_items.size())
        return QVariant();

    const GalleryItem &item = m_items.at(index.row());

    switch (role) {
    case ImageRole:         return item.image;
    case NameRole:          return item.name;
    case AgeRole:           return item.age;
    case SexRole:           return item.sex;
    case SizeRole:          return item.size;
    case CompatDogsRole:    return item.compatDogs;
    case CompatCatsRole:    return item.compatCats;
    case CompatKidsRole:    return item.compatKids;
    case VaccinationsRole:  return item.vaccinations;
    case ActivityLevelRole: return item.activityLevel;
    case PottyTrainingRole: return item.pottyTraining;
    case SpayedNeuteredRole: return item.spayedNeutered;
    }

    return QVariant();
}

QHash<int, QByteArray> GalleryModel::roleNames() const
{
    return {
        { ImageRole,          "image" },
        { NameRole,           "name" },
        { AgeRole,            "age" },
        { SexRole,            "sex" },
        { SizeRole,           "petSize" },
        { CompatDogsRole,     "compatDogs" },
        { CompatCatsRole,     "compatCats" },
        { CompatKidsRole,     "compatKids" },
        { VaccinationsRole,   "vaccinations" },
        { ActivityLevelRole,  "activityLevel" },
        { PottyTrainingRole,  "pottyTraining" },
        { SpayedNeuteredRole, "spayedNeutered" },
    };
}
