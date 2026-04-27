# 历史上的今天组件快速入门

## 目录

- [简介](#简介)
- [约束与限制](#约束与限制)
- [快速入门](#快速入门)
- [API参考](#API参考)
- [示例代码](#示例代码)

## 简介

本组件提供查询历史上的今天相关功能，此组件为mock数据,固定展示6月13号的历史上的今天，实际接入请替换成业务接口

<img src="./screenshot/todayHistory_1.png" width="300" />

## 约束与限制

### 环境

- DevEco Studio版本：DevEco Studio 5.0.4 Release及以上
- HarmonyOS SDK版本：HarmonyOS 5.0.4 Release SDK及以上
- 设备类型：华为手机（包括双折叠和阔折叠）
- 系统版本：HarmonyOS 5.0.4(16)及以上

### 权限
* 网络权限：ohos.permission.INTERNET

## 快速入门

1. 安装组件。

   如果是在DevEco Studio使用插件集成组件，则无需安装组件，请忽略此步骤。

   如果是从生态市场下载组件，请参考以下步骤安装组件。

   a. 解压下载的组件包，将包中所有文件夹拷贝至您工程根目录的XXX目录下。

   b. 在项目根目录build-profile.json5添加today_history和base_apis模块。

    ```typescript
    // 在项目根目录build-profile.json5填写today_history和base_apis路径。其中XXX为组件存放的目录名
    "modules": [
        {
        "name": "today_history",
        "srcPath": "./XXX/today_history",
        },
        {
        "name": "base_apis",
        "srcPath": "./XXX/base_apis",
        }
    ]
    ```
   c. 在项目根目录oh-package.json5中添加依赖。
    ```typescript
    // XXX为组件存放的目录名称
    "dependencies": {
      "today_history": "file:./XXX/today_history"
    }
   ```

2. 引入组件。

   ```typescript
   import { TodayHistory } from 'today_history';
   ```

3. 调用组件，详细参数配置说明参见[API参考](#API参考)

   ```typescript
   import { TodayHistory } from 'today_history';
   
   @Entry
   @Component
   struct Index {
     pageInfo: NavPathStack = new NavPathStack()
   
     build() {
       Navigation(this.pageInfo) {
        TodayHistory({
          selectColor: '#c4272b',
          titleColor: '#ffffff',
          routerModule: this.pageInfo,
        })
       }
     }
   }
   ```

## API参考

### 子组件

无

### 接口

TodayHistory(options?: TodayHistoryOptions)

用户信息组件。

**参数：**

| 参数名  | 类型                                                | 必填 | 说明               |
| ------- | --------------------------------------------------- | ---- | ------------------ |
| options | [TodayHistoryOptions](#TodayHistoryOptions对象说明) | 否   | 历史上的今天组件。 |

### TodayHistoryOptions对象说明

| 名称         | 类型         | 必填 | 说明           |
| ------------ | ------------ | ---- | -------------- |
| selectDate   | Date         | 否   | 当前选择的日期 |
| selectColor  | [ResourceStr](https://developer.huawei.com/consumer/cn/doc/harmonyos-references-V14/ts-types-V14#resourcestr)  | 否   | 导航栏颜色     |
| titleColor   | [ResourceStr](https://developer.huawei.com/consumer/cn/doc/harmonyos-references-V14/ts-types-V14#resourcestr)  | 否   | 导航栏标题颜色 |
| routerModule | [NavPathStack](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ts-basic-components-navigation#navpathstack10) | 否   | 路由栈         |

## 示例代码

### 示例1

1. 调用组件

   ```typescript
   import { TodayHistory } from 'today_history';
   
   @Entry
   @Component
   struct Index {
     pageInfo: NavPathStack = new NavPathStack()
   
     build() {
       Navigation(this.pageInfo) {
        TodayHistory({
          selectColor: '#c4272b',
          titleColor: '#ffffff',
          routerModule: this.pageInfo,
        })
       }
     }
   }
   ```

<img src="./screenshot/todayHistory.png" width="300" />