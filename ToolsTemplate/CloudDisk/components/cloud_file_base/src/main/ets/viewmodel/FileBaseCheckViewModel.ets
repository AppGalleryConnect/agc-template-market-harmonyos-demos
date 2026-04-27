import { FileBaseInfo, FileBaseType } from '../model/FileBaseInfo'
import { display } from '@kit.ArkUI'

// 列表展示来源
export enum FileBaseCheckViewModelSource {
  DEFAULT = 0,
  SHARE = 1,
  COLLECT = 2,
  RECYCLEBIN = 3
}

// 文件选择viewmodel
@ObservedV2
export class FileBaseCheckViewModel {
  // view来源
  listSource: FileBaseCheckViewModelSource = FileBaseCheckViewModelSource.DEFAULT
  // 列表是否宫格模式展示
  @Trace isListVisibleGridMode: boolean = false
  // 选中文件列表索引集合
  @Trace selectedIndexes: Set<number> = new Set()
  // 文件操作弹框是否展示
  @Trace isShow: boolean = false;
  // 文件列表
  @Trace fileList: FileBaseInfo[] = []
  // 选中某一项
  didSelectedAtIndexAction: (index: number) => void = (_: number) => {
  }
  // 全选、反选block
  switchAllSelectedAction: (isAllSelected: boolean) => void = (_: boolean) => {
  }
  // 点击某一项
  didClickAtIndexAction: (index: number) => void = (_: number) => {
  }

  // 构造函数重载
  constructor(fileList?: FileBaseInfo[],
    clickAction?: (index: number) => void, selectAction?: (index: number) => void,
    switchAllSelectedAction?: (isAllSelected: boolean) => void) {
    if (fileList !== undefined) {
      this.fileList = fileList
    }

    if (switchAllSelectedAction !== undefined) {
      this.switchAllSelectedAction = switchAllSelectedAction
    }

    if (clickAction !== undefined) {
      this.didClickAtIndexAction = clickAction
    }

    if (selectAction !== undefined) {
      this.didSelectedAtIndexAction = selectAction
    }
  }

  // 控制全选、反选
  public switchAllSelected() {
    if (this.fileList.length === 0) {
      // 无内容，不做任何处理
      return
    }

    const isChecked = this.checkIsAllSelected();
    if (isChecked) {
      this.selectedIndexes.clear()
    } else {
      this.fileList.forEach((item: FileBaseInfo, index: number) => {
        if (item.fileType === FileBaseType.PRIVATESPACE) {
          // 隐私空间不可选中
          return
        }

        this.selectedIndexes.add(index)
      })
    }

    // 全选、反选结果回调
    this.switchAllSelectedAction(!isChecked)
  }

  // 检测是否全部选中
  public checkIsAllSelected(): boolean {
    if (this.fileList.length === 0) {
      // 无内容
      return false
    }

    // 判断隐私空间个数，隐私空间不可选中
    let canSelected: number = 0
    this.fileList.forEach((item: FileBaseInfo) => {
      if (item.fileType === FileBaseType.PRIVATESPACE) {
        return
      }

      canSelected++
    })
    return (canSelected === this.selectedIndexes.size) ? true : false
  }

  // 根据文件类型获取图标资源
  public static getImageSource(fileType: number, fileName: string, isGrid: boolean = false,
    thumb?: string): ResourceStr {
    if (thumb !== undefined && thumb.length > 0) {
      return 'file://' + thumb
    }

    let result: ResourceStr = ''
    switch (fileType) {
      case FileBaseType.PRIVATESPACE: {
        result = isGrid ? $r('app.media.base_privatespace_gird_icon') : $r('app.media.base_privatespace_icon')
      }
        break;
      case FileBaseType.DIRECTOR: {
        result = isGrid ? $r('app.media.base_director_gird_icon') : $r('app.media.base_director_icon')
      }
        break;
      case FileBaseType.VIDEO: {
        result = $r('app.media.base_video_icon')
      }
        break;
      case FileBaseType.AUDIO: {
        result = $r('app.media.base_audio_icon')
      }
        break;
      case FileBaseType.PICTURE: {
        result = $r('app.media.base_picture_icon')
      }
        break;
      case FileBaseType.FILE: {
        if (fileName.includes('ppt')) {
          result = $r('app.media.base_ppt_icon')
        } else if (fileName.includes('excel')) {
          result = $r('app.media.base_excel_icon')
        } else if (fileName.includes('word')) {
          result = $r('app.media.base_work_icon')
        } else {
          result = $r('app.media.base_pdf_icon')
        }
      }
        break;
      default: {
        result = $r('app.media.base_picture_icon')
      }
        break;
    }

    return result
  }

  // 获取所有选中项
  public getAllSelected(): FileBaseInfo[] {
    let list: FileBaseInfo[] = []
    this.fileList.forEach((item: FileBaseInfo, index: number) => {
      if (this.selectedIndexes.has(index)) {
        list.push(item)
      }
    })

    return list
  }

  // 获取所有选中项
  public getAllSelectedIds(): number[] {
    let list: number[] = []
    this.fileList.forEach((item: FileBaseInfo, index: number) => {
      if (this.selectedIndexes.has(index)) {
        list.push(item.fileId)
      }
    })

    return list
  }

  // 删除选中项
  public deleteAllSelected() {
    // 倒叙排列，待删除列表
    let delIndexes: number[] = Array.from(this.selectedIndexes)
    delIndexes.sort((a: number, b: number) => {
      return (b - a)
    })

    for (let i = this.fileList.length - 1; i >= 0; i--) {
      // 包含索引列表
      if (delIndexes.includes(i)) {
        this.fileList.splice(i, 1)
      }
    }

    // 清理索引列表
    this.selectedIndexes.clear()
  }

  // 获取网格列数
  public checkGridColumns() {
    // 获取屏幕宽度和高度（单位：px）
    let displayInfo = display.getDefaultDisplaySync();
    // 转换为vp单位
    const width: number = px2vp(displayInfo.width);
    if (width < 600) {
      return 3
    }

    if (width < 840) {
      return 4
    }

    return 6
  }

  // 右下角文本内容
  public rightbottomText(fileInfo: FileBaseInfo): string {
    if (this.listSource === FileBaseCheckViewModelSource.SHARE) {
      return fileInfo.checkShareExpireTime()
    }

    return ''
  }

  // 右小角文本颜色
  public rightbottomTextColor(fileInfo: FileBaseInfo): ResourceColor {
    if (this.listSource === FileBaseCheckViewModelSource.SHARE) {
      return fileInfo.checkShareExpireTimeColor()
    }

    return '#4C000000'
  }

  // 查找文件，通过ids目录
  public searchFileInfoBy(fileIds: number[], list: FileBaseInfo[]): FileBaseInfo | undefined {
    let currentInfo: FileBaseInfo | undefined = undefined
    for (let i = 0; i < fileIds.length; i++) {
      const tmpId = fileIds[i]
      const tmpList: FileBaseInfo[] = (currentInfo !== undefined) ? (currentInfo as FileBaseInfo).contentList : list
      for (let j = 0; j < tmpList.length; j++) {
        if (tmpList[j].fileId === tmpId) {
          // 查询到结果
          currentInfo = tmpList[j]
          break
        }
      }
    }

    return currentInfo
  }
}
