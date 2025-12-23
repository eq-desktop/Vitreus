import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Effects

ShaderEffectSource {
    id: backdropSource
    property int sourceX: 0
    property int sourceY: 0
    property int sourceW: 0
    property int sourceH: 0
    anchors.fill: parent
    sourceRect: Qt.rect(backdropSource.sourceX, backdropSource.sourceY, backdropSource.sourceW, backdropSource.sourceH)
    hideSource: true
    live: true
    visible: false
}