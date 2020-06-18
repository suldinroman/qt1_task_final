import QtQuick 2.14
import QtQuick.Controls 2.14

TextField {
    id: textField
    implicitHeight: 35
    implicitWidth:  100

    verticalAlignment: TextInput.AlignBottom

    property string labelText: "title"

    property int minValue: 1
    property int maxValue: 99

    validator: intValidator

    IntValidator {
        id: intValidator
        bottom: textField.minValue
        top:    textField.maxValue
    }

    Label {
        id: label
        x: 4
        y: 2

        text: textField.labelText
    }

    onAcceptableInputChanged: {
        if (textField.acceptableInput)
            label.color = textField.color = "black";
        else
            label.color = textField.color = "red";
    }
}
