import { AppStorageV2, curves, PersistenceV2 } from '@kit.ArkUI';
import { AvResponse, HomeServiceApi, NewsResponse } from 'lib_tv_apis';
import {
  BreakpointModel,
  CircleButtonModifier,
  Constants,
  NavHeaderTitleBar,
  RouterUtils,
  WindowModel,
} from 'lib_common';
import { SearchViewModel } from '../viewmodel/SearchViewModel';
import { ThrottleUtils } from '../utils/ThrottleUtils';

@Builder
export function NewsSearchBuilder() {
  NewsSearch()
}

@ComponentV2
export struct NewsSearch {
  @Local searchValue: string = ''
  @Local isSearchCommit: boolean = false;
  @Local homeViewVM: SearchViewModel = new SearchViewModel()
  @Local homeViewModel: SearchViewModel = new SearchViewModel();
  @Local windowModel: WindowModel = AppStorageV2.connect(WindowModel, () => new WindowModel())!;
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Local componentId: string = ''
  buttonModifier: CircleButtonModifier = new CircleButtonModifier();
  private searchId: string = 'news_search'
  private readonly SEARCH_THROTTLE_KEY: string = 'search_change';

  @Builder
  searchBuilder() {
    Search({ value: this.searchValue })
      .cancelButton({
        style: CancelButtonStyle.CONSTANT,
      })
      .defaultFocus(true)
      .geometryTransition('news_search_transition_' + this.componentId)
      .transition(TransitionEffect.opacity(0.99))
      .id(this.searchId)
      .onChange((value) => {
        this.searchValue = value
        this.searchValue = value;
        ThrottleUtils.throttle(this.SEARCH_THROTTLE_KEY, () => {
          this.homeViewVM.searchChange(value);
          this.isSearchCommit = true
        }, 300);
      })
      .fontColor($r('sys.color.font_primary'))
      .onSubmit(() => {
        this.homeViewVM.getSearchResultList(this.searchValue)
        this.isSearchCommit = true
      })
      .defaultFocus(true)
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .textFont({ size: $r('sys.float.Body_L'), weight: FontWeight.Medium })
      .flexGrow(1)
  }

  @Builder
  historySearch() {
    Column() {
      Flex({ justifyContent: FlexAlign.SpaceBetween }) {
        Text('历史搜索')
          .fontSize(14)
          .fontColor($r('sys.color.font_secondary'))
        Row({ space: 4 }) {
          Image($r('app.media.clear')).width(16).height(16)
          Text('清空')
            .fontSize(14)
            .fontColor($r('sys.color.font_secondary'))
        }
        .onClick(() => {
          this.homeViewVM.clearHistory()
        })
      }

      Flex({ justifyContent: FlexAlign.Start, wrap: FlexWrap.Wrap }) {
        Row() {
          Text('暂无历史搜索')
            .fontSize(12)
            .fontColor($r('sys.color.font_secondary'))
        }
        .visibility(this.homeViewVM.searchHistory.historyList.length <= 0 ? Visibility.Visible : Visibility.None)
        .width('100%')
        .justifyContent(FlexAlign.Center)

        ForEach(this.homeViewVM.searchHistory.historyList.slice(0, 24), (item: string) => {
          Row() {
            Text(item)
              .fontSize(14)
              .fontColor($r('sys.color.font_primary'))
              .fontWeight(FontWeight.Medium)
          }
          .padding({
            left: 12,
            right: 12,
            top: 4,
            bottom: 4,
          })
          .onClick(() => {
            this.searchValue = item
            this.homeViewVM.getSearchResultList(this.searchValue)
            this.isSearchCommit = true
          })
          .margin({ right: 12, bottom: 12 })
          .borderRadius(14)
          .backgroundColor($r('sys.color.comp_background_tertiary'))
          .visibility(this.homeViewVM.searchHistory.historyList.length <= 0 ? Visibility.None : Visibility.Visible)
        }, (item: string) => item)
      }
      .margin({ top: 12, bottom: 12 })
    }
    .padding({
      left: this.breakPointModel.pagePadding,
      right: this.breakPointModel.pagePadding,
    })
    .margin({ top: 16 })
  }

  @Builder
  searchListBuilder() {
    List({ space: 21 }) {
      ListItem() {
        Column() {
          Image($r('app.media.search_no_result')).width(120).height(120)
          Text('暂无搜索结果')
            .fontSize(14)
            .fontColor($r('sys.color.font_secondary'))
        }
      }
      .visibility(this.homeViewVM.searchResultList.length <= 0 ? Visibility.Visible : Visibility.None)
      .width(Constants.FULL_PERCENT)
      .height('80%')

      ForEach(this.homeViewVM.searchResultList, (item: AvResponse) => {
        ListItem() {
          Flex() {
            Row() {
              Image($r('app.media.search')).width(14).height(14)
                .fillColor($r('sys.color.font_primary'))
            }
            .width(30)
            .height(18)
            .justifyContent(FlexAlign.Start)
            .alignItems(VerticalAlign.Center)

            Text(item.title)
              .fontSize(14)
              .fontColor($r('sys.color.font_primary'))
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .flexGrow(1)
          }
        }
        .onClick(() => {
          this.homeViewVM.goSearchDetails(item.id)
          this.isSearchCommit = true
        })
        .visibility(this.homeViewVM.searchResultList.length <= 0 ? Visibility.None : Visibility.Visible)
      }, (item: NewsResponse) => JSON.stringify(item))
    }
    .padding({
      left: this.breakPointModel.pagePadding,
      right: this.breakPointModel.pagePadding,
    })
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
    .visibility(this.isSearchCommit ? Visibility.Visible : Visibility.None)
    .scrollBar(BarState.Off)
    .layoutWeight(1)
    .cachedCount(1)
  }

  build() {
    NavDestination() {
      NavHeaderTitleBar({ title: '搜索', fontSize: 20 })
        .padding({ left: 16 })
      Column() {
        Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
          this.searchBuilder()
        }
        .padding({
          left: this.breakPointModel.pagePadding,
          right: this.breakPointModel.pagePadding,
        })
        .width('100%')
        .height(50)

        if (this.searchValue.trim() !== '') {
          this.searchListBuilder()
        } else {
          this.historySearch()
        }
      }
      .backgroundColor($r('sys.color.background_primary'))
    }
    .onShown(() => {
      focusControl.requestFocus(this.searchId)
    })
    .hideTitleBar(true)
    .onReady((context: NavDestinationContext) => {
      this.componentId = context.pathInfo?.param as string
    })
  }
}