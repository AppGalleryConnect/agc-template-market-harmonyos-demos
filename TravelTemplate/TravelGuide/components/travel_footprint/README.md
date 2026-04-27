# 旅行足迹组件快速入门

##  目录

- [简介](#简介)
- [约束与限制](#约束与限制)
- [使用](#使用)
- [API参考](#API参考)
- [示例代码](#示例代码)

##  简介

本组件提供了旅行足迹管理的相关功能，支持足迹地图展示、总里程统计、足迹列表浏览、添加新足迹等能力。组件以地图为核心，结合列表展示的形式呈现用户的旅行轨迹，包括地图上的足迹标记、总行驶里程、足迹详情列表等信息，并提供添加新足迹的入口。

支持足迹地图可视化、总里程统计、足迹列表展示、添加新足迹、地图与列表联动等功能。

<img src='screenshots/travel_footprint.jpg' style='max-height:350px;object-fit:contain'>

## 约束与限制

###  环境

- DevEco Studio版本：DevEco Studio 5.0.5 Release及以上
- Harmony0s SDK版本：Harmony0s 5.0.3(15)Release SDK及以上
- 设备类型：华为手机（包括双折叠和阔折叠）
- 系统版本：HarmonyOS 5.0.3及以上

### 权限

无

## 使用

1. 安装组件。  
   如果是在DevEco Studio使用插件集成组件，则无需安装组件，请忽略此步骤。
   如果是从生态市场下载组件，请参考以下步骤安装组件。  
   a. 解压下载的组件包，将包中所有文件夹拷贝至您工程根目录的xxx目录下。  
   b. 在项目根目录build-profile.json5并添加travel_footprint模块。

   ```
   // 在项目根目录的build-profile.json5填写travel_footprint路径。其中xxx为组件存在的目录名
   "modules": [
     {
       "name": "travel_footprint",
       "srcPath": "./xxx/travel_footprint",
     }
   ]
   ```

   c. 在项目根目录oh-package.json5中添加依赖

   ```
   // xxx为组件存放的目录名称
   "dependencies": {
     "travel_footprint": "file:./xxx/travel_footprint"
   }
   ```

2. 引入组件。

   ```typescript
   import { Footprint, FootPrintItem } from 'travel_footprint';
   ```

3. 调用组件，详细参数配置说明参见[API参考](#API参考)。

   ```typescript
   Footprint({
       footPrints:this.footPrints // 足迹数据
   })
   ```

## API参考

### 接口

#### Footprint

Footprint(options: { footPrints: [FootPrintItem](#FootPrintItem)[] })

旅行足迹主组件，提供足迹地图展示、总里程统计、足迹列表浏览等功能。

**参数：**

| 参数名            | 类型                    | 是否必填 | 说明               |
|------------------|-------------------------|------|------------------|
| footPrints       | [FootPrintItem](#FootPrintItem)[] | 是    | 足迹数据列表         |
| returnClick | () => void | 否 | 返回按钮点击事件回调 |
| addPostClick | () => void | 否 | 添加足迹按钮点击事件回调 |
| jumpPostClick | () => void | 否 | 足迹项详情点击事件回调 |

#### LightMap

LightMap(options: { lightItems: [FootPrintItem](#FootPrintItem)[] })

轻量级地图组件，用于展示足迹地理位置信息。

**参数：**

| 参数名            | 类型                    | 是否必填 | 说明               |
|------------------|-------------------------|------|------------------|
| lightItems       | [FootPrintItem](#FootPrintItem)[] | 是    | 用于在地图上显示的足迹数据列表 |

### 数据类型

#### FootPrintItem

足迹项数据模型，用于描述单个足迹信息。

**属性：**

| 属性名            | 类型                    | 说明               |
|------------------|-------------------------|------------------|
| id | string | 数据唯一标识 |
| city             | string                  | 城市名称            |
| img              | ResourceStr             | 足迹图片资源         |
| year             | string                  | 足迹年份            |

#### FootPrintList

足迹列表数据模型，用于按年份分组展示足迹信息。

**属性：**

| 属性名            | 类型                    | 说明               |
|------------------|-------------------------|------------------|
| year             | string                  | 年份               |
| list             | [FootPrintItem](#FootPrintItem)[] | 该年份下的足迹列表     |

## 示例代码

```
import { Footprint, FootPrintItem } from 'travel_footprint';

@Entry
@ComponentV2
struct Index {
  @Local footPrints: FootPrintItem[] = [
    {
      id: '001',
      year: '2025',
      city: '南京',
      img: $r('app.media.ic_location_nanjing')
    },
    {
      id: '002',
      year: '2025',
      city: '北京',
      img: $r('app.media.ic_location_beijing')
    },
    {
      id: '003',
      year: '2024',
      city: '上海',
      img: $r('app.media.ic_location_shanghai')
    },
    {
      id: '004',
      year: '2024',
      city: '深圳',
      img: $r('app.media.ic_location_shenzhen')
    },
    {
      id: '005',
      year: '2023',
      city: '苏州',
      img: $r('app.media.ic_location_suzhou')
    }
  ]

  build() {
    Column() {
      Footprint({
        footPrints: this.footPrints
      })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Start)
    .linearGradient({
      direction: GradientDirection.Bottom,
      colors: [['#0A0B15', 0.0], ['#1B2C3A', 1.0]]
    })
  }
}
```

