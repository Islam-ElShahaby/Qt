import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    id: root
    visible: true
    width: 800
    height: 620
    title: "Calculator"
    color: "#1C1C1E"

    property string expression: ""
    property string displayText: "0"
    property bool hasResult: false

    // Evaluate expression
    function evaluate() {
        if (expression.length === 0)
            return;
        try {
            let expr = expression;
            expr = expr.replace(/×/g, "*");
            expr = expr.replace(/÷/g, "/");
            expr = expr.replace(/\^/g, "**");

            let result = Function('"use strict"; return (' + expr + ')')();

            if (!isFinite(result)) {
                displayText = "Error, did you divide by zero 🤨";
                expression = "";
                hasResult = true;
                return;
            }

            // Round to avoid floating-point noise
            result = Math.round(result * 1e10) / 1e10;
            displayText = result.toString();
            expression = displayText;
            hasResult = true;
        } catch (e) {
            displayText = "Error";
            expression = "";
            hasResult = true;
        }
    }

    function appendToExpression(text) {
        if (hasResult) {
            // After a result, if user presses an operator → chain; otherwise → start fresh
            let operators = ["+", "−", "×", "÷"];
            if (operators.indexOf(text) !== -1) {
                hasResult = false;
            } else {
                expression = "";
                hasResult = false;
            }
        }

        if (displayText === "Error") {
            expression = "";
            displayText = "0";
        }

        expression += text;

        // show the full expression
        let display = expression;
        displayText = display.length > 0 ? display : "0";
    }

    function clearAll() {
        expression = "";
        displayText = "0";
        hasResult = false;
    }

    function backspace() {
        if (hasResult) {
            clearAll();
            return;
        }
        if (expression.length > 0) {
            expression = expression.slice(0, -1);
            displayText = expression.length > 0 ? expression : "0";
        }
    }

    function applyPower() {
        appendToExpression("^");
    }

    function applyPercent() {
        if (expression.length > 0) {
            try {
                let expr = expression.replace(/×/g, "*").replace(/÷/g, "/");
                let val = Function('"use strict"; return (' + expr + ')')();
                val = val / 100;
                val = Math.round(val * 1e10) / 1e10;
                expression = val.toString();
                displayText = expression;
                hasResult = true;
            } catch (e) {
                displayText = "Error";
                expression = "";
                hasResult = true;
            }
        }
    }

    // Button model
    // type: "func", "op", "num", "eq"
    property var buttonModel: [["AC", "func"], ["%", "func"], ["xʸ", "op"], ["÷", "op"], ["7", "num"], ["8", "num"], ["9", "num"], ["×", "op"], ["4", "num"], ["5", "num"], ["6", "num"], ["−", "op"], ["1", "num"], ["2", "num"], ["3", "num"], ["+", "op"], ["⌫", "func"], ["0", "num"], [".", "num"], ["=", "eq"]]

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 12

        // Display Area
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 140
            color: "#2C2C2E"
            radius: 16

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 4

                Item {
                    Layout.fillHeight: true
                }

                // Expression line
                Text {
                    Layout.fillWidth: true
                    text: root.hasResult ? "" : root.expression
                    color: "#8E8E93"
                    font.pixelSize: 18
                    font.family: "monospace"
                    horizontalAlignment: Text.AlignRight
                    elide: Text.ElideLeft
                }

                // Result / current value
                Text {
                    Layout.fillWidth: true
                    text: root.displayText
                    color: "#FFFFFF"
                    font.pixelSize: root.displayText.length > 10 ? 34 : 48
                    font.weight: Font.Light
                    font.family: "monospace"
                    horizontalAlignment: Text.AlignRight
                    elide: Text.ElideLeft

                    Behavior on font.pixelSize {
                        NumberAnimation {
                            duration: 150
                            easing.type: Easing.OutQuad
                        }
                    }
                }
            }
        }

        // Button Grid
        GridLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            columns: 4
            rowSpacing: 10
            columnSpacing: 10

            Repeater {
                model: root.buttonModel

                Rectangle {
                    id: btn
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: 16

                    property string label: modelData[0]
                    property string btnType: modelData[1]

                    color: {
                        if (btnType === "op" || btnType === "eq")
                            return pressed ? "#CC7A00" : "#FF9500";
                        if (btnType === "func")
                            return pressed ? "#444448" : "#3A3A3C";
                        return pressed ? "#505055" : "#48484A";
                    }

                    property bool pressed: false

                    Behavior on color {
                        ColorAnimation {
                            duration: 100
                        }
                    }

                    // Subtle scale animation on press
                    scale: pressed ? 0.92 : 1.0
                    Behavior on scale {
                        NumberAnimation {
                            duration: 80
                            easing.type: Easing.OutQuad
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: btn.label
                        color: {
                            if (btn.btnType === "func")
                                return "#FFFFFF";
                            if (btn.btnType === "op" || btn.btnType === "eq")
                                return "#FFFFFF";
                            return "#FFFFFF";
                        }
                        font.pixelSize: btn.btnType === "func" ? 22 : 28
                        font.weight: Font.Medium
                    }

                    MouseArea {
                        anchors.fill: parent
                        onPressed: btn.pressed = true
                        onReleased: btn.pressed = false
                        onCanceled: btn.pressed = false
                        onClicked: {
                            switch (btn.label) {
                            case "AC":
                                root.clearAll();
                                break;
                            case "⌫":
                                root.backspace();
                                break;
                            case "xʸ":
                                root.applyPower();
                                break;
                            case "%":
                                root.applyPercent();
                                break;
                            case "=":
                                root.evaluate();
                                break;
                            default:
                                root.appendToExpression(btn.label);
                                break;
                            }
                        }
                    }
                }
            }
        }
    }
}
