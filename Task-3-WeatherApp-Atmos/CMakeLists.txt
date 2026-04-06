cmake_minimum_required(VERSION 3.16)

project(Atmos LANGUAGES CXX)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

find_package(Qt6 COMPONENTS Core Gui Qml Quick Network REQUIRED)

qt_add_executable(Atmos
    Atmos.cpp
    WeatherBackend.h
    WeatherBackend.cpp
)

qt_add_qml_module(Atmos
    URI Main
    VERSION 1.0
    QML_FILES Atmos.qml
)

target_link_libraries(Atmos
    PRIVATE Qt6::Core Qt6::Gui Qt6::Qml Qt6::Quick Qt6::Network
)
