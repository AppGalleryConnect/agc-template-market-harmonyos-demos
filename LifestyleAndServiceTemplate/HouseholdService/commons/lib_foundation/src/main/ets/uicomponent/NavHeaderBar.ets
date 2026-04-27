import { CommonConstants } from '../common/Constant';
import { RouterModule } from '../router/RouterModule';

/**
 * 通用页面标题栏
 */
@ComponentV2
export struct NavHeaderBar {
  @Param title: ResourceStr = '';
  @Param showBackBtn: boolean = false;
  @Param isSubTitle: boolean = true;
  @BuilderParam rightPartBuilder: () => void;
  // 自定义返回事件
  @Event onBack: () => void = () => {
    RouterModule.pop()
  };

  build() {
    Row() {
      Row() {
        // 显示返回按钮：主动设置或者二级标题
        if (this.showBackBtn || this.isSubTitle) {
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
          .accessibilityText('返回')
          .onClick(() => {
            this.onBack();
          })
        }

        if (this.title) {
          Text(this.title)
            .fontSize(this.isSubTitle ? $r('sys.float.Title_S') : $r('sys.float.Title_M'))
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Bold)
            .margin({ left: 8 })
            .id('nav_title')
        }
      }

      if (this.rightPartBuilder) {
        this.rightPartBuilder()
      }
    }
    .margin({ bottom: -4 })
    .height(56)
    .width(CommonConstants.FULL_PERCENT)
  }
}