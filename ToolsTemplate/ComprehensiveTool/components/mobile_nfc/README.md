# 手机NFC组件快速入门

## 目录

- [简介](#简介)
- [约束与限制](#约束与限制)
- [使用](#使用)
- [示例代码](#示例代码)

## 简介

本组件提供门禁卡、公交卡和银行卡的读取和克隆功能。

<img src="./screenshot/nfc.png" width="300" >

本组件工程代码结构如下所示：
```ts
mobile_nfc/src/main/ets                           // 手机NFC(har)
  |- common                                       // 模块常量定义   
  |- components                                   // 模块组件
  |- model                                        // 模型定义  
  |- pages                                        // 页面
  |- db                                           // 模块数据库类
  |- viewmodel                                    // 与页面一一对应的vm层  
```

## 约束与限制

### 环境

* DevEco Studio版本：DevEco Studio 5.0.5 Release及以上
* HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上
* 设备类型：华为手机（包括双折叠和阔折叠）
* HarmonyOS版本：HarmonyOS 5.0.5(17)及以上

### 权限

* NFC权限：ohos.permission.NFC_TAG

### 限制
* 本组件当前仅支持MIFARE Classic类型卡片的读取及克隆

## 使用
1. 安装组件。

   如果是在DevEco Studio使用插件集成组件，则无需安装组件，请忽略此步骤。

   如果是从生态市场下载组件，请参考以下步骤安装组件。

   a. 解压下载的组件包，将包中所有文件夹拷贝至您工程根目录的xxx目录下。

   b. 在项目根目录build-profile.json5添加mobile_nfc模块。
   ```
   "modules": [
      {
      "name": "mobile_nfc",
      "srcPath": "./xxx/mobile_nfc",
      },
   ]
   ```
   c. 在项目根目录oh-package.json5中添加依赖
   ```
   "dependencies": {
      "mobile_nfc": "file:./xxx/mobile_nfc",
   }
   ```
2. 在主工程的EntryAbility.ets文件中onCreate的生命周期函数中初始化数据库和NFC。

```typescript
import { appDB, initNFC } from 'mobile_nfc';

onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
   ...
   appDB.initDb(this.context)
   initNFC(want)
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
            // NfcHome为手机NFC路由入口页面名称
            this.pageStack.pushPathByName('NfcHome', null);
         });
      }.hideTitleBar(true);
   }
}
```



