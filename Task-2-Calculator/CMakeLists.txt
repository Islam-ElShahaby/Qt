cmake_minimum_required(VERSION 3.16)
project(CalculatorApp VERSION 1.0 LANGUAGES CXX)

find_package(Qt6 REQUIRED COMPONENTS Core Gui Quick Qml)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR})

if(COMMAND qt_policy)
    qt_policy(SET QTP0001 NEW)
endif()

qt_standard_project_setup()

qt_add_executable(Calculator
    Calculator.cpp
)

qt_add_qml_module(Calculator
    URI Main
    VERSION 1.0
    QML_FILES
        Calculator.qml
)

target_link_libraries(Calculator
    PRIVATE
        Qt6::Core
        Qt6::Gui
        Qt6::Quick
        Qt6::Qml
)
