import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15
import QtQml 2.15
import Qt.labs.settings 1.1
import QtMultimedia 5.15
import "../resourceElements"


Item {
    anchors.fill: parent

    property var poppedItems: []

    Page {
        id: stackWindow
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: isPortrait ? parent.right : nowPlayingWindow.left

        SwipeView {
//        StackView {
            id: stackView
            anchors.fill: parent
            currentIndex: tabBar.currentIndex
            onCurrentItemChanged: tabBar.currentIndex = currentIndex
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
        }

        Component {
            id: homeForm
            HomeForm {

            }
        }

        Component.onCompleted: {
            myLogger.log("pushing home form")
            pushForm(homeForm, "Home")
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
        myLogger.log("pushing form:", formName.objectName, tabName)
        myLogger.log("Stack current index:", stackView.currentIndex)
        myLogger.log("Stack current depth:", stackView.count)

        if( stackView.count -1 > stackView.currentIndex) {    // we have tabs to the left, so get rid of them
            myLogger.log("Removing stack view card.", stackView.count, stackView.currentIndex)

            for( var i = stackView.count -1; i > stackView.currentIndex; i-- ) {
                myLogger.log(i, stackView.currentIndex, tabBar.currentIndex)
                stackView.removeItem( stackView.itemAt(i) )
                tabBar.removeItem( tabBar.itemAt(i) )
            }
        }

        var form = formName.createObject(stackView)
        stackView.addItem(form)

        var tabCount = tabBar.count
        var tab = tabButton.createObject(tabBar, { text: tabName, stackIndexValue: tabCount })
        tabBar.addItem(tab)
        tabBar.currentIndex=tabCount
    }

    function tabClicked( tabName, indexValue ) {
        myLogger.log("Tab Clicked:", indexValue, tabName, stackView.count, tabBar.currentIndex)
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

    Logger {
        id:myLogger
        moduleName: parent.objectName
        debugLevel: appWindow.globalDebugLevel
    }


}
