//MainMenu
import QtQuick 1.1
import com.nokia.meego 1.0

Menu {
    id : mainViewMenu
    MenuLayout {
        MenuItem {
            text : "Open from gallery"
            onClicked : {
                rootWindow.pageStack.push(galleryPage)
                }
        }
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
            text : "Open from URL"
            onClicked : {
                urlMenu.open()
                }
        }
        MenuItem {
            text : "Capture with camera"
            onClicked : {
                prepareForNewImage()
                oView.state = "imageCapture"
                oView.newIsOld = true

                }
        }

        /**
        MenuItem {
            text : "Options"
            onClicked : {
                rootWindow.openFile("OptionsPage.qml")
                }
        }
        **/

        MenuItem {
            text : "About"
            onClicked : {
                rootWindow.openFile("AboutPage.qml")
            }
        }
    }
}