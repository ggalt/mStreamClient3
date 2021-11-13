import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15
import QtQml 2.15
import Qt.labs.settings 1.1
import QtMultimedia 5.15
import "resourceElements"

ApplicationWindow {
    id: appWindow
    objectName: "appWindow"

    visible: true
    width: 800
    height: 480
    title: qsTr("mStreamClient")

    /////////////////////////////////////////////////////////////////////////////////
    /// Visible Items
    /////////////////////////////////////////////////////////////////////////////////

    property bool isPortrait: false // (Screen.primaryOrientation === Qt.PortraitOrientation)
    Screen.orientationUpdateMask:  Qt.LandscapeOrientation | Qt.PortraitOrientation

    Page {
        id: stackWindow
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: isPortrait ? parent.right : nowPlayingWindow.left

        StackView {
            id: stackView
            initialItem: "qrc:/Forms/HomeForm.qml"
            anchors.fill: parent
        }

        Component {
            id: tabButton
            TabButton { }
        }

        footer: TabBar {
            id: tabBar
            currentIndex: 0

            TabButton {
                text: qsTr("Home")
                onClicked: {
                    console.log(stackView.depth)
                }
            }
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

    header: ToolBar {
        id: toolBar
        contentHeight: toolButton.implicitHeight
        property int textPointSize: 20 // mainWindow.getTextPointSize()

        ToolButton {
            id: toolButton
            text: "\u2630"  //: "\u21A9" "\u205D"
            font.pointSize: toolBar.textPointSize

            onClicked: {
                isPortrait = !isPortrait
            }
        }

        ScrollingTextWindow {
            id: _toolBarLabel
            anchors.left: toolButton.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            scrollFontPointSize: toolBar.textPointSize
            scrollText: "mStream Client"
        }
    }



    Drawer {
        id: drawer
        width: appWindow.width * 0.66
        height: appWindow.height

        Column {
            anchors.fill: parent

            ItemDelegate {
                text: qsTr("Page 1")
                width: parent.width
                onClicked: {
                    stackView.push("Page1Form.ui.qml")
                    drawer.close()
                }
            }
            ItemDelegate {
                text: qsTr("Page 2")
                width: parent.width
                onClicked: {
                    stackView.push("Page2Form.ui.qml")
                    drawer.close()
                }
            }
        }
    }

    Screen.onOrientationUpdateMaskChanged: {
        orientationUpdate()
    }

    Component.onCompleted: {
        orientationUpdate()
    }

    /////////////////////////////////////////////////////////////////////////////////
    /// Data Structures
    /////////////////////////////////////////////////////////////////////////////////
    JSONListModel {
        id: artistListJSONModel
        objNm: "name"
    }

    JSONListModel {
        id: albumListJSONModel
    }

    JSONListModel {
        id: songListJSONModel
    }

    JSONListModel {
        id: playListJSONModel
    }

    MusicPlaylist {
        id: _currentPlayList
    }

    Logger {
        id:myLogger
        moduleName: parent.objectName
        debugLevel: appWindow.globalDebugLevel
    }

    /////////////////////////////////////////////////////////////////////////////////
    /// Data Elements
    /////////////////////////////////////////////////////////////////////////////////

    property string myToken: ""
//    property string serverURL: mainWindow.getServerURL()

    property int gettingArtists: 0
    property int gettingAlbums: 0
    property int gettingTitles: 0

    property string currentAlbumArt: ""

    property bool isPlaying: false
    property bool hasPlayListLoaded: false
    property int playlistAddAt: 0

    property int globalDebugLevel: 0        // 0 = critical, 1 = warn, 2 = all

    property var poppedItems: []

    property alias currentPlayList: _currentPlayList
    property alias toolBarLabel: _toolBarLabel

    property string apiVersion: "/api/v1"

    /////////////////////////////////////////////////////////////////////////////////
    /// Functions
    /////////////////////////////////////////////////////////////////////////////////

    function orientationUpdate() {
//        isPortrait = true // (Screen.primaryOrientation === Qt.PortraitOrientation)
        if( Qt.platform.os === "ios" || Qt.platform.os === "android")   {   // mobile platforms, assume full screen
            appWindow.width = Screen.width
            appWindow.height = Screen.height
        } else {
            if( isPortrait ) {
                appWindow.width = 480
                appWindow.height = 800
            } else {
                appWindow.width = 800
                appWindow.height = 480
            }
        }

        nowPlayingWindow.width = isPortrait ? appWindow.width : appWindow.width / 2
        nowPlayingWindow.visible = !isPortrait
        stackWindow.anchors.right = isPortrait ? appWindow.right : nowPlayingWindow.left
    }
}
