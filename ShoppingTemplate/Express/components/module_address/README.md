# 地址管理组件快速入门

## 目录

- [简介](#简介)
- [约束与限制](#约束与限制)
- [使用](#使用)
- [API参考](#API参考)
- [示例代码](#示例代码)

## 简介

本组件提供地址添加、编辑等功能。

| 地址列表                                         | 地址编辑                                        |
|----------------------------------------------|---------------------------------------------|
| <img src="screenshots/list.png" width="300"> | <img src="screenshots/add.png" width="300"> |

## 约束与限制

### 环境

* DevEco Studio版本：DevEco Studio 5.0.0 Release及以上
* HarmonyOS SDK版本：HarmonyOS 5.0.0 Release SDK及以上
* 设备类型：华为手机（包括双折叠和阔折叠）
* 系统版本：HarmonyOS 5.0.0(12) 及以上

### 权限

无

## 使用

1. 安装组件。

   如果是在DevEco Studio使用插件集成组件，则无需安装组件，请忽略此步骤。

   如果是从生态市场下载组件，请参考以下步骤安装组件。

   a. 解压下载的组件包，将包中所有文件夹拷贝至您工程根目录的XXX目录下。

   b. 在项目根目录build-profile.json5添加module_address和module_base模块。

    ```
    // 在项目根目录build-profile.json5填写module_address和module_base路径。其中XXX为组件存放的目录名
    "modules": [
        {
        "name": "module_address",
        "srcPath": "./XXX/module_address",
        },
        {
        "name": "module_base",
        "srcPath": "./XXX/module_base",
        }
    ]
    ```
   c. 在项目根目录oh-package.json5中添加依赖。
    ```
    // XXX为组件存放的目录名称
    "dependencies": {
      "module_address": "file:./XXX/module_address"
    }
    ```

2. 引入组件与地址管理组件句柄。

   ```
   import { AddressManage } from 'module_address';
   ```

3. 调用组件，详细参数配置说明参见[API参考](#API参考)。
   ```
   import { AddressManage } from 'module_address';
   
   @Entry
   @ComponentV2
   struct SampleAddress {
     private readonly TAG: string = 'AddressManageDemo';
   
     private navPathStack: NavPathStack = new NavPathStack()
   
     public build(): void {
       Navigation(this.navPathStack) {
         Column() {
           AddressManage({
             navPathStack: this.navPathStack,
             isSelectMode: true,
             onSelect: (address) => {
               console.info(this.TAG, '当前所选地址：' + JSON.stringify(address));
             },
             onBeforeNavigate: () => {
               console.info(this.TAG, '页面跳转');
               return true;
             }
           }) {
             Button('地址管理')
           }
         }
         .width('100%')
         .height('100%')
         .justifyContent(FlexAlign.Center)
       }
       .hideTitleBar(true)
       .mode(NavigationMode.Stack)
     }
   }
   ```

## API参考

### 子组件

无

### 接口

AddressManage(option: AddressManageOptions)

地址管理组件。

**参数：**

| 参数名     | 类型                                                | 是否必填 | 说明           |
|---------|---------------------------------------------------|------|--------------|
| options | [AddressManageOptions](#AddressManageOptions对象说明) | 否    | 配置地址管理组件的参数。 |

### AddressManageOptions对象说明

| 参数名              | 类型                                             | 是否必填 | 说明                    |
|:-----------------|:-----------------------------------------------|:-----|:----------------------|
| navPathStack     | NavPathStack                                   | 是    | Navigation路由栈实例       |
| isSelectMode     | boolean                                        | 否    | 是否开启地址选择模式            |
| onSelect         | (address: [IAddrInfo](#IAddrInfo对象说明)) => void | 否    | 选择地址后的回调              |
| onBeforeNavigate | () => boolean                                  | 否    | 页面跳转前的回调，返回false将取消跳转 |
| route            | string                                         | 否    | 页面跳转的路由               |
| address          | [IAddrInfo](#IAddrInfo对象说明)                    | 否    | 地址编辑数据                |

### IAddrInfo对象说明

表示地址数据的结构体，用于页面组件传入、组件内部管理，或作为网络接口的请求/响应格式。

| 字段名         | 类型      | 是否必填 | 说明                |
|-------------|---------|------|-------------------|
| id          | string  | 是    | 地址唯一标识符           |
| name        | string  | 是    | 姓名                |
| phone       | string  | 是    | 手机号               |
| countryCode | string  | 是    | 国家代码（如 "CN" 表示中国） |
| country     | string  | 是    | 国家名称（如 "中国"）      |
| province    | string  | 是    | 所在省份              |
| city        | string  | 是    | 所在城市              |
| district    | string  | 是    | 所在区/县             |
| street      | string  | 是    | 街道名称（如乡镇、街道）      |
| detail      | string  | 是    | 详细地址（如门牌号、楼栋房间号）  |
| isDefault   | boolean | 是    | 是否为默认地址           |
| createdAt   | number  | 是    | 创建时间戳（毫秒）         |
| updatedAt   | number  | 是    | 更新时间戳（毫秒）         |

## 示例代码

```
import { AddressManage } from 'module_address';

@Entry
@ComponentV2
struct Sample {
  private readonly TAG: string = 'AddressManageDemo';

  private navPathStack: NavPathStack = new NavPathStack()

  public build(): void {
    Navigation(this.navPathStack) {
      Column() {
        AddressManage({
          navPathStack: this.navPathStack,
          isSelectMode: true,
          onSelect: (address) => {
            console.info(this.TAG, '当前所选地址：' + JSON.stringify(address));
          },
          onBeforeNavigate: () => {
            console.info(this.TAG, '页面跳转');
            return true;
          }
        }) {
          Button('地址管理')
        }
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
    }
    .hideTitleBar(true)
    .mode(NavigationMode.Stack)
  }
}
```