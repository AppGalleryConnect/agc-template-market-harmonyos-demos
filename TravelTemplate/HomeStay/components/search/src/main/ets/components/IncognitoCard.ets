import { Constants } from '../common/Constant';

@ComponentV2
export struct IncognitoCard {
  build() {
    Column({ space: Constants.SPACE_S }) {
      Row({ space: Constants.SPACE_S }) {
        SymbolGlyph($r('sys.symbol.shield_badge_magnifyingglass'))
          .fontSize(Constants.CHEVRON_WIDTH)
          .fontColor([$r('sys.color.icon_primary')])
        Text('您已开启无痕模式')
          .fontSize($r('sys.float.Subtitle_L'))
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(FontWeight.Medium)
          .fontFamily('HarmonyHeiTi')
          .flexShrink(1)
      }
      .justifyContent(FlexAlign.Center)
      .width(Constants.FULL_PERCENT)

      Text('在无痕模式下，搜索与浏览历史不会被记录，推荐词不涉及信息收集')
        .fontSize($r('sys.float.Body_M'))
        .fontColor($r('sys.color.font_secondary'))
        .fontWeight(FontWeight.Regular)
        .fontFamily('HarmonyHeiTi')
    }
    .width(Constants.FULL_PERCENT)
    .borderRadius(Constants.BORDER_RADIUS_20)
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .backgroundColor($r('sys.color.comp_background_primary'))
    .margin({ top: Constants.PADDING_S, bottom: Constants.PADDING_M })
    .padding({
      top: Constants.PADDING_XXL,
      bottom: Constants.PADDING_XXL,
      left: Constants.PADDING_M,
      right: Constants.PADDING_M,
    })
  }
}