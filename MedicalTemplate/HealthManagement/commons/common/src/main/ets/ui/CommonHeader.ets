import { BarVM } from '../model/BarVM'
import { UnitConverter } from '../util/UnitConverter'

/**
 * @fileType: common
 * @zhName: 通用导航栏组件
 */
@ComponentV2
export struct CommonHeader {
  @Param @Require onReturnClick?: () => void
  @Param title: ResourceStr = ''
  @Param leftImageRes: Resource | undefined = undefined
  @Param rightImageRes: Resource | undefined = undefined
  @Param fontWightParam: FontWeight | number = 700
  @Param backgroundColorParam: ResourceColor | undefined = $r('sys.color.background_secondary')
  @Param rowFlexAlign: FlexAlign | undefined = FlexAlign.Start
  @Param rightOnClick: () => void = () => {
  }

  build() {
    Row() {
      Image(this.leftImageRes ?? $r('app.media.ic_backward2'))
        .width($r('app.float.vp_40'))
        .aspectRatio(1)
        .margin({ top: $r('app.float.vp_24') })
        .visibility(this.leftImageRes ? Visibility.Visible : Visibility.None)
        .onClick(() => {
          if (this.onReturnClick) {
            this.onReturnClick?.()
          }
        })

      Text(this.title)
        .size({ height: $r('app.float.vp_28') })
        .margin({ left: this.leftImageRes ? $r('app.float.vp_8') : 0, top: $r('app.float.vp_24') })
        .fontSize($r('sys.float.Title_S'))
        .fontWeight(this.fontWightParam)
        .fontColor($r('sys.color.font_primary'))

      Image(this.rightImageRes)
        .width($r('app.float.vp_24'))
        .aspectRatio(1)
        .margin({ top: $r('app.float.vp_24'), right: $r('app.float.vp_16') })
        .visibility(this.rightImageRes ? Visibility.Visible : Visibility.Hidden)
        .onClick(() => {
          if (this.rightOnClick) {
            this.rightOnClick?.()
          }
        })
    }
    .height(UnitConverter.px2vp(BarVM.instance.statusBarHeight.value) + 60)
    .width('100%')
    .margin({ top: $r('app.float.vp_8'), bottom: $r('app.float.vp_12') })
    .justifyContent(this.rowFlexAlign)
    .backgroundColor(this.backgroundColorParam)
  }
}