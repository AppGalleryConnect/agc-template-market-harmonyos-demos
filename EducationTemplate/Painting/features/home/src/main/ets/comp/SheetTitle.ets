import { Constants, WindowPopManager } from 'common'
import { CommonConstants } from '../constants/Constant'

@ComponentV2
export struct SheetTitle {
  @Param @Require title: string = ''

  build() {
    Row() {
      Row() {
        Text(this.title)
          .fontColor($r('app.color.mask_black'))
          .fontWeight(FontWeight.Bold)
          .fontSize(23)
          .width(256)
          .textAlign(TextAlign.Start)
        Image($r('app.media.sheet_close'))
          .width(40)
          .height(40)
          .onClick(() => {
            WindowPopManager.destroyWindow(CommonConstants.WINDOW_NAME)
          })
      }
      .width(Constants.FULL_SIZE)
      .height(Constants.FULL_SIZE)
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)
    }
    .padding({
      top: 8,
      right: 16,
      left: 16,
    })
    .width(Constants.FULL_SIZE)
    .height(56)
    .borderRadius({ topLeft: $r('sys.float.corner_radius_level16'), topRight: $r('sys.float.corner_radius_level16') })
    .backgroundColor(Color.White)
  }
}