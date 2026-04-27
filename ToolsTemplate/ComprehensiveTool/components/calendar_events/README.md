# 日程提醒组件快速入门

## 目录

- [简介](#简介)
- [约束与限制](#约束与限制)
- [使用](#使用)
- [API参考](#API参考)
- [示例代码](#示例代码)

## 简介

本组件支持新增以及编辑日历、生日、纪念日、待办，支持将日程添加到系统日历提醒中。

<img src="./screenshot/CalendarEventMain.png">

本组件工程代码结构如下所示：
```ts
calendar_events/src/main/ets                      // 日程提醒(har)
  |- base                                         // 模块基础组件   
  |- constants                                    // 模块常量定义
  |- components                                   // 模块组件  
  |- model                                        // 模型定义
  |- utils                                        // 模块工具类
  |- viewmodel                                    // 与页面一一对应的vm层 
  |- views                                        // 模块页面 
```

## 约束与限制
### 环境

* DevEco Studio版本：DevEco Studio 5.1.0 Release及以上
* HarmonyOS SDK版本：HarmonyOS 5.1.0 Release SDK及以上
* 设备类型：华为手机（包括双折叠和阔折叠）
* HarmonyOS版本：HarmonyOS 5.1.0(18)及以上

### 权限
* 获取日历权限：ohos.permission.WRITE_CALENDAR，ohos.permission.READ_CALENDAR。
* 网络权限：ohos.permission.INTERNET

## 使用

1. 安装组件。

   如果是在DevEco Studio使用插件集成组件，则无需安装组件，请忽略此步骤。

   如果是从生态市场下载组件，请参考以下步骤安装组件。

   a. 解压下载的组件包，将包中所有文件夹拷贝至您工程根目录的XXX目录下。

   b. 在项目根目录build-profile.json5添加calendar_events模块。

    ```typescript
    // 在项目根目录build-profile.json5填写base_calendar。其中XXX为组件存放的目录名
    "modules": [
        {
        "name": "calendar_events",
        "srcPath": "./XXX/calendar_events",
        }
    ]
    ```
   c. 在项目根目录oh-package.json5中添加依赖。
    ```typescript
    // XXX为组件存放的目录名称
    "dependencies": {
      "calendar_events": "file:./XXX/calendar_events"
    }
    ```

2. 引入组件。

   ```typescript
    import { CalendarEventMain } from 'calendar_events';
   ```

3. 调用组件，详细参数配置说明参见[API参考](#API参考)。

   ```typescript
   // 跳转组件

   @Entry
   @Component
   struct Index {
     pageInfo:NavPathStack = new NavPathStack() 
     build() {
       Navigation(this.pageInfo) {
         Button('跳转到日程添加')
          .onClick(() => {
            this.pageInfo.pushPathByName('CalendarEvent', null)
          })
       }
       .hideTitleBar(true)
     }
   }
   ```

## API参考

### 子组件

无

### 接口

CalendarEventMain(options?: CalendarEventMainOptions)

支持新增以及编辑日历、生日、纪念日、待办，支持将日程添加到系统日历提醒中。

**参数：**

| 参数名  | 类型                                                         | 是否必填 | 说明               |
| ------- | ------------------------------------------------------------ | -------- | ------------------ |
| options | [CalendarEventMainOptions](#CalendarEventMainOptions对象说明) | 否       | 日程提醒组件的参数。 |

### CalendarEventMainOptions对象说明

| 名称      | 类型                                                         | 是否必填 | 说明                   |
| --------- | ------------------------------------------------------------ | -------- | ---------------------- |
| pathStack | [NavPathStack](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ts-basic-components-navigation#navpathstack10) | 是       | 传入当前组件所在路由栈 |

### UserEventItem对象说明

| 名称       | 类型                                            | 是否必填 | 说明                       |
| ---------- | ----------------------------------------------- | -------- | -------------------------- |
| id         | string                                          | 是       | 日程提醒ID                 |
| eventType  | [EVENT_TYPE](#EVENT_TYPE对象说明)               | 是       | 日程提醒类型               |
| eventId    | number                                          | 是       | 添加到日历之后生成的ID     |
| content    | string                                          | 是       | 日程提醒内容               |
| date       | [CalendarStartDate](#CalendarStartDate对象说明) | 是       | 开始日期时间、结束日期时间 |
| repeatType | string                                          | 是       | 提醒类型                   |
| remindList | [REMIND_MENU](#REMIND_MENU对象说明)             | 是       | 重复类型                   |
| remarks    | string                                          | 否       | 备注                       |
| isDone     | boolean                                         | 否       | 是否完成                   |

### CalendarStartDate对象说明

| 名称 | 类型   | 是否必填 | 说明 |
| ---- | ------ | -------- | ---- |
| date | Date   | 是       | 日期 |
| time | string | 是       | 时间 |

### EVENT_TYPE枚举说明

| 名称          | 说明   |
| -------------| ------ |
| SCHEDULE       | 日程   |
| BIRTHDAY       | 生日   |
| ANNIVERSARIES  | 纪念日 |
| TODO          | 待办   |

### REMIND_MENU枚举说明

| 名称      | 类型       |
| --------- | ---------- |
| NO_REPEAT | 不重复     |
| DAILY     | 每天       |
| WEEKLY    | 每周       |
| MONTHLY   | 每月       |
| YEARLY    | 每年       |
| HOLIDAY   | 法定工作日 |

### 事件

支持以下事件：

#### onCalendarEventChange

onCalendarEventChange(callback: userEventInfo:[UserEventItem](#UserEventItem对象说明))) => void)

日程提醒添加更新回调，返回添加或者更新的日程信息

#### onCalendarEventDelete

onCalendarEventDelete(callback: userEventInfo:[UserEventItem](#UserEventItem对象说明))) => void)

日程提醒删除回调，返回当前删除的日程信息

## 示例代码

   ```typescript
@Entry
@ComponentV2
struct Index {
   pageInfo: NavPathStack = new NavPathStack()

   build() {
      Navigation(this.pageInfo) {
         Button('跳转到日程添加')
            .onClick(() => {
               this.pageInfo.pushPathByName('CalendarEvent', null)
            })
      }
      .hideTitleBar(true)
   }
}
   ```

<img src="./screenshot/CalendarEventMain_1.png" width="300">