import { ChatContentSingleModel } from 'chat_window';

@ComponentV2
export struct VideoMsgBody {
  @Param @Require chatVM: ChatContentSingleModel;
  build() {
    Stack({ alignContent: Alignment.Center }) {
      Column() {
        Image(this.chatVM.snapshotPath)
          .width('100%')
          .height('100%')
          .objectFit(ImageFit.Cover)
          .draggable(false)
      }
      .width(96)
      .height(72)
      .borderRadius(12)
      .clip(true)

      Column() {
        Image($r('app.media.video_stop'))
          .width(24).height(24)
          .objectFit(ImageFit.Cover)
          .draggable(false)
      }
    }
    .width('100%')
  }
}