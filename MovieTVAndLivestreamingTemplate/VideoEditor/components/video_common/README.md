# 视频通用模块组件快速入门

## 目录

- [简介](#简介)
- [约束与限制](#约束与限制)
- [使用](#使用)
- [API参考](#API参考)
- [示例代码](#示例代码)

## 简介

本组件是视频编辑应用的基础模块，封装了视频数据模型、作品管理、视频导出等核心功能的数据结构和业务逻辑，为其他视频编辑相关模块提供统一的数据层支持。

## 约束与限制

### 环境

- DevEco Studio版本：DevEco Studio 5.0.5 Release及以上
- HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上
- 设备类型：华为手机（包括双折叠和阔折叠）
- 系统版本：HarmonyOS 5.0.3(15)及以上

### 权限

- 无

## 使用

1. 安装组件

   如果是在DevEco Studio使用插件集成组件，则无需安装组件，请忽略此步骤。

   如果是从生态市场下载组件，请参考以下步骤安装组件。

   a. 解压下载的组件包，将包中所有文件夹拷贝至您工程根目录的XXX目录下。

   b. 在项目根目录build-profile.json5添加video_common模块。

   ```typescript
   // 在项目根目录build-profile.json5填写video_common路径。其中XXX为组件存放的目录名
   "modules": [
       {
       "name": "video_common",
       "srcPath": "./XXX/video_common",
       }
   ]
   ```

   c. 在项目根目录oh-package.json5中添加依赖。

   ```typescript
   // XXX为组件存放的目录名称
   "dependencies": {
     "video_common": "file:./XXX/video_common"
   }
   ```

2. 引入组件。

   ```typescript
   import { WorkListViewModel, WorkViewModel, VideoModel } from 'video_common';
   ```

3. 调用组件，详细参数配置说明参见[API参考](#API参考)。

## API参考

### 子组件

无

### 接口

#### VideoModel

VideoModel()

视频播放状态模型。

**参数：**

| 参数名       | 类型    | 是否必填 | 说明           |
| ------------ | ------- | ---- | -------------- |
| isPlaying    | boolean | 否   | 是否正在播放   |
| videoName    | string  | 否   | 视频名称       |
| playStatus   | boolean | 否   | 播放状态       |

#### WorkViewModel

WorkViewModel()

单个作品的视图模型。

**参数：**

| 参数名           | 类型   | 是否必填 | 说明           |
| ---------------- | ------ | ---- | -------------- |
| id               | string | 否   | 作品ID         |
| title            | string | 否   | 作品标题       |
| duration         | string | 否   | 视频时长       |
| thumbnail        | string | 否   | 缩略图         |
| createTime       | string | 否   | 创建时间       |
| fileSize         | string | 否   | 文件大小       |
| status           | string | 否   | 状态           |
| fileFormat       | string | 否   | 文件格式       |
| videoCodeFormat  | string | 否   | 视频编码格式   |
| audioCodeFormat  | string | 否   | 音频编码格式   |
| resolutionRatio  | string | 否   | 分辨率         |
| videoUrl         | string | 否   | 视频URL        |

#### WorkListViewModel

WorkListViewModel()

作品列表管理视图模型。

**方法：**

| 方法名              | 参数                  | 返回值           | 说明               |
| ------------------- | --------------------- | ---------------- | ------------------ |
| addList             | newWork: [WorkViewModel](#WorkViewModel) | void             | 添加作品           |
| removeList          | index: number         | void             | 删除作品           |
| getFinishWorkList   | 无                    | [WorkViewModel](#WorkViewModel)[]  | 获取已完成作品列表 |
| getUnFinishWorkList | 无                    | [WorkViewModel](#WorkViewModel)[]  | 获取草稿列表       |

#### GlobalContext

GlobalContext

全局上下文管理工具类。

**方法：**

| 方法名                  | 参数                              | 返回值                  | 说明                   |
| ----------------------- | --------------------------------- | ----------------------- | ---------------------- |
| initUIAbilityContext    | context: common.UIAbilityContext  | void                    | 初始化UIAbilityContext |
| getUIAbilityContext     | 无                                | common.UIAbilityContext | 获取UIAbilityContext   |
| initUIContext           | context: UIContext                | void                    | 初始化UIContext        |
| getUIContext            | 无                                | UIContext               | 获取UIContext          |

### 事件

无

## 示例代码

### 示例1（作品列表管理）

```typescript
import { WorkListViewModel, WorkViewModel } from 'video_common';

@Entry
@ComponentV2
struct Index {
  @Local workList: WorkListViewModel = new WorkListViewModel();

  aboutToAppear() {
    // 添加作品
    const newWork = new WorkViewModel();
    newWork.title = '我的视频';
    newWork.status = 'finish';
    this.workList.addList(newWork);
  }

  build() {
    Column() {
      // 显示已完成作品
      List() {
        ForEach(this.workList.getFinishWorkList(), (work: WorkViewModel) => {
          ListItem() {
            Text(work.title)
          }
        })
      }
    }
  }
}
```

