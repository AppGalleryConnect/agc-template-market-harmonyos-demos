import { AppStorageV2 } from '@kit.ArkUI';
import { CommonConstants } from '../constants/CommonConstants';
import { CustomConfigModel } from '../models/CustomConfigModel';

/**
 * 通用页面标题栏
 */
@ComponentV2
export struct NavHeaderBar {
  @Param title: ResourceStr = '';
  @Param showBackBtn: boolean = false;
  @Param bgColor: ResourceColor = '#00000000';
  @Param isSubTitle: boolean = true;
  @Param headerBarHeight: Length = $r('app.float.nav_header_height');
  @Param customPadding: Padding = {};
  // 自定义返回事件
  @Event onBack: () => void = () => {
    this.configInfo.pathStack.pop();
  };
  @Local configInfo: CustomConfigModel = AppStorageV2.connect(CustomConfigModel, () => new CustomConfigModel())!

  build() {
    Row() {
      Row() {
        // 显示返回按钮：主动设置或者二级标题
        if (this.showBackBtn || this.isSubTitle) {
          Button() {
            SymbolGlyph($r('sys.symbol.chevron_backward'))
              .fontColor([$r('sys.color.font_primary')])
              .fontWeight(FontWeight.Normal)
              .fontSize($r('app.float.normal_img_size'))
          }
          .width(40)
          .height(40)
          .type(ButtonType.Circle)
          .backgroundColor($r('sys.color.comp_background_tertiary'))
          .accessibilityText('返回')
          .onClick(() => {
            this.onBack();
          })
        }
        if (this.title) {
          Text(this.title)
            .fontSize(this.isSubTitle ? '20vp' : '24vp')
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Bold)
            .margin({ left: CommonConstants.SPACE_S })
            .id('nav_title')
        }
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(this.headerBarHeight)
    }
    .width(CommonConstants.FULL_PERCENT)
    .backgroundColor(this.bgColor)
    .padding({
      left: this.customPadding.left ?? 0,
      right: this.customPadding.right ?? 0,
      top: this.customPadding.top ?? (this.configInfo.isSheet ? CommonConstants.PADDING_S : 0),
      bottom: this.customPadding.bottom ?? 0,
    })
  }
}