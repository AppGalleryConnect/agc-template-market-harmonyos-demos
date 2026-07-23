import { AppStorageV2 } from '@kit.ArkUI';
import { BreakpointModel, CircleButtonModifier, CommonConstants, RouterUtils, WindowModel } from 'lib_common';

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
  @BuilderParam rightPartBuilder: () => void;
  // 自定义返回事件
  @Event onBack: () => void = () => {
    RouterUtils.pop()
  };
  @Local windowModel: WindowModel = AppStorageV2.connect(WindowModel, () => new WindowModel())!;
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Consumer() isCommentInModalDialog: boolean = false
  buttonModifier: CircleButtonModifier = new CircleButtonModifier();

  build() {
    Row() {
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
            .attributeModifier(this.buttonModifier)
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
              .margin({ left: CommonConstants.SPACE_S })
              .id('nav_title')
          }
        }

        if (this.rightPartBuilder) {
          this.rightPartBuilder()
        }
      }
      .height(this.headerBarHeight)
      .justifyContent(FlexAlign.SpaceBetween)
      .width(CommonConstants.FULL_PERCENT)
    }
    .padding({
      left: this.customPadding.left ?? this.breakPointModel.pagePadding,
      right: this.customPadding.right ?? this.breakPointModel.pagePadding,
      top: this.customPadding.top ?? (this.isCommentInModalDialog ? CommonConstants.PADDING_S :
      this.windowModel.windowTopPadding),
      bottom: this.customPadding.bottom ?? 0,
    })
    .width(CommonConstants.FULL_PERCENT)
    .backgroundColor(this.bgColor)
  }
}