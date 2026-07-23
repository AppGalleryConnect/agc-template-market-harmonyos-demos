import { common } from '@kit.AbilityKit';
import { MeasureUtils } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { Constants } from '../common/Constant';
import { GridRowColSetting } from '../common/GridRowColSetting';
import { AvatarInfo, AvatarParam } from '../models/DataModels';
import { MessageModel, MessageType, SenderType } from '../models/MessageModel';
import { ChatUtil } from '../utils/ChatUtil';
import DateUtil from '../utils/DateUtil';
import { ChatVM } from '../viewmodels/ChatVM';

@ComponentV2
export struct BaseChatItem {
  @Param @Require message: MessageModel
  @Param avatarInfo: AvatarInfo = new AvatarInfo()
  @Param avatarParam: AvatarParam = {}
  @Local sendTime: string = ''
  @Local strArr: string[] = []
  @Local urlArr: string[] = []
  @Local containerWidth: number = 0
  @Local messageString: string = ''
  @Event onChatAvatarClick: (senderType: SenderType) => void = () => {
  }
  private uiContext: UIContext = this.getUIContext();
  private context: common.UIAbilityContext = this.uiContext.getHostContext() as common.UIAbilityContext
  private uiContextMeasure: MeasureUtils = this.uiContext.getMeasureUtils()
  vm: ChatVM = ChatVM.getInstance()

  @Computed
  get contentWidth() {
    return 2 * (this.avatarParam.avatarMargin ?? Constants.ZERO) +
      (this.avatarParam.avatarSize ?? Constants.AVATAR_SIZE);
  }

  @Computed
  get maxMessageWidth() {
    return this.containerWidth - GridRowColSetting.getGutter(this.vm.breakpoint) - this.contentWidth;
  }

  @Computed
  get gridSize() {
    return (this.containerWidth -
      GridRowColSetting.getGutter(this.vm.breakpoint) * (GridRowColSetting.getWindowColumn(this.vm.breakpoint) - 1)) /
    GridRowColSetting.getWindowColumn(this.vm.breakpoint);
  }

  @Computed
  get imageSize():  ConstraintSizeOptions {
    if (this.message.imageAspectRatio && this.message.imageAspectRatio <= 3 && this.message.imageAspectRatio >= 1) {
      return { maxWidth: Constants.IMAGE_ROW_WIDTH }
    } else if (this.message.imageAspectRatio && this.message.imageAspectRatio < 1) {
      return {
        maxWidth: Constants.IMAGE_COL_WIDTH,
        maxHeight: this.message.imageAspectRatio && this.message.imageAspectRatio > 1 / 3 ? undefined :
          Constants.IMAGE_COL_HEIGHT
      }
    } else {
      return { maxWidth: this.gridSize * (this.vm.breakpoint === 'sm' ? 2 : 4) }
    }
  }

  @Computed
  get messageWidth() {
    let wordWidth = 0
    let textSize: SizeOptions = this.uiContextMeasure.measureTextSize({
      textContent: this.messageString,
      fontSize: 14
    })
    if (textSize) {
      wordWidth = this.uiContext.px2vp(textSize.width as number) + 2 * Constants.PADDING_M;
    }
    return wordWidth
  }

  @Computed
  get sender() {
    return this.message.sender === SenderType.CUSTOMER_SERVICE;
  }

  @Monitor('vm.isRefreshing')
  onTimeChange() {
    this.sendTime = DateUtil.formatTimeForChat(this.message.timestamp);
  }

  @Monitor('message.id')
  onMessageChange() {
    let content: string = '';
    if (typeof this.message.content === 'string') {
      content = this.message.content;
    } else {
      try {
        content = this.context.resourceManager.getStringSync(this.message.content.id);
      } catch (error) {
        hilog.error(0x00ff, '[BaseChatItem]', 'fail to get string sync')
      }
    }
    this.messageString = content;
    ChatUtil.splitUrls(content, (array: string[][]) => {
      this.strArr = array[0];
      this.urlArr = array[1];
    });
  }

  aboutToAppear(): void {
    this.onTimeChange();
    this.onMessageChange();
  }

  build() {
    Column({ space: Constants.SPACE_M }) {
      if (this.message.isShowTime) {
        Text(this.sendTime)
          .textAlign(TextAlign.Center)
          .textOtherStyles($r('sys.color.font_secondary'))
      }
      Row({ space: GridRowColSetting.getGutter(this.vm.breakpoint) }) {
        if (this.sender) {
          this.avatarBuilder(this.avatarInfo.avatar)
          this.customerServiceMessage()
        } else {
          this.customerServiceMessage()
          this.avatarBuilder(this.avatarInfo.avatar)
        }
      }
      .alignItems(VerticalAlign.Top)
      .justifyContent(this.sender ? FlexAlign.Start : FlexAlign.End)
    }
    .width(Constants.FULL_PERCENT)
  }

  @Builder
  customerServiceMessage() {
    Column({ space: Constants.SPACE_XS }) {
      Text(this.avatarInfo.name)
        .textOtherStyles($r('sys.color.font_tertiary'))
      if ([MessageType.TEXT, MessageType.URL].includes(this.message.type)) {
        this.textBuilder()
      }
      if (this.message.type === MessageType.IMAGE) {
        this.imageBuilder()
      }
      if (this.message.type === MessageType.LOCATION) {
        this.locationBuilder()
      }
    }
    .onSizeChange((_, newSize) => {
      this.containerWidth = newSize.width as number
    })
    .layoutWeight(1)
    .alignItems(this.sender ? HorizontalAlign.Start : HorizontalAlign.End)
  }

  @Builder
  textBuilder() {
    Row() {
      Text() {
        ForEach(this.strArr, (str: string, index: number) => {
          Span(str);
          if (this.urlArr.length > index) {
            Span(this.urlArr[index])
              .fontColor($r('sys.color.font_emphasize'))
              .decoration({ type: TextDecorationType.Underline, color: $r('sys.color.font_emphasize') })
              .onClick(() => {
                this.vm.onUrlClick(this.context, this.urlArr[index]);
              })
          }
        }, (str: string, index: number) => str + index);
      }
      .copyOption(CopyOptions.LocalDevice)
      .textBodyStyles()
      .wordBreak(WordBreak.BREAK_ALL)
    }
    .width((this.messageWidth >= this.maxMessageWidth) ? this.maxMessageWidth : undefined)
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .padding(Constants.PADDING_M)
    .borderRadius({
      topLeft: this.sender ? Constants.RADIUS_SMALL : Constants.RADIUS_BIG,
      topRight: this.sender ? Constants.RADIUS_BIG : Constants.RADIUS_SMALL,
      bottomLeft: Constants.RADIUS_BIG,
      bottomRight: Constants.RADIUS_BIG,
    })
  }

  @Builder
  imageBuilder() {
      Image(this.message.content)
        .objectFit(ImageFit.Cover)
        .constraintSize(this.imageSize)
        .borderRadius(Constants.RADIUS_BIG)
        .aspectRatio(this.message.imageAspectRatio && this.message.imageAspectRatio > 3 ? 2 : undefined)
        .onClick(() => {
          this.vm.onImageClick(this.uiContext, this.message.content)
        })
  }

  @Builder
  locationBuilder() {
    Column() {
      Row() {
        Image(this.message.locationInfo!.locationSnapShot)
          .objectFit(ImageFit.Cover)
          .borderRadius({
            topLeft: this.sender ? Constants.RADIUS_SMALL : Constants.RADIUS_BIG,
            topRight: this.sender ? Constants.RADIUS_BIG : Constants.RADIUS_SMALL,
          })
      }
      .height(Constants.SNAPSHOT_HEIGHT)

      Row() {
        Column({ space: Constants.SPACE_TEN }) {
          Text(this.message.locationInfo!.address)
            .textBodyStyles()
            .width(Constants.FULL_PERCENT)

          Row({ space: Constants.SPACE_XS }) {
            SymbolGlyph($r('sys.symbol.position'))
              .fontColor([$r('sys.color.icon_secondary')])
              .fontSize(Constants.POSITION_SIZE)
            Text('定位')
              .textOtherStyles($r('sys.color.font_secondary'))
          }
          .justifyContent(FlexAlign.Start)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
      }
      .backgroundColor($r('sys.color.comp_background_list_card'))
      .borderRadius({ bottomLeft: Constants.RADIUS_BIG, bottomRight: Constants.RADIUS_BIG })
      .padding({
        top: Constants.PADDING_S,
        bottom: Constants.PADDING_S,
        left: Constants.PADDING_M,
        right: Constants.PADDING_M,
      })
    }
    .constraintSize({
      maxWidth: this.vm.breakpoint === 'sm' ?
        this.containerWidth - GridRowColSetting.getGutter(this.vm.breakpoint) - this.contentWidth :
        this.vm.locationWidth
    })
    .onClick(() => {
      this.vm.onLocationClick(this.message.locationInfo!, this.context)
    })
  }

  @Builder
  avatarBuilder(avatar: ResourceStr) {
    Image(avatar)
      .width(this.avatarParam.avatarSize ?? Constants.AVATAR_SIZE)
      .height(this.avatarParam.avatarSize ?? Constants.AVATAR_SIZE)
      .borderRadius(this.avatarParam.avatarRadius ?? $r('sys.float.corner_radius_level10'))
      .margin({
        right: this.avatarParam.avatarMargin ?? Constants.ZERO,
        left: this.avatarParam.avatarMargin ?? Constants.ZERO
      })
      .objectFit(ImageFit.Fill)
      .onClick(() => {
        this.onChatAvatarClick(this.message.sender)
      })
  }
}

@Extend(Text)
function textBodyStyles() {
  .textAlign(TextAlign.Start)
  .fontSize($r('sys.float.Body_M'))
  .fontWeight(FontWeight.Medium)
  .lineHeight(Constants.FONT_HEIGHT_19)
}

@Extend(Text)
function textOtherStyles(fontColor: Resource) {
  .fontColor(fontColor)
  .fontSize($r('sys.float.Caption_L'))
  .fontWeight(FontWeight.Regular)
  .lineHeight(Constants.FONT_HEIGHT_16)
}