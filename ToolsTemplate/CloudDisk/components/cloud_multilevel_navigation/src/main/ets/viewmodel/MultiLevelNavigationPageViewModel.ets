import { FileBaseCheckViewModel, FileBaseInfo, FileBaseType } from 'cloud_file_base';
import { OperationItemType, OperationItemViewModel } from 'cloud_operation_item';

@ObservedV2
export class MultiLevelNavigationPageViewModel extends FileBaseCheckViewModel {
  // 内边距
  contentPadding: Padding | Length | LocalizedPadding = 0
  // 默认操作项列表
  operationList: OperationItemType[] = [
    OperationItemType.DOWNLOAD,
    OperationItemType.DELETE,
    OperationItemType.SHARE,
    OperationItemType.RENAME,
    OperationItemType.MOVE,
    OperationItemType.MOVETO_PRIVATESPACE,
  ]
  // 底部操作项
  operationVM: OperationItemViewModel = new OperationItemViewModel(this.operationList)
  // 当前排序索引
  @Trace sortIndex: number = 0;
  // 文件排序弹框是否可见
  @Trace sortListIsVisible: boolean = false;
  // 排序列表内容
  sortList: string[] = ['智能', '按修改时间', '按文件名', '按文件大小', '按文件类型'];
  // 筛选是否选中
  @Trace isFilterSelected: boolean = false;
  // 文件分类标题项目
  filterTitles: string[] = ['全部', '图片', '视频', '文件', '音频', '其他'];
  // 文件类型索引
  @Trace filterIndex: number = 0;
  // 查看文件详情
  checkFileAction: (index: number) => boolean = () => {
    return true
  }
  // 选择操作项
  selectOperationItemAction: (operationItem: OperationItemType) => boolean = () => {
    return true
  }
  // 多级目录列表
  @Trace levelDirectorList: FileBaseInfo[] = []

  // 构造函数
  constructor(fileInfo: FileBaseInfo) {
    super();

    this.levelDirectorList = [fileInfo]
    this.fileList = fileInfo.contentList
  }

  // 数组排序
  private sortFileListByArr(fileList: FileBaseInfo[], index: number) {
    fileList.sort((first: FileBaseInfo, second: FileBaseInfo) => {
      // 隐私空间在最前面
      if (first.fileType === FileBaseType.PRIVATESPACE) {
        return -1
      }

      // 隐私空间在最前面
      if (second.fileType === FileBaseType.PRIVATESPACE) {
        return 1;
      }

      // 文件类型靠前
      if (first.fileType === FileBaseType.DIRECTOR && second.fileType !== FileBaseType.DIRECTOR) {
        return -1
      }

      // 文件类型靠前
      if (first.fileType !== FileBaseType.DIRECTOR && second.fileType === FileBaseType.DIRECTOR) {
        return 1
      }

      // 按修改时间
      if (index === 1) {
        return first.createTime.localeCompare(second.createTime)
      }

      // 按文件名
      if (index === 2) {
        return first.name.localeCompare(second.name)
      }

      // 按文件大小
      if (index === 3) {
        return first.fileSize.localeCompare(second.fileSize)
      }

      // 按文件类型
      return first.fileType - second.fileType
    })
  }

  // 文件排序
  public sortFileList(index: number) {
    this.sortIndex = index

    // 排序
    this.sortFileListByArr(this.fileList, index)
    if (this.selectedIndexes.size > 0) {
      this.selectedIndexes.clear()
      this.isShow = false
    }
  }

  // 类型分类
  public filterListBySelectedType(index: number) {
    this.filterIndex = index
    if (this.selectedIndexes.size > 0) {
      this.selectedIndexes.clear()
      this.isShow = false
    }

    // 全部类型
    let tmpArr: FileBaseInfo[] = this.levelDirectorList[this.levelDirectorList.length - 1].contentList;
    if (index === 0) {
      this.fileList = tmpArr
      return
    }

    // 根据类型查找
    let list: FileBaseInfo[] = []
    let foundType: FileBaseType = FileBaseType.OTHER
    switch (this.filterIndex) {
      case 1: {
        foundType = FileBaseType.PICTURE
      }
        break
      case 2: {
        foundType = FileBaseType.VIDEO
      }
        break
      case 3: {
        foundType = FileBaseType.FILE
      }
        break
      case 4: {
        foundType = FileBaseType.AUDIO
      }
        break
      default:
        break;
    }
    tmpArr.forEach((item: FileBaseInfo) => {
      if (foundType === FileBaseType.OTHER && item.fileType > FileBaseType.AUDIO) {
        list.push(item)
      } else if (foundType === item.fileType) {
        list.push(item)
      }
    })
    this.sortFileListByArr(list, this.sortIndex)
    this.fileList = list
  }

  // 初始化响应事件
  public initializationResponses() {
    // 选中某一项
    this.didSelectedAtIndexAction = (_: number) => {
      // 选中项更新
      const isVisible: boolean = (this.selectedIndexes.size > 0) ? true : false
      if (isVisible !== this.isShow) {
        this.isShow = isVisible
      }

      if (isVisible) {
        this.updateBottomOperations()
      }
    }
    // 全选、反选更新
    this.switchAllSelectedAction = (isAllSelected: boolean) => {
      this.isShow = isAllSelected

      if (isAllSelected) {
        this.updateBottomOperations()
      }
    }
    // 查看目录或文件
    this.didClickAtIndexAction = (index: number) => {
      // 非目录 or 隐私空间
      if (this.fileList[index].fileType !== FileBaseType.DIRECTOR &&
        this.fileList[index].fileType !== FileBaseType.PRIVATESPACE) {
        if (this.checkFileAction(index)) {
          // 隐藏下方的操作栏
          this.selectedIndexes.clear()
          this.isShow = false
        }
        return
      }

      // 查看目录
      this.jumpToNextlevelDirector(index)
    }
    // 底部操作选中
    this.operationVM.didSelectedItemAction = (itemType: OperationItemType) => {
      if (this.selectOperationItemAction(itemType)) {
        this.selectedIndexes.clear()
        this.isShow = false
      }
    }
  }

  // 更新底部操作栏
  private updateBottomOperations() {
    let showList: OperationItemType[] = Array.from(this.operationList)
    if (this.selectedIndexes.size > 1) {
      // 删除重命名和分享
      showList.splice(2, 2)
    } else if (this.selectedIndexes.size === 1) {
      if (this.fileList[0].fileId === FileBaseType.DIRECTOR) {
        // 文件夹不支持分享
        showList.splice(2, 1)
      }
    }

    let collected: boolean = true
    for (let i = 0; i < this.fileList.length; i++) {
      const fileInfo = this.fileList[i]
      if (!fileInfo.isCollected) {
        collected = false
        break
      }
    }
    showList.push(collected ? OperationItemType.COLLECTED : OperationItemType.UNCOLLECTED)
    const length: number = showList.length
    if (length === this.operationVM.operationList.length &&
      showList[length - 1] === this.operationVM.operationList[length - 1]) {
      // 数量相同，且最后一项也相同，不做处理
      return
    }

    this.operationVM.operationList = showList
  }

  // 跳转下一级目录
  private jumpToNextlevelDirector(index: number) {
    // 底部弹框事件是穿透的，此时弹框可能显示
    this.isShow = false
    // 关闭所有选择
    this.selectedIndexes.clear()
    const nextInfo: FileBaseInfo = this.fileList[index]
    this.levelDirectorList.push(nextInfo)
    this.fileList = nextInfo.contentList
    this.sortFileList(this.sortIndex)
  }

  // 切换到一级目录
  public changeToPrelevelDirector(index: number) {
    // 底部弹框事件是穿透的，此时弹框可能显示
    this.isShow = false
    this.selectedIndexes.clear()
    this.levelDirectorList.splice(index + 1, this.levelDirectorList.length - index - 1)
    this.fileList = this.levelDirectorList[index].contentList
  }

  // 获取多级fileId列表
  public checkMultiLevelFileIds(index?: number) {
    let fileids: number[] = []
    this.levelDirectorList.forEach((item) => {
      fileids.push(item.fileId)
    })

    if (index !== undefined) {
      fileids.push(this.fileList[index].fileId)
    }
    return fileids
  }

  // 添加到指定id
  public addFileListToFileId(fileList: FileBaseInfo[], fileId: number) {
    if (this.levelDirectorList[0].fileId === fileId) {
      fileList.forEach((item) => {
        this.levelDirectorList[0].contentList.push(item)
      })

      return
    }

    this.addFileListToSource(fileList, fileId, this.levelDirectorList[0].contentList)
  }

  // 遍历查询
  private addFileListToSource(fileList: FileBaseInfo[], fileId: number, original: FileBaseInfo[]) {
    for (let i = 0; i < original.length; i++) {
      const subItem = original[i];
      if (subItem.fileId === fileId) {
        fileList.forEach((item) => {
          subItem.contentList.push(item)
        })
        return
      }

      if (subItem.contentList.length) {
        continue
      }

      this.addFileListToSource(fileList, fileId, subItem.contentList)
    }
  }
}