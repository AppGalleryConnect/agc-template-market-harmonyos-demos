# 网盘隐私空间组件快速入门

## 目录
- [简介](#简介)
- [约束与限制](#约束与限制)
- [使用](#使用)
- [API参考](#API参考)
- [示例代码](#示例代码)

## 简介

本组件提供了网盘隐私空间文件管理功能，展示隐私空间下的文件列表，支持文件选择、查看、下载、移动、重命名、删除等操作。组件继承自文件基础组件，提供与普通文件管理类似的功能，但专门用于隐私空间场景。

隐私空间界面

<img src='screenshots/private.jpg' style='max-height:350px;object-fit:contain'> |

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
   b. 在项目根目录build-profile.json5并添加cloud_privatespace模块和cloud_operation_item,cloud_file_base模块。
   ```typescript
   // 在项目根目录的build-profile.json5填写cloud_privatespace路径。其中xxx为组件存在的目录名
   "modules": [
     {
       "name": "cloud_privatespace",
       "srcPath": "./xxx/cloud_privatespace",
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
      "cloud_privatespace": "file:./xxx/cloud_privatespace"
   }
   ```

2. 引入组件。

   ```typescript
import { FileBaseInfo, FileBaseType } from 'cloud_file_base';
import { PrivatespacePageBuilder, PrivatespacePageViewModel } from 'cloud_privatespace';
   ```

3. 调用组件，详细参数配置说明参见[API参考](#API参考)。

   ```typescript
   // 通过路由跳转使用
   this.navPathStack.pushPathByName('PrivatespacePage',this.privatespaceVM,false)
   ```

## API参考

### 接口

#### PrivatespacePageBuilder

PrivatespacePageBuilder(param: PrivatespacePageViewModel)

隐私空间页面构建器，通过路由跳转使用。

**参数：**

| 参数名 | 类型                        | 是否必填 | 说明           |
|--------|----------------------------|------|---------------|
| param  | [PrivatespacePageViewModel](#PrivatespacePageViewModel) | 是    | 隐私空间视图模型 |

### 数据模型

#### PrivatespacePageViewModel

隐私空间视图模型，继承自 FileBaseCheckViewModel，管理隐私空间文件列表和操作。

**主要属性：**

| 名称                      | 类型                                                            | 说明                   |
|--------------------------|---------------------------------------------------------------|------------------------|
| fileList                 | [FileBaseInfo](#FileBaseInfo)[]                               | 隐私文件列表（继承自父类） |
| selectedIndexes          | Set\<number\>                                                 | 选中索引集合（继承自父类） |
| isShow                   | boolean                                                       | 操作弹框是否展示（继承自父类） |
| isListVisibleGridMode    | boolean                                                       | 是否宫格模式展示（继承自父类） |
| listSource               | [FileBaseCheckViewModelSource](#FileBaseCheckViewModelSource) | 列表展示来源（继承自父类） |
| contentPadding           | Padding \| Length \| LocalizedPadding                         | 内边距              |
| operationList            | [OperationItemType](#OperationItemType)[]                     | 默认操作项列表         |
| operationVM              | [OperationItemViewModel](#OperationItemViewModel)             | 底部操作项视图模型     |
| checkFileAction          | (index: number) => boolean                                    | 查看文件详情回调       |
| checkDirectorAction      | (index: number) => boolean                                    | 查看文件夹回调         |
| selectOperationItemAction| (type: [OperationItemType](#OperationItemType)) => boolean    | 选择操作项回调         |

**主要方法：**

- `initializationResponses()`: 初始化响应事件
- `addFileListToTargetFileId(fileList: FileBaseInfo[], fileId: number)`: 添加文件到指定ID目录
- `switchAllSelected()`: 全选/反选（继承自父类）
- `checkIsAllSelected()`: 检测是否全部选中（继承自父类）
- `getAllSelected()`: 获取所有选中项（继承自父类）
- `getAllSelectedIds()`: 获取所有选中项ID（继承自父类）
- `deleteAllSelected()`: 删除选中项（继承自父类）

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

#### OperationItemViewModel

底部操作项视图模型，来自 `cloud_operation_item` 组件，管理文件操作项的展示和交互。

**构造函数：**

```typescript
constructor(
  items?: OperationItemType[],
  callbackAction?: (actionType: OperationItemType) => void
)
```

**参数：**

| 参数名         | 类型                                      | 是否必填 | 说明                                                                                     |
|----------------|-------------------------------------------|----------|------------------------------------------------------------------------------------------|
| items          | [OperationItemType](#OperationItemType)[] | 否       | 操作项列表，默认包含下载、删除、分享、重命名、移动、移入隐私空间、收藏                   |
| callbackAction | (actionType: [OperationItemType](#OperationItemType)) => void | 否       | 选择操作项回调函数                                                                       |

**主要属性：**

| 名称                   | 类型                                      | 说明                     |
|------------------------|-------------------------------------------|--------------------------|
| showList               | OperationItemModel[]                      | 展示的操作项列表         |
| operationList          | [OperationItemType](#OperationItemType)[] | 支持的操作类型列表       |
| originalOperationCount | number                                    | 原始操作项数量           |
| didSelectedItemAction  | (actionType: [OperationItemType](#OperationItemType)) => void | 选择操作项回调函数       |

#### FileBaseCheckViewModelSource

列表展示来源枚举，来自 `cloud_file_base` 组件，用于标识文件列表的来源场景。

| 值 | 名称         | 说明     |
|---|------------|--------|
| 0 | DEFAULT    | 默认列表   |
| 1 | SHARE      | 分享列表   |
| 2 | COLLECT    | 收藏列表   |
| 3 | RECYCLEBIN | 回收站列表  |

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

#### checkDirectorAction

查看文件夹回调，当用户点击文件夹时触发。

**参数：**

| 参数名  | 类型    | 说明         |
|---------|---------|-------------|
| index   | number  | 文件夹索引   |

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

展示隐私空间页面的基本使用，包含文件列表展示和操作功能。

```typescript
import { PrivatespacePageBuilder, PrivatespacePageViewModel, FileBaseInfo, FileBaseType } from 'cloud_privatespace';

// 创建模拟隐私文件数据
const file1 = new FileBaseInfo();
file1.fileId = 1;
file1.name = '私密照片.jpg';
file1.fileType = FileBaseType.PICTURE;
file1.fileSize = '3.2MB';
file1.createTime = '2024-11-20 10:30';

const file2 = new FileBaseInfo();
file2.fileId = 2;
file2.name = '重要文档.pdf';
file2.fileType = FileBaseType.FILE;
file2.fileSize = '1.5MB';
file2.createTime = '2024-11-18 14:20';

const folder1 = new FileBaseInfo();
folder1.fileId = 3;
folder1.name = '私密文件夹';
folder1.fileType = FileBaseType.DIRECTOR;
folder1.createTime = '2024-11-15 09:00';

const  fileList = [file1, file2, folder1];

@Entry
@ComponentV2
struct Index {
   private navPathStack: NavPathStack = new NavPathStack();
   privatespaceVM: PrivatespacePageViewModel = new PrivatespacePageViewModel(fileList);

   @Builder
   pageStackMap(name: string,
   vm: PrivatespacePageViewModel) {
      PrivatespacePageBuilder(vm)
   }
   public build(): void {
      Navigation(this.navPathStack) {
      Column() {
         // 在 FeedbackTrigger 中自定义触发样式，被点击时将自动跳转至问题反馈页面。
         Button('隐私空间')
            .onClick(()=>{
               this.navPathStack.pushPathByName('PrivatespacePage',this.privatespaceVM,false)
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
