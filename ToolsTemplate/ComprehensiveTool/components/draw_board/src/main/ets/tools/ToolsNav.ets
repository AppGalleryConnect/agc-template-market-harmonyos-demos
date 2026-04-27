import { baseActionSheet } from '../components/ActionSheet';
import { CommonConstants } from '../constants/CommonConstants';

@ComponentV2
export struct ToolsNav {
  @Param title: ResourceStr = '';
  @Event closePicker?: () => void;

  build() {
    Row() {
      Text(this.title)
        .fontSize(20)
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Bold);
      Image($r('app.media.close_circle'))
        .width(30)
        .height(30)
        .onClick(() => {
          baseActionSheet.close('canvasTools');
          this.closePicker!();
        });
    }
    .width(CommonConstants.ONE_HUNDRED_PERCENT)
    .justifyContent(FlexAlign.SpaceBetween)
    .margin({ bottom: 32 });
  }
}