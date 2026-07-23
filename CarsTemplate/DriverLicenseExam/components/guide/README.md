# 考试引导组件快速入门

## 目录

- [简介](#简介)
- [约束与限制](#约束与限制)
- [快速入门](#快速入门)
- [API参考](#API参考)
- [示例代码](#示例代码)

## 简介

本组件提供驾考信息登记导航组件，用于引导用户完成驾考报名前的信息登记流程。
* **城市选择** ：集成城市选择功能
* **驾照类型选择** ：支持5种驾照类型选择
* **考试科目选择** ：科目一至科目四选择
* **数据验证** ：自动验证表单完整性
* **响应式设计** ：适配不同屏幕尺寸
* **国际化支持** ：内置多语言资源支持

<img src="screenshots/guide.jpg" width="300">

## 约束与限制
### 环境
* DevEco Studio版本：DevEco Studio 5.0.1 Release及以上
* HarmonyOS SDK版本：HarmonyOS 5.0.1 Release SDK及以上
* 设备类型：华为手机（包括双折叠和阔折叠）、平板
* 系统版本：HarmonyOS 5.0.1(13)及以上

## 快速入门

1. 安装组件。

   如果是在DevEco Studio使用插件集成组件，则无需安装组件，请忽略此步骤。

   如果是从生态市场下载组件，请参考以下步骤安装组件。

   a. 解压下载的组件包，将包中所有文件夹拷贝至您工程根目录的XXX目录下。

   b. 在项目根目录build-profile.json5添加guide模块。

    ```typescript
    // 在项目根目录build-profile.json5填写guide路径。其中XXX为组件存放的目录名
    "modules": [
        {
          "name": "guide",
          "srcPath": "./XXX/guide",
        }
    ]
    ```
   c. 在项目根目录oh-package.json5中添加依赖。
    ```typescript
    // XXX为组件存放的目录名称
    "dependencies": {
      "@ohos_agcit/driver_license_exam_guide": "file:./XXX/guide"
    }
   ```

2. 引入组件。

    ```
    import { GuideView, GuideService } from '@ohos_agcit/driver_license_exam_guide'
    ```

3. 调用组件，详细参数配置说明参见[API参考](#API参考)。

```typescript
import { GuideView, GuideService } from '@ohos_agcit/driver_license_exam_guide'
import { promptAction } from '@kit.ArkUI';

@Entry
@ComponentV2
struct DrivingTestPage {
   private guideService: GuideService = GuideService.instance;

   // 跳转城市选择页面
   goCitySelectPage() {
      promptAction.showToast({
         message: '需要跳转城市选择页面',
         duration: 1500,
      })
      // 选择城市后需要更新城市选择数据
      this.guideService.updateCity('北京')
   }

   // 登记引导完成回调
   onComplete() {
      promptAction.showToast({
         message: '登记引导完成',
         duration: 1500,
      })
      const data = this.guideService.getGuideData();
      console.log('引导数据', JSON.stringify(data))
   }

   build() {
      Column() {
         GuideView({
            goCitySelectPage: this.goCitySelectPage,
            completed: this.onComplete
         })
      }
      .width('100%')
         .height('100%')
   }
}
```



## API参考

**GuideService服务**

| 方法名                | 参数                 | 返回值       | 说明     |
|:-------------------|:-------------------|:----------|:-------|
| updateCity         | city:string        | void      | 更新当前城市 |
| updateLicenseType  | type: LICENSE_TYPE | void      | 更新驾照类型 |
| updateDriveStage   | stage: DRIVE_STAGE | void      | 更新考试阶段 |
| getGuideData       | -                  | GuideData | 获取当前数据 |
| isCompleteGuidance | -                  | boolean   | 检查是否完成 |


## 示例代码

```
import { GuideView, GuideService } from '@ohos_agcit/driver_license_exam_guide'
import { promptAction } from '@kit.ArkUI';

@Entry
@ComponentV2
struct DrivingTestPage {
  private guideService: GuideService = GuideService.instance;  
  
  // 跳转城市选择页面
  goCitySelectPage() {    
    promptAction.showToast({
      message: '需要跳转城市选择页面',
      duration: 1500,
    })
    // 选择城市后需要更新城市选择数据
    this.guideService.updateCity('北京')
  }

  // 登记引导完成回调
  onComplete() {
    promptAction.showToast({
      message: '登记引导完成',
      duration: 1500,
    })
    const data = this.guideService.getGuideData();
    console.log('引导数据', JSON.stringify(data))
  }

  build() {
    Column() {
      GuideView({
        goCitySelectPage: this.goCitySelectPage,
        completed: this.onComplete
      })
    }
    .width('100%')
    .height('100%')
  }
}
```