import { Constants } from '../common/Constant';
import { GridRowColSetting } from '../common/GridRowColSetting';
import { SearchWordItem } from '../types/Type';
import { SearchViewModel } from '../viewmodel/SearchViewModel';

@ComponentV2
export struct GuessLike {
  @Param guessLikeList: SearchWordItem[] = [];
  @Param breakpoint: string = 'sm';
  @Param itemBuilderParam: WrappedBuilder<[string]> | undefined = undefined;
  @Require @Param vm: SearchViewModel = SearchViewModel.getInstance();
  @Event selectGuessLikeItem: (item: SearchWordItem, index?: number) => void = () => {
  }
  @Event queryGuessList: () => void = () => {
  };

  build() {
    Column() {
      Row() {
        Text('猜你想搜')
          .fontSize($r('sys.float.Subtitle_L'))
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(FontWeight.Bold)
          .fontFamily('HarmonyHeiTi')
          .maxLines(1)
          .flexShrink(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        if (!this.vm.isHiddenGuess) {
          Row({ space: Constants.SPACE_XL }) {
            SymbolGlyph($r('sys.symbol.arrow_counterclockwise'))
              .fontSize(Constants.CHEVRON_WIDTH)
              .fontColor([$r('sys.color.icon_primary')])
              .maxFontScale(1)
              .onClick(() => {
                this.queryGuessList();
              })
            SymbolGlyph($r('sys.symbol.enhance_eyes'))
              .fontSize(Constants.CHEVRON_WIDTH)
              .fontColor([$r('sys.color.icon_primary')])
              .maxFontScale(1)
              .onClick(() => {
                this.vm.isHiddenGuess = true;
              })
          }
        } else {
          Row({ space: Constants.SPACE_XS }) {
            Text('已隐藏')
              .fontColor($r('sys.color.font_secondary'))
              .fontSize($r('sys.float.Body_M'))
              .fontWeight(FontWeight.Regular)
              .fontFamily('HarmonyHeiTi')
            SymbolGlyph($r('sys.symbol.eye_slash'))
              .fontSize(Constants.CHEVRON_WIDTH)
              .fontColor([$r('sys.color.icon_secondary')])
              .maxFontScale(1)
              .onClick(() => {
                this.vm.isHiddenGuess = false;
              })
          }
          .alignItems(VerticalAlign.Bottom)
        }
      }
      .width(Constants.FULL_PERCENT)
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Bottom)
      .padding({
        top: Constants.PADDING_XXL,
        bottom: Constants.PADDING_S,
      })

      if (!this.vm.isHiddenGuess) {
        List({ space: GridRowColSetting.getGuessLikeSpace(this.breakpoint) }) {
          ForEach(
            this.guessLikeList.slice(0, ((['lg', 'xl'].includes(this.breakpoint)) && this.vm.isShallowWindow) ? 4 :
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
    .width(Constants.FULL_PERCENT)
    .padding({
      top: Constants.PADDING_TEN,
      bottom: Constants.PADDING_TEN,
    })
  }
}