import QtQuick 1.0
import com.nokia.meego 1.0
import com.nokia.extras 1.0

Page {
    id : comPage

    property int index : 0

    onIndexChanged : {
        console.log(index)
        var path = captureList.get(index).path
        imagePreview.source = path
    }

    /** Preview image **/
    Image {
        id : imagePreview
        y: 0
        rotation: screen.currentOrientation == 1 ? 90 :0
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        //source : (capture.list.count > 0) ? captureList.get(index).path : ""
        onSourceChanged : {
            console.log(source)
        }
    }

    /** Image overlay **/

    Image {
        id : oldImage
        rotation : oView.overlayRotation
        anchors.fill : parent
        fillMode : Image.PreserveAspectFit
        source : rootWindow.oldImageURL
        opacity : oView.overlayOpacity
        smooth : true
        sourceSize.width : 854
        sourceSize.height : 480
    }

    /** Preview label **/

    Label {
        visible : imagePreview.visible
        text : (index+1) + "/" + captureList.count
        color : "white"
        font.pixelSize : 32
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom : oView.bottom
        anchors.bottomMargin : 48
    }

    tools: ToolBarLayout {
        ToolIcon { iconId: "toolbar-back"
            onClicked: pageStack.pop()
        }
        ToolButton {
            iconSource : "image://theme/icon-m-toolbar-previous"
            flat : false
            enabled : index != 0
            onClicked: {
                comPage.index = comPage.index - 1
            }
        }
        ToolButton {
            iconSource : "image://theme/icon-m-toolbar-next"
            flat : false
            enabled : index < (captureList.count-1)
            onClicked: {
                comPage.index = comPage.index + 1
            }
        }
        ToolIcon {
            iconId : "toolbar-settings"
            onClicked : { overlayMenu.open() }
        }
    }
}