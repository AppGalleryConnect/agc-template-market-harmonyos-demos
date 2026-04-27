# 网盘分享管理组件快速入门

## 目录
- [简介](#简介)
- [约束与限制](#约束与限制)
- [使用](#使用)
- [API参考](#API参考)
- [示例代码](#示例代码)

## 简介

本组件提供了网盘文件分享管理功能，包括我的分享列表展示、分享详情查看、分享状态管理等。支持按状态筛选（全部分享、分享中、分享过期），查看下载浏览次数、修改有效期、复制提取码、取消分享、再次分享等操作。

| 我的分享 | 分享详情 |
|--------|---------|
| <img src='screenshots/sharelist.jpg' style='max-height:350px;object-fit:contain'>| <img src='screenshots/sharedetail.jpg' style='max-height:350px;object-fit:contain'> |

## 约束与限制

### 环境

- DevEco Studio版本：DevEco Studio 5.0.5 Release及以上
- HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上
- 设备类型：华为手机（包括双折叠和阔折叠）
- 系统版本：HarmonyOS 5.0.3(15) 及以上

### 权限

- 无

### 依赖

本组件依赖以下组件：

- cloud_file_base：网盘文件基础组件
- cloud_operation_item：网盘文件操作项组件

## 使用

1. 安装组件。  
   如果是在DevEco Studio使用插件集成组件，则无需安装组件，请忽略此步骤。
   如果是从生态市场下载组件，请参考以下步骤安装组件。  
   a. 解压下载的组件包，将包中所有文件夹拷贝至您工程根目录的xxx目录下。  
   b. 在项目根目录build-profile.json5并添加cloud_share模块和cloud_operation_item,cloud_file_base模块。
   ```typescript
   // 在项目根目录的build-profile.json5填写cloud_share路径。其中xxx为组件存在的目录名
   "modules": [
     {
       "name": "cloud_share",
       "srcPath": "./xxx/cloud_share",
     },
     {
       "name": "cloud_operation_item",
       "srcPath": "./xxx/cloud_operation_item"
     },
     {
       "name": "cloud_file_base",
       "srcPath": "./xxx/cloud_file_base"
     },
   ]
   ```
   c. 在项目根目录oh-package.json5中添加依赖
   ```typescript
   // xxx为组件存放的目录名称
   "dependencies": {
      "cloud_share": "file:../xxx/cloud_share",
   }
   ```

2. 引入组件。

   ```typescript
   import { MySharePageBuilder, MySharePageViewModel } from 'cloud_share';
   ```

3. 调用组件，详细参数配置说明参见[API参考](#API参考)。

   ```typescript
   // 我的分享页面
   this.navPathStack.pushPathByName('MySharePage',new MySharePageViewModel(createMockShareFiles()),false)
   ```

## API参考

### 接口

#### MySharePageBuilder

MySharePageBuilder(param: MySharePageViewModel)

我的分享页面构建器，通过路由跳转使用。

**参数：**

| 参数名 | 类型                  | 是否必填 | 说明           |
|--------|----------------------|------|---------------|
| param  | [MySharePageViewModel](#MySharePageViewModel) | 是    | 我的分享视图模型 |

#### ShareDetailPageBuilder

ShareDetailPageBuilder(param: ShareDetailPageViewModel)

分享详情页面构建器，通过路由跳转使用。

**参数：**

| 参数名 | 类型                      | 是否必填 | 说明           |
|--------|--------------------------|------|---------------|
| param  | [ShareDetailPageViewModel](#ShareDetailPageViewModel) | 是    | 分享详情视图模型 |

### 数据模型

#### MySharePageViewModel

我的分享视图模型，管理分享列表和筛选状态。

**构造函数：**

```typescript
constructor(allFileList: FileBaseInfo[], contentPadding: Padding | Length | LocalizedPadding = 0)
```

**参数：**

| 参数名         | 类型                                  | 是否必填 | 说明           |
|---------------|--------------------------------------|------|---------------|
| allFileList   | [FileBaseInfo](#FileBaseInfo)[]      | 是   | 所有文件列表   |
| contentPadding| Padding \| Length \| LocalizedPadding | 否   | 内边距         |

**主要属性：**

| 名称            | 类型                                | 说明               |
|----------------|-------------------------------------|-------------------|
| fileTypeIndex  | number                              | 当前选中索引       |
| isShowList     | boolean[]                           | 操作栏显示状态数组 |
| fileTypeTitles | string[]                            | 分类标题数组       |
| tabListVM      | FileBaseCheckViewModel[]            | 标签页视图模型数组 |
| checkShareDetail | (fileBaseInfo: [FileBaseInfo](#FileBaseInfo)) => void | 跳转文件详情回调 |
| shareAgain     | (fileBaseInfo: [FileBaseInfo](#FileBaseInfo)) => void | 再次分享回调     |
| contentPadding | Padding \| Length \| LocalizedPadding | 内边距         |

**主要方法：**

- `static getAllOperation(fileList: FileBaseInfo[], currentIndex: number): OperationItemType[]`: 获取所有可用操作项
- `static getButtonWidth(): number`: 获取按钮宽度

#### ShareDetailPageViewModel

分享详情视图模型，管理单个分享的详细信息。

**构造函数：**

```typescript
constructor(fileInfo: FileBaseInfo, contentPadding: Padding | Length | LocalizedPadding = 0)
```

**参数：**

| 参数名         | 类型                                  | 是否必填 | 说明           |
|---------------|--------------------------------------|------|---------------|
| fileInfo      | [FileBaseInfo](#FileBaseInfo)        | 是   | 文件信息       |
| contentPadding| Padding \| Length \| LocalizedPadding | 否   | 内边距         |

**主要属性：**

| 名称                | 类型                                                                                      | 说明           |
|--------------------|------------------------------------------------------------------------------------------|---------------|
| shareExtureInfoVM  | [ShareDetailRowViewInfoViewModel](#ShareDetailRowViewInfoViewModel)                     | 分享详情行视图信息模型 |
| fileInfo           | [FileBaseInfo](#FileBaseInfo)                                                            | 文件信息       |
| contentPadding     | Padding \| Length \| LocalizedPadding                                                    | 内边距         |
| blockUsefullTime   | (id: number, value: string \| Resource) => void                                          | 有效期修改回调 |
| shareAgains        | (fileBaseInfo: [FileBaseInfo](#FileBaseInfo)) => void                                    | 再次分享回调   |
| changeExpiretime   | (fileBaseInfo: [FileBaseInfo](#FileBaseInfo), blockUsefullTime: (id: number, value: string \| Resource) => void, usefullTimeId?: number) => void | 有效期修改回调 |

**主要方法：**

- `static getButtonWidth(): number`: 获取按钮宽度

#### ShareDetailRowViewInfoViewModel

分享详情行视图信息视图模型。

| 名称           | 类型     | 说明           |
|---------------|---------|---------------|
| usefullTime   | string  | 有效时间       |
| usefullTimeId | number  | 有效时间ID     |

**注意：** 组件使用 `FileBaseInfo` 作为文件信息数据模型，该模型来自 `cloud_file_base` 组件。

### 回调事件

#### checkShareDetail

查看分享详情回调（MySharePageViewModel）。

**回调参数：**

| 参数名       | 类型                              | 说明       |
|-------------|----------------------------------|-----------|
| fileBaseInfo| [FileBaseInfo](#FileBaseInfo)    | 文件信息   |

#### shareAgain

再次分享回调（MySharePageViewModel）。

**回调参数：**

| 参数名       | 类型                              | 说明       |
|-------------|----------------------------------|-----------|
| fileBaseInfo| [FileBaseInfo](#FileBaseInfo)    | 文件信息   |

#### shareAgains

再次分享回调（ShareDetailPageViewModel）。

**回调参数：**

| 参数名       | 类型                              | 说明       |
|-------------|----------------------------------|-----------|
| fileBaseInfo| [FileBaseInfo](#FileBaseInfo)    | 文件信息   |

#### changeExpiretime

有效期修改回调（ShareDetailPageViewModel）。

**回调参数：**

| 参数名           | 类型                                                    | 说明           |
|-----------------|--------------------------------------------------------|---------------|
| fileBaseInfo    | [FileBaseInfo](#FileBaseInfo)                          | 文件信息       |
| blockUsefullTime| (id: number, value: string \| Resource) => void        | 有效期回调     |
| usefullTimeId   | number                                                 | 有效时间ID     |

#### FileBaseInfo

文件基础信息数据模型。

| 名称           | 类型                                  | 说明                  |
|--------------|-------------------------------------|---------------------|
| fileId       | number                              | 文件唯一标识              |
| parentFileId | number                              | 父文件ID               |
| name         | string                              | 文件名                 |
| fileType     | [FileBaseType](#FileBaseType)       | 文件类型                |
| fileSize     | string                              | 文件大小                |
| createTime   | string                              | 文件创建时间              |
| updateTime   | string                              | 文件更新时间              |
| isCollected  | boolean                             | 是否已收藏               |
| isPrivate    | boolean                             | 是否隐私文件              |
| downloadUrl  | string                              | 资源下载路径              |
| thumbnailUrl | string                              | 缩略图路径               |
| path         | string                              | 本地路径                |
| resolution   | string                              | 文件尺寸（图片/视频）         |
| contentList  | [FileBaseInfo](#FileBaseInfo)[]     | 子文件列表（文件夹）          |
| expireTime   | number                              | 过期时间（0-未设置，-1-永久有效） |
| expire       | boolean                             | 是否过期                |
| usefullTime  | string                              | 有效期描述               |
| getCode      | string                              | 提取码                 |


**主要方法：**

- `removeFileBaseExtension(): string` - 删除文件扩展名后缀
- `checkShareExpireTime(): string` - 获取分享过期时间描述
- `checkShareExpireTimeColor(): ResourceColor` - 获取分享过期时间文本颜色
- `changeTimeBy(content: string): void` - 根据文本内容修改过期时间戳
- `toJSON(): FileBaseInfoPlain` - 序列化为 JSON 对象
- `static fromJSON(json: string): FileBaseInfo` - 从 JSON 字符串反序列化
- `static fromPlain(obj: Partial<FileBaseInfoPlain>): FileBaseInfo` - 从普通对象构建实例


#### FileBaseType

文件类型枚举。

| 值 | 名称           | 说明   |
|---|--------------|------|
| 0 | ALL          | 全部   |
| 1 | PICTURE      | 图片   |
| 2 | VIDEO        | 视频   |
| 3 | FILE         | 文件   |
| 4 | AUDIO        | 音频   |
| 5 | OTHER        | 其他   |
| 6 | DIRECTOR     | 文件夹  |
| 7 | PRIVATESPACE | 隐私空间 |

## 示例代码

本示例展示两个页面：
1. **我的分享列表页**：展示分享文件列表，支持按状态筛选
2. **分享详情页**：点击列表项后显示，展示文件详细信息

```typescript
// 我的分享页
// Index.page
import { 
  MySharePageBuilder, MySharePageViewModel, 
   FileBaseInfo, FileBaseType 
} from 'cloud_share';

// 创建模拟分享文件数据
function createMockShareFiles(): FileBaseInfo[] {
   const fileList: FileBaseInfo[] = [];

   // 分享有效的文件1
   const file1 = new FileBaseInfo();
   file1.fileId = 1;
   file1.name = '项目文档.pdf';
   file1.fileType = FileBaseType.FILE;
   file1.fileSize = '2.5MB';
   file1.createTime = '2024-11-20 10:30';
   file1.expireTime = -1; // -1表示永久有效
   file1.downloadUrl = 'https://share.example.com/abc123';
   fileList.push(file1);

   // 分享有效的文件2
   const file2 = new FileBaseInfo();
   file2.fileId = 2;
   file2.name = '设计图.png';
   file2.fileType = FileBaseType.PICTURE;
   file2.fileSize = '5.8MB';
   file2.createTime = '2024-11-18 14:20';
   file2.expireTime = -1;
   file2.downloadUrl = 'https://share.example.com/def456';
   fileList.push(file2);

   // 分享过期的文件3
   const file3 = new FileBaseInfo();
   file3.fileId = 3;
   file3.name = '会议记录.docx';
   file3.fileType = FileBaseType.FILE;
   file3.fileSize = '1.2MB';
   file3.createTime = '2024-11-10 09:15';
   file3.expireTime = 2; // 2表示已过期
   file3.downloadUrl = 'https://share.example.com/ghi789';
   fileList.push(file3);

   // 分享过期的文件4
   const file4 = new FileBaseInfo();
   file4.fileId = 4;
   file4.name = '培训视频.mp4';
   file4.fileType = FileBaseType.VIDEO;
   file4.fileSize = '156.8MB';
   file4.createTime = '2024-11-05 16:30';
   file4.expireTime = 2;
   file4.downloadUrl = 'https://share.example.com/jkl012';
   fileList.push(file4);

   return fileList;
}

@Entry
@ComponentV2
struct Index {
   private navPathStack: NavPathStack = new NavPathStack();
   @Builder
   pageStackMap(name: string,
   vm: MySharePageViewModel) {
      MySharePageBuilder(vm)
   }
   public build(): void {
      Navigation(this.navPathStack) {
      Column() {
         // 在 FeedbackTrigger 中自定义触发样式，被点击时将自动跳转至问题反馈页面。
         Button('我的分享')
            .onClick(()=>{
               this.navPathStack.pushPathByName('MySharePage',new MySharePageViewModel(createMockShareFiles()),false)
            })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
   }
      .hideTitleBar(true)
      .mode(NavigationMode.Stack)
      .navDestination(this.pageStackMap)
}
}
```
