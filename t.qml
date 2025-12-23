//@ pragma UseQApplication
//@ pragma Env QT_SCALE_FACTOR=1
//@ pragma IconTheme MacTahoe-dark
import Quickshell
import QtQuick
import QtQuick.Controls
import QtQuick.Window
import QtQuick.Effects
import qs.ui
import qs.ui.icons
import qs.ui.cf
import qs.be.effects

ApplicationWindow {
    id: root
    visible: true
    width: 800
    height: 500
    color: '#211023'
    title: "Vitreus"

    //MouseArea {
    //    id: mouseArea
    //    anchors.fill: parent
    //    hoverEnabled: true
    //    property point prevMousePos: Qt.point(0,0)
    //    onPositionChanged: (mouse) => {
    //        box.x = mouse.x - box.width / 2
    //        box.y = mouse.y - box.height / 2
    //        prevMousePos = mouse
    //    }
    //}

    // Recommended values
    // For w: 200, h: 30
    //     rimStrength: 0.2
    //     lightDir: Qt.point(1, -0.05)
    // For w: 200, h: 200
    //     rimStrength: 1.0
    //     lightDir: Qt.point(1, -0.2)
    Rectangle {
        id: boxContainer
        color: "#211023"
        anchors.fill: parent
        Image {
            anchors.fill: parent
            source: Qt.resolvedUrl(Quickshell.shellDir + "/t.png")
            opacity: 1.0
            fillMode: Image.PreserveAspectFit
            smooth: true
        }
        layer.enabled: true
    }
    Backdrop {
        id: finderSource2
        sourceX: box.x
        sourceY: box.y
        sourceW: box.width
        sourceH: box.height
        sourceItem: boxContainer
        hideSource: true
    }
    Backdrop {
        id: finderSource
        sourceX: container.x
        sourceY: container.y
        sourceW: container.width
        sourceH: container.height
        sourceItem: boxContainer
        hideSource: true
    }
    Rectangle {
        id: container
        width: visual.width
        height: visual.height
        x: container.posX
        y: container.posY
        color: "transparent"

        property int posX: 0
        property int posY: 0

        Behavior on posX {
            SpringAnimation { spring: 4; damping: 0.35; mass: 1 }
        }
        Behavior on posY {
            SpringAnimation { spring: 4; damping: 0.35; mass: 1 }
        }

        GlassBox {
            id: visual
            anchors.centerIn: parent
            width: 150
            height: 150
            radius: 26
            source: finderSource
            color: '#20ffffff'

            Behavior on width {
                SpringAnimation { spring: 6; damping: 0.4 }
            }
            Behavior on height {
                SpringAnimation { spring: 6; damping: 0.4 }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        property point lastPos: Qt.point(0,0)

        onPositionChanged: (mouse) => {
            let dx = mouse.x - lastPos.x
            let dy = mouse.y - lastPos.y

            container.posX = mouse.x
            container.posY = mouse.y
            box.height = mouse.y

            // Stretch effect via width/height
            visual.width = 150 + Math.min(Math.abs(dx) * 3, 100)
            visual.height = 150 + Math.min(Math.abs(dy) * 3, 100)

            lastPos = mouse
        }
    }
    GlassBox {
        id: box
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            topMargin: -50
            leftMargin: -((box.height/parent.height)*50)
            rightMargin: -((box.height/parent.height)*50)
        }
        height: 150
        radius: (1-(box.height/parent.height))*100
        source: finderSource2
        Behavior on x { NumberAnimation { duration: 300; easing.type: Easing.OutBack; easing.overshoot: 3 } }
        Behavior on y { NumberAnimation { duration: 300; easing.type: Easing.OutBack; easing.overshoot: 3 } }
        Behavior on width { NumberAnimation { duration: 300; easing.type: Easing.OutBack; easing.overshoot: 3 } }
        Behavior on height { NumberAnimation { duration: 300; easing.type: Easing.OutBack; easing.overshoot: 3 } }
        rimStrength: 1.0
        glassMaxRefractionDistance: Math.max(10, Math.min(box.height-50, ((1-(box.height/parent.height))*2)*50))
        glassBevel: Math.max(30, Math.min(box.height-50, (1-(box.height/parent.height))*50))
        color: '#00ffffff'
        highlightEnabled: false
        lightDir: Qt.point(1, -0.2)
    }
    // Set height to mouse pos
    //Backdrop {
    //    id: sliderSource
    //    sourceItem: boxContainer
    //    sourceX: slider.x
    //    sourceY: slider.y
    //    sourceW: slider.width
    //    sourceH: slider.height
    //    hideSource: true
    //}
    //CFButton {
    //    id: button
    //    text: "Button"
    //    width: 200
    //    height: 100
    //    primary: true
    //    anchors {
    //        centerIn: parent
    //    }
    //}
    //CFSlider {
    //    id: slider
    //    source: sliderSource
    //    anchors {
    //        horizontalCenter: parent.horizontalCenter
    //        verticalCenter: parent.verticalCenter
    //    }
    //}
}
