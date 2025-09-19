QML官方也有实现侧边栏的组件[Drawer（抽屉）](https://doc.qt.io/qt-6/qml-qtquick-controls-drawer.html) 。
<details>
<summary>但它的局限性是它无法同时支持菜单全展开、半展开、收起三个稳定状态。 </summary>
     
官方文档说道：

     position : real
     This property holds the position of the drawer relative to its final destination. That is, the position will be 0.0 when the drawer is fully closed, and 1.0 when fully open.

</details>

想要实现菜单栏的多状态，本项目就是一个很好的例子，使用了原始的实现。

关键代码：

     width: expandedMenuId === 0 ? 0 : (expandMode === 1 ? 200 : mainWindw_wth - rightMenuBar.width)

如果你还是想用Drawer（确实代码量更少），一个二态的Drawer的简单使用示例：


     import QtQuick
     import QtQuick.Controls
     
     ApplicationWindow {
         id: window
         width: 640
         height: 480
         visible: true
     
         Drawer {
             id: drawer
             width: 200
             height: parent.height
             edge: Qt.LeftEdge
             modal: false
     
             Label {
                 text: "我是侧边栏内容"
                 anchors.centerIn: parent
             }
         }
     
         Button {
             text: "打开侧边栏"
             onClicked: drawer.open() // 直接调用 open()
             anchors.centerIn: parent
             anchors.verticalCenterOffset: -30
         }
     
         Button {
             text: "关闭侧边栏"
             onClicked: drawer.close() // 直接调用 close()
             anchors.centerIn: parent
             anchors.verticalCenterOffset: 30
         }
     }
