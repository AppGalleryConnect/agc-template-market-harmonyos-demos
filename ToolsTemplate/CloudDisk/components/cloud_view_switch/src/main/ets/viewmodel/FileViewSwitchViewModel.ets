import { FileBaseCheckViewModel, FileBaseInfo, FileBaseType } from 'cloud_file_base';
import { OperationItemType, OperationItemViewModel } from 'cloud_operation_item';

@ObservedV2
export class FileViewSwitchViewModel extends FileBaseCheckViewModel {
  // 底部操作项
  operationVM: OperationItemViewModel = new OperationItemViewModel([
    OperationItemType.DOWNLOAD,
    OperationItemType.DELETE,
    OperationItemType.SHARE,
    OperationItemType.RENAME,
    OperationItemType.MOVE,
    OperationItemType.MOVETO_PRIVATESPACE,
    OperationItemType.COLLECTED
  ])
  // 原始数据
  private originalFileList: FileBaseInfo[] = []
  // 当前排序索引
  @Trace currentSortIndex: number = 0;
  // 文件排序弹框是否可见
  @Trace isSortDialogVisible: boolean = false;
  // 排序列表内容
  sortList: string[] = [
    '智能',
    '按修改时间',
    '按文件名',
    '按文件大小',
    '按文件类型'
  ];
  // 筛选是否选中
  @Trace isFilterSelected: boolean = false;
  // 文件分类数据
  fileTypeTitles: string[] = ['全部', '图片', '视频', '文件', '音频', '其他'];
  // 文件类型索引
  @Trace fileTypeIndex: number = 0;
  // 查看文件详情
  viewFileAction: (index: number) => boolean = () => {
    return true
  }
  // 查看目录详情
  viewDirectorAction: (index: number) => boolean = () => {
    return true
  }
  // 选择操作项
  selectOperationItemAction: (operationItem: OperationItemType) => boolean = () => {
    return true
  }

  // 构造函数重载
  constructor(fileList?: FileBaseInfo[],
    clickAction?: (index: number) => void, selectAction?: (index: number) => void,
    switchAllSelectedAction?: (isAllSelected: boolean) => void) {
    super(fileList, clickAction, selectAction, switchAllSelectedAction)

    if (fileList !== undefined) {
      this.originalFileList = fileList
      this.sortFileList(0)
    }
  }

  public reInitializeAgain(fileList: FileBaseInfo[]) {
    this.originalFileList = fileList
    this.fileList = fileList
    this.sortFileList(this.currentSortIndex)
  }

  // 数组排序
  private sortFileListByArr(fileList: FileBaseInfo[], index: number) {
    fileList.sort((a: FileBaseInfo, b: FileBaseInfo) => {
      // 隐私空间在最前面
      if (a.fileType === FileBaseType.PRIVATESPACE) {
        return -1
      }

      // 隐私空间在最前面
      if (b.fileType === FileBaseType.PRIVATESPACE) {
        return 1;
      }

      // 文件类型靠前
      if (a.fileType === FileBaseType.DIRECTOR && b.fileType !== FileBaseType.DIRECTOR) {
        return -1
      }

      // 文件类型靠前
      if (a.fileType !== FileBaseType.DIRECTOR && b.fileType === FileBaseType.DIRECTOR) {
        return 1
      }

      // 按修改时间
      if (index === 1) {
        return a.createTime.localeCompare(b.createTime)
      }

      // 按文件名
      if (index === 2) {
        return a.name.localeCompare(b.name)
      }

      // 按文件大小
      if (index === 3) {
        return a.fileSize.localeCompare(b.fileSize)
      }

      // 按文件类型
      return a.fileType - b.fileType
    })
  }

  // 文件排序
  public sortFileList(index: number) {
    this.currentSortIndex = index

    this.sortFileListByArr(this.fileList, index)
    if (this.selectedIndexes.size > 0) {
      this.selectedIndexes.clear()
      this.isShow = false
    }
  }

  // 类型分类
  public filterListBySelectedType(index: number) {
    this.fileTypeIndex = index
    if (this.selectedIndexes.size > 0) {
      this.selectedIndexes.clear()
      this.isShow = false
    }

    // 全部类型
    let tmpArr: FileBaseInfo[] = this.originalFileList;
    if (index === 0) {
      this.fileList = tmpArr
      return
    }

    // 根据类型查找
    let list: FileBaseInfo[] = []
    let tmpType: FileBaseType = FileBaseType.OTHER
    switch (this.fileTypeIndex) {
      case 1: {
        tmpType = FileBaseType.PICTURE
      }
        break
      case 2: {
        tmpType = FileBaseType.VIDEO
      }
        break
      case 3: {
        tmpType = FileBaseType.FILE
      }
        break
      case 4: {
        tmpType = FileBaseType.AUDIO
      }
        break
      default:
        break;
    }
    tmpArr.forEach((item: FileBaseInfo) => {
      if (tmpType === FileBaseType.OTHER && item.fileType > FileBaseType.AUDIO) {
        list.push(item)
      } else if (tmpType === item.fileType) {
        list.push(item)
      }
    })
    this.sortFileListByArr(list, this.currentSortIndex)
    this.fileList = list
  }

  // 初始化响应事件
  public initializationResponses() {
    // 选中某一项
    this.didSelectedAtIndexAction = (_: number) => {
      // 控制底部弹框是否出现
      const isVisible: boolean = (this.selectedIndexes.size > 0) ? true : false
      if (isVisible !== this.isShow) {
        this.isShow = isVisible
      }

      if (isVisible) {
        this.updateBottomOperations()
      }
    }
    // 全选、反选切换
    this.switchAllSelectedAction = (isAllSelected: boolean) => {
      this.isShow = isAllSelected

      if (isAllSelected) {
        this.updateBottomOperations()
      }
    }
    // 单击某行
    this.didClickAtIndexAction = (index: number) => {
      // 非目录 or 隐私空间
      if (this.fileList[index].fileType !== FileBaseType.DIRECTOR &&
        this.fileList[index].fileType !== FileBaseType.PRIVATESPACE) {
        if (this.viewFileAction(index)) {
          // 隐藏下方的操作栏
          this.selectedIndexes.clear()
          this.isShow = false
        }
        return
      }

      // 查看目录
      if (this.viewDirectorAction(index)) {
        // 隐藏下方的操作栏
        this.selectedIndexes.clear()
        this.isShow = false
      }
    }
    // 弹框操作项参数
    this.operationVM.didSelectedItemAction = (type: OperationItemType) => {
      if (this.selectOperationItemAction(type)) {
        this.selectedIndexes.clear()
        this.isShow = false
      }
    }
  }

  // 更新底部操作栏
  private updateBottomOperations() {
    let modelList: OperationItemType[] = [
      OperationItemType.DOWNLOAD,
      OperationItemType.DELETE,
      OperationItemType.SHARE,
      OperationItemType.RENAME,
      OperationItemType.MOVE,
      OperationItemType.MOVETO_PRIVATESPACE,
    ]
    if (this.selectedIndexes.size > 1) {
      // 删除重命名和分享
      modelList.splice(2, 2)
    } else if (this.selectedIndexes.size === 1) {
      if (this.fileList[0].fileId === FileBaseType.DIRECTOR) {
        // 文件夹不支持分享
        modelList.splice(2, 1)
      }
    }

    let isCollected: boolean = true
    for (let i = 0; i < this.fileList.length; i++) {
      const fileInfo = this.fileList[i]
      if (!fileInfo.isCollected) {
        isCollected = false
        break
      }
    }
    modelList.push(isCollected ? OperationItemType.COLLECTED : OperationItemType.UNCOLLECTED)
    const length: number = modelList.length
    if (length === this.operationVM.operationList.length &&
      modelList[length - 1] === this.operationVM.operationList[length - 1]) {
      // 数量相同，且最后一项也相同，不做处理
      return
    }

    this.operationVM.operationList = modelList
  }

  // 添加隐私空间
  public addFileListToPrivateSpace(fileList: FileBaseInfo[]) {
    const first: FileBaseInfo = this.originalFileList[0]
    fileList.forEach((item) => {
      first.contentList.push(item)
    })
  }

  // 添加到根目录
  public addFileListToRoot(fileList: FileBaseInfo[]) {
    fileList.forEach((item) => {
      this.originalFileList.push(item)
    })
  }

  // 添加到指定id
  public addFileListByFileId(fileList: FileBaseInfo[], fileId: number) {
    this.addFileListBy(fileList, fileId, this.originalFileList)
  }

  // 遍历查询
  private addFileListBy(fileList: FileBaseInfo[], fileId: number, original: FileBaseInfo[]) {
    for (let index = 0; index < original.length; index++) {
      const element = original[index];
      if (element.fileId === fileId) {
        fileList.forEach((item) => {
          element.contentList.push(item)
        })
        return
      }

      if (element.contentList.length) {
        continue
      }

      this.addFileListBy(fileList, fileId, element.contentList)
    }
  }
}