import QtQuick 1.0
import com.nokia.meego 1.0
import com.nokia.extras 1.0

Menu {
    id : pagingDialog
    MenuLayout {
        //width : pagingDialog.width
        id : mLayout
        Row {
            //anchors.left : mLayout.left
            //anchors.right : mLayout.right
            Slider {
                id : pagingSlider
                width : mLayout.width*0.9
                //anchors.topMargin : height*0.5
                //anchors.left : mLayout.left
                maximumValue: mainView.maxPageNumber
                minimumValue: 1
                value: mainView.pageNumber
                stepSize: 1
                valueIndicatorVisible: false
                //orientation : Qt.Vertical
                onPressedChanged : {
                    //only load the page once the user stopped dragging to save resources
                    mainView.pageNumber = value
                }
            }
            CountBubble {
                //width : mLayout.width*0.2
                //anchors.left : pagingSlider.right
                //anchors.right : mLayout.right
                value : pagingSlider.value
                largeSized : true
            }
        }
        Row {
            id : mButtonRow
            property int usableWidth : mLayout.width - 10
            spacing : 10
            Button {
                text : mainView.pageFitMode
                iconSource : "image://theme/icon-m-common-expand"
                width : mButtonRow.usableWidth/2.0
                onClicked : {
                    pageFitSelector.open()
                }
            }
            Button {
                text : "rotation"
                iconSource : "image://theme/icon-m-common-" + __iconType
                width : mButtonRow.usableWidth/2.0
                property string __iconType: (mainView.orientationLock == PageOrientation.LockPrevious) ? "locked" : "unlocked"

                onClicked: {
                    if (mainView.orientationLock == PageOrientation.LockPrevious) {
                        mainView.orientationLock = PageOrientation.Automatic
                    } else {
                        mainView.orientationLock = PageOrientation.LockPrevious
                    }
                }
            }
            /*
            platformIconId: "icon-m-common-" + __iconType + __inverseString

            property string __inverseString: style.inverted ? "-inverse" : ""
            */

        }
    }
}