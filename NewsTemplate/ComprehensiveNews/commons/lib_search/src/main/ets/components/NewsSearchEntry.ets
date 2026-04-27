import { RouterUtils, BreakpointNameEnum } from 'lib_common';
import { SearchView, SearchItem, SearchWordItem, PresentationType, SearchViewController } from 'module_search';
import { SearchControllerMng } from '../common/SearchControllerMng';
import { NewsSearchViewModel } from '../viewmodels/NewsSearchViewModel';
import { resultItemBuilder, searchAbstractBuilder } from './CustomBuilder';

/**
 * 搜索入口
 * 直板机、折叠屏点击行为：跳转搜索页面
 * 平板点击行为：当前页面打开半模态窗口
 */
@ComponentV2
export struct NewsSearchEntry {
  @Require @Param name: string = '';
  @Param controller: SearchViewController = new SearchViewController();
  @Param tabBarScroller: Scroller = new Scroller();
  @Param searchResultScroller: Scroller = new Scroller();
  @Param colorMode: ThemeColorMode = ThemeColorMode.SYSTEM;
  @Param searBarFgColor: ResourceColor = $r('sys.color.font_primary');
  @Param searchBarPlaceholderColor: ResourceColor = $r('sys.color.font_secondary');
  @Param searchBarBgColor: ResourceColor = $r('sys.color.comp_background_tertiary');
  @Param searchButtonFgColor: ResourceColor = $r('sys.color.icon_primary');
  @Local vm: NewsSearchViewModel = new NewsSearchViewModel();

  async aboutToAppear(): Promise<void> {
    await this.vm.init();
    SearchControllerMng.addController(this.name, this.controller);
  }

  aboutToDisappear(): void {
    SearchControllerMng.deleteController(this.name);
  }

  build() {
    Row() {
      SearchView({
        presentationType: [BreakpointNameEnum.SM,
          BreakpointNameEnum.MD].includes(this.vm.breakPointModel.currentBreakpoint) ? PresentationType.SEARCH_ICON :
          PresentationType.SEARCH_BOX,
        entranceText: ['输入关键词'],
        routerStack: RouterUtils.getStack(),
        controller: this.controller,
        placeholder: '输入关键词',
        themeColor: $r('app.color.app_theme'),
        colorMode: this.colorMode,
        searBarFgColor: this.searBarFgColor,
        searchBarPlaceholderColor: this.searchBarPlaceholderColor,
        searchBarBgColor: this.searchBarBgColor,
        searchButtonFgColor: this.searchButtonFgColor,
        showFilterTag: true,
        showGuessLike: true,
        showHotSearch: true,
        isShallowWindow: true,
        tabBarScroller: this.tabBarScroller,
        searchResultScroller: this.searchResultScroller,
        handleSearch: (keyWord: string | SearchWordItem | SearchItem) => {
          return this.vm.handleSearch(keyWord);
        },
        searchSuggestion: (keyWord: string) => {
          return this.vm.searchSuggestion(keyWord);
        },
        queryHistoryList: () => {
          return this.vm.queryHistoryList();
        },
        deleteHistoryList: () => {
          return this.vm.deleteHistoryList();
        },
        queryGuessList: (isRefresh: boolean) => {
          return this.vm.queryGuessList(isRefresh);
        },
        queryHotSearchList: () => {
          return this.vm.queryHotSearchList();
        },
        resultItemBuilderParam: wrapBuilder(resultItemBuilder),
        searchAbstractBuilderParam: wrapBuilder(searchAbstractBuilder),
      })
    }
  }
}