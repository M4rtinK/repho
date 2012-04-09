//MainView.qml
//import Qt 4.7
import QtQuick 1.1
import com.nokia.meego 1.0
import com.nokia.extras 1.0
import QtMultimediaKit 1.1

Page {
    id : mainView
    objectName : "mainView"
    anchors.fill : parent
    tools : mainViewToolBar

    // workaround for calling python properties causing segfaults
    function shutdown() {
        //console.log("main view shutting down")
    }

    function notify(text) {
        // send notifications
        notification.text = text;
        notification.show();
    }

    function toggleFullscreen() {
        /* handle fullscreen button hiding,
        it should be only visible with no toolbar */
        fullscreenButton.visible = !fullscreenButton.visible
        rootWindow.showToolBar = !rootWindow.showToolBar;
        options.set("QMLToolbarState", rootWindow.showToolBar)
    }

    // restore possible saved rotation lock value
    function restoreRotation() {
        var savedRotation = options.get("QMLmainViewRotation", "auto")
        if ( savedRotation == "auto" ) {
            mainView.orientationLock = PageOrientation.Automatic
        } else if ( savedRotation == "portrait" ) {
            mainView.orientationLock = PageOrientation.LockPortrait
        } else {
            mainView.orientationLock = PageOrientation.LockLandscape
        }
    }

    function showPrevFeedback() {
    // only show with feedback enabled and no feedback in progress
        if (mainView.pagingFeedback && !prevFbTimer.running) {
            prevFbTimer.start()
        }
    }

    function showNextFeedback() {
    // only show with feedback enabled and no feedback in progress
        if (mainView.pagingFeedback && !nextFbTimer.running) {
            nextFbTimer.start()
        }
    }

    Component.onCompleted : {
      restoreRotation()
    }

    Camera {
        id: camera
        x: 0
        y: 0
        width: parent.width // - stillControls.buttonsPanelWidth
        height: parent.height
        focus: visible //to receive focus and capture key events
        //captureResolution : "640x480"

        //flashMode: stillControls.flashMode
        //whiteBalanceMode: stillControls.whiteBalance
        //exposureCompensation: stillControls.exposureCompensation

        onImageCaptured : {
            console.log("image captured")
            console.log(preview)
            //photoPreview.source = preview
            //stillControls.previewAvailable = true
            //cameraUI.state = "PhotoPreview"
        }
    }

    /** Toolbar **/

    ToolBarLayout {
        id : mainViewToolBar
        visible: false
        ToolIcon {
            id : backTI
            iconId: "toolbar-view-menu"
            onClicked: {
                if (platform.showQuitButton()) {
                    mainViewMenuWithQuit.open()
                } else {
                    mainViewMenu.open()
                }
            }
        }
        //ToolIcon { iconId: "toolbar-previous" }
        ToolButton { id : pageNumbers
                     text : mainView.pageLoaded ? mainView.pageNumber + "/" + mainView.maxPageNumber : "-/-"
                     anchors.top : backTI.top
                     anchors.bottom : backTI.bottom
                     flat : true
                     onClicked : { pagingDialog.open() }
        }
        //ToolIcon { iconId: "toolbar-next" }
        ToolIcon { //iconId: "toolbar-down"
                   // fix for incomplete theme on Fremantle
                   iconId: platform.incompleteTheme() ?
                   "icon-m-common-next" : "toolbar-down"
                   rotation : platform.incompleteTheme() ? 90 : 0
                   onClicked: mainView.toggleFullscreen() }
        //ToolIcon { iconSource: "image://icons/view-normal.png"; onClicked: mainView.toggleFullscreen() }
        }

    /** Main menu **/

    Menu {
        id : mainViewMenu
        MenuLayout {
            MenuItem {
              text : "Open from file"
              onClicked : {
                  //fileSelector.down(readingState.getSavedFileSelectorPath());
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

    Menu {
        id : mainViewMenuWithQuit
        MenuLayout {
            MenuItem {
              text : "Open file"
              onClicked : {
                  fileSelector.down(readingState.getSavedFileSelectorPath());
                  fileSelector.open();
            }
        }

            MenuItem {
                text : "History"
                onClicked : {
                    rootWindow.openFile("HistoryPage.qml")
                    }
            }

            MenuItem {
                text : "Info"
                onClicked : {
                    rootWindow.openFile("InfoPage.qml")
                }
            }

            MenuItem {
                text : "Options"
                onClicked : {
                    rootWindow.openFile("OptionsPage.qml")
                    }
            }

            MenuItem {
                text : "Quit"
                onClicked : {
                    readingState.quit()
                    }
            }
        }
    }

    /** No pages loaded label **/

    Label {
        anchors.centerIn : parent
        text : "<h1>No pages loaded</h1>"
        visible : !mainView.pageLoaded
    }

    /** Paging feedback **/

    Item {
        id : previousFeedback
        visible : false
        opacity : 0.7
        anchors.verticalCenter : parent.verticalCenter
        anchors.left : parent.left
        anchors.leftMargin : 20
        Image {
            id : previousIcon
            anchors.left : parent.left
            source : "image://theme/icon-m-toolbar-previous"
        }
        /* Text {
            //text : "<b>PREVIOUS</b>"
            anchors.left : previousIcon.right
            anchors.leftMargin : 20
            anchors.verticalCenter : previousIcon.verticalCenter
            style : Text.Outline
            styleColor : "white"
            font.pixelSize : 25
        } */
    }
    Item {
        id : nextFeedback
        visible : false
        opacity : 0.7
        anchors.verticalCenter : parent.verticalCenter
        anchors.right : parent.right
        anchors.rightMargin : 20
        Image {
            id : nextIcon
            anchors.right : parent.right
            source : "image://theme/icon-m-toolbar-next"
        }
        /* Text {
            //text : "<b>NEXT</b>"
            anchors.right : nextIcon.left
            anchors.rightMargin : 20
            anchors.verticalCenter : nextIcon.verticalCenter
            style : Text.Outline
            styleColor : "white"
            font.pixelSize : 25
            //color : "white"
        } */
    }

    Timer {
        id : prevFbTimer
        interval : 500
        // we need to show and hide the feedback
        triggeredOnStart : true
        onTriggered : {
            previousFeedback.visible = !previousFeedback.visible
        }
    }
    Timer {
        id : nextFbTimer
        interval : 500
        // we need to show and hide the feedback
        triggeredOnStart : true
        onTriggered : {
            nextFeedback.visible = !nextFeedback.visible
        }
    }
}