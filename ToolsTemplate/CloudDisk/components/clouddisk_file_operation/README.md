# 网盘文件操作组件快速入门

## 目录

- [简介](#简介)
- [约束与限制](#约束与限制)
- [快速入门](#快速入门)
- [API参考](#API参考)
- [示例代码](#示例代码)

## 简介

本组件提供了网盘文件操作的相关功能，包括文件的下载、删除、分享、重命名、移动、收藏等常见操作，以及新建文件夹与上传文件的入口。组件可与文件选择组件联动，根据选中文件自动调整可用操作项。

| 文件操作菜单 | 新建文件/文件夹 | 文件夹命名 |
|---------|---------|---------|
| <img src='screenshot/screenshot01.jpg' style='max-height:350px;object-fit:contain'> | <img src='screenshot/screenshot02.jpg' style='max-height:350px;object-fit:contain'> | <img src='screenshot/screenshot03.jpg' style='max-height:350px;object-fit:contain'> |

## 约束与限制

### 环境

- DevEco Studio版本：DevEco Studio 5.0.5 Release及以上
- HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上
- 设备类型：华为手机（包括双折叠和阔折叠）
- 系统版本：HarmonyOS 5.0.3(15) 及以上

## 快速入门

1. 安装组件。  
   如果是在DevEco Studio使用插件集成组件，则无需安装组件，请忽略此步骤。
   如果是从生态市场下载组件，请参考以下步骤安装组件。  
   a. 解压下载的组件包，将包中所有文件夹拷贝至您工程根目录的xxx目录下。  
   b. 在项目根目录build-profile.json5并添加clouddisk_file_operation模块。
   ```typescript
   // 在项目根目录的build-profile.json5填写clouddisk_file_operation路径。其中xxx为组件存在的目录名
   "modules": [
     {
       "name": "clouddisk_file_operation",
       "srcPath": "./xxx/clouddisk_file_operation",
     }
   ]
   ```
   c. 在项目根目录oh-package.json5中添加依赖
   ```typescript
   // xxx为组件存放的目录名称
   "dependencies": {
     "clouddisk_file_operation": "file:./xxx/clouddisk_file_operation",
     "common": "file:./commons/common",
     "module_share": "file:./components/module_share",
     "module_cloud_upload": "file:./components/module_cloud_upload",
     "coulddisk_file_select": "file:./components/coulddisk_file_select"
   }
   ```

2. 引入组件。

   ```typescript
   import {
     OperationSelect,
     NewFolderInputSelect,
     NewFileFolderOperationSelect,
     FileOperationModel,
     FileOperationType,
     OperationSelectVM,
     NewFileFolderOperationSelectVM
   } from 'clouddisk_file_operation';
   ```

3. 调用组件，详细参数配置说明参见[API参考](#API参考)。

   ```typescript
   // 文件操作选择组件
   OperationSelect({ 
     vm: this.opVM, 
     bgColor: '#F1F3F5',
     paddingBottom: 10
   })
   
   // 新建文件/文件夹操作组件
   NewFileFolderOperationSelect({ 
     vm: this.newVM,
     addFileSuccess: (fileInfo: FileInfo) => {
       console.info('文件上传成功:', fileInfo.name);
     }
   })
   
   // 新建文件夹输入组件
   NewFolderInputSelect({
     originName: '新建文件夹',
     imageSrc: $r('app.media.folder'),
     closeWithResult: (text?: string) => {
       if (text) {
         console.info('创建文件夹:', text);
       }
     }
   })
   ```

## API参考

### 接口

#### OperationSelect

OperationSelect(options: { vm?: OperationSelectVM; bgColor?: Color | string; paddingBottom?: number })

文件操作选择组件，提供文件的各种操作入口。

**参数：**

| 参数名           | 类型                                      | 是否必填 | 说明                                            |
|---------------|-----------------------------------------|----|-----------------------------------------------|
| vm            | [OperationSelectVM](#OperationSelectVM) | 否  | 操作视图模型，默认 OperationSelectVM.defaultInstance() |
| bgColor       | Color \| string                         | 否  | 背景色，默认 #F1F3F5                                |
| paddingBottom | number                                  | 否  | 底部内边距，默认 0                                    |

#### NewFileFolderOperationSelect

NewFileFolderOperationSelect(options: { vm: NewFileFolderOperationSelectVM; addFileSuccess?: (fileInfo: FileInfo) =>
void })

新建文件/文件夹操作入口组件。

**参数：**

| 参数名            | 类型                                  | 是否必填 | 说明          |
|----------------|-------------------------------------|----|-------------|
| vm             | [NewFileFolderOperationSelectVM](#NewFileFolderOperationSelectVM) | 是  | 上传/新建入口的 VM |
| addFileSuccess | (fileInfo: FileInfo) => void        | 否  | 文件上传成功回调函数  |

#### NewFolderInputSelect

NewFolderInputSelect(options: { originName?: string; imageSrc?: ResourceStr; closeWithResult?: (text?: string) =>
void })

新建文件夹命名输入组件，作为子弹窗或子页面使用。

**参数：**

| 参数名             | 类型                      | 是否必填 | 说明                           |
|-----------------|-------------------------|----|------------------------------|
| originName      | string                  | 否  | 原始名称，默认 '新建文件夹'              |
| imageSrc        | ResourceStr             | 否  | 图标资源，默认 $r('app.media.file') |
| closeWithResult | (text?: string) => void | 否  | 关闭回调函数，返回输入的文本               |

### 数据模型

#### FileOperationModel

文件操作项数据模型。

| 名称            | 类型                     | 是否必填 | 说明     |
|---------------|------------------------|----|--------|
| operationType | [FileOperationType](#FileOperationType) | 是  | 操作类型   |
| name          | string                 | 是  | 操作名称   |
| iconNormal    | Resource               | 是  | 普通状态图标 |
| iconSelected  | Resource               | 是  | 选中状态图标 |

#### FileOperationType

操作类型枚举。

| 值 | 名称                  | 说明      |
|---|---------------------|---------|
| 0 | Download            | 下载      |
| 1 | Delete              | 删除      |
| 2 | Share               | 分享      |
| 3 | Rename              | 重命名     |
| 4 | Move                | 移动      |
| 5 | MoveToPrivateSpace  | 移动到隐私空间 |
| 6 | MoveOutPrivateSpace | 移出隐私空间  |
| 7 | Collect             | 收藏      |

### ViewModel

#### OperationSelectVM

操作选择视图模型。

**主要方法：**

- `updateFileList(fileList: FileInfo[])`: 根据选中文件动态调整操作项
- `changeFileName(name: string)`: 更新当前文件名

#### NewFileFolderOperationSelectVM

新建文件/文件夹操作视图模型。

**主要属性：**

- `isShow: boolean`: 是否显示新建入口布局
- `isShowInput: boolean`: 是否显示新建文件夹对话框

## 示例代码

```typescript
import {
   OperationSelect,
   OperationSelectVM,
   NewFileFolderOperationSelect,
   NewFileFolderOperationSelectVM,
   NewFolderInputSelect,
   FileOperationType
} from 'clouddisk_file_operation';
import { FileListSelectViewVM } from 'coulddisk_file_select';
import { FileInfo, FileType } from 'common';
import { MainPageVM } from 'clouddisk_homepage/src/main/ets/viewmodel/MainPageVM';
import { promptAction } from '@kit.ArkUI';

@Entry
@ComponentV2
export struct clouddiskTestPage {
   // 模拟文件数据
   fileList: FileInfo[] = [
      new FileInfo(
         FileType.Picture, // fileType
         '图片.jpg', // name
         '2024-10-28'// createTime
      )];
   vm: MainPageVM = new MainPageVM()
   // 选中列表由文件选择组件维护
   selectVM: FileListSelectViewVM = new FileListSelectViewVM(
      this.fileList,
      (index: number) => {
         console.info('点击文件:', this.fileList[index].name);
      },
      (index: number) => {
         console.info('选中文件:', this.fileList[index].name);
         // 同步选中文件到操作组件
         const selected: FileInfo[] = this.fileList.filter((_, i) => this.selectVM.selectedIndexes.has(i));
         this.opVM.updateFileList(selected);
      }
   );
   // 操作入口 VM
   opVM: OperationSelectVM = new OperationSelectVM([
      FileOperationType.Download,
      FileOperationType.Delete,
      FileOperationType.Share,
      FileOperationType.Rename,
      FileOperationType.Move,
      FileOperationType.MoveToPrivateSpace,
      FileOperationType.Collect
   ])
   newVM: NewFileFolderOperationSelectVM = new NewFileFolderOperationSelectVM();

   aboutToAppear() {
      // 初始化选中列表并同步给操作组件
      const selected: FileInfo[] = this.fileList.filter((_, i) => this.selectVM.selectedIndexes.has(i));
      this.opVM.updateFileList(selected);
   }

   build() {
      Column({ space: 20 }) {
         Text('网盘文件操作示例')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .margin({ bottom: 20 })

         Button('文件操作')
            .onClick(() => {
               this.vm.isShow = !this.vm.isShow
            })
            .bindSheet($$this.vm.isShow, this.dealWithFileSheet(),
               {
                  showClose: false,
                  height: 112,
                  enableOutsideInteractive: true,
                  maskColor: Color.Transparent,
                  radius: { topLeft: 0, topRight: 0 }
               })


         Button('新建文件/文件夹')
            .onClick(() => {
               this.newVM.isShow = !this.newVM.isShow
            })
            .bindSheet($$this.newVM.isShow, this.newFilefolderSheet(),
               {
                  showClose: false,
                  height: 384,
                  enableOutsideInteractive: false,
                  radius: { topLeft: 24, topRight: 24 }
               })

         // 新建文件夹输入组件
         Button('文件夹命名')
            .onClick(() => {
               promptAction.openCustomDialog({
                  builder: () => {
                     this.inputCustomDialog()
                  },
                  alignment: DialogAlignment.Center,
                  width: '90%'
               })
            })


         // 操作状态显示
         Text(`已选中 ${this.selectVM.selectedIndexes.size} 个文件`)
            .fontSize(14)
            .fontColor('#666666')
            .margin({ top: 20 })
      }
      .height('100%')
         .width('100%')
         .padding(16)
         .margin({ top: 60 })
         .justifyContent(FlexAlign.Center)

   }

   @Builder
   dealWithFileSheet() {

      // 文件操作入口
      OperationSelect({
         vm: this.opVM,
         bgColor: '#F1F3F5',
         paddingBottom: 10
      })
   }

   @Builder
   newFilefolderSheet() {
      // 新建/上传入口
      NewFileFolderOperationSelect({
         vm: this.newVM,
         addFileSuccess: (fileInfo: FileInfo) => {
            console.info('文件上传成功:', fileInfo.name);
            // 将新上传的文件添加到列表中
            this.fileList.push(fileInfo);
         }
      })
   }

   @Builder
   inputCustomDialog() {
      NewFolderInputSelect({
         originName: '新建文件夹',
         imageSrc: $r('app.media.file'),
         closeWithResult: (text?: string) => {
            this.newVM.isShowInput = false;
            if (text && text !== '新建文件夹') {
               console.info('创建文件夹:', text);
               // 处理文件夹创建逻辑
            }
         }
      })
   }
}
```