//MainMenu
import QtQuick 1.1
import com.nokia.meego 1.0

Menu {
    id : mainViewMenu
    MenuLayout {
        MenuItem {
            text : "Open from file"
            onClicked : {
                console.log("Opening file selector")
                console.log(repho.getSavedFileSelectorPath())
                fileSelector.down(repho.getSavedFileSelectorPath());
                //fileSelector.down("/home/user/MyDocs");
                fileSelector.open();
        }
    }

        MenuItem {
            text : "Open from gallery"
            onClicked : {
                //rootWindow.openFile("HistoryPage.qml")
                }
        }

        MenuItem {
            text : "Open URL"
            onClicked : {
                //rootWindow.openFile("HistoryPage.qml")
                }
        }

        MenuItem {
            text : "Options"
            onClicked : {
                rootWindow.openFile("OptionsPage.qml")
                }
        }

        MenuItem {
            text : "About"
            onClicked : {
                rootWindow.openFile("InfoPage.qml")
            }
        }
    }
}