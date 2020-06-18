#ifndef POINTLIST_H
#define POINTLIST_H

#include <QAbstractListModel>
#include <random>

#include "Polygon.h"

Q_DECLARE_METATYPE(QVector<QPoint>)

class PolygonListModel : public QAbstractListModel
{
    Q_OBJECT

public:
    explicit PolygonListModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    bool setData(const QModelIndex &index, const QVariant &value, int role = Qt::EditRole) override;

    Q_INVOKABLE bool insertRows(int row, int count = 1, const QModelIndex &parent = QModelIndex()) override;
    Q_INVOKABLE bool removeRows(int row, int count = 1, const QModelIndex &parent = QModelIndex()) override;

    Q_INVOKABLE bool containsPoint(const QModelIndex &index, const QVariant &value) const;

    Qt::ItemFlags flags(const QModelIndex& index) const override;

    enum GetData
    {
        BoundingRectRole = Qt::UserRole + 1,
        PointsRole,
        ContainsPointRole,
        RemainingTimeRole
    };

    Q_ENUM(GetData);

    Q_PROPERTY(int quantity     MEMBER m_quantity     NOTIFY quantityChanged)
    Q_PROPERTY(int minSizeRange MEMBER m_minSizeRange NOTIFY minSizeRangeChanged)
    Q_PROPERTY(int maxSizeRange MEMBER m_maxSizeRange NOTIFY maxSizeRangeChanged)
    Q_PROPERTY(int lifespan     MEMBER m_lifespan     NOTIFY lifespanChanged)

    Q_PROPERTY(int minimumWindowWidth  MEMBER m_minimumWindowWidth)
    Q_PROPERTY(int minimumWindowHeight MEMBER m_minimumWindowHeight)

signals:
    void quantityChanged();
    void minSizeRangeChanged();
    void maxSizeRangeChanged();
    void lifespanChanged();

    void restart();

    void timerTriggered(int index);
    void timerStop(int index);

private slots:
    void slot_timerTriggered();
    void slot_timerStop(int index);

private:
    double randomReal(double min, double max);
    QPolygon generatePolygon();

    void beginReconnect();
    void endReconnect();

    int m_quantity;
    int m_minSizeRange;
    int m_maxSizeRange;
    int m_lifespan;

    int m_minimumWindowWidth;
    int m_minimumWindowHeight;

    QVector<Polygon> m_polygons;

    std::default_random_engine m_randomEngine;
};

#endif // POINTLIST_H
