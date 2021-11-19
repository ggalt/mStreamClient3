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
//        actionCommand: "album"
//        actionItem: model.name
        delegateLabel.text: model.metadata.track+" - "+model.metadata.title
        delegateImage.source: model.metadata["album-art"]!==null ? appWindow.getServerURL()+"/album-art/"+model.metadata["album-art"]+"?token="+appWindow.getToken() : "../images/music_default2.png"
        textPointSize:  appWindow.getTextPointSize()

        delegateMouseArea.onClicked: {
                        playlistDelegate.ListView.view.currentIndex=index
                        appWindow.currentPlayList.setCurrentTrack(index)
        }

        delegateMouseArea.onPressAndHold: {
            myLogger.log("adding to playlist", actionItem)
//            appWindow.updatePlaylist(actionItem, actionCommand, "add")
        }

//        onClicked: {
//            playlistDelegate.ListView.view.currentIndex=index
//            appWindow.currentPlayList.setCurrentTrack(index)
//            myLogger.log("click for:", listDelegateRect.delegateLabel.text)
//        }

//        swipe.right: Label {
//            id: removeLabel
//            text: qsTr("Remove Track")
//            color: "white"
//            verticalAlignment: Label.AlignVCenter
//            padding: 12
//            height: parent.height
//            anchors.right: parent.right

//        }
    }

    Component {
        id: highlight
        Rectangle {
            gradient: Gradient {
                GradientStop {
                    position: 0
                    color: "#4d808000"
                }

                GradientStop {
                    position: 0.5
                    color: "#66ffff00"
                }

                GradientStop {
                    position: 1
                    color: "#4d808000"
                }
            }
            border.width: 2
            border.color: "yellow"
            y: currentPlaylistForm.myCurrentItem.y
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



