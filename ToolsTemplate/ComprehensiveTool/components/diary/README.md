# 日记组件快速入门

## 目录
- [简介](#简介)
- [约束和限制](#约束和限制)
- [使用](#使用)
- [示例代码](#示例代码)

## 简介

本组件提供了写日记、编辑日记、删除日记、私密日记等功能。

| 首页                                           | 写日记                                           | 日记详情                                         | 设置私密日记密码                                  | 操作                                             |
| ---------------------------------------------- | ------------------------------------------------ | ------------------------------------------------ | ------------------------------------------------- | ------------------------------------------------ |
| <img src="./screenshot/home.png" width="200" > | <img src="./screenshot/create.png" width="200" > | <img src="./screenshot/detail.png" width="200" > | <img src="./screenshot/privacy.png" width="200" > | <img src="./screenshot/action.png" width="200" > |

本组件工程代码结构如下所示：
```ts
diary/src/main/ets                                // 日记(har)
  |- commons                                      // 模块常量定义   
  |- components                                   // 模块组件
  |- controller                                   // 模块控制器
  |- database                                     // 本地持久化缓存
  |- models                                       // 模型定义
  |- pages                                        // 页面
  |- utils                                        // 模块工具类  
  |- viewmodel                                    // 与页面一一对应的vm层 
```

## 约束和限制
### 环境
- DevEco Studio版本：DevEco Studio 5.0.5 Release及以上
- HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上
- 设备类型：华为手机（包括双折叠和阔折叠）
- HarmonyOS版本：HarmonyOS 5.0.5(17)及以上
### 权限
- 无

## 使用
1. 安装组件。

   如果是在DevEco Studio使用插件集成组件，则无需安装组件，请忽略此步骤。

   如果是从生态市场下载组件，请参考以下步骤安装组件。

   a. 解压下载的组件包，将包中所有文件夹拷贝至您工程根目录的xxx目录下。

   b. 在项目根目录build-profile.json5添加diary模块。
   ```
   "modules": [
      {
         "name": "diary",
         "srcPath": "./xxx/diary",
      },
   ]
   ```
   c. 在项目根目录oh-package.json5中添加依赖
   ```
   "dependencies": {
      "diary": "file:./xxx/diary",
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
            // DiaryPage为日记路由入口页面名称
            this.pageStack.pushPathByName('DiaryPage', null);
         });
      }.hideTitleBar(true);
   }
}
```