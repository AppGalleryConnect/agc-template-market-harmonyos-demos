import { FileInfo, FileType, MockService } from 'common';
import { FileManagerPageVM } from './FileManagerPageVM';

export const moveDirectorRouterName: string = 'MoveDirector'

// 移入目录vm
@ObservedV2
export class MoveDirectorFirstPageVM {
  // 根目录数据
  @Trace fileList: FileInfo[] = []
  // 非根目录数据
  @Trace nextList: FileInfo[] = []
  // 多级目录列表
  @Trace levelDirectorList: FileInfo[] = []
  private _filterIds: number[] = [];

  public set filterIds(value: number[]) {
    this._filterIds = value;
  }

  public get filterIds(): number[] {
    return this._filterIds;
  }

  // 过滤数据
  filterDataSourceBy() {
    const ids: Set<number> = new Set(this._filterIds)
    let list: FileInfo[] = []
    MockService.currentFileList.forEach((item: FileInfo) => {
      if (item.fileType === FileType.Director || item.fileType === FileType.PrivateSpace) {
        if (!ids.has(item.fileId)) {
          list.push(item)
        }
      }
    })

    this.fileList = list
  }

  private updateNextFileList(fileInfo: FileInfo) {
    const ids: Set<number> = new Set(this._filterIds)
    let list: FileInfo[] = []
    fileInfo.contentList.forEach((item: FileInfo) => {
      if (item.fileType === FileType.Director || item.fileType === FileType.PrivateSpace) {
        if (!ids.has(item.fileId)) {
          list.push(item)
        }
      }
    })

    this.nextList = list
  }

  // 跳转下一级目录
  public jumpToNextlevelDirector(index: number) {
    const length: number = this.levelDirectorList.length
    const curFileInfo = (length === 0) ? this.fileList[index] : this.nextList[index]
    this.levelDirectorList.push(curFileInfo)
    this.updateNextFileList(curFileInfo)
  }

  // 切换到一级目录
  public changeToPrelevelDirector(index: number) {
    this.levelDirectorList.splice(index + 1, this.levelDirectorList.length - index - 1)
    this.updateNextFileList(this.levelDirectorList[index])
  }

  // 切换到根目录
  public jumpToRoot() {
    this.levelDirectorList = []
    this.nextList = []
  }

  // 移动文件链表
  public checkMoveFileList(): number[] {
    let result: number[] = []
    this.levelDirectorList.forEach((item) => {
      result.push(item.fileId)
    })
    return result
  }
}