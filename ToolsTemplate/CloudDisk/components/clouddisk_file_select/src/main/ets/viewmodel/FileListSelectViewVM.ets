import { BreakpointModel, BreakpointNameEnum, FileInfo, FileType, TCLogger } from 'common';
import { AppStorageV2 } from '@kit.ArkUI';

const TAG: string = 'FileListSelectViewVM'

// 列表展示来源
export enum FileListSelectViewFrom {
  DEFAULT = 0,
  SHARE = 1,
  COLLECT = 2,
  RECYCLEBIN = 3
}

// 文件选择通用viewmodel
@ObservedV2
export class FileListSelectViewVM {
  // view来源
  listFrom: FileListSelectViewFrom = FileListSelectViewFrom.DEFAULT;
  // 选中文件列表
  @Trace selectedIndexes: Set<number> = new Set()
  // 文件列表
  @Trace fileList: FileInfo[] = []
  // 列表是否宫格模式展示
  @Trace isListVisibleGridMode: boolean = false
  @Trace breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  // 点击某一项
  didClickAtIndexAction: (index: number) => void = (_: number) => {
  }
  // 选中某一项
  didSelectedAtIndexAction: (index: number) => void = (_: number) => {
  }
  // 全选、反选block
  changeAllSelectedAction: (isAllSelected: boolean) => void = (_: boolean) => {
  }

  // 构造函数重载
  constructor(fileList?: FileInfo[],
    clickAction?: (index: number) => void, selectAction?: (index: number) => void,
    changeSelectedAction?: (isAllSelected: boolean) => void) {
    if (fileList !== undefined) {
      this.fileList = fileList
    }

    if (clickAction !== undefined) {
      this.didClickAtIndexAction = clickAction
    }

    if (selectAction !== undefined) {
      this.didSelectedAtIndexAction = selectAction
    }

    if (changeSelectedAction !== undefined) {
      this.changeAllSelectedAction = changeSelectedAction
    }
  }

  // 控制全选、反选
  public switchAllSelected() {
    if (this.fileList.length === 0) {
      // 无内容，不做界面更新
      return
    }

    const isChecked = this.checkIsAllSelected();
    if (isChecked) {
      this.selectedIndexes.clear()
    } else {
      this.fileList.forEach((item: FileInfo, index: number) => {
        if (item.fileType === FileType.PrivateSpace) {
          TCLogger.warn(TAG, 'not selected private space')
          return
        }

        this.selectedIndexes.add(index)
      })
    }

    // 全选、反选结果
    this.changeAllSelectedAction(!isChecked)
  }

  // 判断是否全部选中
  public checkIsAllSelected(): boolean {
    if (this.fileList.length === 0) {
      TCLogger.warn(TAG, 'content is empty')
      return false
    }

    // 判断隐私空间个数，隐私空间不计入选择
    let shouldSelected: number = 0
    this.fileList.forEach((item: FileInfo) => {
      if (item.fileType === FileType.PrivateSpace) {
        TCLogger.warn(TAG, 'private space not selected')
        return
      }

      shouldSelected++
    })
    return (shouldSelected === this.selectedIndexes.size) ? true : false
  }

  // 根据文件类型获取图标资源
  public static getImageSource(fileType: FileType, isGrid: boolean = false): ResourceStr {
    let result: ResourceStr = ''
    switch (fileType) {
      case FileType.PrivateSpace:
        result = isGrid ? $r('app.media.privatespace_gird_icon') : $r('app.media.privatespace_icon')
        break;
      case FileType.Director:
        result = isGrid ? $r('app.media.director_gird_icon') : $r('app.media.director_icon')
        break;
      case FileType.Video:
        result = $r('app.media.video_icon')
        break;
      case FileType.Audio:
        result = $r('app.media.audio_icon')
        break;
      case FileType.Picture:
        result = $r('app.media.picture_icon')
        break;
      default:
        result = $r('app.media.picture_icon')
        break;
    }

    return result
  }

  // 根据文件类型获取图标资源
  public static getImageSourceNew(fileType: FileType, fileName: string, isGrid: boolean = false): ResourceStr {
    let result: ResourceStr = ''
    switch (fileType) {
      case FileType.PrivateSpace: {
        result = isGrid ? $r('app.media.privatespace_gird_icon') : $r('app.media.privatespace_icon')
      }
        break;
      case FileType.Director: {
        result = isGrid ? $r('app.media.director_gird_icon') : $r('app.media.director_icon')
      }
        break;
      case FileType.Video: {
        result = $r('app.media.video_icon')
      }
        break;
      case FileType.Audio: {
        result = $r('app.media.audio_icon')
      }
        break;
      case FileType.Picture: {
        result = $r('app.media.picture_icon')
      }
        break;
      case FileType.File: {
        if (fileName.includes('ppt')) {
          result = $r('app.media.ppt_icon')
        } else if (fileName.includes('word')) {
          result = $r('app.media.work_icon')
        } else if (fileName.includes('excel')) {
          result = $r('app.media.excel_icon')
        } else {
          result = $r('app.media.pdf_icon')
        }
      }
        break;
      default:
        result = $r('app.media.picture_icon')
        break;
    }

    return result
  }

  // 获取所有选中项
  public getAllSelected(): FileInfo[] {
    let list: FileInfo[] = []
    this.fileList.forEach((item: FileInfo, index: number) => {
      if (this.selectedIndexes.has(index)) {
        list.push(item)
      }
    })

    return list
  }

  // 删除选中项
  public deleteAllSelected() {
    // 倒叙，待删除列表
    let delIndexes: number[] = Array.from(this.selectedIndexes)
    delIndexes.sort((a: number, b: number) => {
      return b - a
    })

    for (let i = this.fileList.length - 1; i >= 0; i--) {
      if (delIndexes.includes(i)) {
        this.fileList.splice(i, 1)
      }
    }

    this.selectedIndexes.clear()
  }

  // 获取网格列数
  public checkGridColumns() {
    if (this.breakPointModel.currentBreakpoint === BreakpointNameEnum.SM) {
      return 3
    }

    if (this.breakPointModel.currentBreakpoint === BreakpointNameEnum.MD) {
      return 4
    }

    return 6
  }

  // 右下角文本内容
  public rightbottomText(fileInfo: FileInfo): string {
    if (this.listFrom === FileListSelectViewFrom.SHARE) {
      return fileInfo.checkExpireTime()
    }

    if (this.listFrom === FileListSelectViewFrom.RECYCLEBIN) {
      return fileInfo.checkRecycleBinText()
    }

    return ''
  }

  // 右小角文本颜色
  public rightbottomTextColor(fileInfo: FileInfo): ResourceColor {
    if (this.listFrom === FileListSelectViewFrom.SHARE) {
      return fileInfo.checkExpireTimeColor()
    }

    return '#4C000000'
  }

  // 查找文件，通过ids目录
  public searchFileInfoBy(fileIds: number[], list: FileInfo[]): FileInfo | undefined {
    let currentInfo: FileInfo | undefined = undefined
    for (let i = 0; i < fileIds.length; i++) {
      const tmpId = fileIds[i]
      const tmpList: FileInfo[] = (currentInfo !== undefined) ? (currentInfo as FileInfo).contentList : list
      for (let j = 0; j < tmpList.length; j++) {
        if (tmpList[j].fileId === tmpId) {
          currentInfo = tmpList[j]
          break
        }
      }
    }

    return currentInfo
  }
}
