#include "Polygon.h"

Polygon::Polygon(const Polygon& polygon): QPolygon(static_cast<QPolygon>(polygon))
{
    this->stop();
    if (polygon.remainingTime() >= 0)
        this->setInterval(polygon.remainingTime());
    else
        this->setInterval(polygon.interval());
}
Polygon::Polygon(QPolygon polygon): QPolygon(polygon) { }
Polygon::Polygon(): QPolygon() { }

Polygon& Polygon::operator=(const Polygon& polygon)
{
    if (&polygon == this)
        return *this;

    this->stop();
    this->setInterval(polygon.interval());

    if(!this->empty())
        this->clear();

    for (auto i = polygon.begin(); i != polygon.end(); ++i)
        this->push_back(*i);

    return *this;
}
