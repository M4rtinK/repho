import Qt 4.7
import QtQuick 1.1
import com.nokia.meego 1.0
import com.nokia.extras 1.0

PageStackWindow {
    showStatusBar : options.get("QMLShowStatusBar", false)
    showToolBar : true
    id : rootWindow
    anchors.fill : parent
    initialPage : OverlayView {
                      id : oView
                      }

    property int statusBarHeight : 36

    /* TODO: replace hardcoded value
    with actual status bar height */
    property string oldImageURL: "" // current old image

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

    // handle Mieru shutdown
    function shutdown() {
        oView.shutdown()
    }

    // open dialog with information about how to turn pages
    function openFirstStartDialog() {
        firstStartDialog.open()
    }

    FileSelector {
        id: fileSelector;
        //anchors.fill : rootWindow
        onAccepted: {
            console.log("File selector accepted")
            // reset capture list
            captureList.clear()
            comparisonPage.index = -1

            repho.fileOpened(selectedFile)
            oldImageURL = selectedFile
        }
    }

    /** Overlay menu **/
    OverlayMenu {
        id : overlayMenu
    }

    SideBySideMenu {
      id : pageFitSelectorSbS
    }

    ListModel {
        id : captureList
    }

    ComparisonPage {
        id : comparisonPage
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
        titleText : "How to use repho"
        message : "<b>Open</b> an <b>old image</b>.<br>"
              +"Take a picture <b>of the place on the image</b>.<br>"
              +"Compare the <b>old image</b> with the <b>new one</b>."
        acceptButtonText : "Don't show again"
        rejectButtonText : "OK"
        onAccepted: {
            options.set("QMLShowFirstStartDialog", false)
        }
    }
}