import { PersistenceV2 } from '@kit.ArkUI'
import { CommonConstants, SettingModel, TimeUtils } from 'lib_common'
import { LayoutParams } from 'module_flexlayout'

@ComponentV2
export struct ArticleSourceBuilder {
  @Param @Require cardData: LayoutParams
  @Local settingInfo: SettingModel = PersistenceV2.connect(SettingModel, () => new SettingModel())!

  build() {
    Row() {
      Text(this.cardData.nativeCardData?.author?.authorNickName)
        .fontSize(12 * this.settingInfo.fontSizeRatio)
        .fontColor($r('sys.color.font_tertiary'))
        .textAlign(TextAlign.Start)
      Text(TimeUtils.formatDate(this.cardData.nativeCardData?.createTime, 'YYYY-MM-DD HH:mm'))
        .fontSize(12 * this.settingInfo.fontSizeRatio)
        .fontColor($r('sys.color.font_tertiary'))
        .textAlign(TextAlign.Start)
        .margin({ left: 8 })
      Blank()
      SymbolGlyph($r('sys.symbol.dot_grid_1x2'))
        .fontSize(16)
        .fontColor([$r('sys.color.icon_tertiary')])
        .onClick(() => {
          if (this.cardData.extraInfo.onMoreClick) {
            (this.cardData.extraInfo.onMoreClick as Function)();
          }
        })
    }
    .width(CommonConstants.FULL_PERCENT)
    .visibility(this.cardData.extraInfo.isNeedAuthor ? Visibility.None : Visibility.Visible)
  }
}
