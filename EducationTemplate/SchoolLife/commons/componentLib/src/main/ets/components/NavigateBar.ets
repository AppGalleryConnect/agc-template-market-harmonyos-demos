import { RouterModule, WindowConfig } from 'commonlib';
import { ComponentConst } from '../../../../Index';

@ComponentV2
export struct NavigateBar {
  @Param title: string | Resource = '';
  @Param enableBackward: boolean = false;
  @Local barHeight: number = 56;
  @Consumer('windowConfig') windowConfig: WindowConfig = new WindowConfig();

  build() {
    Column() {
      Row() {
        if (!this.enableBackward) {
          // 一级标题
          Text(this.title)
            .fontSize($r('sys.float.Title_M'))
            .fontColor($r('app.color.font_color_black_90'))
            .fontWeight(FontWeight.Bold)
            .margin({ left: $r('app.string.margin_xs') })
        } else {
          Image($r('app.media.ic_arrow_back'))
            .objectFit(ImageFit.Fill)
            .width(40)
            .height(40)
            .onClick(() => {
              RouterModule.pop();
            })

          // 二级标题
          Text(this.title)
            .fontSize($r('sys.float.Title_S'))
            .fontColor($r('app.color.font_color_black_90'))
            .fontWeight(FontWeight.Bold)
            .margin({ left: $r('app.string.margin_xs') })
        }
      }
      .margin({
        top: this.windowConfig.windowTopHeight,
      })
      .padding({
        left: $r('app.string.padding_xm'),
        right: $r('app.string.padding_xm'),
      })
      .width(ComponentConst.FULL_PARENT)
      .height(this.barHeight)
    }
    .height(this.barHeight + this.windowConfig.windowTopHeight)
    .width(ComponentConst.FULL_PARENT)
  }
}