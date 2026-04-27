# 组件基础能力快速入门

## 目录

- [简介](#简介)
- [约束与限制](#约束与限制)
- [快速入门](#快速入门)
- [API参考](#API参考)

## 简介

本组件提供components目录下组件的基础能力集合。

## 约束与限制

### 环境

* DevEco Studio版本：DevEco Studio 5.0.0 Release及以上
* HarmonyOS SDK版本：HarmonyOS 5.0.0 Release SDK及以上
* 设备类型：华为手机（包括双折叠和阔折叠）
* 系统版本：HarmonyOS 5.0.0(12) 及以上

### 权限

* 无

## 快速入门

1. 安装组件。

   如果是在DevEco Studio使用插件集成组件，则无需安装组件，请忽略此步骤。

   如果是从生态市场下载组件，请参考以下步骤安装组件。

   a. 解压下载的组件包，将包中所有文件夹拷贝至您工程根目录的XXX目录下。

   b. 在项目根目录build-profile.json5添加module_base模块。

    ```
    // 在项目根目录build-profile.json5填写module_base路径。其中XXX为组件存放的目录名
    "modules": [
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
      "module_base": "file:./XXX/module_base"
    }
   ```

2. 引入组件与图表组件句柄。

   ```
   import { CommonUtils, PopViewUtils } from 'module_base';
   ```

## API参考

### 公共方法

#### CommonUtil

通用方法类

##### assign

assign(target: Object, ...source: Object[])

对象赋值

##### encryptPhoneNo

encryptPhoneNo(phoneNo: string): string

手机号码中间四位隐藏

##### getAddressesFromLocationName

getAddressesFromLocationName(position: string)

根据地址获取经纬度

##### rand

rand(min: number, max: number): number

随机四位数

##### copyText

copyText(text: string)

剪贴板内容

#### PopViewUtils

基础弹窗类

---

#### ControllerModule

tab控制类

---

#### Logger

日志打印类

---

#### PickerUtil

拉起相册类

---

#### PreferenceUtil

首选项类

---

#### ScanUtil

扫码类

---

#### TelUtil

打电话类

---

#### WindowUtil

窗口工具类

### 公共常量

#### RouterMap枚举说明

| 名称             | 说明     |
|:---------------|:-------|
| ADDRESS_MANAGE | 地址管理页面 |
| EDIT_ADDRESS   | 编辑地址页面 |

#### AppStorageMap枚举说明

| 名称         | 说明    |
|:-----------|:------|
| UI_CONTEXT | UI上下文 |
