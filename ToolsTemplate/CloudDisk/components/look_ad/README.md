# 看广告领奖励组件快速入门

## 目录

- [简介](#简介)
- [约束与限制](#约束与限制)
- [快速入门](#快速入门)
- [API参考](#API参考)
- [示例代码](#示例代码)

## 简介

本组件提供了看广告领奖励的功能，**其中看广告功能暂未对接三方广告位，所展示广告均为调测广告，实际开发中可以做借鉴使用，具体广告位请对接实际业务**。

| 组件控制                                             |
|--------------------------------------------------|
| <img src="./screenshot/LookAd.jpeg" width="300"> |

## 约束与限制

### 软件

* DevEco Studio版本：DevEco Studio 5.0.0 Release及以上
* HarmonyOS SDK版本：HarmonyOS 5.0.0 Release SDK及以上

### 硬件

* 设备类型：华为手机（包括双折叠和阔折叠）
* 系统版本：HarmonyOS 5.0.0(12)及以上

### 调试

- 本组件支持模拟器和真机调试。**模拟器调试时，无法实现广告播放功能**。

## 快速入门

1. 安装组件。

   如果是在DevEco Studio使用插件集成组件，则无需安装组件，请忽略此步骤。

   如果是从生态市场下载组件，请参考以下步骤安装组件。

   a. 解压下载的组件包，将包中所有文件夹拷贝至您工程根目录的XXX目录下。

   b. 在项目根目录build-profile.json5添加look_ad模块。

   ```
    // 在项目根目录build-profile.json5填写look_ad路径。其中XXX为组件存放的目录名
    "modules": [
        {
        "name": "look_ad",
        "srcPath": "./XXX/look_ad",
        }
    ]
   ```
   c. 在项目根目录oh-package.json5中添加依赖。
    ```
    // XXX为组件存放的目录名称
    "dependencies": {
      "look_ad": "file:./XXX/look_ad"
    }
    ```

2. 引入组件。

   ```
   import { LookAD } from 'look_ad';
   ```

3. 调用组件，详细参数配置说明参见[API参考](#API参考)。

   ```
   import { LookAD } from 'look_ad';
   
   @Entry
   @ComponentV2
   struct Index {
   
     build() {
       Column() {
         LookAD({award:"领现金"})
       }
     }
   }
   ```

## API参考

### 子组件

无

### 接口

LookAD(options?: LookADOptions)

看广告领奖励组件

**参数：**

| 参数名     | 类型                                     | 是否必填 | 说明       |
|---------|----------------------------------------|----|----------|
| options | [LookADOptions](#LookADOptions对象说明) | 否  | 看广告领奖励组件 |

### LookADOptions对象说明

| 名称            | 类型                     | 是否必填 | 说明                      |
|:--------------|:-----------------------|----|-------------------------|
| award         | string                 | 否  | 奖励名称                    |
| onLookSuccess | (balance:number)=>void | 否  | 定义回调函数，balance为看广告获得金币数 |

## 示例代码

```
import { LookAD } from 'look_ad';
   
   @Entry
   @ComponentV2
   struct Index {
     bonus: number = 0
   
     build() {
       Column() {
         LookAD({ award: "领现金", onLookSuccess: (balance: number) => this.bonus += balance })
       }
     }
   }
```