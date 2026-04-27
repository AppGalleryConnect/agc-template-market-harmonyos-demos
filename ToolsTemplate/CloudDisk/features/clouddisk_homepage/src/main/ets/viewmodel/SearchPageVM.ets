import { FileInfo, MockService } from 'common';
import { FileListSelectViewVM } from 'clouddisk_file_select';

@ObservedV2
export class SearchPageVM {
  logTag: string = 'SearchPage';
  searchHistoryLength: number = 7;
  private static _rootInstance: SearchPageVM;

  public static get rootInstance(): SearchPageVM {
    if (SearchPageVM._rootInstance === undefined) {
      SearchPageVM._rootInstance = new SearchPageVM(new FileListSelectViewVM(MockService.allFileList))
    }
    return SearchPageVM._rootInstance;
  }

  // 文件分类数据
  private _fileTypeTitles: string[] = ['全部', '图片', '视频', '文件', '音频', '其他'];

  public get fileTypeTitles(): string[] {
    return this._fileTypeTitles;
  }

  // 文件操作弹框是否展示
  @Trace isShow: boolean = false;
  // 文件列表
  @Trace fileList: FileInfo[] = MockService.allFileList
  // 选择管理类
  @Trace selectVM: FileListSelectViewVM = new FileListSelectViewVM()
  // 显示上拉操作栏
  @Trace isShowOperation: boolean = false;
  @Trace showHistory: boolean = true

  // 构造函数
  constructor(selectVM?: FileListSelectViewVM, fileInfo?: FileInfo) {
    if (selectVM !== undefined) {
      this.selectVM = selectVM
    }
    this.selectVM.fileList = this.fileList
  }
}