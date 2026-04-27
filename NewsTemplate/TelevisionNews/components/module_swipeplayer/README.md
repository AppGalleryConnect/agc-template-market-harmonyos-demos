# 短视频滑动组件快速入门

## 目录

- [简介](#简介)
- [约束与限制](#约束与限制)
- [使用](#使用)
- [API参考](#API参考)
- [示例代码](#示例代码)

## 简介

本组件实现短视频切换场景，提供了短视频上下滑动、横竖屏切换、长按倍速、播放进度条拖动、音量和亮度调节等能力。

| 竖屏                                                            | 横屏                                                              |
|---------------------------------------------------------------|-----------------------------------------------------------------|
| <img src="./screenshots/img_player_vertical.png" width="300"> | <img src="./screenshots/img_player_horizontal.png" width="400"> |

## 约束与限制

### 环境

- DevEco Studio版本：DevEco Studio 6.0.0 Release及以上
- HarmonyOS SDK版本：HarmonyOS 6.0.0 Release SDK及以上
- 设备类型：华为手机（包括双折叠和阔折叠）、平板
- 系统版本：HarmonyOS 5.1.1(19)及以上

### 权限

- 网络权限：ohos.permission.INTERNET、ohos.permission.GET_NETWORK_INFO
- 后台运行权限: ohos.permission.KEEP_BACKGROUND_RUNNING

## 使用

1. 安装组件。

   如果是在DevEco Studio使用插件集成组件，则无需安装组件，请忽略此步骤。

   如果是从生态市场下载组件，请参考以下步骤安装组件。

   a. 解压下载的组件包，将包中所有文件夹拷贝至您工程根目录的XXX目录下。

   b. 在项目根目录build-profile.json5添加module_swipeplayer、module_transition模块。

   ```
   // 项目根目录下build-profile.json5填写module_swipeplayer、module_transition路径。其中XXX为组件存放的目录名
   "modules": [
     {
       "name": "module_swipeplayer",
       "srcPath": "./XXX/module_swipeplayer"
     },
     {
       "name": "module_transition",
       "srcPath": "./XXX/module_transition"
     },
   ]
   ```

   c. 在项目根目录oh-package.json5添加依赖。
   ```
   // XXX为组件存放的目录名称
   "dependencies": {
      "module_swipeplayer": "file:./XXX/module_swipeplayer",
      "module_transition": "file:./XXX/module_transition",
   }
   ```

2. 引入组件。

    ```
    import { VideoSwipePlayer, SwipePlayerController, AVPlayerManager, AVPlayerController, PlayerDataSource } from 'module_swipeplayer';
    ```

3. 调用组件，详细参数配置说明参见[API参考](#API参考)。
   ```
   VideoSwipePlayer({
     // 数据源
     datasource: this.videoDataSources,
     // 滑动播放控制器
     swipePlayerController: this.swipePlayerController,
     // 视频外层控制层，需要实现一个WrappedBuilder组件
     videoLayerBuilder: wrapBuilder(VideoLayerViewBuilder),
     pathStack: this.pathStack,
     isShown: true,
     options: {
       autoPlay: true,
       bottomTabHeight: 56,
       totalCount: 2,
       swiperCallback: {
         onAnimationStart: (_index: number, targetIndex: number, extraInfo: SwiperAnimationEvent) => {
           // TODO 处理切换动画开始的业务逻辑，如：加载更多
         },
         onChange: (index: number) => {
           // TODO 子组件索引变化时的回调
         }
       }
     }
   })
   ```

## API参考

### 接口

VideoSwipePlayer(option: [VideoSwipePlayerOptions](#VideoSwipePlayerOptions对象说明))

滑动视频组件

**参数：**

| 参数名     | 类型                                                      | 是否必填 | 说明         |
|:--------|:--------------------------------------------------------|:-----|:-----------|
| options | [VideoSwipePlayerOptions](#VideoSwipePlayerOptions对象说明) | 是    | 滑动视频组件的参数。 |

#### VideoSwipePlayerOptions对象说明

| 参数名                         | 类型                                                                                                                                                                        | 是否必填 | 说明                                           |
|:----------------------------|:--------------------------------------------------------------------------------------------------------------------------------------------------------------------------|:-----|:---------------------------------------------|
| datasource                  | IDataSource                                                                                                                                                               | 是    | 视频列表的懒加载数据源                                  |
| swipePlayerController       | [SwipePlayerController](#SwipePlayerController对象说明)                                                                                                                       | 是    | 视频滑动播放控制器                                    |
| options                     | [SwipePlayerOptions](#SwipePlayerOptions对象说明)                                                                                                                             | 是    | 配置的信息                                        |
| videoLayerBuilder           | WrappedBuilder<[ESObject, [AVPlayerController](#AVPlayerController对象说明), [SwipePlayerController](#SwipePlayerController对象说明), [PlayerLayoutSize](#PlayerLayoutSize对象说明)]> | 否    | 视频外层的操作层，可自定义，如果不传，则只显示进度条                   |
| fullBtnBuilder              | () => CustomBuilder                                                                                                                                                       | 否    | 全屏播放按钮，可以自定义，如果不传，使用默认样式                     |
| pathStack                   | NavPathStack                                                                                                                                                              | 是    | 全局Navigation的路由栈                             |
| isLandscape                 | boolean                                                                                                                                                                   | 否    | 是否横屏                                         |
| videoNetwork                | [VideoNetworkModel](#VideoNetworkModel对象说明)                                                                                                                               | 否    | 网络状态                                         |
| videoNetworkSetting         | [VideoNetworkSetting](#VideoNetworkSetting对象说明)                                                                                                                           | 否    | 网络播放设置                                       |
| isShown                     | boolean                                                                                                                                                                   | 是    | 当前组件所在的页面是否显示                                |
| videoItemAVPlayerController | [AVPlayerController](#AVPlayerController对象说明)\| undefined                                                                                                                 | 否    | 外部传入的AVPlayerController                      |
| enableAVSession             | boolean                                                                                                                                                                   | 否    | 是否接入播控中心，默认值：false                           |
| currentBreakpoint           | [BreakpointNameEnum](#BreakpointNameEnum枚举说明)                                                                                                                             | 否    | 断点名称，默认值：sm                                  |
| playerStateCallback         | (state: string, id: string) => void                                                                                                                                       | 否    | 播放状态回调。state：视频播放中"playing"的状态，id： 当前播放视频的id |
| playerTimeUpdateCallback    | (videoData: [VideoPlayerData](#VideoPlayerData对象说明), timeMs: number) => void                                                                                              | 否    | 播放进度回调。videoData：视频数据，timeMs：当前进度            |

#### SwipePlayerController对象说明

| 参数名                          | 类型                                                                                                                                                     | 说明                     |
|:-----------------------------|:-------------------------------------------------------------------------------------------------------------------------------------------------------|:-----------------------|
| setAVPlayerMgr               | (avPlayerMgr: [AVPlayerManager](#AVPlayerManager对象说明)) => void                                                                                         | 绑定播放器管理器。              |
| setSwiperController          | (swiperController: [SwiperController](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ts-container-swiper#swipercontroller)) => void | 绑定滑动控制器。               |
| setCurrentIndex              | (curentIndex: number) => void                                                                                                                          | 设置当前索引。                |
| play                         | () => Promise<void>                                                                                                                                    | 播放当前视频。                |
| pause                        | () => Promise<void>                                                                                                                                    | 暂停当前视频。                |
| release                      | () => Promise<void>                                                                                                                                    | 释放当前视频资源（内存、解码器等）。     |
| seek                         | (timeMs: number) => void                                                                                                                               | 跳转到指定播放时间。             |
| setSpeed                     | (speed: [media.PlaybackSpeed](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/arkts-apis-media-e#playbackspeed8)) => void            | 设置播放速度。                |
| changeIndex                  | (index: number, useAnimation: boolean = true) => void                                                                                                  | 切换到指定索引的视频，并控制是否使用动画。  |
| getCurrentAVPlayerController | () => [AVPlayerController](#AVPlayerController对象说明) \| undefined                                                                                       | 获取当前索引对应的播放器控制器。       |
| getAVPlayerMgr               | () => [AVPlayerManager](#AVPlayerManager对象说明) \| undefined                                                                                             | 获取当前绑定的播放器管理器。         |
| getCurrentIndex              | () => number                                                                                                                                           | 获取当前索引。                |
| getAVPlayer                  | () => [media.AVPlayer](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/arkts-apis-media-avplayer) \| undefined                       | 获取当前索引的 `AVPlayer` 实例。 |

#### SwipePlayerOptions对象说明

| 参数名             | 类型                                    | 是否必填 | 说明                                      |
|:----------------|:--------------------------------------|:-----|:----------------------------------------|
| cachedCount     | number                                | 否    | 懒加载缓存的个数。默认2个                           |
| autoPlay        | boolean                               | 否    | 视频是否自动播放                                |
| swiperCallback  | [SwiperCallback](#SwiperCallback对象说明) | 否    | Swiper组件的onChange、onAnimationStart的回调事件 |
| bottomTabHeight | number                                | 否    | 底部tab栏的高度                               |
| totalCount      | number                                | 否    | 视频列表的总数，用来判断是否滑动最后一个                    |

#### VideoPlayerData对象说明

| 参数名              | 类型                         | 是否必填 | 说明                        |
|:-----------------|:---------------------------|:-----|:--------------------------|
| getVideoId       | () => string               | 是    | 返回当前视频的唯一标识 ID，用于定位和追踪视频。 |
| getVideoUrl      | () => string               | 是    | 返回视频的播放地址。                |
| getCoverUrl      | () => string\|undefined    | 是    | 返回视频封面图片地址。               |
| getVideoTitle    | () => string               | 是    | 返回视频标题。                   |
| getVideoDuration | () => number               | 是    | 返回视频总时长（单位：ms）。           |
| getAuthorName    | () => string               | 是    | 返回视频作者名称。                 |
| isNeedVip        | () => boolean              | 是    | 返回视频是否需要 VIP 权限才能播放。      |
| setVideoDuration | (duration: number) => void | 是    | 设置视频总时长（单位：ms）。           |

#### PlayerLayoutSize对象说明

| 参数名                        | 类型                                 | 说明              |
|:---------------------------|:-----------------------------------|:----------------|
| updateXComponentWidth      | (xComponentWidth: Length) => void  | 更新XComponent的宽度 |
| updateXComponentHeight     | (xComponentHeight: Length) => void | 更新XComponent的高度 |
| updateLayoutSizeChangeFlag | (flag: boolean) => void            | 设置尺寸的变化标识       |
| updatePlayerWidth          | (playerWidth: Length): void        | 更新播放器的宽度。       |
| updatePlayerHeight         | (playerHeight: Length): void       | 更新播放器的高度。       |
| updateSlideMovingFlag      | (flag: boolean): void              | 更新进度条滑动状态。      |
| getXComponentWidth         | () => Length                       | 获取XComponent的宽度 |
| getXComponentHeight        | () => Length                       | 获取XComponent的高度 |
| getLayoutSizeChangeFlag    | () => boolean                      | 获取尺寸的变化标识       |
| getPlayerWidth             | (): Length                         | 获取播放器的宽度。       |
| getPlayerHeight            | (): Length                         | 获取播放器的高度。       |
| getSlideMovingFlag         | (): boolean                        | 获取进度条滑动状态。      |

#### SwiperCallback对象说明

| 参数名              | 类型                                                                            | 是否必填 | 说明                             |
|:-----------------|:------------------------------------------------------------------------------|------|:-------------------------------|
| onChange         | (index: number) => void                                                       | 否    | Swiper组件的onChange事件的回调         |
| onAnimationStart | (index: number, targetIndex: number, extraInfo: SwiperAnimationEvent) => void | 否    | Swiper组件的onAnimationStart事件的回调 |

#### AVPlayerManager对象说明

| 参数名                      | 类型                                                                                                                                                         | 说明                                         |
|:-------------------------|:-----------------------------------------------------------------------------------------------------------------------------------------------------------|:-------------------------------------------|
| getInstance              | () => AVPlayerManager                                                                                                                                      | 获取AVPlayerManager单实例对象                     |
| setAVPlayerController    | (playerId: string, avPlayerController: [AVPlayerController](#AVPlayerController对象说明)): void                                                                | 将指定`playerId`的`AVPlayerController`添加到缓存    |
| setPlayerId              | (index: number, playerId: string): void                                                                                                                    | 设置playerId                                 |
| deleteAVPlayerController | (playerId: string): void                                                                                                                                   | 从缓存中移除指定 `playerId` 的 `AVPlayerController` |
| clear                    | () => void                                                                                                                                                 | 清空所有映射与缓存，重置管理器状态                          |
| play                     | (index: number) => Promise<void>                                                                                                                           | 播放某个index的视频                               |
| pause                    | (index: number) => Promise<void>                                                                                                                           | 暂停某个index的视频                               |
| seek                     | (index: number, timeMs: number) => void                                                                                                                    | 设置某个index视频跳转到某个时间位置播放                     |
| release                  | (index: number) => Promise<void>                                                                                                                           | 释放某个index的视频                               |
| setSpeed                 | (index: number, speed: [media.PlaybackSpeed](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/arkts-apis-media-e#playbackspeed8)) => void | 设置播放速度                                     |
| getPlayerId              | (index: number): string \| undefined                                                                                                                       | 根据索引获取对应的 `playerId`                       |
| getAVPlayerController    | (index: number): [AVPlayerController](#AVPlayerController对象说明)                                                                                             | undefined                                  |                        |
| getAVPlayer              | (index: number) => [media.AVPlayer](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/arkts-apis-media-avplayer) \| undefined              | 根据索引获取AVPlayer对象                           |

#### AVPlayerController对象说明

| 参数名              | 类型                                                                                                                                   | 说明                     |
|:-----------------|:-------------------------------------------------------------------------------------------------------------------------------------|:-----------------------|
| avPlayer         | [media.AVPlayer](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/arkts-apis-media-avplayer) \| undefined           | AVPlayer对象             |
| avPlayerCallback | Map<string, Array<(...args: ESObject) => void>>                                                                                      | 事件回调函数表，键为事件名，值为回调函数数组 |
| play             | () => Promise<void>                                                                                                                  | 播放视频。                  |
| pause            | () => Promise<void>                                                                                                                  | 暂停视频。                  |
| seek             | () => void                                                                                                                           | 跳转到指定时间点播放。            |
| reset            | () => Promise<void>                                                                                                                  | 重置播放器，释放当前播放状态，回到初始状态。 |
| onEvent          | (key: string, callback: (...args: ESObject) => void): void                                                                           | 绑定自定义事件回调函数。           |
| setAVPlayer      | (avPlayer: [media.AVPlayer](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/arkts-apis-media-avplayer)): void      | 绑定 `AVPlayer` 实例。      |
| getAVPlayer      | () => [media.AVPlayer](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/arkts-apis-media-avplayer)     \| undefined | 获取当前绑定的 `AVPlayer` 实例。 |

#### VideoNetworkModel对象说明

| 参数名                 | 类型      | 是否必填 | 说明             |
|:--------------------|:--------|------|:---------------|
| hasNet              | boolean | 否    | 是否有网络          |
| isCellular          | boolean | 否    | 是否是移动蜂窝网络      |
| isWiFi              | boolean | 否    | 是否是WiFi网络      |
| hasOfflineTip       | boolean | 否    | 无网络时，是否已经提示    |
| canUseMobileData    | boolean | 否    | 是否可以使用移动流量     |
| hasUseMobileDataTip | boolean | 否    | 使用流量播放时，是否已经提示 |
| isNetworkAvailable  | boolean | 否    | 当前网络是否可用       |

#### VideoNetworkSetting对象说明

| 参数名                  | 类型      | 是否必填 | 说明              |
|:---------------------|:--------|------|:----------------|
| downloadWithoutWlan  | number  | 否    | 非WLAN网络下载图片     |
| remindWithoutWlan    | number  | 否    | 非WLAN网络播放是否进行提醒 |
| autoPlayNext         | boolean | 否    | 是否自动播放下一个视频     |
| autoPlayTabRecommend | boolean | 否    | 是否自动播放视频        |
| enableLivePiP        | boolean | 否    | 是否启用小窗播放        |

#### BreakpointNameEnum枚举说明

| 名称 | 说明   |
|:---|:-----|
| SM | sm断点 |
| MD | md断点 |
| LG | lg断点 |
| XL | xl断点 |

## 示例代码

该示例由Index.ets 和 SwipeVideoPage.ets两个文件组成，主要演示从Index页面使用Navigation跳转到SwipeVideoPage视频滑动页面。滑动页跳转到横屏页时，通过自定义转场动画，实现一镜到底的效果。

横屏页面是组件内部的页面。不需要自行实现。

示例代码使用Navigation，运行示例代码之前需要进行系统路由表的配置，具体操作如下：
在entry/src/main目录下的工程配置文件[module.json5](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/module-configuration-file)中的module字段里配置 "routerMap": "$profile:route_map"，

<img src="./screenshots/router_map.png" width="300">


在entry/src/main/resources/base/profile目录下新增route_map.json文件，文件内容如下：

```
{
  "routerMap": [
    {
      "name": "SwipeVideoPage",
      "pageSourceFile": "src/main/ets/pages/SwipeVideoPage.ets",
      "buildFunction": "SwipeVideoPageBuilder"
    }
  ]
}
```

由于使用了一镜到底效果，需要在entry/src/main/ets/entryability/EntryAbility.ets文件的onWindowStageCreate方法里初始化一镜到底动画：

```ts
import { window } from '@kit.ArkUI';
import { LoneTakeAnimationsTransition } from 'module_transition';

export default class EntryAbility extends UIAbility {
     onWindowStageCreate(windowStage: window.WindowStage): void {
        ...
        LoneTakeAnimationsTransition.init(windowStage);
        ...
     }
}
```

入口页：

```ts
// Index.ets
import { LoneTakeAnimationsTransition } from 'module_transition';

@Entry
@ComponentV2
struct Index {
  // 全局navigation的路由栈
  pageStack: NavPathStack = new NavPathStack();
  @Local isEnabled: boolean = true;
  aboutToAppear(): void {
    this.pageStack.pushPathByName('SwipeVideoPage', '')
  }

  build() {
    Navigation(this.pageStack) {
    }
    .hideNavBar(true)
    .hideTitleBar(true)
    .enabled(this.isEnabled)
    .customNavContentTransition((from: NavContentInfo, to: NavContentInfo, operation: NavigationOperation) => {
        // 自定义转场动画
      return LoneTakeAnimationsTransition.customNavContentTransition(from, to, operation, {
        // 自定义转场过程中禁用手势，避免出现体验问题
        onTransitionStart: () => {
          this.isEnabled = false;
        },
        onTransitionEnd: () => {
          this.isEnabled = true;
        }
      });
    })
  }
}
```

滑动视频页：

需要在工程的entry\src\main\ets\pages目录下新建滑动视频页：SwipeVideoPage.ets

```ts
// SwipeVideoPage.ets
import {
  VideoSwipePlayer,
  AVPlayerManager,
  AVPlayerController,
  PlayerDataSource,
  SwipePlayerController,
  PlayerLayoutSize,
  VideoPlayerData,
} from 'module_swipeplayer';
import { LongTakeAnimationProperties } from 'module_transition';

interface VideoInfo {
  // 视频id
  id: string
  // 标题
  title: string
  // 视频url
  videoUrl: string
  // 封面图
  coverUrl: string
  // 视频时长(单位: 毫秒)
  videoDuration: number
}

class VideoData implements VideoInfo, VideoPlayerData {
  // 视频id
  id: string = ''
  // 标题
  title: string = ''
  // 视频url
  videoUrl: string = ''
  // 封面图
  coverUrl: string = ''
  // 视频时长(单位: 毫秒)
  videoDuration: number = 0
  duration: number = 0

  constructor(data: VideoInfo) {
    this.id = data.id
    this.title = data.title
    this.videoUrl = data.videoUrl
    this.coverUrl = data.coverUrl
    this.videoDuration = data.videoDuration
  }

  getVideoId(): string {
    return this.id;
  }

  getVideoUrl(): string {
    return this.videoUrl;
  }

  getCoverUrl(): string {
    return this.coverUrl;
  }

  getVideoTitle(): string {
    return this.title;
  }

  getVideoDuration(): number {
    return this.videoDuration;
  }

  getAuthorName() {
    return '';
  }

  public isNeedVip() {
    return false;
  }

  public setVideoDuration(duration: number) {
    this.duration = duration;
  }
}

// 视频外层控制层视图
@ComponentV2
struct VideoLayer {
  // 视频数据
  @Param @Require videoData: ESObject;
  // 播放会话
  @Param @Require avPlayerController: AVPlayerController;
  // 滑动播放控制器
  @Param @Require swipePlayerController: SwipePlayerController
  // 评论页面出现时，改变播放页面的尺寸
  @Param @Require playerLayoutSize: PlayerLayoutSize

  // 播放、暂停切换
  switchPlayOrPause() {
    let avPlayer = this.swipePlayerController.getAVPlayer()
    let state = avPlayer?.state
    if (state === 'playing') {
      avPlayer?.pause()
    } else {
      avPlayer?.play()
    }
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Text('这是自定义的外层操作层')
        .fontSize(30)
        .fontColor($r('sys.color.white'))
    }.height('100%')
    .width('100%')
    .onClick(() => {
      this.switchPlayOrPause()
    })
  }
}

@Builder
function VideoLayerViewBuilder(
  videoData: ESObject,
  avPlayerController: AVPlayerController,
  swipePlayerController: SwipePlayerController,
  playerLayoutSize: PlayerLayoutSize,
) {
  VideoLayer({
    videoData,
    avPlayerController,
    swipePlayerController,
    playerLayoutSize,
  })
}

// 滑动视频页
@Builder
export function SwipeVideoPageBuilder() {
  SwipeVideoPage()
}

@ComponentV2
export struct SwipeVideoPage {
  // 数据源
  videoDataSources = new PlayerDataSource<VideoData>()
  // 播放控制器
  swipePlayerController: SwipePlayerController = new SwipePlayerController();
  // 播放管理
  avPlayerManager: AVPlayerManager = new AVPlayerManager();
  // 路由栈
  pathStack = new NavPathStack()
  @Local longTakeSession: LongTakeAnimationProperties = new LongTakeAnimationProperties();

  aboutToAppear() {
    // 设置播放管理
    this.swipePlayerController.setAVPlayerMgr(this.avPlayerManager)

    // 初始化数据
    let data1 = {
      id: 'video1',
      title: '新通话，让每一次连接超越想象',
      videoUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/a20e0965e56a4dc498fc33ee23750c0d.mp4',
      coverUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/6c813cb0874744f4b54fd61f1f9e8f24.jpg',
      videoDuration: 134506,
    } as VideoInfo

    let data2 = {
      id: 'video2',
      title: '星联光模块',
      videoUrl: 'https://e-file.huawei.com/mediares/MarketingMaterial_MCD/EBG/PUBLIC/zh/2025/04/5feb8457-d5e9-4949-a181-795e4d873af9.mp4',
      coverUrl: 'https://e-file.huawei.com/mediares/Video_MCD/EBG/PUBLIC/zh/2025/04/3c04b872-197d-4551-a353-0eb99def6ca2.png',
      videoDuration: 48234,
    } as VideoInfo

    let list: VideoData[] = [
      new VideoData(data1),
      new VideoData(data2),
    ]
    this.videoDataSources.setData(list)
  }

  build() {
    NavDestination() {
      Stack() {
        Column() {
          VideoSwipePlayer({
            // 数据源
            datasource: this.videoDataSources,
            // 滑动播放控制器
            swipePlayerController: this.swipePlayerController,
            // 视频外层控制层，需要实现一个WrappedBuilder组件
            videoLayerBuilder: wrapBuilder(VideoLayerViewBuilder),
            pathStack: this.pathStack,
            isShown: true,
            options: {
              autoPlay: true,
              bottomTabHeight: 56,
              totalCount: 2,
              swiperCallback: {
                onAnimationStart: (_index: number, targetIndex: number, extraInfo: SwiperAnimationEvent) => {
                  // TODO 处理切换动画开始的业务逻辑，如：加载更多
                },
                onChange: (index: number) => {
                  // TODO 子组件索引变化时的回调
                },
              },
            },
          })
        }
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
    }
    .hideTitleBar(true)
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack;
    })
  }
}
```
