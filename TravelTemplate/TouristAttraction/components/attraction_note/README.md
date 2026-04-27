# 游记组件快速入门

## 目录

- [简介](#简介)
- [约束与限制](#约束与限制)
- [使用](#使用)
- [API参考](#API参考)
- [示例代码](#示例代码)

## 简介

本组件提供景区游记浏览搜索、详情查看、游记评论、推荐线路查看等功能。

<img src="screenshots/discovery.png" width="300">

## 约束与限制
### 环境
* DevEco Studio版本：DevEco Studio 5.0.3 Release及以上
* HarmonyOS SDK版本：HarmonyOS 5.0.3 Release SDK及以上
* 设备类型：华为手机（包括双折叠和阔折叠）
* HarmonyOS版本：HarmonyOS 5.0.3(15)及以上

### 权限
* 获取位置权限：ohos.permission.APPROXIMATELY_LOCATION、ohos.permission.LOCATION、ohos.permission.INTERNET。

## 使用
1. 安装组件。
   如果是在DevEco Studio使用插件集成组件，则无需安装组件，请忽略此步骤。

   如果是从生态市场下载组件，请参考以下步骤安装组件。

   a. 解压下载的组件包，将包中所有文件夹拷贝至您工程根目录的xxx目录下。

   b. 在项目根目录build-profile.json5并添加attraction_note和module_base模块
   ```typescript
   "modules": [
      {
      "name": "attraction_note",
      "srcPath": "./xxx/attraction_note",
      },
      {
         "name": "module_base",
         "srcPath": "./xxx/module_base",
      }
   ]
   ```
   c. 在项目根目录oh-package.json5中添加依赖
   ```typescript
   "dependencies": {
      "attraction_note": "file:./xxx/attraction_note",
      "module_base": "file:./xxx/module_base"
   }
   ```

2. 配置地图相关权限。

   a.在主工程的module.json5文件中配置如下地图相关权限。
   ```
   "requestPermissions": [
      {
        "name": "ohos.permission.LOCATION",
        "reason": "$string:app_name",
        "usedScene": {
          "abilities": [
            "EntryAbility"
          ],
          "when": "inuse"
        }
      },
      {
        "name": "ohos.permission.APPROXIMATELY_LOCATION",
        "reason": "$string:app_name",
        "usedScene": {
          "abilities": [
            "EntryAbility"
          ],
          "when": "inuse"
        }
      }
    ],
   ```

   b.将应用的client ID配置到主工程模块的src/main/module.json5文件，详细参考：[配置Client ID](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/account-client-id)。

3. 引入组件。

   ```typescript
   import { PageGround } from 'attraction_note';
   ```
4. 初始化组件所需的路由栈和经纬度信息

   ```typescript
   @Provider('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();
   private locationInfo: LocationInfo =
            PersistenceV2.connect(LocationInfo, 'locationInfo', () => new LocationInfo())!;

   aboutToAppear(): void {
      this.locationInfo.latitude = 22.92
      this.locationInfo.longitude = 113.86
   }
   ```
5. 在module_base模块的src/main/resources/base/profile目录下的router_map.json文件中配置如下内容：
   ```typescript
   ...
   {
      "name": "Tickets",
      "pageSourceFile": "src/main/ets/pages/Tickets.ets",
      "buildFunction": "TicketsBuilder"
    },
    {
      "name": "AttractionDetail",
      "pageSourceFile": "src/main/ets/pages/AttractionDetail.ets",
      "buildFunction": "AttractionDetailBuilder"
    }
   ...
   ```
   
## API参考

### 接口
PageGround(isShowBack: boolean)

游记组件。

#### 参数说明

| 参数名              | 类型                                | 是否必填 | 说明     |
|:-----------------|:----------------------------------|:-----|:-------|
| isShowBack       | boolean                       | 是    | 是否展示返回 |

## 示例代码

```
import { PersistenceV2 } from '@kit.ArkUI';
import { PageGround } from 'attraction_note';
import { LocationInfo } from 'module_base';

@Entry
@ComponentV2
struct Index {
  @Provider('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();
  private locationInfo: LocationInfo =
    PersistenceV2.connect(LocationInfo, 'locationInfo', () => new LocationInfo())!;

  aboutToAppear(): void {
    this.locationInfo.latitude = 22.92
    this.locationInfo.longitude = 113.86
  }

  build() {
    Navigation(this.mainPathStack) {
      Column() {
        PageGround({
          isShowBack: false,
        })
      }.height('90%')
    }.hideTitleBar(true);
  }
}
```
