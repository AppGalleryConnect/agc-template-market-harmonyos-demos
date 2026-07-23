import { AppStorageV2 } from '@kit.ArkUI';
import { CommonConstants } from '../constants/Constants';
import { BreakpointModel } from '../models/BreakpointModel';
import { WindowSize } from '../models/WindowSize';
import { RouterModule } from '../utils/RouterModule';

/**
 * 通用页面标题栏
 */
@ComponentV2
export struct BaseTitle {
  @Param title: ResourceStr = '';
  @Param titleFontSize: Length = $r('sys.float.Title_M');
  @Param showBackBtn: boolean = false;
  @Param fontColor: ResourceColor = $r('sys.color.font_primary');
  @Param btnBgColor: ResourceColor = $r('sys.color.comp_background_tertiary')
  @Param bgColor: ResourceColor = '#00000000';
  @Param headerBarHeight: Length = 56;
  @Param customPadding: Padding = {};
  @BuilderParam rightPartBuilder: () => void;
  // 自定义返回事件
  @Event onBack: () => void = () => {
    RouterModule.pop()
  };
  @Local windowSize: WindowSize = AppStorageV2.connect(WindowSize, () => new WindowSize())!;
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;

  build() {
    Row() {
      Row({ space: 16 }) {
        // 显示返回按钮
        if (this.showBackBtn) {
          Button() {
            SymbolGlyph($r('sys.symbol.chevron_backward'))
              .fontColor([this.fontColor])
              .fontWeight(FontWeight.Normal)
              .fontSize(24)
          }
          .width(40)
          .height(40)
          .backgroundColor(this.btnBgColor)
          .onClick(() => {
            this.onBack();
          })
        }
        if (this.title) {
          Text(this.title)
            .fontSize(this.titleFontSize)
            .fontColor(this.fontColor)
            .fontWeight(FontWeight.Bold)
        }
      }

      if (this.rightPartBuilder) {
        this.rightPartBuilder()
      }
    }
    .height(this.headerBarHeight)
    .justifyContent(FlexAlign.SpaceBetween)
    .width(CommonConstants.FULL_PERCENT)
    .backgroundColor(this.bgColor)
  }
}