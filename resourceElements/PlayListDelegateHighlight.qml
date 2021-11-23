import QtQuick 2.15

Rectangle {
    id: rectangle
    color: Style.clear
    radius: 10
    border.width: 5
    border.color: Style.darkTeal

    Text {
        id: text1
        color: Style.darkTeal
        text: "\u140A"
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        font.pixelSize: 20
        font.weight: Font.Bold
    }

}
