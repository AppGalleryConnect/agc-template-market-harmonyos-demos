# 热量计算组件快速入门

## 目录

- [简介](#简介)
- [约束与限制](#约束与限制)
- [使用](#使用)
- [示例代码](#示例代码)

## 简介

本组件提供了按日和按周根据摄入计算热量的功能。

<img src="./screenshot/calories.png" width="300" >

本组件工程代码结构如下所示：
```ts
calories_calculate/src/main/ets                   // 热量计算(har)
  |- common                                       // 公共路由
  |- apis                                         // 模块接口
  |- components                                   // 模块组件
  |- pages                                        // 页面      
  |- mocks                                        // mock数据
  |- model                                        // 模型定义
  |- viewmodel                                    // 与页面一一对应的vm层
  └- utils                                        // 模块工具类
```

## 约束与限制

### 环境

* DevEco Studio版本：DevEco Studio 5.0.5 Release及以上
* HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上
* 设备类型：华为手机（包括双折叠和阔折叠）
* HarmonyOS版本：HarmonyOS 5.0.5(17)及以上

### 权限

* 无

## 使用
1. 安装组件。

   如果是在DevEco Studio使用插件集成组件，则无需安装组件，请忽略此步骤。

   如果是从生态市场下载组件，请参考以下步骤安装组件。

   a. 解压下载的组件包，将包中所有文件夹拷贝至您工程根目录的xxx目录下。

   b. 在项目根目录build-profile.json5添加calories_calculate模块。
   ```
   "modules": [
      {
      "name": "calories_calculate",
      "srcPath": "./xxx/calories_calculate",
      },
   ]
   ```
   c. 在项目根目录oh-package.json5中添加依赖
   ```
   "dependencies": {
      "calories_calculate": "file:./xxx/calories_calculate",
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
            // CaloriesPage为热量计算路由入口页面名称
            this.pageStack.pushPathByName('CaloriesPage', null);
         });
      }.hideTitleBar(true);
   }
}
```



