import { DialogType, SwiperDirection, TypePicker, UICalendarPicker } from '@hw-agconnect/ui-calendar-picker';
import { AppStorageV2 } from '@kit.ArkUI';
import { ChatBreakpoint, ChatContentSingleModel } from 'chat_base';
import { ContactSearchModel } from '../viewmodel/ContactSearchModel';
import { SearchModel } from '../viewmodel/SearchModel';
import { RecentSearchesView } from './RecentSearchesView';
import { SearchResultView } from './SearchResultView';
import { SearchView } from './SearchView';

@ComponentV2
export struct ChatHistorySearchComponent {
  @Param userId: string = '';
  @Param groupId: string = '';
  @Param onCloudMessageSearch: ((searchKey: string, userId?: string,
    groupId?: string, startDate?: number) => Promise<ChatContentSingleModel[]>) | undefined = undefined;
  @Param onCloudContactSearch: ((searchKey: string) => Promise<ContactSearchModel[]>) | undefined = undefined;
  @Param onReturnClick: () => void = () => {
  };
  @Local chatBreakpoint: ChatBreakpoint = AppStorageV2.connect(ChatBreakpoint, () => new ChatBreakpoint())!;
  @Local searchVM: SearchModel = new SearchModel(this.userId, this.groupId);
  // 搜索点击回调
  @Local onSubmitSearch: () => void = () => {
    if(this.searchVM.searchText?.length > 0) {
      this.searchVM.searchHistory.pushNewSearchText(this.searchVM.searchText);
      this.searchWithText();
      this.searchVM.searching = true;
    }
  };
  // 最近搜索点击回调
  @Local onRecentSearchClick: (searchText: string) => void =
    (searchText: string) => {
      this.searchVM.searchText = searchText;
      this.searchVM.callSearchTextChange();
      this.onSubmitSearch();
    };

  aboutToAppear(): void {
    this.searchVM.searchMessageFromCloud = this.onCloudMessageSearch;
    this.searchVM.searchContactFromCloud = this.onCloudContactSearch;
  }

  /**
   * 关键字搜索
   */
  searchWithText = () => {
    this.searchVM.getSearchResult(this.searchVM.searchParUserId, this.searchVM.searchParGroupId);
  }
  /**
   * 日期搜索
   */
  searchWithStartDate = () => {
    this.searchVM.getSearchResultWithDate(this.searchVM.selectDate ? this.searchVM.selectDate.getTime() : 0,
      this.searchVM.searchParUserId, this.searchVM.searchParGroupId);
  }
  /**
   * 返回时如果选了日期 先清空日期 显示非搜索状态UI 再次点击才能返回
   */
  onBack = () => {
    if (this.searchVM?.selectDate) {
      this.searchVM.selectDate = undefined;
      this.searchVM.searching = false;
    } else {
      this.onReturnClick();
    }
  }

  @Builder
  dateSelectView() {
    UICalendarPicker({
      customBuildPanel: this.dateTextView,
      type: TypePicker.SINGLE,
      dialogType: DialogType.SHEET,
      swiperDirection: SwiperDirection.VERTICAL,
      sheetTitle: $r('app.string.search_date_title'),
      onSelected: (date: Date | Date[]) => {
        this.searchVM.selectDate = Array.isArray(date) ? date[0] : date;
        this.searchWithStartDate();
        this.searchVM.searching = true;
      }
    })
  }

  @Builder
  dateTextView() {
    Text($r('app.string.search_with_date'))
      .fontSize($r('sys.float.Body_M'))
      .fontColor($r('sys.color.font_tertiary'))
      .lineHeight($r('app.float.vp_22'))
  }

  build() {
    Column() {
      SearchView({
        onSubmitSearch: this.onSubmitSearch,
        searchVM: this.searchVM,
        onReturnClick: this.onBack,
      })
      if (!this.searchVM.searching) {
        if (this.userId || this.groupId) {
          Column() {
            this.dateSelectView()
          }.margin({
            top: $r('app.float.vp_40')
          })
        } else {
          if (this.searchVM.searchHistory.searchHistoryList.length > 0) {
            RecentSearchesView({
              onRecentSearchClick: this.onRecentSearchClick,
              searchHistoryList: this.searchVM.searchHistory.searchHistoryList
            })
          }
        }
      } else {
        SearchResultView({
          searchVM: this.searchVM,
        })
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
    .layoutWeight(1)
    .backgroundColor($r('sys.color.white'))
    .padding({
      left: this.chatBreakpoint.pagePadding,
      right: this.chatBreakpoint.pagePadding,
      bottom: this.chatBreakpoint.bottomValue,
      top: $r('app.float.vp_12')
    })
  }
}
