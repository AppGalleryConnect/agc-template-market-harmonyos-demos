import { FileInfo, FileTransferProgressingStatus, FileType, MockService } from 'common';
import { FileListSelectViewVM } from 'clouddisk_file_select';

@ObservedV2
export class MainPageVM {
  logTag: string = 'MainPage';
  // 文件根目录，移动文件需要用到
  private static _rootInstance: MainPageVM;

  public static get rootInstance(): MainPageVM {
    if (MainPageVM._rootInstance === undefined) {
      MainPageVM._rootInstance = new MainPageVM(new FileListSelectViewVM(MockService.allFileList))
    }
    return MainPageVM._rootInstance;
  }

  // 文件分类数据
  private _fileTypeTitles: string[] = ['图片', '视频', '文件', '音频', '其他'];

  public get fileTypeTitles(): string[] {
    return this._fileTypeTitles;
  }

  // 类型分类
  public filterListBySelectedType(index: number) {
    this.fileTypeIndex = index
    // 根据类型查找
    let list: FileInfo[] = []
    let tmpType: FileType = FileType.Other
    switch (this.fileTypeIndex) {
      case 0:
        tmpType = FileType.Picture
        break
      case 1:
        tmpType = FileType.Video
        break
      case 2:
        tmpType = FileType.File
        break
      case 3:
        tmpType = FileType.Audio
        break
      default:
        break;
    }
    this.fileList.forEach((item: FileInfo) => {
      if (tmpType === item.fileType) {
        list.push(item)
      }
    })
    this.selectVM.fileList = list
  }

  // 显示上拉操作栏
  @Trace isShowOperation: boolean = false;
  // 文件操作弹框是否展示
  @Trace isShow: boolean = false;
  // 文件类型索引
  @Trace fileTypeIndex: number = 0;
  // 文件列表
  @Trace fileList: FileInfo[] = MockService.allFileList
  // 上传文件更新列表
  @Trace uploadFileProgressingList: FileInfo[] = []
  // 文件上传更新提示
  @Trace uploadFileUpdate: FileTransferProgressingStatus = new FileTransferProgressingStatus()
  // 选择管理类
  @Trace selectVM: FileListSelectViewVM = new FileListSelectViewVM()

  // 构造函数
  constructor(selectVM?: FileListSelectViewVM, fileInfo?: FileInfo) {
    if (selectVM !== undefined) {
      this.selectVM = selectVM
    }
    this.filterListBySelectedType(0)
  }
}