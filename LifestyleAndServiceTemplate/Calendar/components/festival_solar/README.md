# 节日节气组件快速入门

## 目录

- [简介](#简介)
- [约束与限制](#约束与限制)
- [快速入门](#快速入门)
- [API参考](#API参考)
- [示例代码](#示例代码)

## 简介

本组件提供了节日、节气展示的相关功能。

<img src="./screenshot/FestivalSolar.png" width="300">

## 约束与限制

### 环境

- DevEco Studio版本：DevEco Studio 5.0.4 Release及以上
- HarmonyOS SDK版本：HarmonyOS 5.0.4 Release SDK及以上
- 设备类型：华为手机（包括双折叠和阔折叠）
- 系统版本：HarmonyOS 5.0.4(16)及以上

## 快速入门

1. 安装组件。

   如果是在DevEco Studio使用插件集成组件，则无需安装组件，请忽略此步骤。

   如果是从生态市场下载组件，请参考以下步骤安装组件。

   a. 解压下载的组件包，将包中所有文件夹拷贝至您工程根目录的XXX目录下。

   b. 在项目根目录build-profile.json5添加festival_solar和base_apis模块。

    ```typescript
    // 在项目根目录build-profile.json5填写festival_solar和base_apis路径。其中XXX为组件存放的目录名
    "modules": [
        {
        "name": "festival_solar",
        "srcPath": "./XXX/festival_solar",
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
      "festival_solar": "file:./XXX/festival_solar"
    }
   ```

2. 引入组件。

   ```typescript
   import { FestivalSolar } from 'festival_solar';
   ```

3. 调用组件，详细参数配置说明参见[API参考](#API参考)。

```typescript
   import { FestivalSolar } from 'festival_solar';
   
   @Entry
   @Component
   struct Index {
     build() {
       Column() {
         FestivalSolar({
           selectedDate: new Date(),
         });
       }
     }
   }
   
```

## API参考

### 接口

FestivalSolar(options?: FestivalSolarOptions)

节日节气展示组件。

**参数：**

| 参数名  | 类型                                                  | 必填 | 说明                     |
| ------- | ----------------------------------------------------- | ---- | ------------------------ |
| options | [FestivalSolarOptions](#FestivalSolarOptions对象说明) | 否   | 节日节气展示组件的参数。 |

### FestivalSolarOptions对象说明

| 名称         | 类型 | 必填 | 说明     |
| ------------ | ---- | ---- | -------- |
| selectedDate | Date | 是   | 当前日期 |

### 事件

支持以下事件：

#### onFestivalCardClick

onFestivalCardClick(callback: (festivalInfo: [HolidayInfo](#HolidayInfo对象说明)) => void)

公众节日卡片事件，返回节日信息

#### onSolarCardClick

onFestivalCardClick(callback: (solarInfo: [SolarInfo](#SolarInfo对象说明)) => void)

节气卡片事件，返回节日信息

#### onHolidayCardClick

onFestivalCardClick(callback: (festivalInfo: [HolidayInfo](#HolidayInfo对象说明)) => void)

公众假日卡片事件，返回节日信息

### HolidayInfo对象说明

| 名称        | 类型     | 必填 | 说明               |
| ----------- | -------- | ---- | ------------------ |
| solarDate   | string   | 是   | 阳历日期           |
| lunarDate   | string   | 是   | 农历日期           |
| holidayName | string[] | 是   | 假期名称集合       |
| daysUntil   | number   | 是   | 距离今天还剩多少天 |
| month       | string   | 是   | 月                 |
| day         | string   | 是   | 日                 |

### SolarInfo对象说明

| 名称      | 类型   | 必填 | 说明       |
| --------- | ------ | ---- | ---------- |
| solarDate | string | 是   | 阳历日期   |
| lunarDate | string | 是   | 农历日期   |
| solarTerm | string | 是   | 节气名称 |

## 示例代码

### 示例1

本示例通过selectedDate实现不同节假日信息展示。

```typescript
   import { FestivalSolar } from 'festival_solar';
   
   @Entry
   @Component
   struct Index {
     build() {
       Column() {
         FestivalSolar({
           selectedDate: new Date(),
         });
       }
     }
   }
   
```

<img src="./screenshot/FestivalSolar_3.png" width="300">