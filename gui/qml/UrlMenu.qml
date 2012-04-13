import QtQuick 1.0
import com.nokia.meego 1.0
import com.nokia.extras 1.0

Menu {
    id : pagingDialog
    MenuLayout {
        //width : pagingDialog.width
        id : mLayout
        property int usableWidth : width - 16
        TextField {
            id : urlField
            anchors.left : parent.left
            anchors.right : parent.right
            anchors.leftMargin : 0
            anchors.rightMargin : 0
            font.pointSize : 24
            //width : usableWidth*0.75
            text : ""
        }
        Row {
            anchors.top : urlField.bottom
            anchors.topMargin : 16
            id : mButtonRow
            property int usableWidth : mLayout.width - 10
            spacing : 10
            Button {
                id : screenRLock
                text : "Paste"
                iconSource : "image://theme/icon-m-toolbar-cut-paste"
                width : mButtonRow.usableWidth/2.0

                onClicked: {
                    urlField.paste()
                }
            }

            Button {
                id : imageRotationB
                text : "Done"
                enabled : urlField.text != ""
                iconSource : "image://theme/icon-m-toolbar-done"
                width : mButtonRow.usableWidth/2.0
                onClicked: {
                    openUrl(urlField.text)
                }
            }
        }
    }
}