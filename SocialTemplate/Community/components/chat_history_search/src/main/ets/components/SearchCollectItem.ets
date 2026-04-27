import { ChatContentSingleModel, ChatTypeEnum, VideoImageView } from 'chat_base';
import { TimeView } from './TimeView';
import { CollectSearchModel } from '../viewmodel/CollectSearchModel';

@ComponentV2
export struct SearchCollectItem {
  @Param @Require collectMsg: ChatContentSingleModel;
  @Param @Require searchText: string;
  @Param onChatBubbleClick: (chatVM: ChatContentSingleModel) => void =
    (_chatVM: ChatContentSingleModel) => {
    };
  @Local collectSearchModel: CollectSearchModel = new CollectSearchModel()

  aboutToAppear(): void {
    this.collectSearchModel.message = this.collectMsg.textElem;
    this.collectSearchModel.messageShowing = this.collectSearchModel.message;
    this.collectSearchModel.searchTextLower = this.searchText.toLowerCase();
    this.collectSearchModel.calcLightIndex();
  }

  build() {
    Row() {
      Column() {
        if (this.collectMsg?.chatType === ChatTypeEnum.CHAT_TYPE_TEXT) {
          Stack({ alignContent: Alignment.BottomEnd }) {
            Text() {
              if (this.collectSearchModel.calcFinish) {
                ForEach(this.collectSearchModel.keyNum?.length > 0 ? this.collectSearchModel.keyNum :
                  [this.collectSearchModel.messageShowing.length],
                  (start: number, index: number) => {
                    Span(this.collectSearchModel.messageShowing.substring(index !== 0 ?
                      (this.collectSearchModel.keyNum[index - 1] + this.searchText.length) :
                      0, start));
                    Span(this.collectSearchModel.messageShowing.substring(start, (start + this.searchText.length)))
                      .fontColor($r('app.color.color_564af7'));
                    if (index === (this.collectSearchModel.keyNum.length - 1)) {
                      Span(this.collectSearchModel.messageShowing.substring((start + this.searchText.length),
                        this.collectSearchModel.messageShowing.length));
                    }
                  }, (item: number) => item.toString())
              }
            }
            .width('100%')
            .fontSize($r('sys.float.Body_M'))
            .fontColor(Color.Black)
            .lineHeight($r('app.float.vp_22'))
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .padding(0)
            .onSizeChange((oldValue: SizeOptions, newValue: SizeOptions) => {
              let newW = Number.parseInt(newValue.width + '');
              this.collectSearchModel.onExpandTextSizeChange(newW);
            })

            if (this.collectSearchModel.showExpandButton) {
              Text(this.collectSearchModel.isExpand ? $r('app.string.collapse') : $r('app.string.expand'))
                .fontColor($r('app.color.color_564AF7'))
                .fontSize($r('sys.float.Body_M'))
                .lineHeight($r('app.float.vp_22'))
                .onClick(() => {
                  if (this.collectSearchModel.isExpand) {
                    this.collectSearchModel.collapseText()
                  } else {
                    this.collectSearchModel.expandText()
                  }
                })
            }
          }
          .width('100%')
          .margin({
            top: $r('app.float.vp_14'),
            bottom: $r('app.float.vp_14')
          })
        } else if (this.collectMsg?.chatType === ChatTypeEnum.CHAT_TYPE_IMAGE) {
          Row() {
            Image(this.collectMsg.imageInfo![0].url)
              .objectFit(ImageFit.Cover)
              .width($r('app.float.vp_48'))
              .height($r('app.float.vp_48'))
              .borderRadius($r('app.float.vp_12'))
          }
          .alignItems(VerticalAlign.Center)
          .justifyContent(FlexAlign.Start)
          .width('100%')
        } else if (this.collectMsg?.chatType === ChatTypeEnum.CHAT_TYPE_SOUND) {
          Row() {
            Image($r('app.media.voice_message_icon'))
              .size({ width: $r('app.float.vp_24'), height: $r('app.float.vp_24') })

            Text(this.collectMsg.soundInfo?.duration.toString() + 's')
              .fontSize($r('app.float.vp_14'))
              .fontWeight(FontWeight.Regular)
              .fontColor(Color.Black)
              .lineHeight($r('app.float.vp_22'))
              .margin({ left: $r('app.float.vp_8') })
          }
          .size({ width: $r('app.float.vp_90'), height: $r('app.float.vp_38') })
          .alignItems(VerticalAlign.Center)
          .justifyContent(FlexAlign.Start)
          .width('100%')
        } else if (this.collectMsg?.chatType === ChatTypeEnum.CHAT_TYPE_VIDEO) {
          Column() {
            VideoImageView({ videpImage: this.collectMsg.snapshotPath, viewSize: $r('app.float.vp_48') })
          }.borderRadius($r('app.float.vp_12')).clip(true)
        }
      }.layoutWeight(1)

      TimeView({ timestamp: this.collectMsg.timestamp })
    }
    .constraintSize({ minHeight: $r('app.float.vp_72') })
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
    .width('100%')
    .onClick(() => {
      this.onChatBubbleClick?.(this.collectMsg);
    })
  }
}