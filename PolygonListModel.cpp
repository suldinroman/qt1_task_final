#include <QtMath>
#include "PolygonListModel.h"

const double SIZE_FACTOR_MIN = 21.6640204041598;
const double SIZE_FACTOR_MAX = 43.3280408083196;

PolygonListModel::PolygonListModel(QObject *parent):
    QAbstractListModel(parent), m_quantity(0), m_minSizeRange(0), m_maxSizeRange(0), m_lifespan(0),
    m_minimumWindowWidth(0), m_minimumWindowHeight(0)
{
    //std::srand(std::time(nullptr));
    std::random_device random_device;

    m_randomEngine = std::default_random_engine(/*std::rand()*/random_device());
    connect(this, &PolygonListModel::timerStop, this, &PolygonListModel::slot_timerStop);
}

int PolygonListModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;
    return m_polygons.size();
}

QVariant PolygonListModel::data(const QModelIndex &index, int role) const
{
    if (index.isValid())
        switch (role)
        {
        case GetData::BoundingRectRole:
            return m_polygons[index.row()].boundingRect();

        case GetData::PointsRole:
            return QVariant::fromValue(QVector<QPoint>(m_polygons[index.row()].begin(), m_polygons[index.row()].end()));

        case GetData::RemainingTimeRole:
            return m_polygons[index.row()].remainingTime();

        default:
            return QVariant();
        }
    return QVariant();
}

bool PolygonListModel::setData(const QModelIndex &index, const QVariant &value, int role)
{
    if (index.isValid() && Qt::EditRole)
    {
        m_polygons[index.row()] = qvariant_cast<QPolygon>(value);
        emit dataChanged(index, index, QVector<int>() << role);
        return true;
    }
    return false;
}

bool PolygonListModel::insertRows(int row, int count, const QModelIndex &parent)
{
    if (row > rowCount())
        return false;

    beginInsertRows(parent, row, row + count - 1);
    beginReconnect();
    for (int i = 0; i < count; ++i)
    {
        m_polygons.insert(row + i, generatePolygon());
        m_polygons[row + i].setInterval(m_lifespan);
    }
    endReconnect();
    endInsertRows();

    return true;
}

bool PolygonListModel::removeRows(int row, int count, const QModelIndex &parent)
{
    if (row + count > rowCount())
        return false;

    beginRemoveRows(parent, row, row + count - 1);
    beginReconnect();
    m_polygons.remove(row, count);
    endReconnect();
    endRemoveRows();

    if (m_polygons.empty())
        emit restart();

    return true;
}

bool PolygonListModel::containsPoint(const QModelIndex &index, const QVariant &value) const
{
    if (index.isValid())
        return m_polygons[index.row()].containsPoint(value.toPoint(), Qt::OddEvenFill);
    return false;
};

Qt::ItemFlags PolygonListModel::flags(const QModelIndex &index) const
{
    if (!index.isValid())
        return Qt::NoItemFlags;
    return Qt::ItemIsEditable;
}

void PolygonListModel::slot_timerTriggered()
{
    Polygon* polygon = qobject_cast<Polygon*>(sender());
    if (polygon)
        emit timerTriggered(m_polygons.indexOf(*polygon));
}

void PolygonListModel::slot_timerStop(int indexModel)
{
    m_polygons[indexModel].stop();
}

double PolygonListModel::randomReal(double min, double max)
{
    std::uniform_real_distribution<> realDistributon(min, max);
    return realDistributon(m_randomEngine);
}

QPolygon PolygonListModel::generatePolygon()
{
    QPolygon polygon;

    int sides = randomReal(m_minSizeRange, m_maxSizeRange);
    int angle = randomReal(0, 360);

    int offsetX = randomReal(0, m_minimumWindowWidth);
    int offsetY = randomReal(0, m_minimumWindowHeight);

    double sizeFactor = randomReal(SIZE_FACTOR_MIN, SIZE_FACTOR_MAX);

    for (int i = 0; i < sides; ++i)
    {
        double pointFactor = randomReal(0, 360 / sides) - 360 / sides / 2;
        int X = -cos((angle + 360 / sides * i + pointFactor) * M_PI / 180) * sizeFactor + offsetX;
        int Y = -sin((angle + 360 / sides * i + pointFactor) * M_PI / 180) * sizeFactor + offsetY;
        polygon.push_back(QPoint(X, Y));
    }
    return polygon;
}

void PolygonListModel::beginReconnect()
{
    for (int i = 0; i < rowCount(); ++i)
    {
        int remainingTime = m_polygons[i].remainingTime();

        m_polygons[i].stop();
        disconnect(&m_polygons[i], &Polygon::timeout, this, &PolygonListModel::slot_timerTriggered);

        if (remainingTime > 0)
            m_polygons[i].setInterval(remainingTime);
        else
            m_polygons[i].setInterval(0);
    }
}

void PolygonListModel::endReconnect()
{
    for (int i = 0; i < rowCount(); ++i)
    {
        connect(&m_polygons[i], &Polygon::timeout, this, &PolygonListModel::slot_timerTriggered);
        m_polygons[i].start();
    }
}
