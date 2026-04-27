import { AppStorageV2 } from '@kit.ArkUI'
import { BreakpointModel } from '../model/BreakpointModel'

/**
 * @fileType: common
 * @zhName: 通用导航栏组件
 */
@ComponentV2
export struct CommonHeader {
  @Param @Require onReturnClick?: () => void
  @Param title: string = ''
  @Param isDeepColor: boolean = false
  @Param hasBackButton: boolean = true
  @Param rightImageRes: Resource | undefined = undefined
  @Param fontWightParam: FontWeight | number = 700
  @BuilderParam rightBuilder?: () => void;
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Event rightOnClick: () => void = () => {
  }

  build() {
    Row() {
      Row() {
        if (this.hasBackButton) {
          Image(this.isDeepColor ? $r('app.media.black_back_icon') : $r('app.media.ic_backward2'))
            .width(40)
            .aspectRatio(1)
            .margin({ right: this.breakPointModel.pagePadding / 2 })
            .onClick(() => {
              if (this.onReturnClick) {
                this.onReturnClick?.()
              }
            })
        }
        Text(this.title).size({ height: 27 })
          .fontSize(26)
          .fontColor(this.isDeepColor ? '#fff' : 'rgba(0, 0, 0, 0.90)')
          .fontFamily('HarmonyOS Sans SC Medium')
      }

      if (this.rightImageRes) {
        Image(this.rightImageRes).size({ width: 40, height: 40 })
          .margin({ left: '8vp' })
          .onClick(this.rightOnClick)
      } else if (this.rightBuilder) {
        this.rightBuilder()
      } else {
        Row().size({ width: 40, height: 40 })
          .margin({ left: '8vp' })
      }
    }
    .height(40)
    .width('100%')
    .margin({ top: 8, bottom: 24 })
    .justifyContent(FlexAlign.SpaceBetween)
  }
}