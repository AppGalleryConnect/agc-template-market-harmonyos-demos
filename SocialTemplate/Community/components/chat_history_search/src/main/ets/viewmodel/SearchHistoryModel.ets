@ObservedV2
export class SearchHistoryModel {
  @Trace searchHistoryList: string[] = [];

  public pushNewSearchText(searchText: string) {
    let newList = this.searchHistoryList.filter((item) => item !== searchText);
    newList = [searchText, ...newList];
    if (newList.length > 6) {
      newList = newList.slice(0, 6);
    }
    this.searchHistoryList = newList;
  }
}