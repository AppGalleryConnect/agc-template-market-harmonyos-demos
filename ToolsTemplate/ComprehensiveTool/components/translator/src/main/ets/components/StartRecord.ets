import { VideoTranPageVM } from '../viewmodel/VideoTranPageVM'
import { ToastMessage } from './ToastMessage'

@ComponentV2
export struct StartRecord {
  vm: VideoTranPageVM = VideoTranPageVM.instance

  build() {
    Column() {
      ToastMessage()
      Row() {
        Button('开始录音')
          .width(160)
          .onClick(() => {
            this.vm.start()
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
    }
    .layoutWeight(1)
    .justifyContent(FlexAlign.SpaceBetween)
  }
}