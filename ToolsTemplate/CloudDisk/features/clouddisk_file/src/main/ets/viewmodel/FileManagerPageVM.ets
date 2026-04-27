import { FileViewSwitchViewModel } from 'cloud_view_switch';
import { FileBaseCheckViewModel, FileBaseInfo, FileBaseInfoPlain, FileBaseType } from 'cloud_file_base';
import {
  BarVM,
  EmitterUtil,
  FileInfo,
  FileType,
  GlobalContext,
  MockService,
  PreferenceConstant,
  PreferenceUtil,
  RouterMap,
  TCLogger,
  UserInfo
} from 'common';
import {
  FileTransferDownloadPageVM,
  FileTransferManagerPageVM,
  SettingPrivateSpacePasswordPageBuilder
} from '../../../../Index';
import { PersistenceV2 } from '@kit.ArkUI';
import { NavPageInfo, phoneRouterControl } from 'oh_router';
import { VipCenterPageBuilder } from 'collect_personal_info';
import { ImageVideoPageBuilder, ImageVideoPageVM } from 'clouddisk_file_detail';
import { OperationItemType } from 'cloud_operation_item';
import { MoveDirectorFirstPageBuilder, MoveDirectorFirstPageParam } from '../pages/MoveDirectorFirstPage';
import { PopViewUtils, ShareSheetParams } from 'module_share';
import { FirstPosterShareBuilder } from 'module_share/src/main/ets/buider/FirstPosterShareBuilder';
import { MultiLevelNavigationPageBuilder, MultiLevelNavigationPageViewModel } from 'cloud_multilevel_navigation';
import { PrivatespacePageBuilder, PrivatespacePageViewModel } from 'cloud_privatespace';
import { BusinessError, emitter } from '@kit.BasicServicesKit';
import { FileOperationUtil } from 'module_cloud_upload';
import { filePreview } from '@kit.PreviewKit';
import { fileUri } from '@kit.CoreFileKit';

const TAG: string = 'FileManagerPageVM';

// 文件tab主页
@ObservedV2
export class FileManagerPageVM {
  // 文件根目录，移动文件需要用到
  private static _rootInstance: FileManagerPageVM;

  public static get rootInstance(): FileManagerPageVM {
    if (FileManagerPageVM._rootInstance === undefined) {
      FileManagerPageVM._rootInstance = new FileManagerPageVM()
    }
    return FileManagerPageVM._rootInstance;
  }

  @Trace userInfo: UserInfo = PersistenceV2.connect(UserInfo, () => new UserInfo())!;
  // 标记是否在当前页面跳转开通了vip
  private isJumpToOpenVIP: boolean = false
  // 选择管理类
  selectVM: FileViewSwitchViewModel = new FileViewSwitchViewModel()
  // 新建文件夹对话框，用于关闭
  newFolderDialogId: number = 0
  // 重命名对话框
  renameDialogId: number = 0
  // 重命名弹框
  renameAction?: (name: string, icon: ResourceStr, complete: (text: string) => void) => void

  // 构造函数
  private constructor() {
    MockService.currentFileList.splice(0, 0, MockService.privateSpaceInfo)
    let list = this.convertFileList(MockService.currentFileList)
    this.selectVM.fileList = list

    this.selectVM = new FileViewSwitchViewModel(list)
    this.selectVM.viewDirectorAction = (index: number): boolean => {
      return this.jumpToNextlevelDirector(index)
    }
    this.selectVM.viewFileAction = (index: number): boolean => {
      return this.jumpToFileDetail(index)
    }
    this.selectVM.selectOperationItemAction = (operationItem: OperationItemType): boolean => {
      return FileManagerPageVM.dealwithFileOperation(operationItem, this.selectVM, MockService.currentFileList)
    }
  }

  // 重新初始化数据
  public reInitializeAgain() {
    let list = this.convertFileList(MockService.currentFileList)
    this.selectVM.reInitializeAgain(list)
  }

  // FileInfo数据转换为FileBaseInfo
  public convertFileList(fileList: FileInfo[]): FileBaseInfo[] {
    const currentStr: string = JSON.stringify(fileList.map(item => item.toJSON()))
    const currentArr: FileBaseInfoPlain[] = JSON.parse(currentStr) as FileBaseInfoPlain[]
    return currentArr.map(item => FileBaseInfo.fromPlain(item))
  }

  // FileInfo数据转换为FileBaseInfo
  public convertFileInfo(fileInfo: FileInfo): FileBaseInfo {
    const currentStr: string = JSON.stringify(fileInfo)
    const item: FileBaseInfoPlain = JSON.parse(currentStr) as FileBaseInfoPlain
    return FileBaseInfo.fromPlain(item)
  }

  // 查看文件详情
  private jumpToFileDetail(index: number): boolean {
    // 未查找到数据
    const fileId: number = this.selectVM.fileList[index].fileId
    const fileInfo = this.foundFileInfoBy(fileId)
    if (fileInfo === undefined) {
      return false
    }

    FileManagerPageVM.routerToFileDetail(fileInfo)

    return true
  }

  // 跳转下一级目录
  private jumpToNextlevelDirector(index: number): boolean {
    // 未查找到数据
    const fileId: number = this.selectVM.fileList[index].fileId
    const fileInfo = this.foundFileInfoBy(fileId)
    if (fileInfo === undefined) {
      return false
    }

    // 隐私空间
    if (this.selectVM.fileList[index].fileType === FileBaseType.PRIVATESPACE) {
      if (!FileManagerPageVM.openPrivateSpace(this.selectVM)) {
        TCLogger.warn(TAG, 'privatespace not opened, goto open')
        return false
      }

      FileManagerPageVM.routerToPrivateSpace(fileInfo)
      return true
    }

    // 文件目录
    FileManagerPageVM.routerToDirector(this.selectVM.fileList[index])
    return true
  }

  // 具体操作, 返回true代表清空选择与隐藏弹框
  private static dealwithFileOperation(operationItem: OperationItemType, vm: FileBaseCheckViewModel,
    sourceList: FileInfo[]): boolean {
    const ids: Set<number> = new Set(vm.getAllSelectedIds())
    let fileList: FileInfo[] = []
    sourceList.forEach((item) => {
      if (ids.has(item.fileId)) {
        fileList.push(item)
      }
    })

    if (fileList.length === 0) {
      TCLogger.info(TAG, 'selected file is empty')
      return false
    }

    // 删除
    if (operationItem === OperationItemType.DELETE) {
      vm.deleteAllSelected()
      MockService.deleteFileListFromTargetList(fileList, sourceList)
      const timeStamp = Date.now()
      fileList.forEach((item) => {
        item.deletetime = timeStamp
      })
      MockService.addFileListToTargetList(fileList, MockService.recycleBinFileList)
      return true
    }

    // 移动到隐私空间
    if (operationItem === OperationItemType.MOVETO_PRIVATESPACE) {
      const isOpen = FileManagerPageVM.openPrivateSpace(vm)
      if (!isOpen) {
        return false
      }

      FileManagerPageVM.moveToPrivateSpace(fileList, sourceList, vm)
      return false
    }

    // 移动文件
    if (operationItem === OperationItemType.MOVE) {
      FileManagerPageVM.moveFileListBegin(vm, sourceList, () => {
        vm.isShow = true
      })
      vm.isShow = false
      return false
    }

    // 下载
    if (operationItem === OperationItemType.DOWNLOAD) {
      FileManagerPageVM.downloadFileList(fileList)
      return true
    }

    // 重命名,直接使用文件主页的renameAction方法
    if (operationItem === OperationItemType.RENAME) {
      const mainpageVM = FileManagerPageVM.rootInstance
      if (mainpageVM.renameAction !== undefined) {
        const fileBaseInfo: FileBaseInfo = vm.getAllSelected()[0]
        mainpageVM.renameAction(fileBaseInfo.removeFileBaseExtension(),
          FileViewSwitchViewModel.getImageSource(fileBaseInfo.fileType, fileBaseInfo.name), (text: string) => {
            const lastDotIndex = fileBaseInfo.name.lastIndexOf('.');
            if (lastDotIndex === -1 || lastDotIndex === fileBaseInfo.name.length - 1) {
              fileBaseInfo.name = text
              fileList[0].name = text
            } else {
              let result = text + '.' + fileBaseInfo.name.substring(lastDotIndex)
              fileBaseInfo.name = result
              fileList[0].name = result
            }

            vm.selectedIndexes.clear()
            vm.isShow = false
          })
      }
      return false
    }

    // 分享
    if (operationItem === OperationItemType.SHARE) {
      FileManagerPageVM.shareContent(fileList[0])
      return false
    }

    // 收藏与取消收藏
    if (operationItem === OperationItemType.COLLECTED || operationItem === OperationItemType.UNCOLLECTED) {
      FileManagerPageVM.switchCollectOperation(operationItem, fileList, vm)
      return false
    }

    // 移出隐私空间
    if (operationItem === OperationItemType.MOVEOUT_PRIVATESPACE) {
      FileManagerPageVM.moveoutPrivateSpace(fileList, vm)
      return true
    }

    return false
  }

  // 切换收藏
  private static switchCollectOperation(operationItem: OperationItemType, fileList: FileInfo[],
    vm: FileBaseCheckViewModel) {
    vm.getAllSelected().forEach((item) => {
      item.isCollected = (operationItem === OperationItemType.UNCOLLECTED)
    })
    fileList.forEach((item) => {
      item.isCollected = (operationItem === OperationItemType.UNCOLLECTED)
    })

    // MultiLevelNavigationPageViewModel、FileViewSwitchViewModel都有operationVM对象
    if ((vm instanceof MultiLevelNavigationPageViewModel) || (vm instanceof FileViewSwitchViewModel)) {
      let operationList = Array.from(vm.operationVM.operationList)
      operationList[operationList.length - 1] =
        (operationItem === OperationItemType.COLLECTED) ? OperationItemType.UNCOLLECTED : OperationItemType.COLLECTED
      vm.operationVM.operationList = operationList
    }

    // 收藏列表数据同步
    if (operationItem === OperationItemType.UNCOLLECTED) {
      MockService.addFileListToTargetList(fileList, MockService.collectFileList)
    } else {
      MockService.deleteFileListFromTargetList(fileList, MockService.collectFileList)
    }
  }

  // 开启隐私空间
  public static openPrivateSpace(vm: FileBaseCheckViewModel): boolean {
    if (!PreferenceUtil.getInstance().has(PreferenceConstant.PRIVATE_SPACE_PASSWORD_KEY)) {
      const managerVM: FileManagerPageVM = FileManagerPageVM.rootInstance
      // 在当前页面跳转到vip页面且成功开通，跳过提示
      if (managerVM.isJumpToOpenVIP && managerVM.userInfo.isVip) {
        phoneRouterControl.jumpPage({
          pageName: RouterMap.OPEN_PRIVATE_SPACE_PAGE,
          builder: wrapBuilder(SettingPrivateSpacePasswordPageBuilder),
          param: false
        })

        vm.selectedIndexes.clear()
        vm.isShow = false
        return false
      }

      FileManagerPageVM.showTipDialog($r('app.string.open_private_space_message'), $r('app.string.dialog_sure_open'),
        () => {
          if (managerVM.userInfo.isVip) {
            phoneRouterControl.jumpPage({
              pageName: RouterMap.OPEN_PRIVATE_SPACE_PAGE,
              builder: wrapBuilder(SettingPrivateSpacePasswordPageBuilder),
            })

            vm.selectedIndexes.clear()
            vm.isShow = false
          } else {
            FileManagerPageVM.showTipDialog($r('app.string.upgrade_open_private_space'), $r('app.string.goto_upgrade'),
              () => {
                managerVM.isJumpToOpenVIP = true
                phoneRouterControl.jumpPage({
                  pageName: RouterMap.VIP_CENTER_PAGE,
                  builder: wrapBuilder(VipCenterPageBuilder)
                })

                vm.selectedIndexes.clear()
                vm.isShow = false
              })

          }
        })
      return false
    }

    return true
  }

  // 显示弹框
  private static showTipDialog(msg: ResourceStr, sureText: ResourceStr, sureAction: () => void) {
    GlobalContext.getUIContext().showAlertDialog({
      message: msg,
      autoCancel: false,
      alignment: DialogAlignment.Center,
      showInSubWindow: true,
      isModal: true,
      buttonDirection: DialogButtonDirection.HORIZONTAL,
      buttons: [
        {
          value: $r('app.string.dialog_cancel'),
          action: () => {
          }
        },
        {
          value: sureText,
          action: () => {
            sureAction()
          }
        }
      ]
    })
  }

  // 通过fileId查找文件
  private foundFileInfoBy(fileId: number): FileInfo | undefined {
    const length = MockService.currentFileList.length
    for (let index = 0; index < length; index++) {
      const element = MockService.currentFileList[index];
      if (element.fileId === fileId) {
        return element
      }
    }

    return undefined
  }

  // 查找filebase对应的fileinfo
  private static foundFileInfoListBy(ids: number[], fileList: FileInfo[]): FileInfo[] {
    const result: FileInfo[] = []
    const fileIds = new Set(ids)
    fileList.forEach((item) => {
      if (fileIds.has(item.fileId)) {
        result.push(item)
      }
    })
    return result
  }

  // 查找文件，通过ids层级目录
  public static searchFileInfoBy(fileIds: number[],
    list: FileInfo[]): FileInfo | undefined {
    let currentInfo: FileInfo | undefined = undefined
    for (let i = 0; i < fileIds.length; i++) {
      const tmpId = fileIds[i]
      const tmpList: FileInfo[] =
        (currentInfo !== undefined) ? (currentInfo as FileInfo).contentList : list
      for (let j = 0; j < tmpList.length; j++) {
        if (tmpList[j].fileId === tmpId) {
          currentInfo = tmpList[j]
          break
        }
      }
    }

    return currentInfo
  }

  // 路由到目录列表
  public static routerToDirector(fileInfo: FileBaseInfo) {
    const multiLevelVM: MultiLevelNavigationPageViewModel = new MultiLevelNavigationPageViewModel(fileInfo)
    multiLevelVM.contentPadding = { top: BarVM.instance.staBarH, bottom: BarVM.instance.aiBarH }
    multiLevelVM.checkFileAction = (index: number) => {
      let fileIds = multiLevelVM.checkMultiLevelFileIds(index)
      let currentInfo: FileInfo | undefined =
        FileManagerPageVM.searchFileInfoBy(fileIds, MockService.currentFileList)
      if (currentInfo !== undefined) {
        FileManagerPageVM.routerToFileDetail(currentInfo)
      }
      return true
    }
    multiLevelVM.selectOperationItemAction = (operationItem: OperationItemType) => {
      let sourceList: FileInfo[] = []
      let fileIds = multiLevelVM.checkMultiLevelFileIds()
      let currentInfo: FileInfo | undefined =
        FileManagerPageVM.searchFileInfoBy(fileIds, MockService.currentFileList)
      if (currentInfo !== undefined) {
        sourceList = currentInfo.contentList
      }
      return FileManagerPageVM.dealwithFileOperation(operationItem, multiLevelVM, sourceList)
    }
    phoneRouterControl.jumpPage({
      pageName: RouterMap.MULTILEVEL_FILE_PAGE,
      builder: wrapBuilder(MultiLevelNavigationPageBuilder),
      param: multiLevelVM
    })
  }

  // 路由到隐私空间
  public static routerToPrivateSpace(fileInfo: FileInfo, replace: boolean = false) {
    let sourceList: FileBaseInfo[] = FileManagerPageVM.rootInstance.selectVM.fileList[0].contentList
    const privatespaceVM: PrivatespacePageViewModel = new PrivatespacePageViewModel(sourceList)
    privatespaceVM.contentPadding = { top: BarVM.instance.staBarH, bottom: BarVM.instance.aiBarH }
    privatespaceVM.checkFileAction = (index: number) => {
      // 跳文件详情
      const fileId = privatespaceVM.fileList[index].fileId
      for (let i = 0; i < fileInfo.contentList.length; i++) {
        const element = fileInfo.contentList[i];
        if (element.fileId === fileId) {
          FileManagerPageVM.routerToFileDetail(element)
          return true
        }
      }
      return false
    }
    privatespaceVM.selectOperationItemAction = (operationItem: OperationItemType) => {
      return FileManagerPageVM.dealwithFileOperation(operationItem, privatespaceVM, fileInfo.contentList)
    }
    privatespaceVM.checkDirectorAction = (index: number) => {
      FileManagerPageVM.routerToDirector(privatespaceVM.fileList[index])
      return true
    }
    const pageInfo: NavPageInfo = {
      pageName: RouterMap.PRIVATE_SPACE_LIST_PAGE,
      builder: wrapBuilder(PrivatespacePageBuilder),
      param: privatespaceVM
    }
    if (replace) {
      phoneRouterControl.replacePage(pageInfo)
    } else {
      phoneRouterControl.jumpPage(pageInfo)
    }
  }

  // 路由到文件详情
  public static routerToFileDetail(fileInfo: FileInfo) {
    const fileOperationUtil: FileOperationUtil = new FileOperationUtil()
    const currentStr: string = JSON.stringify(fileInfo)
    const current: FileBaseInfoPlain = JSON.parse(currentStr) as FileBaseInfoPlain
    const fileBaseInfo = FileBaseInfo.fromPlain(current)
    const obj: ImageVideoPageVM = new ImageVideoPageVM(fileBaseInfo, () => {
      FileTransferDownloadPageVM.rootInstance.startDownloadFileTask(fileInfo)
    }, () => {
      phoneRouterControl.popPage()
    })
    obj.renameFunc = (text: string) => {
      fileInfo.name = text
    }
    obj.deleteFunc = () => {
      let eventData: emitter.EventData = {
        data: {
          fileId: fileInfo.fileId
        }
      }
      EmitterUtil.emit('fileId', eventData)
    }
    obj.shareFunc = () => {
      FileManagerPageVM.shareContent(fileInfo)
    }
    if (fileInfo.downloadUrl.toLowerCase().endsWith('.docx') || fileInfo.downloadUrl.toLowerCase().endsWith('.doc') ||
    fileInfo.downloadUrl.toLowerCase().endsWith('.xls') || fileInfo.downloadUrl.toLowerCase().endsWith('.xlsx') ||
    fileInfo.downloadUrl.toLowerCase().endsWith('.ppt') || fileInfo.downloadUrl.toLowerCase().endsWith('.pptx')) {
      // 获取文件资源地址
      fileOperationUtil.getCloudFileDownloadUrl(fileInfo.downloadUrl).then((url) => {
        fileOperationUtil.downloadFileToSandbox(fileInfo.downloadUrl, url).then((res) => {
          let filePath = res
          let uiContext = GlobalContext.getUIContext().getHostContext() as Context;
          let displayInfo: filePreview.DisplayInfo = {
            x: 100,
            y: 100,
            width: 800,
            height: 800
          };

          let previewInfo: filePreview.PreviewInfo = {
            title: fileInfo.name,
            uri: fileUri.getUriFromPath(filePath),
            mimeType: ''
          };
          filePreview.openPreview(uiContext, previewInfo, displayInfo).then(() => {
            TCLogger.info('Succeeded in opening preview');
          }).catch((err: BusinessError) => {
            TCLogger.info(`Failed to open preview, err.code = ${err.code}, err.message = ${err.message}`);
          });
        })
      })
    } else {
      phoneRouterControl.jumpPage({
        pageName: RouterMap.IMAGE_VIDEO_PAGE,
        builder: wrapBuilder(ImageVideoPageBuilder),
        param: obj
      })

    }
  }

  // 移入到隐私空间
  public static moveToPrivateSpace(fileList: FileInfo[], sourceList: FileInfo[], vm: FileBaseCheckViewModel) {
    GlobalContext.getUIContext().showAlertDialog({
      message: $r('app.string.private_space_move_tip'),
      autoCancel: false,
      alignment: DialogAlignment.Center,
      showInSubWindow: true,
      isModal: true,
      buttonDirection: DialogButtonDirection.HORIZONTAL,
      buttons: [
        {
          value: $r('app.string.dialog_cancel'),
          action: () => {
          }
        },
        {
          value: $r('app.string.sure'),
          action: () => {
            const baseList: FileBaseInfo[] = vm.getAllSelected()
            FileManagerPageVM.rootInstance.selectVM.addFileListToPrivateSpace(baseList)
            vm.deleteAllSelected()
            vm.isShow = false

            MockService.addFileListToPrivateSpaceFilePage(fileList)
            MockService.deleteFileListFromTargetList(fileList, sourceList)
          }
        }
      ]
    })
  }

  // 移出隐私空间
  public static moveoutPrivateSpace(fileList: FileInfo[], vm: FileBaseCheckViewModel) {
    // 原始数据
    MockService.restoreFileList(fileList)

    // 展现数据
    let result: FileBaseInfo[] = []
    const selectItems: FileBaseInfo[] = vm.getAllSelected()
    selectItems.forEach((item) => {
      let searchItem: FileBaseInfo | undefined =
        FileManagerPageVM.searchFileBaseInfoByParentId(item.parentFileId,
          FileManagerPageVM.rootInstance.selectVM.fileList)
      if (searchItem === undefined) {
        result.push(item)
      } else {
        searchItem.contentList.push(item)
      }
    })

    vm.deleteAllSelected()
    MockService.deleteFileListFromTargetList(fileList, MockService.privateSpaceInfo.contentList)
    if (result.length === 0) {
      TCLogger.info(TAG, 'filelist is all restore')
      return
    }

    result.forEach(item => {
      FileManagerPageVM.rootInstance.selectVM.fileList.push(item)
    })
  }

  // 查找父类文件
  private static searchFileBaseInfoByParentId(parentFileId: number,
    fileList: FileBaseInfo[]): FileBaseInfo | undefined {
    if (parentFileId === 0) {
      return undefined
    }

    for (let i = 0; i < fileList.length; i++) {
      const item = fileList[i];
      if (item.fileId === parentFileId) {
        return item
      }

      if (item.fileId === 0) {
        continue
      }

      let result = FileManagerPageVM.searchFileBaseInfoByParentId(parentFileId, item.contentList)
      if (result !== undefined) {
        return result
      }

      TCLogger.info(TAG, 'current place not found')
    }

    return undefined
  }

  // 移动文件
  public static moveFileListBegin(vm: FileBaseCheckViewModel, sourceList: FileInfo[], backAction?: () => void) {
    const ids = vm.getAllSelectedIds()
    const param: MoveDirectorFirstPageParam = {
      fileIds: ids,
      completeAction: (fileIds: number[]) => {
        // 移动文件
        FileManagerPageVM.moveFileListEnd(fileIds, ids, vm, sourceList)
      },
      backDirectionAction: () => {
        if (backAction !== undefined) {
          backAction()
        }
      }
    }
    phoneRouterControl.jumpPage({
      pageName: RouterMap.MOVE_FILE_FIRST_PAGE,
      builder: wrapBuilder(MoveDirectorFirstPageBuilder),
      param: param
    })
  }

  // ids-选中文件id集合，fileIds-移动目录id层级
  public static moveFileListEnd(fileIds: number[], ids: number[], vm: FileBaseCheckViewModel, sourceList: FileInfo[]) {
    let currentInfo: FileInfo | undefined =
      FileManagerPageVM.searchFileInfoBy(fileIds, MockService.currentFileList)
    if (currentInfo !== undefined) {
      // 判断是否同样的目录
      const moveSet: Set<number> = new Set(ids)
      for (let i = 0; i < currentInfo.contentList.length; i++) {
        if (moveSet.has(currentInfo.contentList[i].fileId)) {
          TCLogger.info(TAG, 'same director')
          vm.isShow = false
          vm.selectedIndexes.clear()
          return
        }
      }

      // 非相同路径
      const selectedItems: FileBaseInfo[] = vm.getAllSelected()
      const tmpFileList: FileInfo[] = FileManagerPageVM.foundFileInfoListBy(ids, sourceList)
      if (currentInfo.fileType === FileType.PrivateSpace) {
        // 展示数据, 非文件主页添数据项中无隐私空间，直接添加到主页即可
        FileManagerPageVM.rootInstance.selectVM.addFileListToPrivateSpace(selectedItems)
        // 原始数据
        MockService.addFileListToPrivateSpaceFilePage(tmpFileList)
        MockService.deleteFileListFromTargetList(tmpFileList, sourceList)
      } else {
        // 展示数据
        if (vm instanceof MultiLevelNavigationPageViewModel || vm instanceof FileViewSwitchViewModel) {
          // 面包屑 & 文件主页
          FileManagerPageVM.rootInstance.selectVM.addFileListByFileId(selectedItems, currentInfo.fileId)
        } else if (vm instanceof PrivatespacePageViewModel) {
          // 隐私空间
          vm.addFileListToTargetFileId(selectedItems, currentInfo.fileId)
        }
        selectedItems.forEach((item) => {
          // 移动到非根目录
          item.parentFileId = currentInfo!.fileId
        })

        // 原始数据
        MockService.addFileListToTargetList(tmpFileList, currentInfo.contentList)
        MockService.deleteFileListFromTargetList(tmpFileList, sourceList)
        tmpFileList.forEach((item) => {
          // 移动到非根目录
          item.parentFileId = currentInfo!.fileId
          // 同时更新文件传输页面列表元素的parentFileId
          FileTransferManagerPageVM.rootInstance.updateFileListParentFileId(item)
        })
      }
    } else {
      // 展示数据
      const selectedItems: FileBaseInfo[] = vm.getAllSelected()
      FileManagerPageVM.rootInstance.selectVM.addFileListToRoot(selectedItems)
      selectedItems.forEach((item) => {
        // 移动到根目录
        item.parentFileId = 0
      })

      // 原始数据
      const tmpFileList: FileInfo[] = FileManagerPageVM.foundFileInfoListBy(ids, sourceList)
      MockService.addFileListToTargetList(tmpFileList, MockService.currentFileList)
      MockService.deleteFileListFromTargetList(tmpFileList, sourceList)
      tmpFileList.forEach((item) => {
        // 移动到根目录
        item.parentFileId = 0
      })
    }

    // 删除选中
    vm.deleteAllSelected()
  }

  // 下载文件
  public static downloadFileList(fileList: FileInfo[]) {
    fileList.forEach((item) => {
      FileTransferManagerPageVM.rootInstance.fileTransferDownloadPageVM.startDownloadFileTask(item)
    })
  }

  // 分享内容
  public static shareContent(info: FileBaseInfo | FileInfo) {
    let params: ShareSheetParams = {
      onPost: () => {
      },
      qrCodeInfo: {
        id: info.fileId.toString(),
        title: info.name,
        type: info.fileType.toString(),
        createTime: info.createTime,
        coverUrl: info.downloadUrl ?? '',
        isVideo: (info.fileType === 2)
      },
    }
    PopViewUtils.showSheet<ShareSheetParams>(wrapBuilder(FirstPosterShareBuilder), {
      showClose: true,
      title: {
        title: '分享到',
      },
      backgroundColor: $r('sys.color.background_secondary'),
      detents: [SheetSize.FIT_CONTENT],
    }, params);
  }

  // 添加文件到当前列表
  public addFileToCurrentList(fileList: FileInfo[]) {
    MockService.addFileListToTargetList(fileList, MockService.currentFileList)

    // 当前显示数据
    const result: FileBaseInfo[] = this.convertFileList(fileList)
    const ids: Set<number> = new Set()
    this.selectVM.fileList.forEach((item) => {
      ids.add(item.fileId)
    })

    result.forEach((item) => {
      if (ids.has(item.fileId)) {
        TCLogger.info(TAG, 'file is existed')
      } else {
        this.selectVM.fileList.push(item)
      }
    })
  }
}
