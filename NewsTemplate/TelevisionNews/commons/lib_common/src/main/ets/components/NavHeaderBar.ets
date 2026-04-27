import { AppStorageV2 } from '@kit.ArkUI';
import { Constants } from '../constants/Constants';
import { WindowModel } from '../models/WindowModel'
import { RouterUtils } from '../utils/RouterUtils'

@ComponentV2
export struct NavHeaderTitleBar {
  @Param title: ResourceStr = '';
  @Param hasBackButton: boolean = true;
  @Param fontSize: number = 26
  @Param bgColor: ResourceStr = 'background_primary';
  @Param needPadding: boolean = false;
  @Param windowTopHeight: number = AppStorageV2.connect(WindowModel)?.getWindowTopHeight() || 38.77

  build() {
    Column() {
      Row({ space: 8 }) {
        if (this.hasBackButton) {
          Button() {
            SymbolGlyph($r('sys.symbol.chevron_backward'))
              .fontColor([$r('sys.color.font_primary')])
              .fontWeight(FontWeight.Normal)
              .fontSize(24)
          }
          .width(40)
          .height(40)
          .type(ButtonType.Circle)
          .backgroundColor($r('sys.color.comp_background_tertiary'))
          .onClick(() => {
            RouterUtils.pop('router pop')
          })
        }
        Text(this.title)
          .fontSize(this.fontSize)
          .width($r('app.string.full_size'))
          .fontWeight(FontWeight.Bold)
          .fontColor($r('sys.color.font_primary'))
      }.height(36)
    }
    .alignItems(HorizontalAlign.Start)
    .padding({
      left: this.needPadding ? 16 : 0,
      right: this.needPadding ? 16 : 0,
      top: 10 + this.windowTopHeight,
      bottom: 8,
    })
    .width(Constants.FULL_SIZE)
  }
}