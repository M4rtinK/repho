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

    property bool shutterVisible : false
    property real overlayOpacity : 0.5
    property int overlayRotation : 0
    property bool newIsOld : false

    property int timedCaptureCount : 0
    property int timedCaptureInterval : 10
    property int sElapsed : 0
    property bool timersEnabled : false

    Connections {
        target : platformWindow
        onActiveChanged : {
            camera.visible = platformWindow.active
        }
    }


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

    function startTimedCapture(interval) {
        timedCaptureInterval = interval
        options.set("timedCaptureInterval", interval)
        state = "timedImageCapture"
    }

    function stopTimedCapture() {
        state = "imageCapture"
    }


    Component.onCompleted : {
      restoreRotation()
    }

    state : "noImage"

    states: [
        State {
            name : "noImage"
            StateChangeScript {
                script : {
                    shutterVisible = false
                    imagePreview.visible = false
                    previewMA.visible = false
                    camera.visible = true
                    timersEnabled = false
                    timedB.visible = false
                }
            }
        },
        State {
            name : "imageCapture"
            StateChangeScript {
                script : {
                    shutterVisible = true
                    imagePreview.visible = false
                    previewMA.visible = false
                    camera.visible = true
                    timersEnabled = false
                    timedB.visible = true
                }
            }
        },
        State {
            name : "timedImageCapture"
            StateChangeScript {
                script : {
                    shutterVisible = false
                    imagePreview.visible = false
                    previewMA.visible = false
                    camera.visible = true
                    timersEnabled = true
                    timedB.visible = true
                }
            }
        },
        State {
            name : "imagePreview"
            StateChangeScript {
                script : {
                    shutterVisible = false
                    imagePreview.visible = true
                    previewMA.visible = true
                    camera.visible = false
                    timersEnabled = false
                    timedB.visible = false
                }
            }
        }
    ]

    onStateChanged : {
        console.log(state)
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
        //captureResolution: "1200x675"
        captureResolution: "1152x648"
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
            if (oView.newIsOld || timersEnabled) {
                oldImage.rotation = screen.currentOrientation == 1 ? 90 :0
                oldImageURL = preview
            } else {
                imagePreview.source = preview
                oView.state = "imagePreview"
            }
        }

        onImageSaved : {
            console.log("image saved")
            var storagePath
            if (oView.newIsOld) {
                repho.storeNewAsOld(capturedImagePath)
                oView.newIsOld = false
            } else {
                storagePath = repho.storeImage(capturedImagePath)
                captureList.append({"path":storagePath})
            }
        }
    }


    /** Preview image **/
    Image {
        id : imagePreview
        y: 0
        rotation: screen.currentOrientation == 1 ? 90 :0
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
    }

    /** Image overlay **/

    Image {
        visible : true
        id : oldImage
        rotation : overlayRotation
        anchors.fill : parent
        fillMode : Image.PreserveAspectFit
        source : rootWindow.oldImageURL
        opacity : overlayOpacity
        smooth : true
        sourceSize.width : 854
        sourceSize.height : 480
        onStatusChanged : {
            if (status == Image.Ready) {
                oView.state = "imageCapture"
            } else {
                oView.state = "noImage"
            }
        }
    }

    /** Preview label **/

    Label {
        visible : imagePreview.visible
        text : "<h3>Tap to hide preview</h3>"
        color : "white"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom : oView.bottom
        anchors.bottomMargin : 48
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
        ToolIcon {
            iconId : "toolbar-settings"
            onClicked : { overlayMenu.open() }
        }
        ToolIcon {
            iconId: ""
        }
    }

    /** Main menu **/

    MainMenu {
        id : mainViewMenu
    }

    /** Camera buttons **/
    Button {
        id : shutterL
        width : 160
        height : 100
        visible : shutterVisible && screen.currentOrientation != 1
        anchors.verticalCenter : parent.verticalCenter
        anchors.right : parent.right
        anchors.rightMargin : 16
        opacity : 0.7
        iconSource : "image://theme/icon-m-content-camera"
        onClicked : {
            console.log("shutter pressed")
            camera.captureImage()
        }
    }

    Button {
        id : shutterP
        width : 160
        height : 100
        visible : shutterVisible && screen.currentOrientation == 1
        anchors.horizontalCenter : parent.horizontalCenter
        anchors.bottom : parent.bottom
        anchors.bottomMargin : 16


        opacity : 0.7
        iconSource : "image://theme/icon-m-content-camera"
        onClicked : {
            console.log("shutter pressed")
            camera.captureImage()
        }
    }

    Button {
        id : timedB
        width : 80
        height : 80
        anchors.top : parent.top
        anchors.right : parent.right
        anchors.topMargin : 16
        anchors.rightMargin : 32
        opacity : 0.7
        iconSource : "image://theme/icon-m-common-clock"
        checked : timersEnabled
        onClicked : {
            console.log("timed pressed")
            if (checked) {
                stopTimedCapture()
            } else {
                timingMenu.open()
            }
        }
    }



    MouseArea {
        id : previewMA
        anchors.fill : parent
        onClicked : {
            oView.state = "imageCapture"
        }
    }


    /** No pages loaded label **/

    Label {
        anchors.centerIn : parent
        //text : "<h1>No pages loaded</h1>"
        text : "<h2>No old image loaded</h2>"
        color: "white"
        visible : !oView.newIsOld && oldImage.source == ""
    }


    /** Timed capture label **/

    Label {
        anchors.centerIn : parent
        text : sElapsed == 0 && timedCaptureCount>0 ? "Taking picture" : + (timedCaptureInterval-sElapsed) +" s to next capture"
        color: "white"
        visible : timersEnabled
        font.pixelSize : 32
    }


    /** Capture paused indicator **/
    Rectangle {
        anchors.fill : parent
        visible : !platformWindow.active
        color : "grey"
        Label {
            text : "<h1>Camera paused</h1>"
            color : "white"
            anchors.centerIn : parent
        }

    }

    Timer {
        // update timed capture status
        id : tickTimer
        interval : 1000
        repeat : true
        running : timersEnabled
        onTriggered : {
            var elapsed = sElapsed + 1
            sElapsed = sElapsed + 1
            if (sElapsed == timedCaptureInterval) {
                sElapsed = 0
                timedCaptureCount = timedCaptureCount + 1
                camera.captureImage()
            } else {
                sElapsed = elapsed
            }
        }
    }

    /*
    Timer {
        // capture image in a given interval
        id : captureTimer
        interval : timedCaptureInterval * 1000
        repeat : true
        running : timersEnabled
        onTriggered : {
            sElapsed = 0
            console.log("captureTimer triggered")
        }
    }*/

}