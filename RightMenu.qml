import QtQuick 2.15

Item {
    id:root
    required property int mainWindw_wth

    // 主题颜色配置
    readonly property var themeColors: {
        // 背景色系列
        "background": {
            "menuBar": "#efefef",           // 菜单选择栏背景
            "content": "#cfcfcf",           // 子菜单内容区背景
            "transparent": "transparent"     // 透明背景
        },
        // 交互色系列
        "interactive": {
            "hover": "#3498db",             // 鼠标悬停色
            "selected": "#3498db",          // 选中状态色
            "active": "#3498db"             // 激活状态色
        },
        // 文本色系列
        "text": {
            "primary": "black",             // 主要文本色
            "secondary": "grey"            // 次要文本色
        },
        // 边框/分隔线色系列
        "border": {
            "light": "black",               // 浅色分隔线
            "dark": "#34495e"               // 深色分隔线
        }
    }

    // 菜单配置数据
    property var menuConfig: [
        {
            menuId: 1,
            name: "菜单1",
            columns: 2,
            itemHeight: 100,
            items: [
                { name: "选项一", itemId: 1 },
                { name: "选项二", itemId: 2 },
                { name: "选项三", itemId: 3 }
            ]
        },
        {
            menuId: 2,
            name: "菜单2",
            columns: 2,
            itemHeight: 50,
            items: [
                { name: "选项1", itemId: 1 },
                { name: "选项2", itemId: 2 },
                { name: "选项3", itemId: 3 }
            ]
        }
    ]

    // 当前展开的菜单（0表示都未展开）
    property int expandedMenuId: 0
    // 当前菜单展开状态 (0: 未展开, 1: 半展开, 2: 全展开)
    property int expandMode: 0
    // 当前选中的子菜单
    property int currentMenu: 1
    // 当前选中的子菜单项
    property int currentSelected: 0

    // 菜单选择栏
    Rectangle {
        id: rightMenuBar
        width: 120
        height: parent.height
        anchors.right: rightContent.left
        color: themeColors.background.menuBar
        z: 10

        Column {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 5

            Text {
                text: "菜单选择"
                color: themeColors.text.primary
                font.pixelSize: 16
                font.bold: true
                padding: 10
            }

            Rectangle {
                width: parent.width
                height: 1
                color: themeColors.border.light
            }

            // 使用可复用的菜单项组件
            Repeater {
                model: menuConfig
                delegate: MenuBarItem {
                    width: parent.width
                    menuData: modelData
                    isExpanded: expandedMenuId === modelData.menuId
                    expandMode: root.expandMode

                    onMenuClicked: {
                        handleMenuClick(modelData.menuId)
                    }

                    onMenuDoubleClicked: {
                        handleMenuDoubleClick(modelData.menuId)
                    }
                }
            }
        }
    }

    // 可复用的菜单栏项组件
    component MenuBarItem: Rectangle {
        property var menuData
        property bool isExpanded: false
        property int expandMode: 0

        signal menuClicked()
        signal menuDoubleClicked()

        height: 40
        color: mouseArea.containsMouse ? themeColors.interactive.hover :
               (isExpanded ? themeColors.interactive.selected : themeColors.background.transparent)
        radius: 3

        Row {
            anchors.fill: parent
            spacing: 5

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: expandMode === 1 ? "◀" : ""
                color: themeColors.text.primary
                font.pixelSize: 12
                rightPadding: 10
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: menuData.name
                color: themeColors.text.primary
                font.pixelSize: 14
                leftPadding: 10
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: expandMode === 0 ? "" : "▶"
                color: themeColors.text.primary
                font.pixelSize: 12
                rightPadding: 10
            }
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true

            Timer {
                id: clickTimer
                interval: Qt.styleHints.mouseDoubleClickInterval
                running: false
                repeat: false
                onTriggered: parent.parent.menuClicked()
            }

            onClicked: clickTimer.restart()
            onDoubleClicked: {
                clickTimer.stop()
                parent.menuDoubleClicked()
            }
        }
    }

    // 子菜单内容区域
    Rectangle {
        id: rightContent
        width: expandedMenuId === 0 ? 0 : (expandMode === 1 ? 200 : mainWindw_wth - rightMenuBar.width)
        height: parent.height
        anchors.right: parent.right
        color: themeColors.background.content
        z: 10
        visible: expandedMenuId !== 0 && expandMode !== 0
        Behavior on width { NumberAnimation { duration: 150 } }

        Column {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 10

            Text {
                text: getCurrentMenuData()?.name || "菜单"
                color: themeColors.text.primary
                font.pixelSize: 18
                font.bold: true
                padding: 15
            }

            Rectangle {
                width: parent.width
                height: 1
                color: themeColors.border.dark
            }

            // 可复用的菜单内容组件
            Item {
                width: parent.width
                height: parent.height - 80

                MenuContent {
                    visible: expandedMenuId !== 0
                    anchors.fill: parent
                    menuData: getCurrentMenuData()
                    currentSelected: root.currentSelected

                    onItemClicked: function(itemId, itemName) { //点击选项触发逻辑
                        root.currentSelected = itemId
                        console.log(itemName + "被点击")
                    }
                }
            }
        }
    }

    // 可复用的菜单内容组件
    component MenuContent: Item {
        id: menuContentRoot
        property var menuData
        property int currentSelected: 0

        signal itemClicked(int itemId, string itemName)

        Grid {
            anchors.fill: parent
            columns: menuData?.columns || 2
            columnSpacing: 10
            rowSpacing: 10

            property real itemWidth: (width - columnSpacing * (columns - 1)) / columns

            Repeater {
                model: menuData?.items || []
                delegate: MenuItem {
                    width: parent.itemWidth
                    height: menuData?.itemHeight || 80
                    itemData: modelData
                    isSelected: currentSelected === modelData.itemId

                    onClicked: {
                        // 信号触发
                        menuContentRoot.itemClicked(modelData.itemId, modelData.name)
                    }
                }
            }
        }
    }

    // 可复用的菜单项组件
    component MenuItem: Rectangle {
        property var itemData
        property bool isSelected: false

        signal clicked()

        color: mouseArea.containsMouse ? themeColors.interactive.hover :
               (isSelected ? themeColors.interactive.selected : themeColors.background.transparent)
        radius: 5

        Text {
            anchors.centerIn: parent
            text: itemData.name
            color: themeColors.text.primary
            font.pixelSize: 14
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: parent.clicked()
        }
    }

    // 工具函数
    function getCurrentMenuData() {
        return menuConfig.find(menu => menu.menuId === expandedMenuId)
    }

    function handleMenuClick(menuId) {
        if (expandedMenuId === menuId && expandMode === 1) {
            expandedMenuId = 0
            expandMode = 0
            console.log("触发单击效果：半展开到收起")
        } else if(expandedMenuId === 0 && expandMode === 0){
            expandedMenuId = menuId
            expandMode = 1
            console.log("触发单击效果：收起到半展开")
        } else if(expandedMenuId === menuId && expandMode === 2){
            expandMode = 1
            console.log("触发单击效果：全展开到半展开")
        } else {
            expandedMenuId = menuId
            currentMenu = menuId
        }
    }

    function handleMenuDoubleClick(menuId) {
        if (expandedMenuId === menuId && expandMode === 2) {
            console.log("触发双击效果：全展开到收起")
            expandedMenuId = 0
            expandMode = 0
        } else {
            expandedMenuId = menuId
            expandMode = 2
            console.log("触发双击效果：收起/半展开到全展开")
        }
        currentMenu = menuId
    }
}