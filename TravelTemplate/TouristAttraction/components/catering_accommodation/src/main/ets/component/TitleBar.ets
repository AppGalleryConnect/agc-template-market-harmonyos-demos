import { BreakPointUtils } from '../utils/BreakPointUtils';

@ComponentV2
export struct CustomTitle {
  @Param @Require isShowBack: boolean;
  @Param @Require title: string;
  @Param @Require breakpoint: string = '';
  @Param @Require clickEvent: () => void;
  @Local windowTopHeight: number = AppStorage.get('windowTopHeight') as number || 38.77;

  build() {
    Row({ space: 8 }) {
      if (this.isShowBack) {
        SymbolGlyph($r('sys.symbol.chevron_backward'))
          .width(40)
          .height(40)
          .fontSize(24)
          .fontColor([$r('sys.color.icon_primary')])
          .backgroundColor($r('sys.color.comp_background_tertiary'))
          .borderRadius(1000)
          .padding(8)
          .onClick(this.clickEvent);
      }
      Text(this.title)
        .fontSize($r('sys.float.Title_S'))
        .fontWeight(FontWeight.Bold)
        .fontColor($r('sys.color.font_primary'))
        .textAlign(TextAlign.Start);
    }.margin({ top: this.windowTopHeight }).width('100%').height(56).padding({
      top: 8,
      bottom: 8,
      left: BreakPointUtils.getBreakPointGutter(this.breakpoint),
      right: BreakPointUtils.getBreakPointGutter(this.breakpoint),
    });
  }
}