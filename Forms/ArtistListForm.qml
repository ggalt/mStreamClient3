import QtQuick 2.15
import QtQuick.Controls 2.15
import "../resourceElements"

ScrollingListView {
    id: artistPage
    objectName: "artistPage"
    property string quearyString

    formName: "Artist List"
    myModel: artistListJSONModel.model
    highlightLetter: myCurrentItem.myData.name[0]

//    property color delegateBackground: "#80808080"
//    property color delegatePressed: "lightgrey"

    Logger {
        id:myLogger
        moduleName: parent.objectName
        debugLevel: appWindow.globalDebugLevel
    }

    myDelegate: ActionListDelegate {
        id: artistDelegate
        objectName: "artistDelegate"
        property variant myData: model

        delegateBackgroundColor: Style.white
        delegatePressedColor: Style.teal

        height: 42
        width: artistPage.width
        clip: true
        hasImage: false
        actionCommand: "artist"
        actionItem: model.name
        delegateLabel.text: model.name
        textPointSize:  appWindow.getTextPointSize()

        delegateMouseArea.onClicked: {
            artistDelegate.ListView.view.currentIndex=index
            myLogger.log("click for:", actionItem)
            appWindow.requestArtistAlbums(actionItem)
        }

        delegateMouseArea.onPressAndHold: {
            myLogger.log("adding to playlist", actionItem)
        }
    }
}
