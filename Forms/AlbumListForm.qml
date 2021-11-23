import QtQuick 2.15
import QtQuick.Controls 2.15
import "../resourceElements"

ScrollingListView {
    id: albumPage
    objectName: "albumPage"
    property string quearyString
    property bool pressedAndHeld: false

    formName: "Album List"
    myModel: albumListJSONModel.model
    highlightLetter: myCurrentItem.myData.name[0]
    clip: false

    Logger {
        id:myLogger
        moduleName: parent.objectName
        debugLevel: appWindow.globalDebugLevel
    }

    myDelegate: ActionListDelegate {
        id: albumDelegate
        objectName: "albumDelegate"
        property variant myData: model

        delegateBackgroundColor: Style.white
        delegatePressedColor: Style.teal

        height: 87
        width: albumPage.width
        clip: true
        hasImage: true
        actionCommand: "album"
        actionItem: model.name
        delegateLabel.text: model.name
        delegateImage.source: appWindow.getServerURL()+"/album-art/"+model.album_art_file+"?token="+appWindow.getToken()
        textPointSize:  appWindow.getTextPointSize()

        delegateMouseArea.onClicked: {
            myLogger.log("click for:", actionItem)
            appWindow.requestAlbumSongs(actionItem)
        }

        delegateMouseArea.onPressAndHold: {
            myLogger.log("adding to playlist", actionItem)
            pressedAndHeld = true
        }

        delegateMouseArea.onReleased: {
            if( pressedAndHeld ) {
                pressedAndHeld = false
                myLogger.log("pressedAndHeld is now:", pressedAndHeld )
                if(mouse.button === Qt.RightButton) {
                    appWindow.updatePlaylist(actionItem, actionCommand, "replace")
                } else {
                    appWindow.updatePlaylist(actionItem, actionCommand, "add")
                }
            }
        }
    }

}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
