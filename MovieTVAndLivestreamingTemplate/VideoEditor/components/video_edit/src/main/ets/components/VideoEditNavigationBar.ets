import { BarVM } from 'video_common'

@ComponentV2
export struct VideoEditNavigationBar {
  @Event onClickEvent?: () => void

  build() {
    Column() {
      Blank().height(BarVM.instance.staBarH)
      Row() {
        Image($r('app.media.page_back'))
          .width(24)
          .height(24)
      }
      .padding({ left: 16 })
      .height(44)
      .width('100%')
      .onClick(() => this.onClickEvent?.())
    }
  }
}