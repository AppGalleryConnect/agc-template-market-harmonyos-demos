import { FileInfo, FileType, MockService, TCLogger } from 'common';
import { ShareOptions } from 'module_share';
import { FileOperationModel, FileOperationType } from '../model/FileOperationModel';

const TAG: string = 'OperationSelectVM'

@ObservedV2
export class OperationSelectVM {
  // 是否收藏
  @Trace isCollected: boolean = false;
  // 分享内容
  @Trace shareParams: ShareOptions = new ShareOptions()
  // 待关闭对话框id
  closeDialogId: number = 0
  // 默认支持的操作类型
  @Trace operationList: FileOperationType[] = [
    FileOperationType.Download,
    FileOperationType.Delete,
    FileOperationType.Share,
    FileOperationType.Rename,
    FileOperationType.Move,
    FileOperationType.MoveToPrivateSpace,
    FileOperationType.Collect
  ]
  // 文件列表
  private _fileList: FileInfo[] = [];

  public get fileList(): FileInfo[] {
    return this._fileList;
  }

  // 更新文件列表
  updateFileList(fileList: FileInfo[]) {
    this._fileList = fileList

    // 更新显示项，多选时不展示分享
    const params: ShareOptions = new ShareOptions()
    let modelList: FileOperationModel[] = Array.from(this.originalOperationList)
    if (fileList.length > 1) {
      // 删除重命名和分享
      this.deleteVisibleItemBy(FileOperationType.Rename, modelList)
      this.deleteVisibleItemBy(FileOperationType.Share, modelList)
      MockService.deleteFileListFromTargetList(this.fileList, MockService.shareFileList)
    } else if (fileList.length === 1) {
      // 文件夹不支持分享
      const selectedFileType: FileType = fileList[0].fileType
      if (selectedFileType === FileType.Director) {
        // 删除分享
        this.deleteVisibleItemBy(FileOperationType.Share, modelList)
        MockService.deleteFileListFromTargetList(this.fileList, MockService.shareFileList)
      } else {
        // 修改分享内容
        const curFileInfo: FileInfo = fileList[0]
        params.id = curFileInfo.fileId.toString()
        params.type = curFileInfo.fileType
        params.createTime = curFileInfo.createTime
        params.coverUrl = curFileInfo.downloadUrl
        params.isVideo = (curFileInfo.fileType === FileType.Video)
      }
    }
    this.shareParams = params

    // 内容相同，不做变更
    if (modelList.length !== this.contentList.length) {
      this.contentList = modelList
    }

    // 切换选中状态
    for (let index = 0; index < fileList.length; index++) {
      const item = fileList[index];
      if (!item.isCollected) {
        this.isCollected = false
        return
      }
    }

    this.isCollected = true
  }

  // 文件重命名
  changeFileName(name: string) {
    // 文件名修改时,当前只会有一个是选中状态
    if (this._fileList.length > 0) {
      const fileInfo = this._fileList[0]
      const lastDotIndex = fileInfo.name.lastIndexOf('.');
      if (lastDotIndex === -1 || lastDotIndex === fileInfo.name.length - 1) {
        fileInfo.name = name
        return;
      }

      fileInfo.name = name + '.' + fileInfo.name.substring(lastDotIndex)
    } else {
      TCLogger.info(TAG, 'fileList is empty')
    }
  }

  // 删除指定类型
  private deleteVisibleItemBy(type: FileOperationType, list: FileOperationModel[]) {
    for (let i = 0; i < list.length; i++) {
      const item: FileOperationModel = list[i];
      if (item.operationType === type) {
        list.splice(i, 1)
        return
      }
    }
  }

  // 原始操作列表列表
  private originalOperationList: FileOperationModel[] = []
  // 操作列表
  @Trace contentList: FileOperationModel[] = []
  // 回调事件
  didSelectEvent: (type: FileOperationType) => void = (_: FileOperationType) => {
  }

  constructor(operationList?: FileOperationType[],
    fileList?: FileInfo[],
    didSelectEvent?: (type: FileOperationType) => void) {
    if (operationList !== undefined) {
      this.operationList = operationList
      this.init()
    }

    if (fileList !== undefined) {
      this.updateFileList(fileList)
    }

    if (didSelectEvent !== undefined) {
      this.didSelectEvent = didSelectEvent
    }
  }

  // 切换收藏
  collectSwitched() {
    this.isCollected = !this.isCollected
    this._fileList.forEach((item) => {
      item.isCollected = this.isCollected
    })

    if (this.isCollected) {
      MockService.addFileListToTargetList(this.fileList, MockService.collectFileList)
    } else {
      MockService.deleteFileListFromTargetList(this.fileList, MockService.collectFileList)
    }
  }

  // 默认实例
  public static defaultInstance(): OperationSelectVM {
    const tmpInstance = new OperationSelectVM();
    tmpInstance.init()
    return tmpInstance;
  }

  // 指定是否收藏、默认列表，选中方法
  public static createInstanceWithEvent(didSelectEvent: (type: FileOperationType) => void): OperationSelectVM {
    const tmpInstance = new OperationSelectVM();
    tmpInstance.didSelectEvent = didSelectEvent;
    tmpInstance.init()
    return tmpInstance;
  }

  // 指定是否收藏、默认列表，选中方法
  public static createInstanceWithData(isCollected: boolean,
    operationList: FileOperationType[],
    didSelectEvent: (type: FileOperationType) => void): OperationSelectVM {
    const tmpInstance = new OperationSelectVM();
    tmpInstance.isCollected = isCollected;
    tmpInstance.operationList = operationList;
    tmpInstance.didSelectEvent = didSelectEvent;
    tmpInstance.init()
    return tmpInstance;
  }

  // 初始化
  private init() {
    this.operationList.forEach((value: FileOperationType) => {
      const model = new FileOperationModel(value)
      this.contentList.push(model)
      this.originalOperationList.push(model)
    })
  }

  // 更新地步展示内容
  public updateOperationList(list: FileOperationType[]) {
    this.operationList = list
    let result: FileOperationModel[] = []
    list.forEach((value: FileOperationType) => {
      const model = new FileOperationModel(value)
      result.push(model)
    })
    this.contentList = result
    this.originalOperationList = result
  }

  // 选中所有文件ids
  public checkedFileIds() {
    let ids: number[] = []
    this._fileList.forEach((item: FileInfo) => {
      ids.push(item.fileId)
    })

    return ids
  }
}

