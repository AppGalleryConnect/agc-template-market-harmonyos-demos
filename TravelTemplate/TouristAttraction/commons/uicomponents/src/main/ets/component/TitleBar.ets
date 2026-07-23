import { AppStorageV2 } from '@kit.ArkUI';
import { BreakpointModel } from 'common';

@ComponentV2
export struct TitleBar {
  @Param @Require isShowBack: boolean;
  @Param @Require title: string;
  @Param @Require clickEvent: () => void;
  @Local windowTopHeight: number = AppStorage.get('windowTopHeight') as number || 38.77;
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;

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
      left: this.breakPointModel.pagePadding,
      right: this.breakPointModel.pagePadding,
    });
  }
}