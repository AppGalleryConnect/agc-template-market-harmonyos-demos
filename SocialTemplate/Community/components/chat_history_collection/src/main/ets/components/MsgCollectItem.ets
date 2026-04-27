import measure from '@ohos.measure'
import { ChatContentSingleModel, ChatTypeEnum, TimeUtil, VideoImageView } from 'chat_base';

const TEXT_CONTENT_DEFAULT_LINES = 2;
const TEXT_CONTENT_DEFAULT_MAX_LINES = 100;

@ComponentV2
export struct MsgCollectItem {
  @Param @Require collectMsg: ChatContentSingleModel;
  @Param onChatBubbleClick: (chatVM: ChatContentSingleModel) => void =
    (_chatVM: ChatContentSingleModel) => {
    };
  @Local contentMaxLines: number = TEXT_CONTENT_DEFAULT_LINES
  @Local showExpandButton: boolean = false;
  @Local showAllContent: boolean = false;
  @Local contentLines: number = 0;

  @Styles
  contentText() {
    .backgroundColor($r('sys.color.comp_background_primary'))
  }

  @Builder
  collectTextElem() {
    Text(this.collectMsg.textElem)
      .fontSize($r('sys.float.Body_M'))
      .fontColor(Color.Black)
      .fontWeight(FontWeight.Medium)
      .lineHeight($r('app.float.vp_22'))
      .maxLines(this.contentMaxLines)
      .textOverflow({ overflow: TextOverflow.Ellipsis })
      .animation({ duration: 300 })
      .onSizeChange((_oldValue: SizeOptions, newValue: SizeOptions) => {
        let newHeight = measure.measureTextSize({
          textContent: this.collectMsg.textElem,
          constraintWidth: newValue.width,
          fontSize: $r('sys.float.Body_M'),
          fontWeight: FontWeight.Medium,
          lineHeight: $r('app.float.vp_22'),
        }).height;
        if (newHeight && (Number.parseInt(newHeight + '') / vp2px(22)) !== this.contentLines) {
          this.contentLines = (Number.parseInt(newHeight + '') / vp2px(22));
          this.contentLines = Number.parseInt(this.contentLines + '');
          if (this.contentLines > TEXT_CONTENT_DEFAULT_LINES) {
            this.showExpandButton = true;
          } else {
            this.showExpandButton = false;
          }
        }
      })
  }

  @Builder
  collectImageElem() {
    Image(this.collectMsg.imageInfo ? this.collectMsg.imageInfo[0].url : '')
      .objectFit(ImageFit.Contain)
      .width($r('app.float.vp_102'))
      .borderRadius($r('app.float.vp_12'))
      .aspectRatio(this.collectMsg.imageInfo?.[0].width ?
        this.collectMsg.imageInfo![0].width / this.collectMsg.imageInfo![0].height : undefined)
  }

  @Builder
  collectVoiceElem() {
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
  }

  @Builder
  collectVideoElem() {
    Column() {
      VideoImageView({ videpImage: this.collectMsg.snapshotPath, viewSize: $r('app.float.vp_102') })
    }.borderRadius($r('app.float.vp_12')).clip(true)
  }

  @Builder
  collectOpenElem() {
    Row() {
      Text(TimeUtil.formatDate(this.collectMsg.timestamp * 1000, TimeUtil.PATTERN_DATE_CN))
        .fontColor($r('sys.color.icon_tertiary'))
        .fontWeight(FontWeight.Regular)
        .lineHeight($r('app.float.vp_18'))
        .fontSize($r('sys.float.Body_S'))
        .margin({ top: $r('app.float.vp_4') })

      if (this.collectMsg?.chatType === ChatTypeEnum.CHAT_TYPE_TEXT) {
        Text(this.contentMaxLines === TEXT_CONTENT_DEFAULT_MAX_LINES ? $r('app.string.collapse') :
        $r('app.string.expand'))
          .fontColor($r('app.color.color_564AF7'))
          .fontWeight(FontWeight.Regular)
          .lineHeight($r('app.float.vp_18'))
          .fontSize($r('sys.float.Body_S'))
          .visibility(this.showExpandButton ? Visibility.Visible : Visibility.Hidden)
          .onClick(() => {
            this.contentMaxLines =
              this.contentMaxLines === TEXT_CONTENT_DEFAULT_MAX_LINES ? TEXT_CONTENT_DEFAULT_LINES :
                TEXT_CONTENT_DEFAULT_MAX_LINES;
          })
      }
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
  }

  build() {
    Row() {
      Column() {
        if (this.collectMsg?.chatType === ChatTypeEnum.CHAT_TYPE_TEXT) {
          this.collectTextElem();
        } else if (this.collectMsg?.chatType === ChatTypeEnum.CHAT_TYPE_IMAGE) {
          this.collectImageElem();
        } else if (this.collectMsg?.chatType === ChatTypeEnum.CHAT_TYPE_SOUND) {
          this.collectVoiceElem();
        } else if (this.collectMsg?.chatType === ChatTypeEnum.CHAT_TYPE_VIDEO) {
          this.collectVideoElem();
        }

        this.collectOpenElem();
      }
      .alignItems(HorizontalAlign.Start)
    }
    .justifyContent(FlexAlign.Start)
    .alignItems(VerticalAlign.Center)
    .backgroundColor(Color.White)
    .width('100%')
    .borderRadius($r('app.float.vp_12'))
    .margin({
      bottom: $r('app.float.vp_8')
    })
    .padding({
      left: $r('app.float.vp_16'),
      right: $r('app.float.vp_16'),
      top: $r('app.float.vp_13'),
      bottom: $r('app.float.vp_14'),
    })
    .onClick(() => {
      this.onChatBubbleClick?.(this.collectMsg);
    })
  }
}