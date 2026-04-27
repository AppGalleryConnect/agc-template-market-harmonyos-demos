# 聊天记录搜索组件快速入门

## 目录

- [简介](#简介)
- [约束与限制](#约束与限制)
- [使用](#使用)
- [API参考](#API参考)
- [示例代码](#示例代码)

## 简介

搜索组件，负责社交相关搜索功能，包括搜索聊天记录、收藏以及联系人，以及按日期搜索功能，搜索之后会有最近搜索历史记录，有搜索记录的时候会显示最近搜索，最多六条。
组件入参的userId和groupId不传即位全局搜索，可以搜索所有会话的聊天记录、收藏以及联系人，展示最近搜索记录。
组件入参的userId或者groupId有值时，只能搜索指定会话的聊天消息，不能搜索收藏、联系人，不显示最近搜索记录，但是会显示按日期搜索，可以选择日期筛选指定日期之后收发的所有消息。
组件默认为本地mock数据搜索，通过工具类SearchModelManager.setSearchModel(value: number)
来设置搜索模式，参数传0为本地mock数据搜索，默认为本地搜索，参数传1是云端搜索，云端搜索需用户自行实现，如接入三方sdk并开通其对应搜索服务。

| 全局搜索-最近搜索                                                   | 全局搜索-聊天记录                                                   | 全局搜索-收藏记录                                                   | 全局搜索-联系人                                                    |
|-------------------------------------------------------------|-------------------------------------------------------------|-------------------------------------------------------------|-------------------------------------------------------------| 
| <img src="screenshots/search0.png" alt="检测新版本" width="300"> | <img src="screenshots/search1.png" alt="检测新版本" width="300"> | <img src="screenshots/search2.png" alt="检测新版本" width="300"> | <img src="screenshots/search3.png" alt="检测新版本" width="300"> |

| 指定会话搜索-显示日期查找                                               | 指定会话搜索-日期选择                                                 | 指定会话搜索-日期查找-聊天记录                                            | 指定会话搜索-关键字查找-聊天记录                                           |
|-------------------------------------------------------------|-------------------------------------------------------------|-------------------------------------------------------------|-------------------------------------------------------------|
| <img src="screenshots/search4.png" alt="检测新版本" width="300"> | <img src="screenshots/search5.png" alt="检测新版本" width="300"> | <img src="screenshots/search6.png" alt="检测新版本" width="300"> | <img src="screenshots/search7.png" alt="检测新版本" width="300"> |

## 约束与限制

demo演示模式使用本地mock数据，云端聊天消息以及联系人搜索用户可自行实现，通过接口的形式传入，具体见demo，收藏没有云端搜索，只有本地搜索，若需云端搜索可自行仿照云端消息搜索和联系人搜索实现。
本模块需依赖收藏组件chat_history_collection。

### 环境

- DevEco Studio版本：DevEco Studio 5.0.5 Release及以上
- HarmonyOS SDK版本：HarmonyOS 5.0.3 Release SDK及以上
- 设备类型：华为手机（包括双折叠和阔折叠）
- 系统版本：HarmonyOS 5.0.3(15) 及以上

### 依赖

组件依赖@hw-agconnect/ui-calendar-picker日历组件（版本2.0.0）,需要在项目中配置此依赖。

### 权限

- 网络权限：ohos.permission.INTERNET

## 使用

1. 安装组件。  
   如果是在DevEco Studio使用插件集成组件，则无需安装组件，请忽略此步骤。
   如果是从生态市场下载组件，请参考以下步骤安装组件。  
   a. 解压下载的组件包，将包中所有文件夹拷贝至您工程根目录的xxx目录下。  
   b. 在项目根目录build-profile.json5并添加chat_base、chat_history_collection和chat_history_search模块。
   // 在项目根目录的build-profile.json5填写chat_base和chat_history_collection路径。其中xxx为组件存在的目录名
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
     },
      {
       "name": "chat_history_search",
       "srcPath": "./xxx/chat_history_search"
     }
   ]
   }
   ```
   c. 在项目根目录oh-package.json5中添加依赖
   // xxx为组件存放的目录名称
   ```json
   {
   "dependencies": {
     "chat_location": "file:./xxx/chat_history_collection",
     "chat_history_search": "file:./xxx/chat_history_search"
   }
   }
   ```

2. 引入组件。

   ```ts
   import { CollectDataManager } from 'chat_history_collection';
   import { ChatContentAudio, ChatContentImage, ChatContentSingleModel, ChatTypeEnum } from 'chat_history_search';
   import { ContactSearchModel, ConversationCacheModel, SearchDataMock } from 'chat_history_search';
   ```

   ```ts
   import { ChatHistorySearchComponent, ContactSearchModel, SearchModelManager } from 'chat_history_search';
   import { ChatContentSingleModel } from 'chat_history_search';
   ```

3. 调用组件，详细参数配置说明参见[API参考](#API参考)。

   mock数据源设置
   ```ts
    SearchDataMock.allMessageList = this.mockMessageDataList;
    SearchDataMock.allContactList = MOCK_ACCOUNT_LIST;
   ```
   搜索模式设置
    ```ts
   SearchModelManager.setSearchModel(0);
   ```
   组件引入使用
   ```ts
   Column() {
        ChatHistorySearchComponent({
          userId: this.userId,
          groupId: this.groupId,
          onCloudMessageSearch: this.onCloudMessageSearch,
          onCloudContactSearch: this.onCloudContactSearch
        });
      }
   ```

## API参考

### 接口

#### ChatHistorySearchComponent组件

ChatHistorySearchComponent(options: { userId: string, groupId: string, onCloudMessageSearch: (searchKey: string,
userId?: string, groupId?: string,
startDate?: number) => Promise<ChatContentSingleModel[]> }, onCloudContactSearch: (searchKey: string) => Promise<
ContactSearchModel[]> =
async (searchKey: string): Promise<ContactSearchModel[]> => })

收藏列表组件，展示收藏的聊天消息。

**参数：**

| 参数                   | 类型       | 是否必填 | 说明               |
|----------------------|----------|------|------------------|
| userId               | string   | 否    | 指定搜索对象的userId    |
| groupId              | string   | 否    | 指定搜索群聊对象的groupId |
| onCloudMessageSearch | Function | 否    | 云端搜索消息接口         |
| onCloudContactSearch | Function | 否    | 云端搜索联系人接口        |

**注意：** 组件使用 `@Param` 装饰器，参数通过对象形式传递。

#### setSearchModel接口

SearchModelManager.setSearchModel(0);

设置搜索模式，当实现了云端消息和联系人搜索接口以后，此接口设置为1时则为云端搜索，否则为本地搜索。

**参数：**

| 参数   | 类型     | 是否必填 | 说明                                  |
|------|--------|------|-------------------------------------|
| type | string | 是    | 0 本地mock数据搜索，默认；1 云端搜索，仅限聊天消息和联系人搜索 |

#### SearchDataMock.allMessageList

通过SearchDataMock.allMessageList设置本地聊天消息mock数据源。

**参数：**

| 参数   | 类型                                                  | 是否必填 | 说明             |
|------|-----------------------------------------------------|------|----------------|
| type | [ConversationCacheModel](#ConversationCacheModel)[] | 是    | 本地mock聊天消息数据搜索 |

#### SearchDataMock.allContactList

通过SearchDataMock.allContactList设置本地联系人mock数据源。

**参数：**

| 参数   | 类型                                          | 是否必填 | 说明            |
|------|---------------------------------------------|------|---------------|
| type | [ContactSearchModel](#ContactSearchModel)[] | 是    | 本地mock联系人数据搜索 |

### 数据模型

#### ChatWindowComponent

聊天窗口组件。

**参数：**

| 参数名               | 类型                                                                        | 必填 | 说明              |
|-------------------|---------------------------------------------------------------------------|----|-----------------|
| onReturnClick     | Function                                                                  | 是  | 返回事件回调          |
| chatContentList   | [ChatContentSingleModel](../chat_base/README.md#chatcontentsinglemodel)[] | 是  | 组件展示的数据内容       |
| title             | string                                                                    | 否  | 组件标题，聊天对象名称     |
| scroller          | ListScroller                                                              | 否  | 滑动组件控制器         |
| onChatBubbleClick | Function                                                                  | 否  | 聊天消息点击事件回调      |
| onChatAvatarClick | Function                                                                  | 否  | 头像点击事件回调        |
| isShowRightImage  | boolean                                                                   | 否  | 是否展示右上角更多按钮     |
| menuList          | MenuElement[]                                                             | 否  | 右上角更多按钮点击后的弹框内容 |

#### ContactSearchModel

联系人搜索对象，为好友对象的部分需要字段集合。

**构造函数：**

```ts
constructor(userId:
string, nickName:
string, avatarUrl:
string
)
```

**属性：**

| 参数名       | 类型     | 说明   |
|-----------|--------|------|
| userId    | string | 用户id |
| nickName  | string | 用户昵称 |
| avatarUrl | string | 用户头像 |

#### ConversationCacheModel

聊天消息搜索数据源对象，包含用户id、群组id、会话id以及对应聊天消息集合。

**构造函数：**

```typescript
constructor()
```

**属性：**

| 参数名              | 类型                       | 说明   |
|------------------|--------------------------|------|
| userId           | string                   | 用户id |
| groupID          | string                   | 群组id |
| conversationID   | string                   | 会话id |
| allCachedMsgList | ChatContentSingleModel[] | 消息集合 |

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

#### 2、需提前开通地图权限，否则地图无法显示，开通方式参考：https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/map-config-agc#section16133115441516。

### 二、编辑Index页面负责Mock添加收藏的消息

```ts
import { buffer } from '@kit.ArkTS';
import { CollectDataManager } from 'chat_history_collection';
import { ChatContentAudio, ChatContentImage, ChatContentSingleModel, ChatTypeEnum } from 'chat_history_search';
import { ContactSearchModel, ConversationCacheModel, SearchDataMock } from 'chat_history_search';

const MOCK_ACCOUNT_LIST: ContactSearchModel[] = [
   new ContactSearchModel('user_one', 'Michael',
      'https://gips2.baidu.com/it/u=1651586290,17201034&fm=3028&app=3028&f=JPEG&fmt=auto&q=100&size=f600_800'),
   new ContactSearchModel('user_two', 'James',
      'https://gips2.baidu.com/it/u=1651586290,17201034&fm=3028&app=3028&f=JPEG&fmt=auto&q=100&size=f600_800'),
   new ContactSearchModel('user_three', 'David',
      'https://gips2.baidu.com/it/u=1651586290,17201034&fm=3028&app=3028&f=JPEG&fmt=auto&q=100&size=f600_800'),
   new ContactSearchModel('user_four', 'Daniel',
      'https://gips2.baidu.com/it/u=1651586290,17201034&fm=3028&app=3028&f=JPEG&fmt=auto&q=100&size=f600_800'),
   new ContactSearchModel('user_five', 'William',
      'https://gips2.baidu.com/it/u=1651586290,17201034&fm=3028&app=3028&f=JPEG&fmt=auto&q=100&size=f600_800'),
   new ContactSearchModel('user_six', 'Benjamin',
      'https://gips2.baidu.com/it/u=1651586290,17201034&fm=3028&app=3028&f=JPEG&fmt=auto&q=100&size=f600_800'),
] as ContactSearchModel[];

const TEXT_USER_ID: string = 'TEXT_USER_ID';

@Entry
@ComponentV2
struct Index {
   pageStack: NavPathStack = new NavPathStack();
   @Local mockMessageDataList: ConversationCacheModel[] = []
   @Local mockCollectDataList: ChatContentSingleModel[] = []
   @Local mockContactDataList: ContactSearchModel[] = []

   strToArrayBuffer(content: string) {
      return buffer.from(content, 'utf-8').buffer;
   }

   aboutToAppear(): void {
      this.setMockCollectData();
      this.mockCollectDataList.forEach((item) => {
      let conversationCacheModel = new ConversationCacheModel();
      conversationCacheModel.userId = item.userId;
      conversationCacheModel.conversationID = new Date().getTime().toString();
      let chatVM = this.chatParseMessageModel(item);
      conversationCacheModel.allCachedMsgList = [chatVM];
      this.mockMessageDataList.push(conversationCacheModel);
   })
   SearchDataMock.allMessageList = this.mockMessageDataList;
   SearchDataMock.allContactList = MOCK_ACCOUNT_LIST;
}

setMockCollectData() {
   let longCustom = new ChatContentSingleModel();
   longCustom.chatType = ChatTypeEnum.CHAT_TYPE_TEXT;
   longCustom.textElem = '你好啊，😀😀😀，发展新质生产力不是要忽视、放弃传统产业，要防止一哄而上、泡沫化，也不要搞一种模式。各地要坚持从实际出发，先立后破、因地制宜、分类指导。2024年3月5日，习近平总书记在参加十四届全国人大二次会议江苏代表团审议时强调。';
   longCustom.avatarUrl =
      'https://gips2.baidu.com/it/u=1651586290,17201034&fm=3028&app=3028&f=JPEG&fmt=auto&q=100&size=f600_800';
   longCustom.isOwner = true;
   longCustom.timestamp = new Date().getTime() / 1000;
   longCustom.chatId = '0';
   longCustom.userId = TEXT_USER_ID;
   CollectDataManager.getInstance().addCollectMsg(longCustom);

   let custom = new ChatContentSingleModel();
   custom.chatType = ChatTypeEnum.CHAT_TYPE_TEXT;
   custom.textElem = '你好啊，😀😀😀';
   custom.avatarUrl =
      'https://gips2.baidu.com/it/u=1651586290,17201034&fm=3028&app=3028&f=JPEG&fmt=auto&q=100&size=f600_800';
   custom.isOwner = true;
   custom.timestamp = new Date().getTime() / 1000;
   custom.chatId = '1';
   custom.userId = TEXT_USER_ID;
   CollectDataManager.getInstance().addCollectMsg(custom);

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
   image.userId = TEXT_USER_ID;
   CollectDataManager.getInstance().addCollectMsg(image);

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
   video.userId = TEXT_USER_ID;
   CollectDataManager.getInstance().addCollectMsg(video);

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
   voice.userId = TEXT_USER_ID;
   CollectDataManager.getInstance().addCollectMsg(voice);

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
   location.userId = TEXT_USER_ID;
   CollectDataManager.getInstance().addCollectMsg(location);

   let custom1 = new ChatContentSingleModel();
   custom1.chatType = ChatTypeEnum.CHAT_TYPE_TEXT;
   custom1.textElem = '你好啊111，😀😀😀';
   custom1.avatarUrl =
      'https://gips2.baidu.com/it/u=1651586290,17201034&fm=3028&app=3028&f=JPEG&fmt=auto&q=100&size=f600_800';
   custom1.isOwner = true;
   custom1.timestamp = new Date().getTime() / 1000;
   custom1.chatId = '6';
   custom1.userId = TEXT_USER_ID;
   CollectDataManager.getInstance().addCollectMsg(custom1);

   let custom2 = new ChatContentSingleModel();
   custom2.chatType = ChatTypeEnum.CHAT_TYPE_TEXT;
   custom2.textElem = '你好啊2222，😀😀😀';
   custom2.avatarUrl =
      'https://gips2.baidu.com/it/u=1651586290,17201034&fm=3028&app=3028&f=JPEG&fmt=auto&q=100&size=f600_800';
   custom2.isOwner = true;
   custom2.timestamp = new Date().getTime() / 1000;
   custom2.chatId = '7';
   custom2.userId = TEXT_USER_ID;
   CollectDataManager.getInstance().addCollectMsg(custom2);


   let custom3 = new ChatContentSingleModel();
   custom3.chatType = ChatTypeEnum.CHAT_TYPE_TEXT;
   custom3.textElem = '你好啊333，😀😀😀';
   custom3.avatarUrl =
      'https://gips2.baidu.com/it/u=1651586290,17201034&fm=3028&app=3028&f=JPEG&fmt=auto&q=100&size=f600_800';
   custom3.isOwner = true;
   custom3.timestamp = new Date().getTime() / 1000;
   custom3.chatId = '8';
   custom3.userId = TEXT_USER_ID;
   CollectDataManager.getInstance().addCollectMsg(custom3);

   this.mockCollectDataList = [
      custom, longCustom, image, video, voice, location, custom1, custom2, custom3
   ]
}

chatParseMessageModel(element: ChatContentSingleModel) {
   let chatVM = new ChatContentSingleModel();
   chatVM.chatType = element.chatType;
   chatVM.textElem = element.textElem;
   chatVM.avatarUrl = element.avatarUrl;
   chatVM.isOwner = element.isOwner;
   chatVM.timestamp = element.timestamp;
   chatVM.chatId = element.chatId ?? '';
   chatVM.locationName = element.locationName;
   return chatVM;
}

build() {
   Navigation(this.pageStack) {
      Column({ space: 15 }) {
         Button('全局搜索(不指定userId/groupId)').onClick(() => {
            this.pageStack.pushPathByName('ChatHistorySearchPage', undefined);
         })
         Button('指定会话搜索(指定userId/groupId)').onClick(() => {
            this.pageStack.pushPathByName('ChatHistorySearchPage', { 'userId': TEXT_USER_ID } as Record<string, string>);
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
import { ChatHistorySearchComponent, ContactSearchModel, SearchModelManager } from 'chat_history_search';
import { ChatContentSingleModel } from 'chat_history_search';

@Builder
export function ChatHistorySearchPageBuilder(name: object, param: object) {
   ChatHistorySearchPage({ userId: param?.['userId'], groupId: param?.['groupId'] });
}

@ComponentV2
export struct ChatHistorySearchPage {
   @Local pageStack?: NavPathStack;
   @Param @Require userId: string | undefined
   @Param @Require groupId: string | undefined
   @Local onReturnClick: () => void = () => {
      this.pageStack?.pop();
   }
   onCloudMessageSearch: (searchKey: string, userId?: string, groupId?: string,
      startDate?: number) => Promise<ChatContentSingleModel[]> =
      async (searchKey: string, userId?: string, groupId?: string,
         startDate?: number): Promise<ChatContentSingleModel[]> => {
         return new Promise<ChatContentSingleModel[]>((res,rej) => {
            // todo 云端聊天消息搜索
         })
      };
   onCloudContactSearch: (searchKey: string) => Promise<ContactSearchModel[]> =
      async (searchKey: string): Promise<ContactSearchModel[]> => {
         return new Promise<ContactSearchModel[]>((res,rej) => {
            // todo 云端联系人搜索
         })
      };

   aboutToAppear(): void {
      SearchModelManager.setSearchModel(0); //默认0 0为本地搜索 1为云端搜索 只针对消息和联系人 收藏只有本地搜索
   }

   build() {
      NavDestination() {
         Column() {
            ChatHistorySearchComponent({
               userId: this.userId,
               groupId: this.groupId,
               onCloudMessageSearch: this.onCloudMessageSearch,
               onCloudContactSearch: this.onCloudContactSearch,
               onReturnClick: this.onReturnClick,
            });
         }
      }.hideTitleBar(true)
         .onReady((context) => {
            this.pageStack = context.pathStack;
         })
   }
}
```

### 四、新增ChatHistorySearchPage页面负责加载和展示收藏组件

配置新增页面的路由rote_map,参考：https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ts-basic-components-navigation#%E7%A4%BA%E4%BE%8B2%E4%BD%BF%E7%94%A8%E5%AF%BC%E8%88%AA%E6%8E%A7%E5%88%B6%E5%99%A8%E6%96%B9%E6%B3%95