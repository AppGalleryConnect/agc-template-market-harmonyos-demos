# 实名认证组件快速入门

## 目录

- [简介](#简介)
- [约束与限制](#约束与限制)
- [使用](#使用)
- [API参考](#API参考)
- [示例代码](#示例代码)

## 简介

本组件提供实名认证的功能。

<img src="screenshots/auth.jpeg" width="300">

## 约束与限制

### 环境

* DevEco Studio版本：DevEco Studio 6.0.2 Release及以上
* HarmonyOS SDK版本：HarmonyOS 6.0.2 Release SDK及以上
* 设备类型：华为手机（包括双折叠和阔折叠）
* 系统版本：HarmonyOS 5.0.5(17) 及以上

### 权限

* 无

## 使用

1. 安装组件。

   如果是在DevEco Studio使用插件集成组件，则无需安装组件，请忽略此步骤。

   如果是从生态市场下载组件，请参考以下步骤安装组件。

   a. 解压下载的组件包，将包中所有文件夹拷贝至您工程根目录的XXX目录下。

   b. 在项目根目录build-profile.json5添加module_auth模块。

    ```
    // 在项目根目录build-profile.json5填写module_auth路径。其中XXX为组件存放的目录名
    "modules": [
        {
        "name": "module_auth",
        "srcPath": "./XXX/module_auth",
        }
    ]
    ```
   c. 在项目根目录oh-package.json5中添加依赖。
    ```
    // XXX为组件存放的目录名称
    "dependencies": {
      "module_auth": "file:./XXX/module_auth"
    }
    ```
   
2. 调用组件。
   ```
   @Entry
   @ComponentV2
   struct SampleAuth {
     stack: NavPathStack = new NavPathStack()
   
     build() {
       Navigation(this.stack) {
         Column() {
           RealNameAuthView({
             pathStack: this.stack,
             confirm: () => {
               // todo 实名认证确认
             }
           })
         }
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

RealNameAuthView(options: RealNameAuthOptions);

实名认证组件

**参数：**

| 参数名  | 类型                                                | 是否必填 | 说明             |
| :------ | :-------------------------------------------------- | :------- | :--------------- |
| options | [RealNameAuthOptions](#RealNameAuthOptions对象说明) | 是       | 实名认证组件参数 |

### RealNameAuthOptions对象说明

| 参数名    | 类型         | 是否必填 | 说明                         |
| :-------- | :----------- | :------- | :--------------------------- |
| pathStack | NavPathStack | 是       | 路由栈对象，用于控制页面跳转 |
| confirm   | () => {}     | 是       | 实名认证确认按钮回调         |

## 示例代码

```
import { RealNameAuthView } from 'module_auth';

@Entry
@ComponentV2
struct Sample {
  stack: NavPathStack = new NavPathStack()

  build() {
    Navigation(this.stack) {
      Column() {
        RealNameAuthView({
          pathStack: this.stack,
          confirm: () => {
            // todo 实名认证确认
          }
        })
      }
    }
    .hideTitleBar(true)
    .mode(NavigationMode.Stack)
  }
}
```
