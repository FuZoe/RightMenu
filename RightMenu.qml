import QtQuick 2.15

Item {

    required property int mainWindw_wth

    // 添加背景色 Rectangle，放在最顶部
    Rectangle {
        anchors.fill: parent
        color: "#23272a" // 深青黑色背景
        z: -1
    }
    
    // 菜单数据模型
    ListModel {
        id: menuModel
        ListElement { 
            name: "菜单1" 
            menuId: 1 
        }
        ListElement { 
            name: "菜单2" 
            menuId: 2 
        }
    }
    
    // 菜单1的内容数据模型
    ListModel {
        id: menu1Model
        ListElement { 
            name: "选项一" 
            itemId: 1 
        }
        ListElement { 
            name: "选项二" 
            itemId: 2 
        }
        ListElement { 
            name: "选项三" 
            itemId: 3 
        }
    }
    
    // 菜单2的内容数据模型
    ListModel {
        id: menu2Model
        ListElement { 
            name: "选项1"
            itemId: 1 
        }
        ListElement { 
            name: "选项2"
            itemId: 2 
        }
        ListElement { 
            name: "选项3"
            itemId: 3 
        }
    }
    
    // 当前展开的菜单（0表示都未展开）
    property int expandedMenuId: 0
    // 当前菜单展开状态 (0: 未展开, 1: 半展开, 2: 全展开)
    property int expandMode: 0

    // 菜单选择栏
    Rectangle {
        id: rightMenuBar
        width: 120
        height: parent.height
        anchors.right: rightContent.left
        color: "#34495e"
        z: 10

        Column {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 5

            Text {
                text: "菜单选择"
                color: "white"
                font.pixelSize: 16
                font.bold: true
                padding: 10
            }

            // 分隔线
            Rectangle {
                width: parent.width
                height: 1
                color: "#2c3e50"
            }

            // 使用Repeater动态生成菜单选项
            Repeater {
                model: menuModel
                delegate: Rectangle {
                    width: parent.width
                    height: 40
                    color: menuMouseArea.containsMouse ? "#3498db" :
                           (expandedMenuId === model.menuId ? "#3498db" : "transparent")
                    radius: 3

                    Row {
                        anchors.fill: parent
                        spacing: 5

                        // 展开/收起箭头
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: expandMode === 1 ? "◀" : ""
                            color: "white"
                            font.pixelSize: 12
                            rightPadding: 10
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: model.name
                            color: "white"
                            font.pixelSize: 14
                            leftPadding: 10
                        }

                        // 展开/收起箭头
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: expandMode === 0 ? "" : "▶"
                            color: "white"
                            font.pixelSize: 12
                            rightPadding: 10
                        }
                    }

                    MouseArea {
                        id: menuMouseArea
                        anchors.fill: parent
                        hoverEnabled: true

                        // 单击延迟确认定时器：到期才执行单击逻辑；双击时会被停止
                        Timer {
                            id: clickTimer
                            interval: Qt.styleHints.mouseDoubleClickInterval
                            running: false
                            repeat: false
                            onTriggered: {
                                if (expandedMenuId === model.menuId && expandMode === 1) {
                                    expandedMenuId = 0; // 收起
                                    expandMode = 0;
                                    console.log("触发单击效果：半展开到收起");
                                } else if(expandedMenuId === 0 && expandMode === 0){
                                    expandedMenuId = model.menuId; // 展开
                                    expandMode = 1;
                                    console.log("触发单击效果：收起 到半展开");
                                }
                                else if(expandedMenuId === model.menuId && expandMode === 2){
                                    expandMode = 1;
                                    console.log("触发单击效果：全展开到半展开");
                                }
                                else{ //同步选中菜单
                                    expandedMenuId = model.menuId;
                                    currentMenu = model.menuId;
                                }
                            }
                        }

                        onClicked: { // 单击：仅启动/重启定时器，延迟到期后才真正执行
                            clickTimer.restart();
                        }

                        onDoubleClicked: { // 双击：先取消单击，再执行双击逻辑
                            clickTimer.stop();
                            if (expandedMenuId === model.menuId && expandMode === 2) {
                                console.log("触发双击效果：全展开到收起");
                                expandedMenuId = 0; // 收起
                                expandMode = 0;
                            } else {
                                expandedMenuId = model.menuId; // 展开
                                expandMode = 2;
                                console.log("触发双击效果：收起/半展开到全展开");
                                
                            }
                            currentMenu = model.menuId; // 确定当前选中的子菜单
                        }
                    }
                }
            }
        }
    }

    // 子菜单内容区域（根据选择显示不同子菜单）
    // 只在有菜单展开时显示
    Rectangle {
        id: rightContent
        width: expandedMenuId === 0 ? 0 : (expandMode === 1 ? 200 : mainWindw_wth - rightMenuBar.width)
        height: parent.height
        anchors.right: parent.right
        color: "#2c3e50"
        z: 10
        visible: expandedMenuId !== 0 && expandMode !== 0
        Behavior on width { NumberAnimation { duration: 150 } }

        Column {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 10

            // 菜单标题
            Text {
                text: getMenuTitle(expandedMenuId)
                color: "white"
                font.pixelSize: 18
                font.bold: true
                padding: 15
            }

            // 分隔线
            Rectangle {
                width: parent.width
                height: 1
                color: "#34495e"
            }

            // 子菜单内容区域
            Item {
                width: parent.width
                height: parent.height - 80 // 减去标题和分隔线的高度

                // 菜单1内容（2列网格）
                Grid {
                    id: menuGrid
                    visible: expandedMenuId === 1
                    columns: 2
                    columnSpacing: 10
                    rowSpacing: 10
                    width: parent.width

                    property real itemWidth: (width - columnSpacing) / 2

                    // 使用Repeater动态生成菜单项
                    Repeater {
                        model: menu1Model
                        delegate: Rectangle {
                            width: menuGrid.itemWidth
                            height: 50
                            color: menuItemMouseArea.containsMouse ? "#3498db" :
                                   (currentSelected === model.itemId ? "#3498db" : "transparent")
                            radius: 5

                            Text {
                                anchors.centerIn: parent
                                text: model.name
                                color: "white"
                                font.pixelSize: 14
                            }

                            MouseArea {
                                id: menuItemMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: {
                                    currentSelected = model.itemId
                                    console.log(model.name + "被点击")
                                }
                            }
                        }
                    }
                }

                // 菜单2内容
                Grid {
                    id: menu2Grid
                    visible: expandedMenuId === 2
                    columns: 2
                    columnSpacing: 10
                    rowSpacing: 10
                    width: parent.width

                    property real itemWidth: (width - columnSpacing) / 2

                    // 使用Repeater动态生成菜单项
                    Repeater {
                        model: menu2Model
                        delegate: Rectangle {
                            width: menu2Grid.itemWidth
                            height: 50
                            color: menu2ItemMouseArea.containsMouse ? "#3498db" :
                                   (currentSelected === model.itemId ? "#3498db" : "transparent")
                            radius: 5

                            Text {
                                anchors.centerIn: parent
                                text: model.name
                                color: "white"
                                font.pixelSize: 14
                            }

                            MouseArea {
                                id: menu2ItemMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: {
                                    currentSelected = model.itemId
                                    console.log(model.name + "被点击")
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // 当前选中的子菜单（1或2）
    property int currentMenu: 1

    // 当前选中的子菜单项（1、2、3，0表示未选择）
    property int currentSelected: 0
    
    // 获取子菜单标题的函数
    function getMenuTitle(menuId) {
        for (var i = 0; i < menuModel.count; i++) {
            if (menuModel.get(i).menuId === menuId) {
                return menuModel.get(i).name;
            }
        }
        return "菜单";
    }
}
