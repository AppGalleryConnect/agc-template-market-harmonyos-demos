# 聊天基础组件快速入门

## 目录

- [简介](#简介)
- [约束与限制](#约束与限制)
- [使用](#使用)
- [API参考](#API参考)

## 简介

本组件提供了社交交友聊天组件的基础工具类、数据结构类和图片、视频查看组件。

| 查看聊天图片                                                              | 查看聊天视频                                                              |
|---------------------------------------------------------------------|---------------------------------------------------------------------|
| <img src="screenshots/chat_image_look.jpeg" alt="聊天图片" width="300"> | <img src="screenshots/chat_video_look.jpeg" alt="聊天视频" width="300"> | 

## 约束与限制

### 环境

- DevEco Studio版本：DevEco Studio 5.0.5 Release及以上
- HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上
- 设备类型：华为手机（包括双折叠和阔折叠）
- 系统版本：HarmonyOS 5.0.3(15) 及以上

### 权限

- 无

## 使用

安装组件。

如果是在DevEco Studio使用插件集成组件，则无需安装组件，请忽略此步骤。

如果是从生态市场下载组件，请参考以下步骤安装组件。

a. 解压下载的组件包，将包中所有文件夹拷贝至您工程根目录的xxx目录下。

b. 在项目根目录build-profile.json5并添加chat_base模块。

在项目根目录的build-profile.json5填写chat_base路径。其中xxx为组件存在的目录名

```json
{
  "modules": [
    {
      "name": "chat_base",
      "srcPath": "./XXX/chat_base"
    }
  ]
}
```

## API参考

### 接口

#### FullScreenImagePage

全屏展示图片，支持返回与保存到相册

FullScreenImagePage(options: { imgSrc: string; backAction?: () => void })

**参数：**

| 参数名        | 类型         | 是否必填 | 说明       |
|------------|------------|------|----------|
| imgSrc     | string     | 是    | 图片链接     |
| backAction | () => void | 否    | 返回点击事件回调 |

#### VideoPage

播放聊天视频，支持静音/暂停与保存至相册

VideoPage(options: { videoChatSrc: string; videoStatus: boolean; onReturnClick?: () => void })

**参数：**

| 参数名          | 类型         | 是否必填 | 说明       |
|--------------|------------|------|----------|
| videoChatSrc | string     | 是    | 链接链接     |
| videoStatus  | boolean    | 是    | 视频状态     |
| backAction   | () => void | 否    | 返回点击事件回调 |

#### DownloadUtils

图片、文件下载工具类

**主要属性：**

| 参数名               | 类型                    | 说明   |
|-------------------|-----------------------|------|
| progressCallback  | Function \| undefined | 进度回调 |
| completedCallback | Function \| undefined | 完成回调 |
| failedCallback    | Function \| undefined | 失败回调 |

**主要方法：**

- `async downloadImage(imageUrl: string, callback: (localPath: string) => void)`: 下载图片到沙箱路径
- `async downloadFile(url: string, callback: (progress: number, isSuccess: boolean, localPath: string) => void)`: 下载文件
- `async deleteTask()`: 取消任务

#### RcpDownloader

视频下载工具类

**主要属性：**

| 参数名               | 类型                    | 说明   |
|-------------------|-----------------------|------|
| progressCallback  | Function \| undefined | 进度回调 |
| completedCallback | Function \| undefined | 完成回调 |
| failedCallback    | Function \| undefined | 失败回调 |

**主要方法：**

- `async startDownload(url: string, fileName: string): Promise<rcp.Response>`: 初始化下载任务

#### SaveAlbumTool

保存工具类

**主要方法：**

- `async saveHttpVideo(videoFilePath: string, context: UIContext)`: 保存视频到文本文件
- `async saveAlbum(filePath: string, context: UIContext)`: 保存到相册

#### TimeUtil

日期时间工具类

**主要属性：**

| 参数名                               | 类型     | 说明                        |
|-----------------------------------|--------|---------------------------|
| PATTERN_DATE_TIME_DEFAULT         | string | yyyyMMddHHmmss格式          |
| PATTERN_DATE_TIME_HYPHEN          | string | yyyy-MM-dd HH:mm:ss格式     |
| PATTERN_DATE_TIME_HYPHEN_MS       | string | yyyy-MM-dd HH:mm:ss.SSS格式 |
| PATTERN_DATE_TIME_SLASH           | string | yyyy/MM/dd HH:mm:ss格式     |
| PATTERN_DATE_TIME_BACK_SLASH      | string | yyyy\\MM\\dd HH:mm:ss格式   |
| PATTERN_DATE_TIME_DOT             | string | yyyy.MM.dd HH:mm:ss格式     |
| PATTERN_DATE_TIME_CN              | string | yyyy年MM月dd日 HH:mm:ss格式    |
| PATTERN_DATE_TIME_CN_MONTH        | string | MM月dd日 HH:mm格式            |
| PATTERN_DATE_TIME_MS              | string | yyyyMMddHHmmssSSS格式       |
| PATTERN_DATE_TIME_WITHOUT_SECOND  | string | yyyyMMddHHmm格式            |
| PATTERN_DATE_TIME_SIMPLIFY        | string | MM/dd HH:mm格式             |
| PATTERN_DATE_DEFAULT              | string | yyyyMMdd格式                |
| PATTERN_DATE_HYPHEN               | string | yyyy-MM-dd格式              |
| PATTERN_DATE_SLASH                | string | yyyy/MM/dd式               |
| PATTERN_DATE_BACK_SLASH           | string | yyyy\\MM\\dd格式            |
| PATTERN_TIME_WITHOUT_SECOND       | string | HHmm格式                    |
| PATTERN_TIME_COLON_WITHOUT_SECOND | string | HH:mm格式                   |

**主要方法：**

- `static parseDate(dateTimeString: string, format: string = TimeUtil.PATTERN_DATE_HYPHEN, referenceDate?: Date): number`:
  根据日期/时间字符串反序列化对应的时间戳
- `static parseDuration(dateTimeString: string, format: string = TimeUtil.PATTERN_TIME_COLON_DOT_MS): number`:
  根据时间字符串反序列化对应的时长
- `static formatDate(timestamp: number, format: string = TimeUtil.PATTERN_DATE_HYPHEN, isFill: boolean = true): string`:
  把整数时间戳格式化为指定格式的日期+时间字符串
- `static formatCommentData(time: number): string`: 预约时间格式，与当前时间作比较

### 数据模型

#### ChatContentSingleModel

聊天消息结构类

**主要属性：**

| 参数名               | 类型                                            | 说明                                                |
|-------------------|-----------------------------------------------|---------------------------------------------------|
| forwardMessage    | Object                                        | 转发的消息对象                                           |
| chatId            | string                                        | 消息 ID                                             |
| ConversationType  | [ChatConversationType](#ChatConversationType) | 会话类型                                              |
| timestamp         | number                                        | 消息的 UTC 时间戳                                       |
| nickName          | string                                        | 消息发送者昵称                                           |
| friendRemark      | string                                        | 消息发送者好友备注                                         |
| avatarUrl         | string                                        | 消息发送者头像                                           |
| chatType          | [ChatTypeEnum](#ChatTypeEnum)                 | 消息元素类型                                            |
| groupId           | string                                        | 如果是群组消息，groupID 为会话群组 ID，否则为空                     |
| userId            | string                                        | 如果是单聊消息，userID 为会话用户 ID，否则为空                      |
| sender            | string                                        | 消息发送者                                             |
| keyId             | string                                        | 消息序列号                                             |
| isOwner           | boolean                                       | 消息发送者是否是自己                                        |
| textElem          | string                                        | 消息类型 为 CHAT_TYPE_TEXT，textElem 会存储文本消息内容          |
| locationName      | string                                        | 消息类型 为 CHAT_TYPE_LOCATION，地理位置名称                  |
| locationDesc      | string                                        | 消息类型 为 CHAT_TYPE_LOCATION，地理位置描述信息                |
| locationLongitude | number                                        | 消息类型 为 CHAT_TYPE_LOCATION，经度，发送消息时设置              |
| locationLatitude  | number                                        | 消息类型 为 CHAT_TYPE_LOCATION，纬度，发送消息时设置              |
| groupTipContent   | string                                        | 消息类型 为 CHAT_GROUP_TIPS，群消息提醒内容                    |
| imageInfo         | [ChatContentImage](#ChatContentImage)[]       | 消息类型 为 CHAT_TYPE_IMAGE，ChatContentImage 会存储图片消息内容 |
| soundInfo         | [ChatContentAudio](#ChatContentAudio)         | 消息类型 为 CHAT_ELEM_TYPE_SOUND，soundInfo 会存储语音消息内容   |
| speechToText      | string                                        | 语音转换文字内容                                          |
| videoChatSrc      | string                                        | 视频URL                                             |
| type              | string                                        | 视频类型                                              |
| duration          | number                                        | 视频时间                                              |
| snapshotPath      | string                                        | 视频封面                                              |

#### ChatContentImage

图片消息结构类

**主要属性：**

| 参数名    | 类型     | 说明                     |
|--------|--------|------------------------|
| uuid   | string | 图片 ID，内部标识，可用于外部缓存 key |
| type   | number | 图片类型，1: 原图，2：缩略图，4：大图  |
| size   | number | 图片大小（type == 1 有效）     |
| width  | number | 图片宽度                   |
| height | number | 图片高度                   |
| url    | string | 图片 url                 |

#### ChatContentAudio

语音消息结构类

**主要属性：**

| 参数名      | 类型     | 说明               |
|----------|--------|------------------|
| path     | string | 语音文件路径，只有发送方才能获取 |
| uuid     | string | 语音消息内部 ID        |
| dataSize | number | 语音数据大小           |
| duration | number | 语音长度（秒）          |
| url      | string | 获取语音的 URL 下载地址   |

#### ChatConversationType

聊天会话类型枚举

**枚举：**

| 值 | 名称           | 说明 |
|---|--------------|----|
| 0 | CHAT_UNKNOWN | 未知 |
| 1 | CHAT_C2C     | 单聊 |
| 2 | CHAT_GROUP   | 群聊 |

#### ChatTypeEnum

聊天消息类型枚举

**枚举：**

| 值 | 名称                 | 说明     |
|---|--------------------|--------|
| 0 | CHAT_TYPE_NONE     | 未知消息   |
| 1 | CHAT_TYPE_TEXT     | 文本消息   |
| 3 | CHAT_TYPE_IMAGE    | 图片消息   |
| 4 | CHAT_TYPE_SOUND    | 语音消息   |
| 5 | CHAT_TYPE_VIDEO    | 视频消息   |
| 7 | CHAT_TYPE_LOCATION | 地理位置消息 |
| 9 | CHAT_GROUP_TIPS    | 群通知提醒  |

#### ChatBreakpoint

一多适配的数据结构类

**主要属性：**

| 参数名                | 类型     | 说明            |
|--------------------|--------|---------------|
| topValue           | number | 顶部状态栏高度       |
| bottomValue        | number | 底部状态栏高度       |
| currentScreenWidth | number | 当前屏幕宽度        |
| pagePadding        | number | 根据当前断点，获取页面边距 |

**主要方法：**

- `getColumnWidth(uiContext: UIContext): number`: 根据栅格化动态获取每栅格宽度