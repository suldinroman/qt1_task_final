#include <QGuiApplication>
#include <QQmlApplicationEngine>

#include "PolygonListModel.h"

int main(int argc, char *argv[])
{
    qmlRegisterType<PolygonListModel>("PolygonListModel", 1, 0, "PolygonListModel");
    qRegisterMetaType<QVector<QPoint>>();

    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine("qrc:/Main.qml");

    return app.exec();
}
