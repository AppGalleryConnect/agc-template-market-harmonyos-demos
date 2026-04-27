# 录音专家组件快速入门

## 目录

- [简介](#简介)
- [约束与限制](#约束与限制)
- [使用](#使用)
- [示例代码](#示例代码)

## 简介

本组件提供了录音、音频格式转换、音频转文字、音频编辑等功能。

<img src="./screenshot/recorder.png" width="300" >

本组件工程代码结构如下所示：
```ts
simple_recorder/src/main/ets                      // 录音专家(har) 
  |- components                                   // 模块组件
  |- model                                        // 模型定义  
  |- pages                                        // 页面
  |- util                                         // 模块类
  |- viewModels                                   // 与页面一一对应的vm层
  |- workers                                      // 工作线程
```

## 约束与限制

### 环境

* DevEco Studio版本：DevEco Studio 5.0.5 Release及以上
* HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上
* 设备类型：华为手机（包括双折叠和阔折叠）
* HarmonyOS版本：HarmonyOS 5.0.5(17)及以上

### 权限

* 麦克风权限：ohos.permission.MICROPHONE

### 调试
* 录音专家的音频转文字功能不能使用模拟器调试，请使用真机调试。

## 使用
1. 安装组件。

   如果是在DevEco Studio使用插件集成组件，则无需安装组件，请忽略此步骤。

   如果是从生态市场下载组件，请参考以下步骤安装组件。

   a. 解压下载的组件包，将包中所有文件夹拷贝至您工程根目录的xxx目录下。

   b. 在项目根目录build-profile.json5添加simple_recorder模块。
   ```
   "modules": [
      {
      "name": "simple_recorder",
      "srcPath": "./xxx/simple_recorder",
      },
   ]
   ```
   c. 在项目根目录oh-package.json5中添加依赖
   ```
   "dependencies": {
      "simple_recorder": "file:./xxx/simple_recorder",
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
            // RecorderHomePage为录音专家路由入口页面名称
            this.pageStack.pushPathByName('RecorderHomePage', null);
         });
      }.hideTitleBar(true)
         .mode(NavigationMode.Stack);
   }
}
```



