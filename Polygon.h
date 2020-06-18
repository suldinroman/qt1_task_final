#ifndef POLYGON_H
#define POLYGON_H

#include <QPolygon>
#include <QTimer>

class Polygon : public /*protected*/ QTimer, public QPolygon
{
    Q_OBJECT

public:
    Polygon(const Polygon&);
//  Polygon(const QRect& rectangle, bool = false);
//  Polygon(const QVector<QPoint>& points);
//  Polygon(int size);
    Polygon(QPolygon);
    Polygon();

    Polygon& operator=(const Polygon& polygon);
};

#endif // POLYGON_H
