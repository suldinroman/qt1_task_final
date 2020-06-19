#include <QtMath>
#include "PolygonListModel.h"

#include <iostream>

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

        case GetData::OffsetRole:
            return m_polygons[index.row()].getOffset();

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
        m_polygons.insert(row + i, generatePolygon(i));
        m_polygons[row + i].setOffset(randomReal(0, m_minimumWindowWidth), randomReal(0, m_minimumWindowHeight));
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

double angleBetween(QPoint p1, QPoint p2)
{
    double numenator = p1.x() * p2.x() + p1.y() * p2.y();
    double denominator = sqrt(p1.x() * p1.x() + p1.y() * p1.y()) * sqrt(p2.x() * p2.x() + p2.y() * p2.y());
    double angle = qAcos(numenator / denominator);
    return angle * 57.3;
}

double determinant(QPoint p1, QPoint p2)
{
    return p1.x() * p2.y() - p2.x() * p1.y();
}

QPolygon PolygonListModel::generatePolygon(int index)
{
    QPolygon polygon;
    QVector<QPoint> generatedPoints;

    int sides = randomReal(m_minSizeRange, m_maxSizeRange);

    if (m_polygonSeed.empty())
        for (int i = 0; i < sides; ++i)
            generatedPoints.push_back(QPoint(randomReal(0, 100), randomReal(0, 100)));
    else
    {
        polygon.push_back(m_polygonSeed[index]);
        polygon.push_back(m_polygonSeed[index + 1 == m_polygonSeed.size() ? 0 : index + 1]);

        for (int i = 0; i < sides - 2; ++i)
            generatedPoints.push_back(QPoint(randomReal(0, 100), randomReal(0, 100)));
    }

    polygon.push_back(generatedPoints[0]);
    generatedPoints.remove(generatedPoints.indexOf(generatedPoints[0]));

    while (!generatedPoints.empty())
    {
        QVector<QPoint>::iterator selectedPoint = selectedPoint = generatedPoints.begin();

        for (auto i = generatedPoints.begin(); i != generatedPoints.end(); ++i)
            if (determinant(polygon.back(), *i) < 0)
            {
                selectedPoint = i;
                break;
            }

        for (auto i = generatedPoints.begin(); i != generatedPoints.end(); ++i)
            if (i != selectedPoint)
                if (angleBetween(polygon.back(), *selectedPoint) > angleBetween(polygon.back(), *i))
                    if (determinant(polygon.back(), *i) < 0)
                        selectedPoint = i;

        polygon.push_back(*selectedPoint);
        generatedPoints.remove(generatedPoints.indexOf(*selectedPoint));
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
