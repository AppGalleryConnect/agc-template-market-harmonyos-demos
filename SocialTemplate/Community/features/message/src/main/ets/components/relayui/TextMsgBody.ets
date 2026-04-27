import { ChatContentSingleModel } from 'chat_window';

@ComponentV2
export struct TextMsgBody {
  @Param @Require chatVM: ChatContentSingleModel;

  build() {
    Text(this.chatVM.textElem)
      .maxLines(2)
      .textOverflow({ overflow: TextOverflow.Ellipsis })
      .width('100%')
      .backgroundColor('#FFFFFF')
      .borderRadius(16)
      .padding(10)
      .lineHeight(22)
      .textAlign(TextAlign.Start)
  }
}
