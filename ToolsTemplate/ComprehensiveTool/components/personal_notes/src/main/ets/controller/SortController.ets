import { SortEnum } from '../commons/Enum';
import { NoteUtil } from '../utils/NoteUtil';

@ObservedV2
export class SortController {
  noteUtil: NoteUtil = NoteUtil.instance;
  private static _instance: SortController;

  public static get instance() {
    if (!SortController._instance) {
      SortController._instance = new SortController();
    }
    return SortController._instance;
  }

  /**
   * 排序方式
   */
  @Trace sortBy: SortEnum = SortEnum.CREATE_TIME;
  /**
   * 是否打开排序弹窗
   */
  @Trace openSortSheet: boolean = false;


  // 排序确认方法
  onSortConfirm(categoryId: string, sortBy: SortEnum, searchKeyword: string) {
    this.sortBy = sortBy;
    this.noteUtil.getNoteList(categoryId, this.sortBy, searchKeyword);
    this.openSortSheet = false;
  }


}

