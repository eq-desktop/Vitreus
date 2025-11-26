import QtQuick
import Quickshell
import QtQuick.Controls
import QtQuick.Effects
import qs.be.glass

Item {
    id: box

    property color color: "#10ffffff"
    property bool highlightEnabled: true
    property bool transparent: false
    
    property color light: '#40ffffff'
    property var   lightDir: Qt.point(1, -0.2)
    property real  rimSize: 0.8
    property real  rimStrength: 1.0

    // Individual corner radii
    property int radius: 50

    property int animationSpeed: 16
    property int animationSpeed2: 16

    Behavior on color { PropertyAnimation { duration: animationSpeed; easing.type: Easing.InSine } }
    
    GlassRim {
        id: boxContainer
        anchors.fill: parent
        color: box.transparent ? "transparent" : box.color
        radius: box.radius
        glowColor: box.highlightEnabled ? box.light : Qt.rgba(0,0,0,0)
        lightDir: box.lightDir
        glowEdgeBand: box.rimSize
        glowAngWidth: box.rimStrength
    }
}
