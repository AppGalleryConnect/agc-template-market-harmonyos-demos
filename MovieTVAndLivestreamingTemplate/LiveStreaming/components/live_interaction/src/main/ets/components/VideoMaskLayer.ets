import { ChangeScreen } from '../view/ChangeScreen'

@ComponentV2
export struct VideoMaskLayer {
  @Local visible: boolean = true
  @Event onFullScreen: Function = () => {
  }

  build() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      if (this.visible) {
        ChangeScreen({
          onChangeScreen: () => {
            this.onFullScreen()
          }
        }).margin({ right: 16, bottom: 12 })

      }
    }.onClick(() => {
      this.visible = !this.visible
    })
    .height('100%')
    .width('100%')
  }
}