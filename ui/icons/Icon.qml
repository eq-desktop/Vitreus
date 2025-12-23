import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Controls.Fusion
import QtQuick.Effects

Button {
    id: root
    property string iconPath: ""
    property string iconName: ""
    property int _animDuration: 200
    property var _animType: Easing.OutBack
    property real _animOvershoot: 0.5
    property int size: 96
    background: Rectangle {
        color: "transparent"
        width: size
        height: size
    }
    width: size
    height: size
    IconImage {
        id: iconImage
        source: iconPath
        width: root.size - 20
        height: root.size - 20
        anchors.centerIn: parent
        transform: Translate {
            y: iconName != "" ? -10 : 0
            Behavior on y {
                NumberAnimation {
                    duration: _animDuration
                    easing.type: _animType
                    easing.overshoot: _animOvershoot
                }
            }
        }
        smooth: true
        asynchronous: true
        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: "#80000000"   // semi-transparent black
            shadowBlur: 1.0            // how soft the shadow is
            blurEnabled: false
            blurMax: 64                // max blur radius
        }
    }
    Text {
        id: label
        text: iconName
        font.pixelSize: 12
        color: "white"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 2
        elide: Text.ElideRight
        horizontalAlignment: Text.AlignHCenter
        width: parent.width
    }
}