# 新闻广告组件快速入门

## 目录

- [简介](#简介)
- [约束与限制](#约束与限制)
- [使用](#使用)
- [API参考](#API参考)
- [示例代码](#示例代码)

## 简介

本组件提供了测试使用的全屏广告和横幅广告的模板，开发者可以根据业务需要添加自己的广告。

| 全屏广告                                          | 横幅广告                                          |
|-----------------------------------------------|-----------------------------------------------|
| <img src="./screenshot/001.jpeg" width="300"> | <img src="./screenshot/002.jpeg" width="300"> |

## 约束与限制

### 环境

- DevEco Studio版本：DevEco Studio 5.0.3 Release及以上
- HarmonyOS SDK版本：HarmonyOS 5.0.3 Release SDK及以上
- 设备类型：华为手机（包括双折叠和阔折叠）、平板
- 系统版本：HarmonyOS 5.0.1(13)及以上

### 权限

- 网络权限：ohos.permission.INTERNET

## 使用

1. 安装组件。

   如果是在DevEco Studio使用插件集成组件，则无需安装组件，请忽略此步骤。

   如果是从生态市场下载组件，请参考以下步骤安装组件。

   a. 解压下载的组件包，将包中所有文件夹拷贝至您工程根目录的XXX目录下。

   b. 在项目根目录build-profile.json5添加module_advertisement模块。
   ```
   // 项目根目录下build-profile.json5填写module_advertisement路径。其中XXX为组件存放的目录名
   "modules": [
     {
       "name": "module_advertisement",
       "srcPath": "./XXX/module_advertisement"
     }
   ]
   ```

   c. 在项目根目录oh-package.json5添加依赖。

   ```
   // XXX为组件存放的目录名称
   "dependencies": {
     "module_advertisement": "file:./XXX/module_advertisement"
   }
   ```

2. 引入广告组件句柄

   ```
   import { AdvertisementComponent } from 'module_advertisement';
   ```
3. 调用组件，详细组件调用参见[示例代码](#示例代码)。

   ``` 
   import { AdvertisementComponent } from 'module_advertisement';

   @Entry
   @Component
   struct Index {
     @State message: string = 'Hello World';
   
     build() {
       RelativeContainer() {
         // 开屏广告
         AdvertisementComponent({
           testAd: 'testd7c5cewoj6',
           adType: 1,
           // 备考隐私协议方法
           skipAd: () => {
           },
         })
       }
       .height('100%')
       .width('50%')
       .margin({ top: 36 })
     }
   }
   ```

## API参考

### 接口

AdvertisementComponent({testAd:string,adType:number})

广告组件。

**参数：**

| 参数名    | 类型     | 是否必填 |              说明               |
|:-------|:-------|:-----|:-----------------------------:|
| testAd | string | 是    |             广告位ID             |
| adType | number | 是    | 广告组件的类型，当前只支持两种：1 开屏广告 8 横幅广告 |

### 事件

支持以下事件：

#### skipAd

skipAd: () => void = () => {}

全屏广告右上角跳过。

## 示例代码
- 开屏广告
   ``` 
   import { AdvertisementComponent } from 'module_advertisement';

   @Entry
   @Component
   struct Index {
     @State message: string = 'Hello World';
   
     build() {
       RelativeContainer() {
         // 开屏广告
         AdvertisementComponent({
           testAd: 'testd7c5cewoj6',
           adType: 1,
           // 备考隐私协议方法
           skipAd: () => {
           },
         })
       }
       .height('100%')
       .width('50%')
       .margin({ top: 36 })  
     }
   }
   ```
- 横幅广告
   ```
   import { AdvertisementComponent } from 'module_advertisement';

   @Entry
   @Component
   struct Index {
     @State message: string = 'Hello World';
   
     build() {
       RelativeContainer() {
         // 横幅广告
         Row() {
           AdvertisementComponent({
             testAd: 'testw6vs28auh3',
             adType: 8,
           })
         }
         .width('100%')
         .height(120)
         .padding({
           left: 16,
           right: 16,
           top: 12,
           bottom: 12
         })
       }
       .height('100%')
       .width('50%')
       .margin({ top: 36 })
     }
   }
   ```
