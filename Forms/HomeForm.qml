import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQml 2.15
import Qt.labs.settings 1.1
import QtMultimedia 5.12
import QtQuick.Layouts 1.12
import "../resourceElements"

Rectangle {
    id: homeForm
    objectName: "homeForm"
    color: "#2f2f2f"

    Logger {
        id:myLogger
        moduleName: parent.objectName
        debugLevel: appWindow.globalDebugLevel
    }


    ColumnLayout {
        id: mainLayout
        anchors.fill: parent
        anchors.margins: 5


        HoverButton {
            id: artistButton

            Layout.alignment: Qt.AlignHCenter

            Layout.fillWidth: true
            Layout.minimumWidth: 100
            Layout.preferredWidth: 150
            Layout.maximumWidth: (parent.width * 6) / 10
            Layout.minimumHeight: (parent.height /4)
            shadowRadius: 8
            shadowVertOffset: 4
            shadowHorzOffset: 4
            labelFont.pointSize: 20
            labelText: "Artists"
            imageSource: "../images/artist_silhouette_640.png"
            onClicked: {
                appWindow.actionClick("Artists")
            }
        }

        HoverButton {
            id: albumButton

            Layout.alignment: Qt.AlignHCenter

            Layout.fillWidth: true
            Layout.minimumWidth: 100
            Layout.preferredWidth: 150
            Layout.maximumWidth: (parent.width * 6) / 10
            Layout.minimumHeight: (parent.height /4)
            shadowRadius: 8
            shadowVertOffset: 4
            shadowHorzOffset: 4
            labelFont.pointSize: 20
            labelText: "Albums"
            imageSource: "../images/turntable-297877_640.png"
            onClicked: {
                appWindow.actionClick("Albums")
            }
        }

        HoverButton {
            id: playlistButton

            Layout.alignment: Qt.AlignHCenter

            Layout.fillWidth: true
            Layout.minimumWidth: 100
            Layout.preferredWidth: 150
            Layout.maximumWidth: (parent.width * 6) / 10
            Layout.minimumHeight: (parent.height /4)
            shadowRadius: 8
            shadowVertOffset: 4
            shadowHorzOffset: 4
            labelFont.pointSize: 20
            labelText: "Playlists"
            imageSource: "../images/music_silhouette_640.png"
            onClicked: {
                appWindow.actionClick("Playlists")
            }
        }

    }
}
