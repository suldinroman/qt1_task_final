cmake_minimum_required(VERSION 3.0)

project(qt1_task_final LANGUAGES CXX)

set(CMAKE_INCLUDE_CURRENT_DIR ON)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt5 COMPONENTS Core Quick REQUIRED)

add_executable(qt1_task_final
      Main.cpp
      Polygon.h Polygon.cpp
      PolygonListModel.h PolygonListModel.cpp
      Resources.qrc
    )

target_link_libraries(qt1_task_final PRIVATE Qt5::Core Qt5::Quick)
