import { VideoTranPageVM } from '../viewmodel/VideoTranPageVM'
import { ToastMessage } from './ToastMessage'

@ComponentV2
export struct ProgressRecord {
  vm: VideoTranPageVM = VideoTranPageVM.instance

  build() {
    Column() {
      ToastMessage()

      Column() {
        Row() {
          Row()
            .width(6)
            .height(6)
            .borderRadius(4)
            .backgroundColor($r('sys.color.brand'))
            .margin({ right: 4 })
          Text(this.vm.recordTimeText)
            .fontSize($r('sys.float.Body_M'))
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Regular)
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .margin({ bottom: 24 })

        Row() {
          Button('结束录音')
            .width(160)
            .onClick(() => {
              this.vm.stop()
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
      }
      .margin({ bottom: 24 })
    }
    .layoutWeight(1)
    .justifyContent(FlexAlign.SpaceBetween)
  }
}