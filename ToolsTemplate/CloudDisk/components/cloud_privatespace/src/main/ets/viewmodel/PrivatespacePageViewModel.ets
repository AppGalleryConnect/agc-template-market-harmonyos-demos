import { FileBaseCheckViewModel, FileBaseInfo, FileBaseType } from 'cloud_file_base';
import { OperationItemType, OperationItemViewModel } from 'cloud_operation_item';

@ObservedV2
export class PrivatespacePageViewModel extends FileBaseCheckViewModel {
  // 内边距
  contentPadding: Padding | Length | LocalizedPadding = 0
  // 默认操作项列表
  operationList: OperationItemType[] = [
    OperationItemType.DOWNLOAD,
    OperationItemType.MOVE,
    OperationItemType.MOVEOUT_PRIVATESPACE,
    OperationItemType.RENAME,
    OperationItemType.DELETE
  ]
  // 底部操作项
  operationVM: OperationItemViewModel = new OperationItemViewModel(this.operationList)
  // 查看文件详情
  checkFileAction: (index: number) => boolean = () => {
    return true
  }
  // 查看文件详情
  checkDirectorAction: (index: number) => boolean = () => {
    return true
  }
  // 选择操作项
  selectOperationItemAction: (operationItem: OperationItemType) => boolean = () => {
    return true
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
      if (this.checkDirectorAction(index)) {
        // 隐藏下方的操作栏
        this.selectedIndexes.clear()
        this.isShow = false
      }
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
      // 删除重命名
      showList.splice(3, 1)
    }
    if (showList.length === this.operationVM.operationList.length) {
      // 数量相同
      return
    }

    this.operationVM.operationList = showList
  }

  // 添加到指定id
  public addFileListToTargetFileId(fileList: FileBaseInfo[], fileId: number) {
    this.addFileListToTarget(fileList, fileId, this.fileList)
  }

  // 遍历查询
  private addFileListToTarget(fileList: FileBaseInfo[], fileId: number, sourceList: FileBaseInfo[]) {
    for (let j = 0; j < sourceList.length; j++) {
      const subItem = sourceList[j];
      if (subItem.fileId === fileId) {
        fileList.forEach((item) => {
          subItem.contentList.push(item)
        })
        return
      }

      if (subItem.contentList.length) {
        continue
      }

      this.addFileListToTarget(fileList, fileId, subItem.contentList)
    }
  }
}