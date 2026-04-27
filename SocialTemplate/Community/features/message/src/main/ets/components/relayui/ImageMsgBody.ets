import { ChatContentSingleModel } from 'chat_window';

@ComponentV2
export struct ImageMsgBody {
  @Param @Require chatVM: ChatContentSingleModel;
  build() {
    Row(){
      Image(this.chatVM.imageInfo?.[0].url)
        .width(72)
        .height(72)
        .borderRadius(12)
        .aspectRatio(1)
        .objectFit(ImageFit.Fill)
    }.width('100%').justifyContent(FlexAlign.Center)
  }
}