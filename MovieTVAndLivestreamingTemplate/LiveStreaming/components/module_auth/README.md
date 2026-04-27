# 实名认证组件快速入门

## 目录

- [简介](#简介)
- [约束与限制](#约束与限制)
- [快速入门](#快速入门)
- [API参考](#API参考)
- [示例代码](#示例代码)

## 简介

本组件提供实名认证的功能。

<img src="screenshots/auth.png" width="300">

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

   b. 在项目根目录build-profile.json5添加module_auth和module_base模块。

    ```
    // 在项目根目录build-profile.json5填写module_auth和module_base路径。其中XXX为组件存放的目录名
    "modules": [
        {
        "name": "module_auth",
        "srcPath": "./XXX/module_auth",
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
      "module_auth": "file:./XXX/module_auth"
    }
    ```

2. 调用组件。
   ```
   @Entry
   @ComponentV2
   struct Sample {
     stack: NavPathStack = new NavPathStack()
   
     build() {
       Navigation(this.stack) {
         Column({ space: 10 }) {
           Text('实名认证').fontSize(20).fontWeight(FontWeight.Bold)
           Button('go').width('100%').onClick(() => {
             this.stack.pushPath({
               name: 'RealNameAuthPage',
             })
           })
         }
         .padding(10)
       }
       .hideTitleBar(true)
     }
   }
   ```

## API参考

### 子组件
无
### 接口

由于本组件内流程闭环，以页面的方式注册并对外提供，不涉及API介绍。

## 示例代码

```
@Entry
@ComponentV2
struct Sample {
  stack: NavPathStack = new NavPathStack()

  build() {
    Navigation(this.stack) {
      Column({ space: 10 }) {
        Text('实名认证').fontSize(20).fontWeight(FontWeight.Bold)
        Button('go').width('100%').onClick(() => {
          this.stack.pushPath({
            name: 'RealNameAuthPage',
          })
        })
      }
      .padding(10)
    }
    .hideTitleBar(true)
  }
}
```
