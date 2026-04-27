# 网盘多级导航组件快速入门

## 目录
- [简介](#简介)
- [约束与限制](#约束与限制)
- [使用](#使用)
- [API参考](#API参考)
- [示例代码](#示例代码)

## 简介

本组件提供了网盘文件夹的多级目录导航功能，支持面包屑导航、目录层级跳转、返回上级等操作。让用户可以方便地在不同文件夹层级间浏览和切换，清晰展示当前所在位置。

多级导航界面

<img src='screenshots/multileval.jpg' style='max-height:350px;object-fit:contain'> 

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
   b. 在项目根目录build-profile.json5并添加cloud_multilevel_navigation模块和cloud_operation_item,cloud_file_base模块。
   ```typescript
   // 在项目根目录的build-profile.json5填写cloud_multilevel_navigation路径。其中xxx为组件存在的目录名
   "modules": [
     {
       "name": "cloud_multilevel_navigation",
       "srcPath": "./xxx/cloud_multilevel_navigation",
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
      "cloud_multilevel_navigation": "file:./xxx/cloud_multilevel_navigation",
   }
   ```

2. 引入组件。

   ```typescript
   import { FileBaseInfo, FileBaseType } from 'cloud_file_base';
   import { MultiLevelNavigationPageBuilder, MultiLevelNavigationPageViewModel } from 'cloud_multilevel_navigation';

   ```

3. 调用组件，详细参数配置说明参见[API参考](#API参考)。

   ```typescript
   // 通过路由跳转使用
   this.navPathStack.pushPathByName('PrivatespacePage', this.navigationVM, false)
   ```

## API参考

### 接口

#### MultiLevelNavigationPageBuilder

MultiLevelNavigationPageBuilder(param: MultiLevelNavigationPageViewModel)

多级导航页面构建器，通过路由跳转使用。

**参数：**

| 参数名 | 类型                              | 是否必填 | 说明           |
|--------|-----------------------------------|------|---------------|
| param  | [MultiLevelNavigationPageViewModel](#MultiLevelNavigationPageViewModel) | 是   | 多级导航视图模型 |

### 数据模型

#### MultiLevelNavigationPageViewModel

多级导航视图模型，继承自 FileBaseCheckViewModel，管理导航路径、文件列表和操作。

**构造函数：**

```typescript
constructor(fileInfo: FileBaseInfo)
```

**参数：**

| 参数名   | 类型                              | 是否必填 | 说明           |
|---------|-----------------------------------|------|---------------|
| fileInfo| [FileBaseInfo](#FileBaseInfo)     | 是   | 根目录文件信息 |

**主要属性：**

| 名称                      | 类型                                      | 说明                           |
|--------------------------|------------------------------------------|-------------------------------|
| levelDirectorList        | [FileBaseInfo](#FileBaseInfo)[]          | 多级目录列表（面包屑导航）      |
| fileList                 | [FileBaseInfo](#FileBaseInfo)[]          | 当前层级的文件列表             |
| sortIndex                | number                                   | 当前排序索引                   |
| sortList                 | string[]                                 | 排序列表（智能、按修改时间等）  |
| sortListIsVisible        | boolean                                  | 文件排序弹框是否可见           |
| filterIndex              | number                                   | 文件类型筛选索引               |
| filterTitles             | string[]                                 | 文件分类标题（全部、图片等）    |
| isFilterSelected         | boolean                                  | 筛选是否选中                   |
| operationList            | [OperationItemType](#OperationItemType)[]| 默认操作项列表                 |
| operationVM              | OperationItemViewModel                   | 底部操作项视图模型             |
| contentPadding           | Padding \| Length                        | 内边距                         |
| checkFileAction          | (index: number) => boolean               | 查看文件详情回调               |
| selectOperationItemAction| (type: [OperationItemType](#OperationItemType)) => boolean | 选择操作项回调 |

**主要方法：**

- `initializationResponses()`: 初始化响应事件
- `sortFileList(index: number)`: 文件排序
- `filterListBySelectedType(index: number)`: 类型分类筛选
- `changeToPrelevelDirector(index: number)`: 切换到指定层级目录
- `checkMultiLevelFileIds(index?: number)`: 获取多级fileId列表
- `addFileListToFileId(fileList: FileBaseInfo[], fileId: number)`: 添加文件到指定ID目录

#### FileBaseInfo

文件基础信息数据模型，来自 `cloud_file_base` 组件。

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

文件类型枚举，来自 `cloud_file_base` 组件。

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

#### OperationItemType

操作类型枚举，来自 `cloud_operation_item` 组件。

| 值 | 名称                  | 说明         |
|----|-----------------------|-------------|
| 0  | DOWNLOAD              | 下载         |
| 1  | DELETE                | 删除         |
| 2  | SHARE                 | 分享         |
| 3  | RENAME                | 重命名       |
| 4  | MOVE                  | 移动         |
| 5  | MOVETO_PRIVATESPACE   | 移入隐私空间 |
| 6  | MOVEOUT_PRIVATESPACE  | 移出隐私空间 |
| 7  | UNCOLLECTED           | 未收藏       |
| 8  | COLLECTED             | 已收藏       |
| 9  | CANCELSHARE           | 取消分享     |
| 10 | COPYLINK              | 复制链接     |

### 回调事件

#### checkFileAction

查看文件详情回调，当用户点击非目录文件时触发。

**参数：**

| 参数名  | 类型    | 说明         |
|---------|---------|-------------|
| index   | number  | 文件索引     |

**返回值：**

| 类型    | 说明         |
|---------|-------------|
| boolean | 是否成功处理 |

#### selectOperationItemAction

选择操作项回调，当用户选择底部操作项时触发。

**参数：**

| 参数名        | 类型                                  | 说明         |
|--------------|--------------------------------------|-------------|
| operationType| [OperationItemType](#OperationItemType) | 操作类型     |

**返回值：**

| 类型    | 说明         |
|---------|-------------|
| boolean | 是否成功处理 |


## 示例代码

展示多级导航页面的基本使用，包含文件夹层级导航和文件列表展示。

```typescript
import { 
  MultiLevelNavigationPageBuilder, MultiLevelNavigationPageViewModel, 
   FileBaseInfo, FileBaseType 
} from 'cloud_multilevel_navigation';

const folder2 = new FileBaseInfo();
folder2.fileId = 2;
folder2.name = '图片';
folder2.fileType = FileBaseType.DIRECTOR;
folder2.createTime = '2024-11-12 14:00';

@Entry
@ComponentV2
struct Index {
   private navPathStack: NavPathStack = new NavPathStack();
   navigationVM: MultiLevelNavigationPageViewModel = new MultiLevelNavigationPageViewModel(folder2);

   @Builder
   pageStackMap(name: string,
   vm: MultiLevelNavigationPageViewModel) {
      MultiLevelNavigationPageBuilder(vm)
   }

   public build(): void {
      Navigation(this.navPathStack) {
      Column() {
         // 在 FeedbackTrigger 中自定义触发样式，被点击时将自动跳转至问题反馈页面。
         Button('面包屑')
            .onClick(() => {
               this.navPathStack.pushPathByName('PrivatespacePage', this.navigationVM, false)
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
