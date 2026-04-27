# 网盘视图切换组件快速入门

## 目录
- [简介](#简介)
- [约束与限制](#约束与限制)
- [使用](#使用)
- [API参考](#API参考)
- [示例代码](#示例代码)

## 简介

本组件提供了完整的文件视图管理功能，包括列表/宫格视图切换、文件排序、类型筛选、文件选择和批量操作等功能。组件继承自 FileBaseCheckViewModel，支持文件的多选、全选、查看、下载、删除、分享、重命名、移动等操作。
列表视图

<img src='screenshots/view_switch.jpg' style='max-height:350px;object-fit:contain'> |

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
   b. 在项目根目录build-profile.json5并添加cloud_view_switch模块和cloud_operation_item,cloud_file_base模块。
   ```typescript
   // 在项目根目录的build-profile.json5填写cloud_view_switch路径。其中xxx为组件存在的目录名
   "modules": [
     {
       "name": "cloud_view_switch",
       "srcPath": "./xxx/cloud_view_switch",
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
      "cloud_view_switch": "file:../xxx/cloud_view_switch",
   }
   ```

2. 引入组件。

   ```typescript
   import { 
     FileViewSwitchView,
     FileViewSwitchViewModel
   } from 'cloud_view_switch';
   import { FileBaseInfo, FileBaseType } from 'cloud_file_base';
   import { OperationItemType } from 'cloud_operation_item';
   ```

3. 调用组件，详细参数配置说明参见[API参考](#API参考)。

   ```typescript
   // 创建视图模型并初始化
   const viewSwitchVM = new FileViewSwitchViewModel(fileList);
   viewSwitchVM.initializationResponses();
   
   // 使用组件
   FileViewSwitchView({
     vm: viewSwitchVM
   })
   ```

## API参考

### 接口

#### FileViewSwitchView

FileViewSwitchView(options: { vm: FileViewSwitchViewModel })

文件视图管理组件，提供列表/宫格视图切换、排序、筛选和批量操作功能。

**参数：**

| 参数名 | 类型                          | 是否必填 | 说明           |
|-------|-----------------------------|------|---------------|
| vm    | [FileViewSwitchViewModel](#FileViewSwitchViewModel) | 是    | 视图切换模型   |

**注意：** 组件使用 `@Require @Param` 装饰器，vm 为必填参数。

### 数据模型

#### FileViewSwitchViewModel

文件视图切换视图模型，继承自 FileBaseCheckViewModel，管理文件列表、视图模式、排序和筛选状态。

**构造函数：**

```typescript
constructor(
  fileList?: FileBaseInfo[],
  clickAction?: (index: number) => void,
  selectAction?: (index: number) => void,
  switchAllSelectedAction?: (isAllSelected: boolean) => void
)
```

**参数：**

| 参数名                  | 类型                               | 是否必填 | 说明           |
|------------------------|-----------------------------------|------|---------------|
| fileList               | [FileBaseInfo](#FileBaseInfo)[]   | 否   | 文件列表       |
| clickAction            | (index: number) => void           | 否   | 点击项回调     |
| selectAction           | (index: number) => void           | 否   | 选中项回调     |
| switchAllSelectedAction| (isAllSelected: boolean) => void  | 否   | 全选/反选回调  |

**主要属性：**

| 名称                      | 类型                                      | 说明                           |
|--------------------------|------------------------------------------|-------------------------------|
| isListVisibleGridMode    | boolean                                  | 是否为宫格模式（继承自父类）    |
| fileList                 | [FileBaseInfo](#FileBaseInfo)[]          | 文件列表（继承自父类）          |
| selectedIndexes          | Set\<number\>                            | 选中索引集合（继承自父类）      |
| isShow                   | boolean                                  | 操作弹框是否展示（继承自父类）  |
| operationVM              | OperationItemViewModel                   | 底部操作项视图模型             |
| currentSortIndex         | number                                   | 当前排序索引                   |
| isSortDialogVisible      | boolean                                  | 文件排序弹框是否可见           |
| sortList                 | string[]                                 | 排序列表内容                   |
| isFilterSelected         | boolean                                  | 筛选是否选中                   |
| fileTypeTitles           | string[]                                 | 文件分类数据                   |
| fileTypeIndex            | number                                   | 文件类型索引                   |
| viewFileAction           | (index: number) => boolean               | 查看文件详情回调               |
| viewDirectorAction       | (index: number) => boolean               | 查看目录详情回调               |
| selectOperationItemAction| (operationItem: [OperationItemType](#OperationItemType)) => boolean | 选择操作项回调            |

**主要方法：**

- `initializationResponses()`: 初始化响应事件
- `reInitializeAgain(fileList: FileBaseInfo[])`: 重新初始化文件列表
- `sortFileList(index: number)`: 文件排序
- `filterListBySelectedType(index: number)`: 类型分类筛选
- `addFileListToPrivateSpace(fileList: FileBaseInfo[])`: 添加到隐私空间
- `addFileListToRoot(fileList: FileBaseInfo[])`: 添加到根目录
- `addFileListByFileId(fileList: FileBaseInfo[], fileId: number)`: 添加到指定ID目录
- `switchAllSelected()`: 全选/反选（继承自父类）
- `checkIsAllSelected()`: 检测是否全部选中（继承自父类）
- `getAllSelected()`: 获取所有选中项（继承自父类）
- `getAllSelectedIds()`: 获取所有选中项ID（继承自父类）
- `deleteAllSelected()`: 删除选中项（继承自父类）

#### FileBaseInfo

文件基础信息数据模型，来自 `cloud_file_base` 组件。

**主要属性：**

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

#### viewFileAction

查看文件详情回调，当用户点击非目录文件时触发。

**参数：**

| 参数名  | 类型    | 说明         |
|---------|---------|-------------|
| index   | number  | 文件索引     |

**返回值：**

| 类型    | 说明         |
|---------|-------------|
| boolean | 是否成功处理 |

#### viewDirectorAction

查看目录详情回调，当用户点击文件夹时触发。

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

```typescript
import { promptAction } from '@kit.ArkUI';
import {
   FileViewSwitchView, FileViewSwitchViewModel,
   FileBaseInfo, FileBaseType,
   OperationItemType
} from 'cloud_view_switch';

@Entry
@ComponentV2
export struct ViewSwitchTestPage {
   // 视图切换模型
   @Local viewSwitchVM: FileViewSwitchViewModel = new FileViewSwitchViewModel()

   aboutToAppear() {
      // 创建模拟文件列表
      const fileList: FileBaseInfo[] = this.createMockFileList();

      // 初始化视图模型
      this.viewSwitchVM = new FileViewSwitchViewModel(fileList);

      // 设置查看文件回调
      this.viewSwitchVM.viewFileAction = (index: number) => {
         const fileInfo = this.viewSwitchVM.fileList[index];
         console.info('查看文件:', fileInfo.name);
         promptAction.showToast({ message: `打开文件: ${fileInfo.name}` });
         return true;
      };

      // 设置查看文件夹回调
      this.viewSwitchVM.viewDirectorAction = (index: number) => {
         const fileInfo = this.viewSwitchVM.fileList[index];
         console.info('进入文件夹:', fileInfo.name);
         promptAction.showToast({ message: `进入文件夹: ${fileInfo.name}` });
         return true;
      };

      // 设置操作项选择回调
      this.viewSwitchVM.selectOperationItemAction = (type: OperationItemType) => {
         console.info('选择操作:', type);
         const selectedFiles = this.viewSwitchVM.getAllSelected();
         console.info('选中文件数量:', selectedFiles.length);

         switch (type) {
            case OperationItemType.DOWNLOAD:
               promptAction.showToast({ message: '下载文件' });
               break;
            case OperationItemType.DELETE:
               promptAction.showToast({ message: '删除文件' });
               this.viewSwitchVM.deleteAllSelected();
               break;
            case OperationItemType.SHARE:
               promptAction.showToast({ message: '分享文件' });
               break;
            case OperationItemType.RENAME:
               promptAction.showToast({ message: '重命名文件' });
               break;
            case OperationItemType.MOVE:
               promptAction.showToast({ message: '移动文件' });
               break;
            case OperationItemType.MOVETO_PRIVATESPACE:
               promptAction.showToast({ message: '移入隐私空间' });
               break;
            case OperationItemType.COLLECTED:
            case OperationItemType.UNCOLLECTED:
               promptAction.showToast({ message: '收藏/取消收藏' });
               break;
            default:
               break;
         }
         return true;
      };

      // 初始化响应事件
      this.viewSwitchVM.initializationResponses();
   }

   createMockFileList(): FileBaseInfo[] {
      const fileList: FileBaseInfo[] = [];

      // 创建文件1
      const file1 = new FileBaseInfo();
      file1.fileId = 1;
      file1.name = '项目文档.pdf';
      file1.fileType = FileBaseType.FILE;
      file1.fileSize = '2.5MB';
      file1.createTime = '2024-11-20 10:30';
      file1.isCollected = false;
      fileList.push(file1);

      // 创建文件2
      const file2 = new FileBaseInfo();
      file2.fileId = 2;
      file2.name = '设计图.jpg';
      file2.fileType = FileBaseType.PICTURE;
      file2.fileSize = '5.8MB';
      file2.createTime = '2024-11-18 14:20';
      file2.isCollected = true;
      fileList.push(file2);

      // 创建文件夹
      const folder1 = new FileBaseInfo();
      folder1.fileId = 3;
      folder1.name = '工作文件夹';
      folder1.fileType = FileBaseType.DIRECTOR;
      folder1.createTime = '2024-11-15 09:00';
      folder1.isCollected = false;
      fileList.push(folder1);

      // 创建视频文件
      const file3 = new FileBaseInfo();
      file3.fileId = 4;
      file3.name = '演示视频.mp4';
      file3.fileType = FileBaseType.VIDEO;
      file3.fileSize = '125.3MB';
      file3.createTime = '2024-11-10 16:45';
      file3.isCollected = false;
      fileList.push(file3);

      // 创建音频文件
      const file4 = new FileBaseInfo();
      file4.fileId = 5;
      file4.name = '会议录音.mp3';
      file4.fileType = FileBaseType.AUDIO;
      file4.fileSize = '8.2MB';
      file4.createTime = '2024-11-05 11:20';
      file4.isCollected = true;
      fileList.push(file4);

      return fileList;
   }

   build() {
      Column() {
         // 顶部标题栏
         Row() {
            Text('文件管理')
               .fontSize(18)
               .fontWeight(FontWeight.Bold)
               .layoutWeight(1)

            // 操作按钮
            Button('全选')
               .fontSize(14)
               .height(32)
               .onClick(() => {
                  this.viewSwitchVM.switchAllSelected();
               })
               .margin({ right: 10 })

            Button('添加文件')
               .fontSize(14)
               .height(32)
               .onClick(() => {
                  const newFile = new FileBaseInfo();
                  newFile.fileId = Date.now();
                  newFile.name = `新文件${this.viewSwitchVM.fileList.length + 1}.txt`;
                  newFile.fileType = FileBaseType.FILE;
                  newFile.fileSize = '0.5MB';
                  newFile.createTime = new Date().toLocaleString();
                  newFile.isCollected = false;

                  this.viewSwitchVM.addFileListToRoot([newFile]);
                  this.viewSwitchVM.reInitializeAgain(this.viewSwitchVM.fileList);
                  promptAction.showToast({ message: '已添加文件' });
               })
         }
         .width('100%')
            .padding(16)
            .backgroundColor('#FFFFFF')

         Divider()

         // 文件视图组件（包含排序、筛选、列表/宫格切换）
         FileViewSwitchView({
            vm: this.viewSwitchVM
         })

         // 底部信息栏
         Row() {
            Text(`视图模式: ${this.viewSwitchVM.isListVisibleGridMode ? '宫格' : '列表'}`)
               .fontSize(14)
               .fontColor('#666666')

            Text(`文件数量: ${this.viewSwitchVM.fileList.length}`)
               .fontSize(14)
               .fontColor('#666666')
               .margin({ left: 20 })

            Text(`已选中: ${this.viewSwitchVM.selectedIndexes.size}`)
               .fontSize(14)
               .fontColor('#666666')
               .margin({ left: 20 })
         }
         .width('100%')
            .padding(16)
            .backgroundColor('#FFFFFF')
      }
      .height('100%')
         .width('100%')
         .backgroundColor('#F8F8F8')
   }
}
```
