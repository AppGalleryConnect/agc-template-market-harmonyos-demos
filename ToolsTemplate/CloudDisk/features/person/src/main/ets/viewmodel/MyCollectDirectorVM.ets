import { FileOperationType, OperationSelectVM } from 'clouddisk_file_operation';
import { FileInfo } from 'common';
import { FileListSelectViewVM } from 'clouddisk_file_select';

// 文件tab主页，面包屑导航页通用viewmodel
@ObservedV2
export class MyCollectDirectorVM {
  // 选择管理类
  @Trace selectVM: FileListSelectViewVM = new FileListSelectViewVM()
  // 文件操作弹框是否展示
  @Trace isShow: boolean = false;
  // 多级目录列表
  @Trace levelDirectorList: FileInfo[] = []
  // 只支持下载、分享、收藏
  operationVM: OperationSelectVM = new OperationSelectVM([
    FileOperationType.Download,
    FileOperationType.Share,
    FileOperationType.CancleCollect
  ])

  // 构造函数
  constructor(fileInfo: FileInfo) {
    this.levelDirectorList = [fileInfo]
    this.selectVM.fileList = fileInfo.contentList
  }

  // 跳转下一级目录
  public jumpToNextlevelDirector(index: number) {
    // 底部弹框事件是穿透的，此时弹框可能显示
    this.isShow = false

    if (this.levelDirectorList.length === 0) {
      return
    }

    // 关闭所有选择
    this.selectVM.selectedIndexes.clear()
    const nextInfo: FileInfo = this.selectVM.fileList[index]
    this.levelDirectorList.push(nextInfo)
    this.selectVM.fileList = nextInfo.contentList
  }

  // 切换到一级目录
  public changeToPrelevelDirector(index: number) {
    // 底部弹框事件是穿透的，此时弹框可能显示
    this.isShow = false
    this.levelDirectorList.splice(index + 1, this.levelDirectorList.length - index - 1)
    this.selectVM.fileList = this.levelDirectorList[index].contentList
  }

  // 删除所有选中项
  public cancelCollectedAllSelected() {
    this.selectVM.getAllSelected().forEach((item) => {
      item.isCollected = false
    })
    this.selectVM.selectedIndexes.clear()
  }
}