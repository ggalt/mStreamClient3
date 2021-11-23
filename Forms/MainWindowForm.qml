import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15
import QtQml 2.15
import Qt.labs.settings 1.1
import QtMultimedia 5.15
import "../resourceElements"


Item {
    id: localMainWindow
    anchors.fill: parent

    property var nowPlayingForm: _nowPlayingForm
    state: isPortrait ? "Portrait" : "Landscape"

    property var poppedItems: []

    function setFlippedState( newState ) {
        mainFlipable.isFlipped = newState
        if( isPortrait && !mainFlipable.isFlipped) {
            flipTimer.start()
        }
    }

    function restartFlipTimer() {
        if(isPortrait)
            flipTimer.restart()
    }

    Timer {
        id: flipTimer
        interval: 5000
        running: false
        onTriggered: appWindow.setFlipableState(true)   // we want to be "flipped" to the back
    }

    Flipable {
        id: mainFlipable
        objectName: "mainFlipable"
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        width: appWindow.isPortrait ? parent.width : parent.width / 2
        //        anchors.right: appWindow.isPortrait ? parent.right : nowPlayingWindow.left

        property bool isFlipped: false

        front: Page {
            id: stackWindow
            clip: true

            anchors.fill: parent
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
                    onClicked: {
                        appWindow.resetFlipTimer()
                        tabClicked(text, stackIndexValue)
                    }
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

        back: Item {
            id: _flippedNowPlayingForm
            anchors.fill: parent
        }

        transform: Rotation {
            id: rotation
            origin.x: mainFlipable.width/2
            origin.y: mainFlipable.height/2
            axis.x: 0; axis.y: 1; axis.z: 0     // set axis.y to 1 to rotate around y-axis
            angle: 0    // the default angle
        }

        states: State {
            name: "back"
            PropertyChanges { target: rotation; angle: 180 }
            when: mainFlipable.isFlipped && isPortrait && appWindow.isPlaying
        }

        transitions: Transition {
            NumberAnimation { target: rotation; property: "angle"; duration: 1000 }
        }

    }


    Item {
        id: _flatnowPlayingForm
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.left: mainFlipable.right
        visible: !appWindow.isPortrait
        //        width: appWindow.isPortrait ? parent.width : parent.width / 2
    }

    NowPlayingForm {
        id: _nowPlayingForm
        parent: isPortrait ? _flippedNowPlayingForm : _flatnowPlayingForm
        anchors.fill: parent
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
        myLogger.log("window width", stackWindow.width)
    }

    function tabClicked( tabName, indexValue ) {
        myLogger.log("Tab Clicked:", indexValue, tabName, stackView.count, tabBar.currentIndex)
        stackView.currentIndex = indexValue
    }

    function setState( newstate ) {
        state = newstate
    }

    states: [
        State {
            name: "Portrait"
            PropertyChanges {
                target: mainFlipable
                width: parent.width
            }
            PropertyChanges {
                target: _flatnowPlayingForm
                visible: false
            }
            ParentChange {
                target: _nowPlayingForm
                parent: _flippedNowPlayingForm
            }
            PropertyChanges {
                target: mainFlipable
                isFlipped: true
            }
//            PropertyChanges {
//                target: _nowPlayingForm
//                anchors.fill: parent
//            }
        },
        State {
            name: "Landscape"
            PropertyChanges {
                target: mainFlipable
                width: parent.width / 2
            }
            PropertyChanges {
                target: _flatnowPlayingForm
                visible: true
            }
            ParentChange {
                target: _nowPlayingForm
                parent: _flatnowPlayingForm
            }
//            PropertyChanges {
//                target: _nowPlayingForm
//                anchors.fill: parent
//            }
        }
    ]

    Logger {
        id:myLogger
        moduleName: parent.objectName
        debugLevel: appWindow.globalDebugLevel
    }


}
