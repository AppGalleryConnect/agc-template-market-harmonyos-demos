# 隐私笔记组件快速入门

## 目录
- [简介](#简介)
- [约束和限制](#约束和限制)
- [使用](#使用)
- [示例代码](#示例代码)

## 简介

本组件提供了写笔记、编辑笔记、删除笔记、笔记分类、搜索、多选、排序、分享、复制等功能。

| 首页                                                | 新建笔记                                              | 笔记分类                                               | 分享、复制                                            | 操作                                                   |
| --------------------------------------------------- | ----------------------------------------------------- | ------------------------------------------------------ | ----------------------------------------------------- | ------------------------------------------------------ |
| <img src="./screenshot/note_home.png" width="200" > | <img src="./screenshot/create_note.png" width="200" > | <img src="./screenshot/add_category.png" width="200" > | <img src="./screenshot/note_action.png" width="200" > | <img src="./screenshot/note_operate.png" width="200" > |

本组件工程代码结构如下所示：
```ts
personal_notes/src/main/ets                       // 隐私笔记(har)
  |- commons                                      // 模块常量定义   
  |- components                                   // 模块组件
  |- models                                       // 模型定义  
  |- pages                                        // 页面
  |- utils                                        // 模块工具类
  |- viewmodel                                    // 与页面一一对应的vm层 
  |- controller                                   // 模块控制器 
```

## 约束和限制
### 环境
- DevEco Studio版本：DevEco Studio 5.1.0 Release及以上
- HarmonyOS SDK版本：HarmonyOS 5.1.0 Release SDK及以上
- 设备类型：华为手机（包括双折叠和阔折叠）
- HarmonyOS版本：HarmonyOS 5.1.0(18)及以上
### 权限
- 无

## 使用
1. 安装组件。

   如果是在DevEco Studio使用插件集成组件，则无需安装组件，请忽略此步骤。

   如果是从生态市场下载组件，请参考以下步骤安装组件。

   a. 解压下载的组件包，将包中所有文件夹拷贝至您工程根目录的xxx目录下。

   b. 在项目根目录build-profile.json5添加personal_notes模块。
   ```
   "modules": [
      {
         "name": "personal_notes",
         "srcPath": "./xxx/personal_notes",
      },
   ]
   ```
   c. 在项目根目录oh-package.json5中添加依赖
   ```
   "dependencies": {
      "personal_notes": "file:./xxx/personal_notes",
   }
   ```

## 示例代码

```typescript
@Entry
@ComponentV2
export struct Index {
   @Local pageStack: NavPathStack = new NavPathStack();

   build() {
      Navigation(this.pageStack) {
         Button('跳转').onClick(() => {
            // PersonalNotesPage为隐私笔记路由入口页面名称
            this.pageStack.pushPathByName('PersonalNotesPage', null);
         });
      }.hideTitleBar(true);
   }
}
```