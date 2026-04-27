import { AppStorageV2 } from '@kit.ArkUI';
import { CommonConstants } from '../common/Constant';
import { BreakpointModel } from '../model/BreakpointModel';
import { WindowInfo } from '../model/WindowInfo';
import { RouterModule } from '../router/RouterModule';

@ComponentV2
export struct CommonTitle {
  /** 标题 */
  @Param title: ResourceStr = '';
  @Param fontSize: number = 20;
  /** 背景色 */
  @Param bgColor: ResourceColor = '#00000000';
  @Param titleHeight: Length = 56;
  /** 是否需要返回按钮 */
  @Param showBackBtn: boolean = true;
  @Event onBack: () => void = () => {
    RouterModule.pop();
  }
  /** 标题右侧内容 */
  @BuilderParam rightBuilder: () => void;

  @Local windowModel: WindowInfo = AppStorageV2.connect(WindowInfo, () => new WindowInfo())!;
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;

  build() {
    Row() {
      Row() {
        Row({ space: 8 }) {
          // 显示返回按钮
          if (this.showBackBtn) {
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
              this.onBack();
            })
          }
          if (this.title) {
            Text(this.title)
              .fontSize(this.fontSize)
              .fontColor($r('sys.color.font_primary'))
              .fontWeight(FontWeight.Bold)
          }
        }

        if (this.rightBuilder) {
          this.rightBuilder()
        }
      }
      .height(this.titleHeight)
      .justifyContent(FlexAlign.SpaceBetween)
      .width(CommonConstants.FULL_PERCENT)
    }
    .padding({
      left: this.breakPointModel.pagePadding,
      right: this.breakPointModel.pagePadding,
      top: this.windowModel.windowTopPadding,
      bottom: 0,
    })
    .width(CommonConstants.FULL_PERCENT)
    .backgroundColor(this.bgColor)
  }
}