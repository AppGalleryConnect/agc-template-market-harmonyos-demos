import { buildTitleBar, CommonConstants, PreferenceUtil, RouterMap, RouterModule } from 'commonlib';
import { LengthMetrics } from '@kit.ArkUI';
import { SearchPageVM } from '../viewModels/SearchPageVM';
import { HomeSearch } from 'home_search';
import { LoneTakeAnimationsTransition, LongTakeTransitionParam } from 'module_transition';

@Builder
export function SearchPageBuilder() {
  SearchPage();
}

@Preview
@ComponentV2
struct SearchPage {
  vm: SearchPageVM = new SearchPageVM();

  aboutToAppear(): void {
    this.vm.getHotkeys();
    this.vm.getDefaultSearch();
    this.vm.historyInfo = PreferenceUtil.getInstance().get(CommonConstants.SEARCH_KEYS) as [] ?? [];
  }

  private onColumnClicked(indexValue: string, snapShotComponentId: string): void {
    let param: Record<string, Object> = {};
    let clickedIndex = parseInt(indexValue);
    param.id = clickedIndex;
    param.indexValue = clickedIndex;
    param.snapShotId = snapShotComponentId;

    let longTakeTransitionParam: LongTakeTransitionParam | undefined =
      LoneTakeAnimationsTransition.generateLongTakeParam(this.getUIContext(), snapShotComponentId, 9);
    if (longTakeTransitionParam) {
      param.longTakeTransitionParam = longTakeTransitionParam;
    }
    RouterModule.push(RouterMap.DISHES, param)
  }

  build() {
    NavDestination() {
      Scroll() {
        HomeSearch({
            hotInfo: this.vm.hotInfo,
            resultList: this.vm.resultList,
            paramsKeyword: this.vm.paramsKeyword,
            isShowResult: this.vm.isShowResult,
            historyInfo: this.vm.historyInfo,
            isShowSearch: this.vm.formPage !== CommonConstants.CLASSIFICATION_PAGE,
            searchDishes: (keyword: string) => {
              this.vm.searchDishes(keyword)
            },
            changeIndex: (index: number, keyword: string) => {
              this.vm.changeIndex(index, keyword)
            },
            changeShowResult: (flag: boolean) => {
              this.vm.isShowResult = false
              this.vm.resultList = this.vm.resultList.filter(() => false)
            },
            goRecipeDetail: (id: number, index: number) => {
              this.onColumnClicked(id.toString(), `recipes_flow_${id}_${index}`)
            },
            submitKeyWords: (keyword: string) => {
              this.vm.submitKeyWords(keyword)
            },
            onKeyClick: (keyword: string) => {
              this.vm.onKeyClick(keyword)
            },
            clearRecords: () => {
              this.vm.clearRecords()
            },
            changeRecipes: (keyword: string) => {
              this.vm.searchDishes(keyword)
            }
          })
      }
      .height('100%')
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .align(Alignment.Top)
    }
    .title(buildTitleBar(this.vm.title, this.vm.formPage === CommonConstants.CLASSIFICATION_PAGE),
      { paddingStart: LengthMetrics.vp(16) })
    .backgroundColor($r('sys.color.comp_background_gray'))
    .padding({top: 40})
  }
}


