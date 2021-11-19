import QtQuick 2.15
import QtQuick.Controls 2.15
import "../resourceElements"

ScrollingListView {
    id: albumPage
    objectName: "albumPage"
    property string quearyString

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
//            artistDelegate.ListView.view.currentIndex=index
            myLogger.log("click for:", actionItem)
            appWindow.requestAlbumSongs(actionItem)
        }

        delegateMouseArea.onPressAndHold: {
            myLogger.log("adding to playlist", actionItem)
            appWindow.updatePlaylist(actionItem, actionCommand, "add")
        }

//        delegateMouseArea.onClicked: {
//            ListView.view.currentIndex=index
//            myLogger.log("click for:", actionItem)
//            mainApp.requestAlbumSongs(actionItem)
//        }

    }

}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
