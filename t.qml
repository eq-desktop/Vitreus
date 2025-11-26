import Quickshell
import QtQuick
import QtQuick.Controls
import QtQuick.Window
import QtQuick.Effects
import qs.ui

ApplicationWindow {
    id: root
    visible: true
    width: 800
    height: 500
    color: '#211023'
    title: "Vitreus"

    // Recommended values
    // For w: 200, h: 30
    //     rimStrength: 0.2
    //     lightDir: Qt.point(1, -0.05)
    // For w: 200, h: 200
    //     rimStrength: 1.0
    //     lightDir: Qt.point(1, -0.2)
    Box {
        width: 200
        height: 30
        rimStrength: 0.2
        lightDir: Qt.point(1, -0.05)
        anchors.centerIn: parent
    }
}