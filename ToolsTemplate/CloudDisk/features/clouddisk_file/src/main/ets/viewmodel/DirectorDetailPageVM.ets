import { FileInfo, FileType, MockService, TCLogger } from 'common';
import { FileListSelectViewVM } from 'clouddisk_file_select';
import { FileTransferManagerPageVM } from '../../../../Index';

const TAG: string = 'DirectorDetailPageVM';

// 面包屑导航页通用viewmodel
@ObservedV2
export class DirectorDetailPageVM {
  // 选择管理类
  @Trace selectVM: FileListSelectViewVM = new FileListSelectViewVM()
  // 文件操作弹框是否展示
  @Trace isShow: boolean = false;
  // 当前排序索引
  @Trace currentSortIndex: number = 0;
  // 文件排序弹框是否可见
  @Trace isSortDialogVisible: boolean = false;
  // 排序列表内容
  private _sortList: string[] = [
    '智能',
    '按修改时间',
    '按文件名',
    '按文件大小',
    '按文件类型'
  ];

  public get sortList(): string[] {
    return this._sortList;
  }

  // 筛选是否选中
  @Trace isFilterSelected: boolean = false;
  // 文件分类数据
  private _fileTypeTitles: string[] = ['全部', '图片', '视频', '文件', '音频', '其他'];

  public get fileTypeTitles(): string[] {
    return this._fileTypeTitles;
  }

  // 文件类型索引
  @Trace fileTypeIndex: number = 0;
  // 多级目录列表
  @Trace levelDirectorList: FileInfo[] = []

  // 构造函数
  constructor(fileInfo: FileInfo) {
    this.levelDirectorList = [fileInfo]
    this.selectVM.fileList = fileInfo.contentList
  }

  // 跳转下一级目录
  public jumpToNextlevelDirector(index: number) {
    // 底部弹框事件是穿透的，此时弹框可能显示
    this.isShow = false
    // 关闭所有选择
    this.selectVM.selectedIndexes.clear()
    const nextInfo: FileInfo = this.selectVM.fileList[index]
    this.levelDirectorList.push(nextInfo)
    this.selectVM.fileList = nextInfo.contentList
    this.sortFileList(this.currentSortIndex)
  }

  // 切换到一级目录
  public changeToPrelevelDirector(index: number) {
    // 底部弹框事件是穿透的，此时弹框可能显示
    this.isShow = false
    this.levelDirectorList.splice(index + 1, this.levelDirectorList.length - index - 1)
    this.selectVM.fileList = this.levelDirectorList[index].contentList
  }

  // 数组排序
  private sortFileListByArr(fileList: FileInfo[], index: number) {
    fileList.sort((a: FileInfo, b: FileInfo) => {
      // 隐私空间在最前面
      if (a.fileType === FileType.PrivateSpace) {
        return -1
      }

      // 隐私空间在最前面
      if (b.fileType === FileType.PrivateSpace) {
        return 1;
      }

      // 文件类型靠前
      if (a.fileType === FileType.Director && b.fileType !== FileType.Director) {
        return -1
      }

      // 文件类型靠前
      if (a.fileType !== FileType.Director && b.fileType === FileType.Director) {
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

    this.sortFileListByArr(this.selectVM.fileList, index)
    if (this.selectVM.selectedIndexes.size > 0) {
      this.selectVM.selectedIndexes.clear()
      this.isShow = false
    }
  }

  // 类型分类
  public filterListBySelectedType(index: number) {
    this.fileTypeIndex = index
    if (this.selectVM.selectedIndexes.size > 0) {
      this.selectVM.selectedIndexes.clear()
      this.isShow = false
    }

    // 全部类型
    let tmpArr: FileInfo[] = this.levelDirectorList[this.levelDirectorList.length - 1].contentList;
    if (index === 0) {
      this.selectVM.fileList = tmpArr
      return
    }

    // 根据类型查找
    let list: FileInfo[] = []
    let tmpType: FileType = FileType.Other
    switch (this.fileTypeIndex) {
      case 1:
        tmpType = FileType.Picture
        break
      case 2:
        tmpType = FileType.Video
        break
      case 3:
        tmpType = FileType.File
        break
      case 4:
        tmpType = FileType.Audio
        break
      default:
        break;
    }
    tmpArr.forEach((item: FileInfo) => {
      if (tmpType === FileType.Other && item.fileType > FileType.Audio) {
        list.push(item)
      } else if (tmpType === item.fileType) {
        list.push(item)
      }
    })
    this.sortFileListByArr(list, this.currentSortIndex)
    this.selectVM.fileList = list
  }

  // 删除所有选中项
  public deleteAllSelected() {
    this.selectVM.deleteAllSelected()
    this.levelDirectorList[this.levelDirectorList.length - 1].contentList = this.selectVM.fileList
  }

  // ids-选中文件id集合，fileIds-移动目录id层级
  public moveFileList(fileIds: number[], ids: number[]) {
    let currentInfo: FileInfo | undefined =
      this.selectVM.searchFileInfoBy(fileIds, MockService.currentFileList)
    if (currentInfo !== undefined) {
      // 判断是否同样的目录
      const moveSet: Set<number> = new Set(ids)
      for (let i = 0; i < currentInfo.contentList.length; i++) {
        if (moveSet.has(currentInfo.contentList[i].fileId)) {
          TCLogger.info(TAG, 'same director')
          this.isShow = false
          this.selectVM.selectedIndexes.clear()
          return
        }
      }

      // 非相同路径
      const selectedItems: FileInfo[] = this.selectVM.getAllSelected()
      if (currentInfo.fileType === FileType.PrivateSpace) {
        MockService.addFileListToPrivateSpaceFilePage(selectedItems)
      } else {
        MockService.addFileListToTargetList(selectedItems, currentInfo.contentList)
        selectedItems.forEach((item) => {
          // 移动到非根目录
          item.parentFileId = currentInfo!.fileId
          // 同时更新文件传输页面列表元素的parentFileId
          FileTransferManagerPageVM.rootInstance.updateFileListParentFileId(item)
        })
      }
    } else {
      const selectedItems: FileInfo[] = this.selectVM.getAllSelected()
      MockService.addFileListToTargetList(selectedItems, MockService.currentFileList)
      selectedItems.forEach((item) => {
        // 移动到根目录
        item.parentFileId = 0
      })
    }

    // 删除选中
    this.selectVM.deleteAllSelected()
  }
}