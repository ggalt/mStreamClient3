import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQml 2.15
import Qt.labs.settings 1.1
import QtMultimedia 5.12
import QtQuick.Layouts 1.12
import "../resourceElements"
import "../"

Rectangle {
    id: _settingsForm
    //    property alias userName: appSettings.setUserName
    //    property alias passWord: appSettings.setPassword
    //    property string serverURLandPort: ""
    //    property alias serverURL: appSettings.setServerURL
    //    property alias serverPort: appSettings.setServerPort
    //    property alias mediaVolume: appSettings.setMediaVolume
    //    property alias isSetup: appSettings.setIsSetup

    objectName: "settingsForm"

    property int drawerWidth
    property int drawerHeight

    Logger {
        id:myLogger
        moduleName: parent.objectName
        debugLevel: appWindow.globalDebugLevel
    }

    function updateSettings() {
        //        appSettings.setUseLoginCredentials = loginCredentials
        //        if(loginCredentials.checked) {
        appSettings.setUserName = txtUserName.text
        appSettings.setPassword = txtPassword.text
        //        }
        appSettings.setServerURL = txtServerURL.text
        appSettings.setServerPort = txtPortNumber.text
        getFullURL()
        appSettings.setIsSetup = true
        appSettings.basePointSize = pointSizeSlider.value
        myLogger.log(appSettings.setServerURL, appSettings.setServerPort, appSettings.setUserName, appSettings.setPassword )
        console.log(appSettings.setServerURL, appSettings.setServerPort, appSettings.setUserName, appSettings.setPassword )
        //        mainWindow.setMainWindowState("ListChooserWindow")
    }

    function getFullURL() {
        if(appSettings.setServerURL.substring(0,7) === "http://") {
            appSettings.setFullServerURL = appSettings.setServerURL+":"+appSettings.setServerPort
        } else if(appSettings.setServerURL.substring(0,8) === "https://") {
            appSettings.setFullServerURL = "http://"+appSettings.setServerURL.substring(8, appSettings.setServerURL.length-8)+":"+appSettings.setServerPort
        } else {
            appSettings.setFullServerURL = "http://"+appSettings.setServerURL+":"+appSettings.setServerPort
        }
    }

    function setVolume( currentVol ) {
        mediaVolume = currentVol
    }

    ColumnLayout {
        id: column
        anchors.fill: parent
        anchors.margins: 5

        RowLayout {
            id: row
            Layout.fillWidth: true
            spacing: 20

            Text {
                id: text1
                text: qsTr("mStream Server URL:")
                font.pixelSize: 12
                minimumPixelSize: 0
                minimumPointSize: 20
            }

            TextField {
                id: txtServerURL
                text: qsTr(appSettings.setServerURL)
                font.pixelSize: 12
                placeholderTextColor: "#6f6f6f"
                cursorVisible: true
                background: Rectangle {
                    anchors.fill: parent
                    color: Style.darkGray
                }
            }

        }

        RowLayout {
            id: row1
            Layout.fillWidth: true
            spacing: 20

            Text {
                id: text2
                text: qsTr("Server Port:")
                font.pixelSize: 12
                minimumPixelSize: 0
                minimumPointSize: 20
            }

            TextField {
                id: txtPortNumber
                text: qsTr(appSettings.setServerPort)
                font.pixelSize: 12
                placeholderTextColor: "#6f6f6f"
                cursorVisible: true
                background: Rectangle {
                    anchors.fill: parent
                    color: Style.darkGray
                }
            }
        }

        RowLayout {
            id: row2
            Layout.fillWidth: true
            width: parent.width
            spacing: 20

            Text {
                id: text3
                text: qsTr("Username:")
                font.pixelSize: 12
                minimumPixelSize: 14
                minimumPointSize: 14
            }

            TextField {
                id: txtUserName
                text: qsTr(appSettings.setUserName)
                font.pixelSize: 12
                placeholderTextColor: "#6f6f6f"
                cursorVisible: true
                background: Rectangle {
                    anchors.fill: parent
                    color: Style.darkGray
                }
            }
        }

        RowLayout {
            id: row3
            Layout.fillWidth: true
            spacing: 20

            Text {
                id: text4
                text: qsTr("Password:")
                font.pixelSize: 12
            }

            TextField {
                id: txtPassword
                text: qsTr(appSettings.setPassword)
                font.pixelSize: 12
                placeholderTextColor: "#6f6f6f"
                cursorVisible: true
                background: Rectangle {
                    anchors.fill: parent
                    color: Style.darkGray
                }
            }
        }

        RowLayout {
            id: row4
            Layout.fillWidth: true
            spacing: 20

            Text {
                id: text5
                text: qsTr("Text Size:")
                font.pixelSize: pointSizeSlider.value
            }

            Slider {
                id: pointSizeSlider
                snapMode: Slider.SnapAlways
                stepSize: 1
                to: 30
                from: 5
                value: appSettings.basePointSize
            }

        }

        RowLayout {
            id: row5
            Layout.fillWidth: true
            spacing: 20

            Button {
                id: btnOK
                text: qsTr("Accept")
                onClicked:{
                    updateSettings()
                    drawer.close()
                    appWindow.sendLogin()
                }
            }

            Button {
                id: btnCancel
                text: qsTr("Cancel")
                onClicked: {
                    drawer.close()
                    //                mainWindow.setMainWindowState("ListChooserWindow")
                }

            }
        }
    }

}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}D{i:1}D{i:4}D{i:5}D{i:3}D{i:7}D{i:8}D{i:6}
D{i:10}D{i:11}D{i:9}D{i:13}D{i:14}D{i:12}D{i:16}D{i:17}D{i:15}D{i:19}D{i:20}D{i:18}
D{i:2}
}
##^##*/
