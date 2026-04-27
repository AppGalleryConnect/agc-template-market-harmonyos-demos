
@ObservedV2
export class SearchController {
  private static _instance: SearchController;

  public static get instance() {
    if (!SearchController._instance) {
      SearchController._instance = new SearchController();
    }
    return SearchController._instance;
  }

  @Trace searchCondition: string = '';
  @Trace isShowResult: boolean = false;
  // 热门搜索
  @Trace hotSearch: Array<string> = ['如家', '北京环球度假村', '颐和园', '故宫', '天坛', '迪士尼', '全季', '南京'];
  // 搜索历史
  @Trace historySearch: Array<string> = [];

  updateHistorySearch(content: string) {
    let index: number = this.historySearch.indexOf(content);
    if (index === -1) {
      this.historySearch.unshift(content);
      return;
    }
    this.historySearch.splice(index, 1);
    this.historySearch.unshift(content);
    return;
  }
}