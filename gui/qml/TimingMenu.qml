//TimingMenu.qml
import QtQuick 1.0
import com.nokia.meego 1.0
import com.nokia.extras 1.0

Menu {
    id : pagingDialog
    MenuLayout {
        //property int usableWidth : width - 16
        id : mLayout
        Label {
            text: "<b>Timed capture</b>"
        }
        Row {
            id : mButtonRow
            property int usableWidth : mLayout.width - 10
            spacing : 10
            TextField {
                id : seconds
                anchors.left : parent.left
                anchors.right : parent.right
                anchors.leftMargin : 0
                anchors.rightMargin : 0
                font.pointSize : 24
                validator : IntValidator {bottom : 1}
                inputMethodHints: Qt.ImhDigitsOnly
                width : usableWidth/2.0
                text : "10"
            }

            Label {
                text : "seconds"
            }

        }
        Label {
            text : "<b>Image</b>"
        }
        Row  {
            spacing : 10
            Button {
                text: "Cancel"
                width : mLayout.width/2.0
                onClicked : {
                    close()
                }
            }
            Button {
                text: "Start"
                width : mLayout.width/2.0
                enabled : seconds.acceptableInput
                onClicked : {
                    oView.startTimedCapture(parseInt(seconds.text))
                    close()
                }
            }
        }
    }
}