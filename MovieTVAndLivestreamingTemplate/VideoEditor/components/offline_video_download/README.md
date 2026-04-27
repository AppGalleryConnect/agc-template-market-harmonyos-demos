# 离线视频下载组件快速入门

## 目录

- [简介](#简介)
- [约束与限制](#约束与限制)
- [使用](#使用)
- [API参考](#API参考)
- [示例代码](#示例代码)

## 简介

本组件用于在本地实现视频的下载与播放管理，提供下载进度展示、播放/暂停控制、进度滑条拖拽、横竖屏切换、窗口系统栏控制与自适应尺寸等功能。适用于视频编辑或内容播放场景中的离线缓冲与回放需求。

功能概览：
- 展示视频信息卡片（名称、大小、时长）与下载状态
- 下载进度与大小展示（已缓存/总大小）
- 播放控制：播放/暂停、进度滑条拖动跳转
- 横竖屏切换与返回键拦截（横屏时拦截返回）
- 轨道信息面板（MenuBuilderInfo）
- 组件内部使用 `XComponent` 承载播放器，配合 `Slider` 控件调节播放进度，并使用 `window` 能力进行横竖屏与系统栏控制
- 横屏播放时，返回键会被拦截；点击返回图标将恢复竖屏、显示系统栏并退出播放态
- 组件内部处理播放、暂停与进度拖拽，无需显式事件

视频下载页面:

<img src="screenshot/offlineVideoView.jpeg" alt="首页" width="300">


## 约束与限制

### 环境

- DevEco Studio版本：DevEco Studio 5.0.5 Release及以上
- HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上
- 设备类型：华为手机（包括双折叠和阔折叠）
- 系统版本：HarmonyOS 5.0.3(15)及以上

### 权限

- 网络权限：ohos.permission.INTERNET

## 使用

1. 安装组件。
   如果是在 DevEco Studio 使用插件集成组件，则无需安装组件，请忽略此步骤。

   如果是从生态市场下载组件，请参考以下步骤安装组件。

   a. 解压下载的组件包，将包中所有文件夹拷贝至您工程根目录的 `XXX` 目录下。

   b. 在项目根目录 `build-profile.json5` 添加 `offline_video_download` 模块。

   ```json
   {
     "modules": [
       {
         "name": "offline_video_download",
         "srcPath": "./XXX/offline_video_download"
       },
       {
         "name": "video_common",
         "srcPath": "./XXX/video_common"
       }
     ]
   }
   ```

   c. 在项目根目录 `oh-package.json5` 中添加依赖。

   ```json
   {
     "dependencies": {
       "offline_video_download": "file:./xxx/offline_video_download"
     }
   }
   ```
   
   d.在使用offlineVideo模块中的module.json5增加权限
   ```json
   {
     "requestPermissions": [
       {
         "name": "ohos.permission.INTERNET"
       }
     ]
   }
   ```
   
2. Native 库（.so）相关配置

   a. 在entry模块中的build-profile.json5添加

   ```json
   {
       "buildOption": {
           "nativeLib": {
               "debugSymbol": {
                   "strip": true,
                   "exclude": []
               }
           }
       }
   }
   ```

3. 一多适配获取设备数据
   
   a. 在entry模块的entry\src\main\ets\entryability\entryability.ets文件中添加依赖
   ```typescript
   import { AppStorageV2 } from '@kit.ArkUI';
   import { AiBarHeight, AppStorageKeys, StatusBarHeight } from 'offline_video_download';
   ```
   b. 在entry模块的entry\src\main\ets\entryability\entryability.ets文件中添加属性

   ```typescript
   aiBarHeight: AiBarHeight = AppStorageV2.connect(AiBarHeight, AppStorageKeys.AI_BAR_HEIGHT, () => new AiBarHeight())!;
   statusBarHeight: StatusBarHeight =
   AppStorageV2.connect(StatusBarHeight, AppStorageKeys.STATUS_BAR_HEIGHT, () => new StatusBarHeight())!;
   ```

   c. 在entry模块的entry\src\main\ets\entryability\entryability.ets的onWindowStageCreate(windowStage: window.WindowStage)生命周期方法中添加代码

   ```typescript
    let windowClass: window.Window = windowStage.getMainWindowSync();

    windowClass.on('avoidAreaChange', () => {
      let type = window.AvoidAreaType.TYPE_SYSTEM;
      let avoidArea = windowClass.getWindowAvoidArea(type);
      this.statusBarHeight.value = px2vp(avoidArea.topRect.height);
      type = window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR;
      avoidArea = windowClass.getWindowAvoidArea(type);
      this.aiBarHeight.value = px2vp(avoidArea.bottomRect.height);
    });

    // 设置沉浸式
    windowStage.getMainWindowSync().setWindowLayoutFullScreen(true);
   ```

4. 引入组件句柄。

   ```typescript
   import { OfflineVideoDownload } from 'offline_video_download';
   // 可选：引入示例数据或类型
   import { CommonConstants, VideoInfo } from 'offline_video_download';
   ```

5. 调用组件，详细参数配置说明参见 [API参考](#API参考)。
   ```typescript
   // 使用方式：传入组件内置示例数据
   OfflineVideoDownload({ videoInfo: CommonConstants.VIDEO_HTTPS_LISTS[0]})
   ```

## API参考

### 子组件

无

### 接口

#### OfflineVideoDownload

OfflineVideoDownload(options: OfflineVideoDownloadOptions)

离线视频下载组件。

**参数：**

| 参数名  | 类型                                                 | 是否必填 | 说明                     |
| ------- | ---------------------------------------------------- | ---- | ------------------------ |
| options | [OfflineVideoDownloadOptions](#OfflineVideoDownloadOptions对象说明) | 是   | 组件调用的入参对象     |

### OfflineVideoDownloadOptions对象说明

| 名称      | 类型                                | 是否必填 | 说明                       |
| --------- | ----------------------------------- | ---- | -------------------------- |
| videoInfo | [VideoInfo](#VideoInfo对象说明)     | 是   | 视频信息对象             |

### VideoInfo对象说明

| 名称     | 类型   | 是否必填 | 说明                         |
| -------- | ------ | ---- | ---------------------------- |
| name     | string | 是   | 视频名称                   |
| url      | string | 是   | 视频源地址（支持 http/https） |
| size     | number | 是   | 视频大小（单位：字节）     |
| duration | number | 是   | 视频时长（单位：秒）       |

**构造函数：**

`new VideoInfo(name: string, url: string, size: number, duration: number)`

**方法：**

| 方法名               | 入参 | 返回值  | 说明                         |
| -------------------- | ---- | ------- | ---------------------------- |
| getFormattedSize     | 无   | string  | 返回格式化大小（KB/MB）    |
| getFormattedDuration | 无   | string  | 返回格式化时长（mm:ss）    |

### 组件

OfflineVideoDownload

**参数：**

| 参数名  | 类型                                                 | 是否必填 | 说明                     |
| ------- | ---------------------------------------------------- | ---- | ------------------------ |
| options | [OfflineVideoDownloadOptions](#OfflineVideoDownloadOptions对象说明) | 是   | 组件调用的入参对象。     |

### OfflineVideoDownloadOptions对象说明

| 名称      | 类型                                | 是否必填 | 说明                       |
| --------- | ----------------------------------- | ---- | -------------------------- |
| videoInfo | [VideoInfo](#VideoInfo对象说明)     | 是   | 视频信息对象。             |

### VideoInfo对象说明

| 名称     | 类型   | 是否必填 | 说明                         |
| -------- | ------ | ---- | ---------------------------- |
| name     | string | 是   | 视频名称。                   |
| url      | string | 是   | 视频源地址（支持 http/https）。 |
| size     | number | 是   | 视频大小（单位：字节）。     |
| duration | number | 是   | 视频时长（单位：秒）。       |

**构造函数：**

`new VideoInfo(name: string, url: string, size: number, duration: number)`

**方法：**

| 方法名               | 入参 | 返回值  | 说明                         |
| -------------------- | ---- | ------- | ---------------------------- |
| getFormattedSize     | 无   | string  | 返回格式化大小（KB/MB）。    |
| getFormattedDuration | 无   | string  | 返回格式化时长（mm:ss）。    |

## 示例代码

```text
import { AppStorageV2 } from '@kit.ArkUI';
import { BarVM, OfflineVideoDownload, VideoModel } from 'offline_video_download';
// 可选：引入示例数据或类型
import { CommonConstants, VideoInfo } from 'offline_video_download';

@Entry
@ComponentV2
struct Index {
  @Local videoState: VideoModel = AppStorageV2.connect<VideoModel>(VideoModel, () => new VideoModel())!;
  // 方式一：使用组件内置示例数据
  @Local videoInfo1: VideoInfo = CommonConstants.VIDEO_HTTPS_LISTS[0];
  // 方式二：手动构造 VideoInfo
  @Local videoInfo2: VideoInfo = new VideoInfo(
    '0002',
    '视频2',
    $r('app.string.video2_url'),
    2580421,
    9,
    '0K',
    $r('app.media.cover_video2'),
    false,
    0,
    false
  );

  build() {
    Column() {
      if (!this.videoState.isPlaying) {
        Text('离线视频下载')
          .fontSize(16)
          .fontColor('rgba(255, 255, 255, 0.80)')
          .lineHeight(30)
        Blank().height(16)
      }
      List() {
        ListItem() {
          Row() {
            OfflineVideoDownload({ videoInfo: this.videoInfo1, isDarkMode: true })
              .layoutWeight(1)
          }
          .width('100%')
          .alignItems(VerticalAlign.Center)
        }

        ListItem() {
          Row() {
            OfflineVideoDownload({ videoInfo: this.videoInfo2, isDarkMode: true })
              .layoutWeight(1)
          }
          .width('100%')
          .alignItems(VerticalAlign.Center)
        }
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Auto)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
    }
    .padding({
      top: this.videoState.isPlaying ? 0 : BarVM.instance.staBarH,
      left: this.videoState.isPlaying ? 0 : 16,
      bottom: this.videoState.isPlaying ? 0 : BarVM.instance.aiBarH,
      right: this.videoState.isPlaying ? 0 : 16
    })
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .height('100%')
    .backgroundColor('#000')
  }
}
```