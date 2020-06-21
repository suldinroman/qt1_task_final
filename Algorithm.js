function calibration(points)
{
    let X = points[0].x;
    let Y = points[0].y;

    for (let i = 0; i < points.length; ++i)
    {
        if (X > points[i].x) X = points[i].x;
        if (Y > points[i].y) Y = points[i].y;
    }

    return Qt.point(X, Y);
}
