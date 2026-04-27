# 罗盘组件快速入门

## 目录

- [简介](#简介)
- [约束与限制](#约束与限制)
- [使用](#使用)
- [示例代码](#示例代码)

## 简介

提供了罗盘方向的指引功能。

<img src="./screenshot/Screenshot_1.jpeg" width="300" >

本组件工程代码结构如下所示：
```ts
compass/src/main/ets                              // 罗盘(har)
  |- common                                       // 公共常量
  |- components                                   // 模块组件
  |- controller                                   // 罗盘控制类
  |- model                                        // 模型定义
  |- pages                                        // 页面      
  └- utils                                        // 模块工具类
```

## 约束与限制

### 环境

* DevEco Studio版本：DevEco Studio 5.0.5 Release及以上
* HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上
* 设备类型：华为手机（包括双折叠和阔折叠）
* 系统版本：HarmonyOS 5.0.5(17)及以上

## 使用
1. 安装组件。

   如果是在DevEco Studio使用插件集成组件，则无需安装组件，请忽略此步骤。

   如果是从生态市场下载组件，请参考以下步骤安装组件。

   a. 解压下载的组件包，将包中所有文件夹拷贝至您工程根目录的xxx目录下。

   b. 在项目根目录build-profile.json5添加compass模块。
   ```
   "modules": [
      {
      "name": "compass",
      "srcPath": "./xxx/compass",
      },
   ]
   ```
   c. 在项目根目录oh-package.json5中添加依赖
   ```
   "dependencies": {
      "compass": "file:./xxx/compass",
   }
   ```

2. 在主工程的EntryAbility.ets文件中onBackground的生命周期函数中释放传感器资源。

   ```typescript
   import { sensor } from '@kit.SensorServiceKit';
   
   onBackground(): void {
      ...
      sensor.off(sensor.SensorId.ORIENTATION);
      ...
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
            // CompassPage为罗盘路由入口页面名称
            this.pageStack.pushPathByName('CompassPage', null);
         });
      }.hideTitleBar(true);
   }
}
```



