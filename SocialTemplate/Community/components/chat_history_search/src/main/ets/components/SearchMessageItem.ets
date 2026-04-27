import { ChatContentSingleModel, ChatTypeEnum } from 'chat_base';
import { TimeView } from './TimeView';

@ComponentV2
export struct SearchMessageItem {
  @Param @Require messageItem: ChatContentSingleModel;
  @Param @Require searchText: string;
  @Local keyNum: number[] = [];
  @Local message: string = '';
  @Local messageLower: string = '';
  @Local searchTextLower: string = '';

  aboutToAppear(): void {
    this.message =
      this.messageItem.textElem.length > 0 ? this.messageItem.textElem :
      this.messageItem.locationName;
    this.messageLower = this.message.toLowerCase();
    this.searchTextLower = this.searchText.toLowerCase();
    let firstSearchTextIndex = this.messageLower.indexOf(this.searchTextLower);
    if (firstSearchTextIndex > 10) {
      this.message = '...' + this.message.slice(firstSearchTextIndex - 3, this.message.length);
      this.messageLower = this.message.toLowerCase();
    }
    let num = this.messageLower.split(this.searchTextLower).length - 1;
    let preLength = 0;
    for (let i = 0; i < num; i++) {
      let curIndex = this.messageLower.indexOf(this.searchTextLower, preLength);
      this.keyNum.push(curIndex);
      preLength = curIndex + this.searchTextLower.length;
    }
  }

  build() {
    Row() {
      Image(this.messageItem.avatarUrl.startsWith('http') ? this.messageItem.avatarUrl :
      $r('app.media.' + this.messageItem.avatarUrl))
        .width($r('app.float.vp_48'))
        .height($r('app.float.vp_48'))
        .borderRadius($r('app.float.vp_12'))
        .objectFit(ImageFit.Cover)
      Column() {
        Text(this.messageItem.nickName)
          .fontSize($r('sys.float.Body_M'))
          .fontWeight(FontWeight.Medium)
          .lineHeight($r('app.float.vp_22'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text() {
          if (this.messageItem.chatType === ChatTypeEnum.CHAT_TYPE_TEXT ||
            this.messageItem.chatType === ChatTypeEnum.CHAT_TYPE_LOCATION) {
            if(this.keyNum?.length > 0) {
              ForEach(this.keyNum, (start: number, index: number) => {
                Span(this.message.substring(index !== 0 ? (this.keyNum[index - 1] + this.searchText.length) : 0,
                  start));
                Span(this.message.substring(start, (start + this.searchText.length)))
                  .fontColor($r('app.color.color_564af7'));
                if (index === (this.keyNum.length - 1)) {
                  Span(this.message.substring((start + this.searchText.length),
                    this.message.length));
                }
              }, (item: number) => item.toString())
            } else {
              Span(this.message);
            }
          } else if (this.messageItem.chatType === ChatTypeEnum.CHAT_TYPE_IMAGE) {
            Span('[图片]');
          } else if (this.messageItem.chatType === ChatTypeEnum.CHAT_TYPE_VIDEO) {
            Span('[视频]');
          } else if (this.messageItem.chatType === ChatTypeEnum.CHAT_TYPE_SOUND) {
            Span('[语音]');
          }
        }
        .fontSize($r('sys.float.Body_S'))
        .fontColor($r('sys.color.font_tertiary'))
        .lineHeight($r('app.float.vp_18'))
        .margin({
          top: $r('app.float.vp_2'),
          bottom: $r('app.float.vp_2'),
        })
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      }
      .layoutWeight(1)
      .margin({ left: $r('app.float.vp_12') })
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Start)

      TimeView({ timestamp: this.messageItem.timestamp })
    }
    .justifyContent(FlexAlign.Start)
    .alignItems(VerticalAlign.Center)
    .width('100%')
    .height($r('app.float.vp_72'))
  }
}