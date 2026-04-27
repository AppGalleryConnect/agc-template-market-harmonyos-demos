import { Constants } from '../common/Constant';
import { GridRowColSetting } from '../common/GridRowColSetting';
import { SearchItem } from '../types/Type';

@ComponentV2
export struct HotSearch {
  @Param hotSearchList: SearchItem[] = [];
  @Param breakpoint: string = 'sm';
  @BuilderParam itemBuilderParam: WrappedBuilder<[SearchItem, number]>;
  @Event getMore: () => void = () => {
  }
  @Event selectHotSearchItem: (listItem: SearchItem, index?: number) => void = () => {
  }

  build() {
    Column() {
      Row() {
        Text('热搜榜')
          .fontSize($r('sys.float.Subtitle_L'))
          .fontWeight(FontWeight.Bold)
          .fontFamily('HarmonyHeiTi')

        Row({ space: Constants.SPACE_SPECIAL }) {
          Text('更多')
            .fontColor($r('sys.color.font_secondary'))
            .fontSize($r('sys.float.Body_M'))
            .fontWeight(FontWeight.Regular)
            .fontFamily('HarmonyHeiTi')
            .textAlign(TextAlign.End)

          SymbolGlyph($r('sys.symbol.chevron_right'))
            .fontSize(Constants.CHEVRON_WIDTH)
            .fontColor([$r('sys.color.icon_tertiary')])
        }
        .onClick(() => {
          this.getMore()
        })
      }
      .width(Constants.FULL_PERCENT)
      .height(Constants.HISTORY_HEIGHT)
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({
        left: Constants.PADDING_M,
        right: Constants.PADDING_M,
        top: Constants.PADDING_XL,
        bottom: Constants.PADDING_S,
      })
      .margin({ bottom: Constants.SPACE_S })

      List({ space: Constants.SPACE_S }) {
        ForEach(this.hotSearchList, (listItem: SearchItem, index: number) => {
          ListItem() {
            if (this.itemBuilderParam !== undefined) {
              this.itemBuilderParam.builder(listItem, index)
            } else {
              this.itemBuilder(listItem, index)
            }
          }
          .onClick(() => {
            this.selectHotSearchItem(listItem)
          })
        }, (listItem: SearchItem) => JSON.stringify(listItem.title))
      }
      .nestedScroll({
        scrollForward: NestedScrollMode.PARENT_FIRST,
        scrollBackward: NestedScrollMode.PARENT_FIRST
      })
      .edgeEffect(EdgeEffect.Spring)
      .scrollBar(BarState.Off)
      .lanes(GridRowColSetting.getShowResult(this.breakpoint), 24)
      .width(Constants.FULL_PERCENT)
    }
    .borderRadius(16)
    .backgroundColor($r('sys.color.background_primary'))
    .padding({ bottom: Constants.PADDING_L })
    .margin({ top: Constants.PADDING_S })
  }

  @Builder
  itemBuilder(listItem: SearchItem, index: number) {
    Row({ space: Constants.PADDING_M }) {
      Text(`${index + 1}`)
        .fontSize($r('sys.float.Body_M'))
        .fontWeight(FontWeight.Regular)
        .fontFamily('HarmonyHeiTi')
        .fontColor(Number(index) < 3 ? $r('sys.color.alert') : $r('sys.color.font_secondary'))

      if (listItem.image) {
        Image(listItem.image)
          .width(Constants.IMAGE_WIDTH)
          .height(Constants.IMAGE_HEIGHT)
          .objectFit(ImageFit.Fill)
      }

      Column() {
        Text(listItem.title)
          .textStyles()
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'))

        if (listItem.intro) {
          Text(listItem.intro)
            .textStyles()
            .fontWeight(FontWeight.Regular)
            .fontColor($r('sys.color.font_secondary'))
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(HorizontalAlign.Start)
    }
    .alignItems(VerticalAlign.Center)
    .margin({ right: Constants.PADDING_M, left: Constants.PADDING_M })
    .height(Constants.LIST_HEIGHT)
    .layoutWeight(1)
  }
}

@Extend(Text)
function textStyles() {
  .textAlign(TextAlign.Start)
  .width(Constants.FULL_PERCENT)
  .maxLines(1)
  .textOverflow({ overflow: TextOverflow.Ellipsis })
  .fontSize($r('sys.float.Body_M'))
}