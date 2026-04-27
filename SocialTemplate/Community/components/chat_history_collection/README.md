# 聊天记录收藏组件快速入门

## 目录

- [简介](#简介)
- [约束与限制](#约束与限制)
- [使用](#使用)
- [API参考](#API参考)
- [示例代码](#示例代码)

## 简介

收藏组件，负责聊天消息的收藏以及收藏数据展示能力，支持文本消息、图片消息、视频消息、语音消息以及位置消息。

<img src="screenshots/collect_list.png" alt="检测新版本" width="300">

## 约束与限制

各类型的消息的点击事件，需要用户自行实现，并以组件参数的形式传入，比如图片点击跳转大图查看页面等逻辑。

### 环境

- DevEco Studio版本：DevEco Studio 5.0.5 Release及以上
- HarmonyOS SDK版本：HarmonyOS 5.0.3 Release SDK及以上
- 设备类型：华为手机（包括双折叠和阔折叠）
- 系统版本：HarmonyOS 5.0.3(15) 及以上

### 权限

- 网络权限：ohos.permission.INTERNET

## 使用

1. 安装组件。  
   如果是在DevEco Studio使用插件集成组件，则无需安装组件，请忽略此步骤。
   如果是从生态市场下载组件，请参考以下步骤安装组件。  
   a. 解压下载的组件包，将包中所有文件夹拷贝至您工程根目录的xxx目录下。  
   b. 在项目根目录build-profile.json5并添加chat_base和chat_history_collection模块。
   
   在项目根目录的build-profile.json5填写chat_base和chat_history_collection路径。其中xxx为组件存在的目录名

```json
{
  "modules": [
    {
      "name": "chat_base",
      "srcPath": "./xxx/chat_base"
    },
    {
      "name": "chat_history_collection",
      "srcPath": "./xxx/chat_history_collection"
    }
  ]
}
```

c. 在项目根目录oh-package.json5中添加依赖

 xxx为组件存放的目录名称

```json
{
  "dependencies": {
    "chat_location": "file:./xxx/chat_history_collection"
  }
}
```

2. 引入组件。

   ```ts
   import { ChatHistoryCollectionComponent } from 'chat_history_collection';
   ```
   ```ts
   import { ChatContentAudio, ChatContentImage, ChatContentSingleModel, ChatTypeEnum } from 'chat_history_collection';
   import { CollectDataManager } from 'chat_history_collection';
   ```

3. 调用组件，详细参数配置说明参见[API参考](#API参考)。

   ```ts
   Column() {
      ChatHistoryCollectionComponent({
          onChatBubbleClick: this.onChatBubbleClick,
      })
   }
   ```
   ```ts
   CollectDataManager.getInstance().addCollectMsg(this.chatMsg);
   ```

## API参考

### 接口

#### ChatHistoryCollectionComponent组件

ChatHistoryCollectionComponent(options: { onChatBubbleClick: (chatVM: ChatContentSingleModel) => void })

收藏列表组件，展示收藏的聊天消息。

**参数：**

| 参数                | 类型       | 是否必填 | 说明         |
|-------------------|----------|------|------------|
| onChatBubbleClick | Function | 否    | 各类型消息的点击事件 |

**注意：** 组件使用 `@Param` 装饰器，参数通过对象形式传递。

#### addCollectMsg接口

MsgCollectUtil.getInstance().addCollectMsg(this.chatMsg);

收藏组件的添加收藏接口，将指定的消息加入收藏。

**参数：**

| 参数      | 类型                                                                      | 是否必填 | 说明         |
|---------|-------------------------------------------------------------------------|------|------------|
| chatMsg | [ChatContentSingleModel](../chat_base/README.md#chatcontentsinglemodel) | 是    | 将指定的消息加入收藏 |

## 示例代码

### 一、开始准备

#### 1、需提前配置网络权限，否则图片可能加载不出来。

在entry的module.json5中添加如下代码：

```json
   {
  "requestPermissions": [
    {
      "name": "ohos.permission.INTERNET"
    }
  ]
}
```

#### 2、需提前开通地图权限，否则地图无法显示，开通方式参考：https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/map-config-agc#section16133115441516

### 二、编辑Index页面负责Mock添加收藏的消息

```ts
import { buffer } from '@kit.ArkTS';
import { CollectDataManager } from 'chat_history_collection';
import { ChatContentAudio, ChatContentImage, ChatContentSingleModel, ChatTypeEnum } from 'chat_history_collection';

@Entry
@ComponentV2
struct Index {
   pageStack: NavPathStack = new NavPathStack();
   @Local mockDataList: ChatContentSingleModel[] = []

   strToArrayBuffer(content: string) {
      return buffer.from(content, 'utf-8').buffer;
   }

   aboutToAppear(): void {
      let longCustom = new ChatContentSingleModel();
      longCustom.chatType = ChatTypeEnum.CHAT_TYPE_TEXT;
      longCustom.textElem = '你好啊，😀😀😀，发展新质生产力不是要忽视、放弃传统产业，要防止一哄而上、泡沫化，也不要搞一种模式。各地要坚持从实际出发，先立后破、因地制宜、分类指导。2024年3月5日，习近平总书记在参加十四届全国人大二次会议江苏代表团审议时强调。';
      longCustom.avatarUrl =
      'https://gips2.baidu.com/it/u=1651586290,17201034&fm=3028&app=3028&f=JPEG&fmt=auto&q=100&size=f600_800';
      longCustom.isOwner = true;
      longCustom.timestamp = new Date().getTime() / 1000;
      longCustom.chatId = '0';

      let custom = new ChatContentSingleModel();
      custom.chatType = ChatTypeEnum.CHAT_TYPE_TEXT;
      custom.textElem = '你好啊，😀😀😀';
      custom.avatarUrl =
      'https://gips2.baidu.com/it/u=1651586290,17201034&fm=3028&app=3028&f=JPEG&fmt=auto&q=100&size=f600_800';
      custom.isOwner = true;
      custom.timestamp = new Date().getTime() / 1000;
      custom.chatId = '1';

      let image = new ChatContentSingleModel();
      image.chatType = ChatTypeEnum.CHAT_TYPE_IMAGE;
      let imageModel = new ChatContentImage();
      imageModel.url =
      'https://gips2.baidu.com/it/u=1651586290,17201034&fm=3028&app=3028&f=JPEG&fmt=auto&q=100&size=f600_800';
      image.imageInfo = [imageModel];
      image.isOwner = false;
      image.avatarUrl =
      'https://gips2.baidu.com/it/u=1651586290,17201034&fm=3028&app=3028&f=JPEG&fmt=auto&q=100&size=f600_800';
      image.timestamp = new Date().getTime() / 1000;
      image.chatId = '2';

      let video = new ChatContentSingleModel();
      video.chatType = ChatTypeEnum.CHAT_TYPE_VIDEO;
      video.isOwner = false;
      video.videoChatSrc =
      'https://haokan.baidu.com/v?vid=2367902486523572908&pd=pcshare&hkRelaunch=p1%3Dpc%26p2%3Dvideoland%26p3%3Dshare_input';
      video.snapshotPath =
      'https://gips1.baidu.com/it/u=3309509281,2660302226&fm=3042&app=3042&f=JPEG&wm=1,baiduai3,0,0,13,9&wmo=5,5&w=640&h=480';
      video.avatarUrl =
      'https://gips2.baidu.com/it/u=1651586290,17201034&fm=3028&app=3028&f=JPEG&fmt=auto&q=100&size=f600_800';
      video.timestamp = new Date().getTime() / 1000;
      video.chatId = '3';

      let voice = new ChatContentSingleModel();
      voice.chatType = ChatTypeEnum.CHAT_TYPE_SOUND;
      voice.isOwner = true;
      voice.speechToText = '姐姐，好漂亮啊';
      voice.avatarUrl =
      'https://gips2.baidu.com/it/u=1651586290,17201034&fm=3028&app=3028&f=JPEG&fmt=auto&q=100&size=f600_800';
      let voiceModel = new ChatContentAudio()
      voiceModel.duration = 3;
      voiceModel.url = '语音文件链接';
      voice.soundInfo = voiceModel;
      voice.timestamp = new Date().getTime() / 1000;
      voice.chatId = '4';

      let location = new ChatContentSingleModel();
      location.chatType = ChatTypeEnum.CHAT_TYPE_LOCATION;
      location.isOwner = false;
      location.avatarUrl =
      'https://gips2.baidu.com/it/u=1651586290,17201034&fm=3028&app=3028&f=JPEG&fmt=auto&q=100&size=f600_800';
      location.locationName = '秣周东路悠湖产业园'
      location.locationLatitude = 31.86;
      location.locationLongitude = 118.82;
      location.timestamp = new Date().getTime() / 1000;
      location.chatId = '5';

      this.mockDataList = [
         custom, longCustom, image, video, voice, location
      ]
   }

   build() {
      Navigation(this.pageStack) {
         Column({ space: 15 }) {
            Text('添加测试用数据')
            Button('收藏一条短文本消息').onClick(() => {
               CollectDataManager.getInstance().addCollectMsg(this.mockDataList[0]);
            })
            Button('收藏一条长文本消息').onClick(() => {
               CollectDataManager.getInstance().addCollectMsg(this.mockDataList[1]);
            })
            Button('收藏一条图片消息').onClick(() => {
               CollectDataManager.getInstance().addCollectMsg(this.mockDataList[2]);
            })
            Button('收藏一条视频消息').onClick(() => {
               CollectDataManager.getInstance().addCollectMsg(this.mockDataList[3]);
            })
            Button('收藏一条语音消息').onClick(() => {
               CollectDataManager.getInstance().addCollectMsg(this.mockDataList[4]);
            })
            Button('收藏一条地图消息').onClick(() => {
               CollectDataManager.getInstance().addCollectMsg(this.mockDataList[5]);
            })
            Button('查看收藏列表').onClick(() => {
               this.pageStack.pushPath({ name: 'ChatHistoryCollectionPage' });
            })
         }
         .padding({
            top: 30,
            bottom: 30,
         })

      }
      .width('100%')
         .height('100%')
         .backgroundColor('#F1F3F5')
   }
}
```

### 三、新增ChatHistoryCollectionPage页面负责加载和展示收藏组件

```ts
import { ChatHistoryCollectionComponent } from 'chat_history_collection';
import { ChatContentSingleModel, ChatTypeEnum } from 'chat_history_collection';

@Builder
export function ChatHistoryCollectionPageBuilder() {
   ChatHistoryCollectionPage();
}

@ComponentV2
export struct ChatHistoryCollectionPage {
   @Local onChatBubbleClick: (chatVM: ChatContentSingleModel) => void =
      (chatVM: ChatContentSingleModel) => {
         if (chatVM.chatType === ChatTypeEnum.CHAT_TYPE_LOCATION) {
            //todo 定位消息点击事件
         } else if (chatVM.chatType === ChatTypeEnum.CHAT_TYPE_VIDEO) {
            //todo 视频消息点击事件
         } else if (chatVM.chatType === ChatTypeEnum.CHAT_TYPE_IMAGE) {
            //todo 图片消息点击事件
         } else if (chatVM.chatType === ChatTypeEnum.CHAT_TYPE_SOUND) {
            //todo 语音消息点击事件
         }
      };

   build() {
      NavDestination() {
         Column() {
            ChatHistoryCollectionComponent({
               onChatBubbleClick: this.onChatBubbleClick,
            })
         }
      }.title('收藏')
   }
}
```

### 四、新增ChatHistoryCollectionPage页面负责加载和展示收藏组件

配置新增页面的路由rote_map,参考：https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ts-basic-components-navigation#%E7%A4%BA%E4%BE%8B2%E4%BD%BF%E7%94%A8%E5%AF%BC%E8%88%AA%E6%8E%A7%E5%88%B6%E5%99%A8%E6%96%B9%E6%B3%95