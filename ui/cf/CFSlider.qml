import Quickshell
import qs.ui
import qs.be.effects
import QtQuick
import QtQuick.Controls

Slider {
    id: slider
    background: bg
    property var source: null
    Backdrop {
        id: sourceBg
        sourceItem: slider.source
        hideSource: true
        visible: true
        anchors.fill: parent
        Rectangle {
            id: bg
            x: slider.leftPadding
            y: slider.topPadding + slider.availableHeight / 2 - height / 2
            implicitWidth: 200
            implicitHeight: 6
            width: slider.availableWidth
            height: implicitHeight
            radius: 10
            color: "#30000000"

            Rectangle {
                width: slider.visualPosition * parent.width
                height: parent.height
                color: "#fff"
                radius: 10
            }
        }
    }
    property alias handleXP: handleBox.x
    property alias handleYP: handleBox.y
    property alias handleW: handleBox.width
    property alias handleH: handleBox.height
    handle: handleBox
    GlassBox {
        Backdrop {
            id: handleBg
            sourceItem: slider.source
            sourceX: slider.handleXP
            sourceY: slider.handleYP
            sourceW: slider.handleW
            sourceH: slider.handleH
            hideSource: true
            visible: true
        }
        id: handleBox
        source: handleBg
        x: slider.leftPadding + Math.min(slider.availableWidth - width, Math.max(0, (slider.visualPosition * (slider.availableWidth - (width)))))
        y: slider.topPadding + slider.availableHeight / 2 - height / 2
        width:  slider.pressed ? 40 : 30
        height: slider.pressed ? 25 : 15
        glassBevel: 15
        glassMaxRefractionDistance: 10
        Behavior on width { PropertyAnimation { duration: 200; easing.type: Easing.OutBack; easing.overshoot: 2 } }
        Behavior on height { PropertyAnimation { duration: 200; easing.type: Easing.OutBack; easing.overshoot: 2 } }
        color: slider.pressed ? "#20ffffff" : "#ffffff"
        light: slider.pressed ? "#fff" : "transparent"
        radius: 99
        rimStrength: slider.pressed ? 1 : 0.8
    }
    from: 0
    to: 1
    stepSize: 1 / 100.0
}