import QtQuick 1.0
import com.nokia.meego 1.0
import com.nokia.extras 1.0

Menu {
    id : pagingDialog
    MenuLayout {

        //width : pagingDialog.width
        id : mLayout
        Label {
            text: "<b>Overlay opacity</b>"
        }
        Row {
            //anchors.left : mLayout.left
            //anchors.right : mLayout.right
            Slider {
                id : overlaySlider
                value : oView.overlayOpacity
                minimumValue: 0.0
                maximumValue: 1.0
                stepSize: 0.01
                valueIndicatorText : Math.round(value*100) + " %"
                valueIndicatorVisible: true
                onValueChanged : {
                    oView.overlayOpacity = value
                }
                /*
                onPressedChanged : {
                    var outputValue
                    //completely transparent items don't receive events
                    if (value == 0) {
                        outputValue = 0.01
                    } else {
                        // round away small fractions
                        // that were created by the assured lowest value
                        outputValue = Math.round(value*100)/100
                    }
                    //update once dragging stops
                    //options.set("QMLFullscreenButtonOpacity", outputValue)
                    oView.overlayOpacity = outputValue
                }*/

            }
        }
        Label {
            text: "<b>Rotation</b>"
        }
        Row {
            id : mButtonRow
            property int usableWidth : mLayout.width - 10
            spacing : 10
            Button {
                id : screenRLock
                text : "screen"
                iconSource : "image://theme/icon-m-common-" + __iconType
                width : mButtonRow.usableWidth/2.0
                property string __iconType: (oView.orientationLock == PageOrientation.LockPrevious) ? "locked" : "unlocked"

                onClicked: {
                    if (oView.orientationLock == PageOrientation.LockPrevious) {
                        oView.orientationLock = PageOrientation.Automatic
                    } else {
                        oView.orientationLock = PageOrientation.LockPrevious
                    }
                }
            }

            Button {
                id : imageRotationB
                text : "image"
                iconSource : "image://theme/icon-m-toolbar-refresh1"
                width : mButtonRow.usableWidth/2.0
                onClicked: {
                    oView.overlayRotation = (oView.overlayRotation+90)%360
                }
            }
        }
        Label {
            text : "<b>Image</b>"
        }
        Row  {
            Button {
                text: "compare"
                width : mLayout.width/2.0
                enabled : captureList.count > 0
                onClicked : {
                    if (comparisonPage.index < 0) {
                        comparisonPage.index = 0
                    }
                    rootWindow.pageStack.push(comparisonPage)
                }
            }
        }
    }
}