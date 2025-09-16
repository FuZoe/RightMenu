import QtQuick 2.15
import QtQuick.Controls 2.15

ApplicationWindow {
    id: window
    width: 800
    height: 600
    visible: true
    title: "主界面"

    // 主界面内容区域
    Rectangle {
        anchors.fill: parent
        color: "#f0f0f0"

        Text {
            anchors.centerIn: parent
            text: "主界面内容区域"
            font.pixelSize: 24
            color: "#666"
        }
    }

    RightMenu{
        anchors {
            right: parent.right
            top: parent.top // 添加 top 锚点
            bottom: parent.bottom

        }
        mainWindw_wth :window.width
    }
}
