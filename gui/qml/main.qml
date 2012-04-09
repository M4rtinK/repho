import Qt 4.7
import QtQuick 1.1
import com.nokia.meego 1.0
import com.nokia.extras 1.0
import QtMultimediaKit 1.1
import QtMobility.location 1.1

PageStackWindow {
    showStatusBar : options.get("QMLShowStatusBar", false)
    showToolBar : true
    id : rootWindow
    anchors.fill : parent
    /*
    initialPage : MainView {
                      id : mainView
                      }
    */
    Rectangle {
        id:           backgroundRectangle
        anchors.fill: parent
        color:        "black"

        Camera {
                id: camera
                y: 0
                width: parent.width
                anchors.horizontalCenter: parent.horizontalCenter
                captureResolution: "1152x648"
                focus: visible
                whiteBalanceMode: Camera.WhiteBalanceAuto
                exposureCompensation: -1.0
                //state: (status == PageStatus.Active) ? Camera.ActiveState : Camera.LoadedState
                state: Camera.ActiveState
        }


    }

    Component.onCompleted : {
        console.log("main component completed")
        //camera.start()
    }

    /*
    PositionSource {
            id: gpsSource
            active: true
            updateInterval: 1000
            onPositionChanged: {
                console.log("RePho position changed")
            }
    }*/

    property int statusBarHeight : 36
    /* TODO: replace hardcoded value
    with actual status bar height */

    // ** Open a page and push it in the stack
    function openFile(file) {
        // Create the Qt component based on the file/qml page to load.
        var component = Qt.createComponent(file)
        // If the page is ready to be managed it is pushed onto the stack
        if (component.status == Component.Ready)
            pageStack.push(component);
        else
            console.log("Error loading: " + component.errorString());
    }

    // handle Repho shutdown
    function shutdown() {
        mainView.shutdown()
    }

    // open dialog with information about how to turn pages
    function openFirstStartDialog() {
        firstStartDialog.open()
    }

    FileSelector {
      id: fileSelector;
      //anchors.fill : rootWindow
      onAccepted: readingState.openManga(selectedFile);
    }

    OverlayMenu {
      id : ageFitSelectorOverlay
    }

    SideBySideMenu {
      id : pageFitSelectorSbS
    }


    // ** trigger notifications
    function notify(text) {
        notification.text = text;
        notification.show();
    }

    InfoBanner {
        id: notification
        timerShowTime : 5000
        height : rootWindow.height/5.0
        // prevent overlapping with status bar
        y : rootWindow.showStatusBar ? rootWindow.statusBarHeight + 8 : 8

    }

    QueryDialog {
        id : firstStartDialog
        icon : "image://icons/repho.svg"
        titleText : "How to turn pages"
        message : "Tap the <b>right half</b> of the screen to go to the <b>next page</b>.<br><br>"
              +" Tap the <b>left half</b> to go to the <b>previous page</b>."
        acceptButtonText : "Don't show again"
        rejectButtonText : "OK"
        onAccepted: {
            options.set("QMLShowFirstStartDialog", false)
        }
    }
}