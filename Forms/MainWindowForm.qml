import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15
import QtQml 2.15
import Qt.labs.settings 1.1
import QtMultimedia 5.15
import "../resourceElements"


Item {
    anchors.fill: parent
    Page {
        id: stackWindow
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: isPortrait ? parent.right : nowPlayingWindow.left

        StackView {
            id: stackView
//            initialItem: "qrc:/Forms/HomeForm.qml"
            anchors.fill: parent
        }

        Component {
            id: tabButton
            TabButton {
                property int stackIndexValue
                onClicked: tabClicked(text, stackIndexValue)
            }
        }

        footer: TabBar {
            id: tabBar
//            currentIndex: 0

//            TabButton {
//                text: qsTr("Home")
//                onClicked: {
//                    console.log(stackView.depth)
//                }
//            }
        }
        Component.onCompleted: {
            pushForm("qrc:/Forms/HomeForm.qml", "Home")
        }
    }

    Rectangle {
        id: nowPlayingWindow
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        visible: !isPortrait
        width: isPortrait ? parent.width : parent.width / 2
    }

    function pushForm( formName, tabName ) {
        var tabCount = tabBar.count
        stackView.push( formName )
        var tab = tabButton.createObject(tabBar, { text: tabName, stackIndexValue: tabCount })
        tabBar.addItem(tab)
    }

    function tabClicked( tabName, indexValue ) {
        console.log(tabName, indexValue)
    }

    function setState( newstate ) {
        state = newstate
    }

    states: [
        State {
            name: "Portrait"
            PropertyChanges {
                target: stackWindow
                anchors.right: parent.right
            }
            PropertyChanges {
                target: nowPlayingWindow
                visible: false
            }
        },
        State {
            name: "Landscape"
            PropertyChanges {
                target: nowPlayingWindow
                width: parent.width / 2
                visible: true
            }
            PropertyChanges {
                target: stackWindow
                anchors.right: nowPlayingWindow.left
            }
        }
    ]
}
