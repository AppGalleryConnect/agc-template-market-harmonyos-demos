import { FileInfo, MockService } from 'common';
import { FileListSelectViewVM } from 'clouddisk_file_select';

@ObservedV2
export class SearchClassificationPageVM {
  logTag: string = 'SearchClassificationPage';
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
  // 筛选列表
  @Trace searchFileList: FileInfo[] = []

  searchQuery(data: string) {
    if (!data) {
      return
    }
    this.selectVM.fileList = this.fuzzySearchObjectArray(this.searchFileList, data, item => item.name)
  }

  fuzzySearchObjectArray<FileInfo>(
    items: FileInfo[],
    searchTerm: string,
    keySelector: (item: FileInfo) => string
  ): FileInfo[] {
    if (!searchTerm.trim()) {
      return items;
    }
    const term = searchTerm.toLowerCase();
    return items.filter(item =>
    keySelector(item).toLowerCase().includes(term)
    );
  }
}