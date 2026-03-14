cmake_minimum_required(VERSION 3.16)

project(WifiManagerApp VERSION 0.1 LANGUAGES CXX)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR})

# Qt requires at least C++17
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_STANDARD 17)

# Enable Qt's automatic moc, rcc, and uic
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

# Find the required Qt6 modules, including DBus!
find_package(Qt6 6.4 REQUIRED COMPONENTS Core Gui Qml Quick QuickControls2 DBus)

# Create the executable and add our C++ files
qt_add_executable(WifiManagerApp
    main.cpp
    Wifi-Manager.cpp
    Wifi-Manager.h
    Bluetooth-Manager.cpp
    Bluetooth-Manager.h
)

# Add QML files as Qt resources
qt_add_resources(WifiManagerApp "qml"
    PREFIX "/"
    FILES
        Main.qml
)

# Link the Qt modules to your executable
target_link_libraries(WifiManagerApp PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
    Qt6::QuickControls2
    Qt6::DBus
)