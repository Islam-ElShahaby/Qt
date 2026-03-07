cmake_minimum_required(VERSION 3.16)
project(VideoSplashApp VERSION 1.0 LANGUAGES CXX)

find_package(Qt6 REQUIRED COMPONENTS Core Gui Quick Multimedia Qml)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR})

if(COMMAND qt_policy)
    qt_policy(SET QTP0001 NEW)
endif()

qt_standard_project_setup()

qt_add_executable(LUMINA
    spalsh.cpp
)

qt_add_qml_module(LUMINA
    URI Main
    VERSION 1.0
    QML_FILES
        Spalsh.qml
        HomeScreen.qml
        GalleryScreen.qml
    SOURCES
        TempReader.h
        TempReader.cpp
        GalleryModel.h
        GalleryModel.cpp
    RESOURCES
        media/splash.mkv
        media/splash2.mp4
)

target_link_libraries(LUMINA
    PRIVATE 
        Qt6::Core 
        Qt6::Gui 
        Qt6::Quick 
        Qt6::Qml
        Qt6::Multimedia
)