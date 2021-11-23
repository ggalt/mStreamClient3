import QtQuick 2.15
import QtQuick.Controls 2.15
import "../resourceElements"

ScrollingListView {
    id: currentPlaylistForm
    objectName: "currentPlaylistForm"

    property color delegateBackground: "#80808080"
    property color delegatePressed: "lightgrey"

    myHighLight: highlight
    myhighlightRangeMode: ListView.NoHighlightRange

    highlightFollowsCurrentItem: true

    function changeTrackIndex( idx ) {
        currentPlaylistForm.myCurrentIndex = idx
        myLogger.log("New Track number:", idx, "current playlist index:", currentPlaylistForm.myCurrentIndex)
    }

    myModel: currentPlayList.plModel

    Logger {
        id:myLogger
        moduleName: parent.objectName
        debugLevel: appWindow.globalDebugLevel
    }

    myDelegate: ActionListDelegate {
        id: playlistDelegate
        height: 87
        width: currentPlaylistForm.width

        delegateBackgroundColor: Style.white
        delegatePressedColor: Style.teal

        clip: true
        hasImage: true
        delegateLabel.text: model.metadata.track+" - "+model.metadata.title
        delegateImage.source: model.metadata["album-art"]!==null ? appWindow.getServerURL()+"/album-art/"+model.metadata["album-art"]+"?token="+appWindow.getToken() : "../images/music_default2.png"
        textPointSize:  appWindow.getTextPointSize()

        delegateMouseArea.onClicked: {
                        playlistDelegate.ListView.view.currentIndex=index
                        appWindow.currentPlayList.setCurrentTrack(index)
        }

        delegateMouseArea.onPressAndHold: {
            myLogger.log("adding to playlist", actionItem)
        }

    }

    Component {
        id: highlight
        Rectangle {
            id: rectangle
            color: Style.clear
            radius: 10
            border.width: 5
            border.color: Style.darkTeal
            y: currentPlaylistForm.myCurrentItem.y

            Text {
                id: text1
                color: Style.darkTeal
                text: "\u140A"
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                font.pixelSize: 20
                font.weight: Font.Bold
            }

            Behavior on y {
                SpringAnimation {
                    spring: 3
                    damping: 0.2
                }
            }
        }
    }

    Component.onCompleted: {
        currentPlayList.trackChange.connect(changeTrackIndex)
    }
}



