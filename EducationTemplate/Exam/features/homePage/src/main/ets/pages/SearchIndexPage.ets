import { BreakpointModel, RouterMap, RouterModule } from 'commonlib';
import { PresentationType, SearchItem, SearchView, SearchViewController } from 'search';
import { AppStorageV2 } from '@kit.ArkUI';

@ComponentV2
export struct SearchIndexPage {
  @Local inputParam: string = ''
  @Local searchSourceData: string[] =
    ['2023初级会计-初级会计实务题库', '初级会计实务', '初级会计实务真题', '初级会计实务真题', '2024初级会计经济法冲刺'];
  @Local navPathStack: NavPathStack = new NavPathStack();
  @Local breakpoint: string = '';
  controller: SearchViewController = new SearchViewController();
  @Local breakpointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;


  onBackPress(): boolean | void {
    return this.controller.onBackPressed();
  }

  aboutToAppear(): void {
    this.inputParam = RouterModule.getNavParam({ url: RouterMap.SEARCH_PAGE }) as string
  }



  build() {
    Column() {
      SearchView({
        presentationType: this.breakpointModel.currentBreakpoint === 'sm' ?
          PresentationType.SEARCH_ICON : PresentationType.SEARCH_BOX,
        entranceText: ['搜索推荐1', '搜索推荐2', '搜索推荐3'],
        routerStack: this.navPathStack,
        controller: this.controller,
        isShallowWindow: true,
        guessItemBuilderParam: wrapBuilder(myBuilder),
        onClickGetMore: () => {
          this.getUIContext().getPromptAction().showToast({ message: '前往更多页，暂未开发' })
        },
        onClickResultItem: (listItem: SearchItem) => {
          this.getUIContext().getPromptAction().showToast({ message: '前往详情页，暂未开发' })
        },
      })
      .width(40).height(40).backgroundColor($r('sys.color.comp_background_tertiary'))
    }
    .onClick(() => {
      this.controller.closePop();
    })
    .width('100%')
    .height('100%')
  }
}

@Builder
function myBuilder(listItem: string) {
  Row({ space: 12 }) {
    SymbolGlyph($r('sys.symbol.magnifyingglass'))
      .fontSize(16)
      .fontColor([$r('sys.color.icon_primary')])

    Text(listItem)
      .fontSize($r('sys.float.Body_M'))
      .fontFamily('HarmonyHeiTi')
      .fontColor($r('sys.color.font_primary'))
      .textAlign(TextAlign.Start)
      .layoutWeight(1)
      .maxLines(1)
      .textOverflow({ overflow: TextOverflow.Ellipsis })
  }
  .justifyContent(FlexAlign.Center)
  .height(40)
  .width('100%')
}

@Builder
export function SearchPageBuilder() {
  SearchIndexPage();
}

