# 地址卡片组件快速入门

## 目录

- [简介](#简介)
- [约束与限制](#约束与限制)
- [使用](#使用)
- [API参考](#API参考)
- [示例代码](#示例代码)

## 简介

本组件提供以卡片形式展示地址、选择地址的功能。

<img src="screenshots/地址卡片.jpeg" width="300"> 

## 约束与限制

### 环境

* DevEco Studio版本：DevEco Studio 5.0.0 Release及以上
* HarmonyOS SDK版本：HarmonyOS 5.0.0 Release SDK及以上
* 设备类型：华为手机（包括双折叠和阔折叠）
* 系统版本：HarmonyOS 5.0.0(12) 及以上

### 权限

* 无

## 使用

1. 安装组件。

   如果是在DevEco Studio使用插件集成组件，则无需安装组件，请忽略此步骤。

   如果是从生态市场下载组件，请参考以下步骤安装组件。

   a. 解压下载的组件包，将包中所有文件夹拷贝至您工程根目录的XXX目录下。

   b. 在项目根目录build-profile.json5添加module_address_card、module_address和module_base模块。

    ```
    // 在项目根目录build-profile.json5填写module_address_card、module_address和module_base路径。其中XXX为组件存放的目录名
    "modules": [
        {
        "name": "module_address_card",
        "srcPath": "./XXX/module_address_card",
        },
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
      "module_address_card": "file:./XXX/module_address_card",
      "module_base": "file:./XXX/module_base"
    }
    ```

2. 引入组件与地址卡片组件句柄。

   ```
   import { CommonAddress } from 'module_address_card';
   ```

3. 调用组件，详细参数配置说明参见[API参考](#API参考)。
   ```
   import { CommonAddress } from 'module_address_card';
   import { IAddrInfo, OrderType } from 'module_base'
   
   const addressData: IAddrInfo = {
     id: '',
     name: '',
     phone: '',
     countryCode: '',
     country: '',
     province: '',
     city: '',
     district: '',
     street: '',
     detail: '',
     isDefault: false,
     createdAt: 0,
     updatedAt: 0,
   }
   
   @Entry
   @ComponentV2
   struct Sample {
     private navPathStack: NavPathStack = new NavPathStack()
     @Local isEdit: boolean = true
     @Local sendAddress: IAddrInfo = addressData
     @Local getAddress: IAddrInfo = addressData
   
     public build(): void {
       Navigation(this.navPathStack) {
         Column() {
           CommonAddress({
             stack: this.navPathStack,
             isEdit: this.isEdit,
             sendAddress: this.sendAddress,
             getAddress: this.getAddress,
             onSelect: (value) => {
               if (value.type === OrderType.SEND) {
                 this.sendAddress = value.address
               } else {
                 this.getAddress = value.address
               }
             },
             onChange: () => {
               const temp = this.sendAddress
               this.sendAddress = this.getAddress
               this.getAddress = temp
             },
           })
         }
         .width('100%')
         .height('100%')
         .justifyContent(FlexAlign.Center)
         .backgroundColor('#F1F3F5')
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

CommonAddress(option: CommonAddressOptions)

地址卡片组件。

**参数：**

| 参数名     | 类型                                                | 是否必填 | 说明           |
|---------|---------------------------------------------------|------|--------------|
| options | [CommonAddressOptions](#CommonAddressOptions对象说明) | 是    | 配置地址卡片组件的参数。 |

### CommonAddressOptions对象说明

| 参数名          | 类型                          | 是否必填 | 说明              |
|:-------------|:----------------------------|:-----|:----------------|
| navPathStack | NavPathStack                | 是    | Navigation路由栈实例 |
| isEdit       | boolean                     | 否    | 是否开启编辑模式        |
| sendAddress  | [IAddrInfo](#IAddrInfo对象说明) | 否    | 寄件地址数据          |
| getAddress   | [IAddrInfo](#IAddrInfo对象说明) | 否    | 收件地址数据          |

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

### IAddressParam对象说明

| 字段名     | 类型                          | 是否必填 | 说明   |
|---------|-----------------------------|------|------|
| type    | [OrderType](#OrderType常量说明) | 是    | 地址类型 |
| address | [IAddrInfo](#IAddrInfo对象说明) | 是    | 地址数据 |

### OrderType常量说明

| 字段名     | 说明  |
|---------|-----|
| ALL     | 全部  |
| SEND    | 寄快递 |
| RECEIVE | 收快递 |

### onSelect事件说明

| 参数名   | 类型            | 是否必填 | 说明    |
|:------|:--------------|:-----|:------|
| value | IAddressParam | 是    | 选中的地址 |

### onChange事件说明

自定义交换寄件地址和收件地址

## 示例代码

```
import { CommonAddress } from 'module_address_card';
import { IAddrInfo, OrderType } from 'module_base'

const addressData: IAddrInfo = {
  id: '',
  name: '',
  phone: '',
  countryCode: '',
  country: '',
  province: '',
  city: '',
  district: '',
  street: '',
  detail: '',
  isDefault: false,
  createdAt: 0,
  updatedAt: 0,
}

@Entry
@ComponentV2
struct Sample {
  private navPathStack: NavPathStack = new NavPathStack()
  @Local isEdit: boolean = true
  @Local sendAddress: IAddrInfo = addressData
  @Local getAddress: IAddrInfo = addressData

  public build(): void {
    Navigation(this.navPathStack) {
      Column() {
        CommonAddress({
          stack: this.navPathStack,
          isEdit: this.isEdit,
          sendAddress: this.sendAddress,
          getAddress: this.getAddress,
          onSelect: (value) => {
            if (value.type === OrderType.SEND) {
              this.sendAddress = value.address
            } else {
              this.getAddress = value.address
            }
          },
          onChange: () => {
            const temp = this.sendAddress
            this.sendAddress = this.getAddress
            this.getAddress = temp
          },
        })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .backgroundColor('#F1F3F5')
    }
    .hideTitleBar(true)
    .mode(NavigationMode.Stack)
  }
}
```