import { RouterMap, RouterModule, CommonConstants, BreakpointModel, BreakpointType } from 'commonlib';
import { FilterTagAndList, PresentationType, SearchItem,
  SearchSource,
  SearchView, SearchViewController,
  SearchWordItem } from 'search';
import { AppStorageV2 } from '@kit.ArkUI';
import { SearchHistory } from '../model/TopicItemModel';

@ComponentV2
export struct TopTabsBuilder {
  // 需要传入title标题,bgColor背景颜色,是否有返回键showBackButton
  @Param title: string = '';
  @Param bgColor: ResourceStr = $r('sys.color.background_secondary');
  @Param showBackButton: boolean = false;
  @Param type: string = '一级建造师';
  @Local index: number = 0;
  private topHeight: number = 56;
  @Local breakpoint: string = 'sm';
  controller: SearchViewController = new SearchViewController();
  @Local storage: SearchHistory = AppStorageV2.connect(SearchHistory, () => new SearchHistory())!;
  @Local breakpointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  searchWidth: BreakpointType<number> = new BreakpointType<number>({
    sm: 40,
    md: 40,
    lg: 400,
    xl: 400,
  });

  @Computed
  get getSearchWidth() {
    return this.searchWidth.getValue(this.breakpointModel.currentBreakpoint);
  }

  onBackPress(): boolean | void {
    return this.controller.onBackPressed();
  }

  public getResultList(keyWord: string | SearchWordItem | SearchItem,
    searchSource: SearchSource, isIncognitoMode: boolean): Promise<FilterTagAndList[]> {
    return new Promise(async resolve => {
      console.log('isIncognitoMode1111',JSON.stringify(isIncognitoMode))
      let storage: SearchHistory = AppStorageV2.connect(SearchHistory, () => new SearchHistory())!;
      let res : string[] = CommonConstants.SEARCH_SOURCE_DATA;
      if(typeof keyWord === 'string') {
        res = res.filter(item => item.includes(keyWord));
        if(!storage.historyList.includes(keyWord) && !isIncognitoMode) {
          storage.historyList.unshift(keyWord);
        }
      }
      if(typeof keyWord === 'object') {
        res = res.filter(item => item.includes((keyWord as SearchWordItem).content));
        if(!storage.historyList.includes((keyWord as SearchWordItem).content) && !isIncognitoMode) {
          storage.historyList.unshift((keyWord as SearchWordItem).content);
        }
      }
      const data: FilterTagAndList[] = [];
      res.forEach((item, index) => {
          data.push({
            label: item,
            id:  (index + 1).toString(),
            itemList: [
              {
                title: item,
                index: '1',
                image: $r('app.media.ic_questionDetail_banner'),
                intro: '初级会计实务精品课程',
              },
            ]
          })
      })
      resolve(data);
    });
  }

  public getGuessList(): Promise<SearchWordItem[]> {
    return new Promise(async resolve => {
      const res : string[] = CommonConstants.SEARCH_SOURCE_DATA;
      const data: SearchWordItem[] = [];
      res.forEach((item, index) => {
        data.push({
          content: item,
          id: index + 1,
        })
      })
      resolve(data);
    });
  }

  public getSearchSuggestion(keyWord: string): Promise<[SearchWordItem[], string[]]> {
    return new Promise(async resolve => {
      const res : string[] = CommonConstants.SEARCH_SOURCE_DATA;
      const data: SearchWordItem[] = [];
      res.forEach((item, index) => {
        if(item.includes(keyWord)) {
          data.push({
            content: item,
            id: index + 1,
          })
        }
      })
      resolve([data,[keyWord]]);
    });
  }

  public getHistoryList(): Promise<SearchWordItem[]> {
    return new Promise(async resolve => {
      let storage: SearchHistory = AppStorageV2.connect(SearchHistory, () => new SearchHistory())!;
      const data: SearchWordItem[] = [];
      storage.historyList.forEach((item, index) => {
        data.push({
          content: item,
          id: index + 1,
        })
      })
      resolve(data);
    });
  }

  build() {
    Row() {
      Row() {
        // 是否有返回键判断
        if (this.showBackButton) {
          Image($r('app.media.ic_back'))
            .height($r('app.float.vp_40'))
            .width($r('app.float.vp_40'))
            .borderRadius($r('app.float.vp_20'))
            .margin({ right: '8vp' })
            .onClick(() => {
              RouterModule.pop()
            })
        }
        if (this.title === '练习') {
          Select([])
            .value(this.type)
            .font({ size: $r('sys.float.Body_L'), weight: FontWeight.Medium })
            .space(8)
            .arrowPosition(ArrowPosition.END)
            .backgroundColor($r('sys.color.comp_background_tertiary'))
            .onClick(() => {
              RouterModule.push({ url: RouterMap.Level_ONE_PAGE })
            })
        } else {
          Text(this.title)
            .fontSize($r('sys.float.Title_S'))
            .fontWeight(FontWeight.Bold)
        }
      }
      .width('60%')
      .justifyContent(FlexAlign.Start)

      Row() {
        Row() {
          SearchView({
            presentationType: this.breakpoint === 'sm' ? PresentationType.SEARCH_ICON : PresentationType.SEARCH_BOX,
            entranceText: ['初级会计实务', '初级会计实务真题', '初级会计实务题库'],
            routerStack: RouterModule.getStack(),
            controller: this.controller,
            isShallowWindow: true,
            showHotSearch: false,
            handleSearch: this.getResultList,
            queryGuessList: this.getGuessList,
            searchSuggestion: this.getSearchSuggestion,
            queryHistoryList: this.getHistoryList,
            onClickGetMore: () => {
              this.getUIContext().getPromptAction().showToast({ message: '前往更多页，暂未开发' })
            },
            onClickResultItem: (listItem: SearchItem) => {
              RouterModule.push({ url: RouterMap.GOOD_COURSE_DETAIL_PAGE, param: listItem.title })
            },
          })
        }
        .height('40vp')
        .width(this.getSearchWidth)
        .borderRadius(20)
        .margin({ right: '8vp' })
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
      }
      .width('40%')
      .justifyContent(FlexAlign.End)
    }
    .backgroundColor(this.bgColor)
    .height(this.topHeight)
    .width('100%')
  }
}