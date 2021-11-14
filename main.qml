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

    Item {
        id: uiWindow
        anchors.fill: parent
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
    function sendLogin() {
        var xmlhttp = new XMLHttpRequest();
        var url = serverURL+apiVersion+"/auth/login";
        myLogger.log("URL:", url)
        xmlhttp.open("POST", url, true);

        xmlhttp.setRequestHeader("Content-Type", "application/json;charset=UTF-8");
        xmlhttp.setRequestHeader("datatype", "json");

        var jsString = JSON.stringify({ username: mainWindow.getUserName(), password: mainWindow.getPassWord() })
        myLogger.log("LOGIN STRING:", jsString)

        xmlhttp.send(jsString);

        xmlhttp.onreadystatechange = function() { // Call a function when the state changes.
            myLogger.log("XMLHTTP readyState and status are:", xmlhttp.readyState, xmlhttp.status)
            myLogger.log("XML RESPONSE TEXT:", xmlhttp.responseText)
            if (xmlhttp.readyState === 4) {
                if (xmlhttp.status === 200) {
                    myLogger.log("ResponseText:", xmlhttp.responseText)
                    var resp = JSON.parse(xmlhttp.responseText)
                    myToken = resp.token
                } else {
                    // manage failure to login
                    myLogger.log("error: " + xmlhttp.status)
                    loginFailureDialog.visible = true
                }
            }
        }
    }

    /// serverCall: Generic function to call the mStream server
    function serverCall(reqPath, JSONval, callType, callback) {
        var xmlhttp = new XMLHttpRequest();
        var url = serverURL+apiVersion+reqPath;
        myLogger.log("Request info:", callType, url, JSONval);
        xmlhttp.open(callType, url, true);
        xmlhttp.setRequestHeader("Content-Type", "application/json;charset=UTF-8");
        xmlhttp.setRequestHeader("datatype", "json");

        if( myToken !== '' ) {
            xmlhttp.setRequestHeader("x-access-token", myToken)
        }

        if(callback !== '') {
            xmlhttp.onreadystatechange = function(){
                if(xmlhttp.readyState === 4) {
                    if(xmlhttp.status === 200) {
                        myLogger.log("callback called")
                        callback(xmlhttp);
                    } else {
                        myLogger.log("error: " + xmlhttp.status)
                    }
                }
            };
        }

        if(JSONval !== '') {
            xmlhttp.send(JSONval);
        } else {
            xmlhttp.send()
        }
    }

    function requestArtists() {
        serverCall("/db/artists", '', "GET", artistsRequestResp)
    }

    function requestAlbums() {
        serverCall("/db/albums", '', "GET", albumRequestResp)
    }

    function requestArtistAlbums(artistName) {
        myLogger.log("Requesting albums for:", artistName)
        serverCall("/db/artists-albums", JSON.stringify({ 'artist' : artistName }), "POST", albumRequestResp)
    }

    function requestAlbumSongs(albumName) {
        myLogger.log("Requesting songs for album:", albumName)
        serverCall("/db/album-songs", JSON.stringify({ 'album' : albumName }), "POST", songRequestResp)
    }

    function requestPlaylists() {
        serverCall("/playlist/getall", '', "GET", playListRequestResp)
    }

    function requestPlayListSongs(playlistName) {
        serverCall("/playlist/load", JSON.stringify({ 'playlistname' : playlistName }), "POST", playlistSongListRequestResponse)
    }

    function artistsRequestResp(xmlhttp) {
        myLogger.log("artistRequestResp:", xmlhttp.responseText)
        artistListJSONModel.json = xmlhttp.responseText
        artistListJSONModel.query = "$.artists[*]"
        stackView.push("qrc:/Forms/ArtistListForm.qml")
        
        //        mainWindow.setMainWindowState("NowPlaying")
        //        mainWindow.listStackView.push( "qrc:/Forms/ArtistListForm.qml" )
    }

    function albumRequestResp(xmlhttp) {
        myLogger.log("albumRequestResp:", xmlhttp.responseText.substring(1,5000))
        albumListJSONModel.json = xmlhttp.responseText
        albumListJSONModel.query = "$.albums[*]"
        //        mainWindow.setMainWindowState("NowPlaying")
        //        mainWindow.listStackView.push( "qrc:/Forms/AlbumListForm.qml" )
    }

    function playListRequestResp(xmlhttp) {
        myLogger.log("playListRequestResp:", xmlhttp.responseText.substring(1,5000))
        playListJSONModel.json = xmlhttp.responseText
        //        playListJSONModel.query = "$.albums[*]"
        //        mainWindow.setMainWindowState("NowPlaying")
        //        mainWindow.listStackView.push( "qrc:/Forms/PlayListForm.qml" )
    }

    function playlistSongListRequestResponse(xmlhttp) {
        myLogger.log("playlistSongListRequestResponse:", xmlhttp.responseText.substring(1,5000))
    }

    function songRequestResp(xmlhttp) {
        songListJSONModel.json = xmlhttp.responseText
        //        mainWindow.listStackView.push( "qrc:/Forms/SongListForm.qml" )
    }

    function actionClick(action) {
        // if we have moved back up the stack, clear the list
        appWindow.poppedItems = []

        if(action === "Artists") {
            myLogger.log("Artist Click")
            requestArtists();
        } else if (action === "Albums") {
            myLogger.log("Album Click")
            requestAlbums();
        } else if (action === "Playlists") {
            myLogger.log("Playlist Click")
            requestPlaylists();
        }
    }

    function updatePlaylist(m_item, typeOfItem, action) { // m_item needs to be the name of an artist, album, playlist or song
        myLogger.log("Update Playlist", m_item, typeOfItem, action)
        if(action === "replace") {
            _currentPlayList.clearPlayList()
            myLogger.log("_currentPlayList.count:", _currentPlayList.count)
            myLogger.log("playlist:", _currentPlayList.json)
            //            playlistAddAt = 0
        }

        if(typeOfItem === "artist") {
            playlistAddArtist(m_item)
        } else if( typeOfItem === "album") {
            playlistAddAlbum(m_item)
        } else if( typeOfItem === "playlist") {
            playlistAddPlaylist(m_item)
        } else if( typeOfItem === "song") {
            myLogger.log("Song object item:", m_item)
            var songObject = JSON.parse(m_item)
            _currentPlayList.addSong(songObject)
        } else {
            playlistAddSong(m_item)
        }
    }

    function loadToPlaylist() {
        if( gettingArtists <= 0 && gettingAlbums <= 0 && gettingTitles <= 0) {
            myLogger.log("loading playlist whch has length of:", _currentPlayList.count)
            isPlaying = true
            mainWindow.listStackView.push("qrc:/Forms/CurrentPlayListForm.qml")
            mainWindow.nowPlayingForm.mediaPlayer.startPlaylist()
        }
    }

    function playlistAddSong(songObj) {   // this actually adds the songs to our playlist
        myLogger.log("playlistAddAt =", playlistAddAt)
        songObj.playListPosition = playlistAddAt++      // add the playListPosition role
        if(songObj.metadata["album-art"] === null) {
            myLogger.log("NULL IMAGE")
        }
        _currentPlayList.addSong(songObj)
        gettingTitles--;
        loadToPlaylist();
    }

    function playlistAddAlbum(title) {  // add songs from album
        myLogger.log("album get count:", gettingAlbums)
        gettingAlbums++;
        serverCall("/db/album-songs", JSON.stringify({ 'album' : title }), "POST", playlistAddAlbumResp)
    }

    function playlistAddArtist(title) { // add albums from artist
        gettingArtists++;
        serverCall("/db/artists-albums", JSON.stringify({ 'artist' : title }), "POST", playlistAddArtistResp)
    }

    function playlistAddPlaylist(title) {

    }

    function playlistAddAlbumResp(resp) {
        var albumResp = JSON.parse(resp.responseText) // for some reason, our delegate doesn't like 'album-art'
        myLogger.log("###albumResponse", resp.responseText)
        for( var i = 0; i < albumResp.length; i++ ) {
            gettingTitles++;
            if( albumResp[i].metadata["album-art"] === null ) {
                if(albumListJSONModel.count > 0) {
                    albumResp[i].metadata["album-art"] = albumListJSONModel.returnObjectContaining("name",albumResp[i].metadata["album"])["album_art_file"]
                }
            }
            playlistAddSong(albumResp[i])
        }
        gettingAlbums--;
        loadToPlaylist()
    }

    function playlistAddArtistResp(resp) {
        var artistResp = JSON.parse(resp.responseText)

        for( var i = 0; i < artistResp.albums.length; i++) {
            playlistAddAlbum(artistResp.albums[i].name)
        }
        gettingArtists--;
        loadToPlaylist()
    }

    function selectSongAtIndex(idx) {
        _currentPlayList.setMusicPlaylistIndex(idx)
        nowPlaying.startPlay()
    }

    function setGlobalVolume(vol) {
        //        mainWindow.mediaVolume = vol
    }

    /////////////////////////////////////////////////////////////////////////////////
    /// States
    /////////////////////////////////////////////////////////////////////////////////

}
