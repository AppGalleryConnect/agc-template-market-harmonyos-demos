import { AppStorageV2, PersistenceV2 } from '@kit.ArkUI';
import {
  BaseViewModel, BreakpointModel, BreakpointNameEnum,
  CommonConfirmDialog,
  PopViewUtils,
  RouterMap, RouterUtils,
} from 'lib_common';
import { AvResponse, HomeServiceApi } from 'lib_tv_apis';
import { SearchHistory } from '../models/SearchHistoryModel';
import { ValueType } from '@kit.ArkData';

@ObservedV2
export class SearchViewModel extends BaseViewModel {
  searchHistory: SearchHistory = PersistenceV2.connect(SearchHistory, () => new SearchHistory())!;
  @Trace searchResultList: AvResponse[] = []
  @Trace breakpointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;

  @Computed
  get isSmDevice() {
    return this.breakpointModel.currentBreakpoint === BreakpointNameEnum.SM
  }

  async getSearchResultList(searchValue: string) {
    if(searchValue.trim() === '') {
      this.searchResultList = []
      return
    }
    let res = await HomeServiceApi.queryTelevisionList()
    this.searchResultList = res.filter(item => item.title.includes(searchValue))
  }

  public goSearchDetails(avId: string) {
    let params: Record<string, ValueType | undefined> = {
      'avId': avId,
      'isCreateSubWindow': false,
    }
    RouterUtils.pushPathByName(RouterMap.VIDEO_PROGRAM_DETAILS, params)
  }

  searchChange(searchValue: string) {
    this.getSearchResultList(searchValue)
    if (this.searchHistory.historyList.includes(searchValue) || searchValue.trim() === '') {
      return
    }
    this.searchHistory.historyList.unshift(searchValue)
  }

  clearHistory() {
    if(this.searchHistory.historyList.length === 0) {
      return
    }
    CommonConfirmDialog.show({
      content: '确定清空全部历史记录？',
      confirm: () => {
        this.searchHistory.historyList = []
      },
    })
  }
}