//MainView.qml
//import Qt 4.7
import QtQuick 1.1
import com.nokia.meego 1.0
import com.nokia.extras 1.0
import QtMultimediaKit 1.1

Page {
    id : oView
    //orientationLock: PageOrientation.LockLandscape
    objectName : "oView"
    anchors.fill : parent
    tools : mainViewToolBar
    property real overlayOpacity : 0.5

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
            oView.orientationLock = PageOrientation.Automatic
        } else if ( savedRotation == "portrait" ) {
            oView.orientationLock = PageOrientation.LockPortrait
        } else {
            oView.orientationLock = PageOrientation.LockLandscape
        }
    }

    function showPrevFeedback() {
    // only show with feedback enabled and no feedback in progress
        if (oView.pagingFeedback && !prevFbTimer.running) {
            prevFbTimer.start()
        }
    }

    function showNextFeedback() {
    // only show with feedback enabled and no feedback in progress
        if (oView.pagingFeedback && !nextFbTimer.running) {
            nextFbTimer.start()
        }
    }

    Component.onCompleted : {
      restoreRotation()
    }


    Rectangle {
        anchors.fill : parent
        color : "black"
    }

    Camera {
        id: camera
        //x: 0
        y: 0
        rotation: screen.currentOrientation == 1 ? 90 :0
        //anchors.fill:parent
        captureResolution: "1200x675"
        //captureResolution: "1152x648"
        //captureResolution: "1000x480"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        //width: parent.height // - stillControls.buttonsPanelWidth
        //height: parent.width
        focus: visible //to receive focus and capture key events
        whiteBalanceMode: Camera.WhiteBalanceAuto
        exposureCompensation: -1.0
        state: Camera.ActiveState

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

    /** Image overlay **/

    Image {
        visible : true
        id : oldImage2
        anchors.fill : parent
        fillMode : Image.PreserveAspectFit
        source : rootWindow.oldImageURL
        opacity : overlayOpacity
        smooth : true
        sourceSize.width : 854
        sourceSize.height : 480
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
                     text : oView.pageLoaded ? oView.pageNumber + "/" + oView.maxPageNumber : "-/-"
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
                   onClicked: oView.toggleFullscreen() }
        //ToolIcon { iconSource: "image://icons/view-normal.png"; onClicked: oView.toggleFullscreen() }
        }

    /** Main menu **/

    MainMenu {
        id : mainViewMenu
    }

    /** No pages loaded label **/

    Label {
        anchors.centerIn : parent
        //text : "<h1>No pages loaded</h1>"
        text : "<h2>No old image loaded</h2>"
        color: "white"
        visible : oldImage.source == ""
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