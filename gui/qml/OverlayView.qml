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
                }
            }
        }
    ]

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
        onVisibleChanged : {
            console.log("camera visible")
            console.log(visible)
        }



        //captureResolution : "640x480"

        //flashMode: stillControls.flashMode
        //whiteBalanceMode: stillControls.whiteBalance
        //exposureCompensation: stillControls.exposureCompensation

        onImageCaptured : {
            console.log("image captured")
            if (oView.newIsOld) {
                oldImage.source = preview
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

    /** Camera button **/
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

    /** Capture paused indicator **/
    Rectangle {
        anchors.fill : parent
        visible : !platformWindow.active
        color : "grey"
        Label {
            text : "<h1>Paused</h1>"
            color : "white"
            anchors.centerIn : parent
        }

    }
}