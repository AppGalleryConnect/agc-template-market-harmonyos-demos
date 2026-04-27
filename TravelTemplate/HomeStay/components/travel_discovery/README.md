# 游记组件快速入门

## 目录

- [简介](#简介)
- [约束与限制](#约束与限制)
- [使用](#使用)
- [API参考](#API参考)
- [示例代码](#示例代码)

## 简介

本组件提供游记浏览搜索、详情查看及评论等功能。

<img src="screenshots/discovery.jpg" width="300">

## 约束与限制
### 环境
* DevEco Studio版本：DevEco Studio 5.0.1 Release及以上
* HarmonyOS SDK版本：HarmonyOS 5.0.1 Release SDK及以上
* 设备类型：华为手机（直板机）
* HarmonyOS版本：HarmonyOS 5.0.1(13)及以上

### 权限
* 无

## 使用
1. 安装组件。
   如果是在DevEco Studio使用插件集成组件，则无需安装组件，请忽略此步骤。

   如果是从生态市场下载组件，请参考以下步骤安装组件。

   a. 解压下载的组件包，将包中所有文件夹拷贝至您工程根目录的xxx目录下。

   b. 在项目根目录build-profile.json5并添加travel_discovery模块
   ```
   "modules": [
   {
      "name": "travel_discovery",
      "srcPath": "./xxx/travel_discovery",
      }
   ]
   ```
   c. 在项目根目录oh-package.json5中添加依赖
   ```
   "dependencies": {
      "travel_discovery": "file:./xxx/travel_discovery"
   }
   ```

2. 引入组件。

   ```
   import { PageGround } from 'travel_discovery';
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
import { PageGround } from 'travel_discovery';

@Entry
@Component
struct Main {
  build() {
    NavDestination() {
      Column() {
        PageGround({
          isShowBack: false,
        })
      }
    }
  }
}
```
