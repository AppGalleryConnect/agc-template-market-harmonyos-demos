import { Constants } from '../common/Constant';
import { GridRowColSetting } from '../common/GridRowColSetting';
import { SearchWordItem } from '../types/Type';
import { SearchViewModel } from '../viewmodel/SearchViewModel';

@ComponentV2
export struct GuessLike {
  @Param guessLikeList: SearchWordItem[] = [];
  @Param breakpoint: string = 'sm';
  @BuilderParam itemBuilderParam: WrappedBuilder<[string]>;
  @Event selectGuessLikeItem: (item: SearchWordItem, index?: number) => void = () => {
  }
  @Event queryGuessList: () => void = () => {
  };
  @Local vm: SearchViewModel = SearchViewModel.getInstance();

  build() {
    Column() {
      Row() {
        Text('猜你想搜')
          .fontSize($r('sys.float.Subtitle_L'))
          .fontWeight(FontWeight.Bold)
          .fontFamily('HarmonyHeiTi')

        SymbolGlyph($r('sys.symbol.arrow_counterclockwise'))
          .fontSize(Constants.CHEVRON_WIDTH)
          .fontColor([$r('sys.color.icon_primary')])
          .onClick(() => {
            this.queryGuessList();
          })
      }
      .width(Constants.FULL_PERCENT)
      .height(Constants.HISTORY_HEIGHT)
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({
        top: Constants.PADDING_XL,
        bottom: Constants.PADDING_S,
      })

      List({ space: GridRowColSetting.getGuessLikeSpace(this.breakpoint) }) {
        ForEach(this.guessLikeList.slice(0, ((['lg', 'xl'].includes(this.breakpoint)) && this.vm.isShallowWindow) ? 4 :
          (2 * GridRowColSetting.getGuessLikeColumn(this.breakpoint))),
          (listItem: SearchWordItem, index: number) => {
            ListItem() {
              if (this.itemBuilderParam !== undefined) {
                this.itemBuilderParam.builder(listItem.content)
              } else {
                this.itemBuilder(listItem.content)
              }
            }
            .onClick(() => {
              this.selectGuessLikeItem(listItem, index)
            })
          }, (listItem: SearchWordItem) => JSON.stringify(listItem.content))
      }
      .nestedScroll({
        scrollForward: NestedScrollMode.PARENT_FIRST,
        scrollBackward: NestedScrollMode.PARENT_FIRST
      })
      .edgeEffect(EdgeEffect.Spring)
      .lanes(GridRowColSetting.getGuessLikeColumn(this.breakpoint),
        GridRowColSetting.getGuessLikeSpace(this.breakpoint))
      .width(Constants.FULL_PERCENT)
    }
  }

  @Builder
  itemBuilder(listItem: string) {
    Row({ space: Constants.SPACE_M }) {
      SymbolGlyph($r('sys.symbol.magnifyingglass'))
        .fontSize(Constants.GLASS_SIZE)
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
    .height(Constants.GUESS_HEIGHT)
    .width(Constants.FULL_PERCENT)
  }
}