import QtQuick 1.1
import com.nokia.meego 1.0
import QtMobility.gallery 1.1

Page {
    id: galleryPage
    GridView {
        //height : parent.height
        //width: parent.width
        anchors.fill : parent
        //anchors.top : parent.top
        //anchors.bottom : parent.bottom
        //rotation: 270

        maximumFlickVelocity: 3000

        model: model

        cellHeight: 160
        cellWidth: 160

        delegate: Image {
            height: 160
            width: 160
            asynchronous: true
            smooth: true
            source: "file:///home/user/.thumbnails/grid/" + Qt.md5(url) + ".jpeg"
            MouseArea {
                anchors.fill : parent
                onClicked : {
                    console.log("Gallery item selected")
                    console.log(url)
                    rootWindow.openImageFile(url)
                    galleryPage.pageStack.pop()
                }
            }
        }
    }
    DocumentGalleryModel {
        id: model
        rootType: DocumentGallery.Image
        properties: ["url"]
        filter: GalleryWildcardFilter {
            property: "fileName";
            value: "*.jpg";
        }
    }
    tools: ToolBarLayout {
            ToolIcon { iconId: "toolbar-back"
                onClicked: pageStack.pop()
            }
    }
}

