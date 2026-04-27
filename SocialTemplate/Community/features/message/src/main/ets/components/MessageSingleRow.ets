import { AppStorageV2 } from '@kit.ArkUI';
import { BreakpointModel } from 'common';
import { CMChatConversation, CMChatConversationType, CMChatElemType } from 'instant_messaging';
import { TimeUtil } from 'chat_window';
import { messageAccessSync } from './relayui/AvatarWrapperBuilder';

@ComponentV2
export struct MessageSingleRow {
  @Param @Require messageVM: CMChatConversation;
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Event onChatClick: (messageVM: CMChatConversation) => void = (_messageVM: CMChatConversation) => {
  }

  build() {
    Row() {
      this.setAvatarImage();
      Blank().width($r('app.float.vp_12'));
      Column() {
        Row() {
          Text(this.messageVM.showName)
            .fontSize($r('sys.float.Body_M'))
            .fontColor(Color.Black)
            .fontWeight(FontWeight.Medium)
            .lineHeight($r('app.float.vp_18'))
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .layoutWeight(1)
            .textAlign(TextAlign.Start)

          Text(TimeUtil.chatCommentData(this.messageVM.lastMessage.timestamp))
            .fontSize($r('sys.float.Body_S'))
            .fontColor($r('app.color.color_66000000'))
            .fontWeight(FontWeight.Regular)
            .lineHeight($r('app.float.vp_18'))
        }

        Blank().height($r('app.float.vp_2'));
        Text(this.lastMsgContent)
          .fontSize($r('sys.float.Body_S'))
          .fontColor($r('app.color.color_66000000'))
          .fontWeight(FontWeight.Regular)
          .lineHeight($r('app.float.vp_18'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .layoutWeight(1)
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Start)
    }
    .justifyContent(FlexAlign.Start)
    .alignItems(VerticalAlign.Center)
    .backgroundColor(this.messageVM.isPinned ? $r('app.color.color_F1F3F5') : Color.Transparent)
    .width('100%')
    .height($r('app.float.vp_72'))
    .padding({
      top: $r('app.float.vp_12'),
      left: this.breakPointModel.pagePadding,
      bottom: $r('app.float.vp_12'),
      right: this.breakPointModel.pagePadding
    })
    .onClick(() => this.onChatClick(this.messageVM))
  }

  @Builder
  setAvatarImage() {
    Stack({ alignContent: Alignment.TopEnd }) {
      Column() {
        Column({ space: this.messageVM.memberInfoList.length > 4 ? 2 : 4 }) {
          if (this.messageVM.type === 1) {
            Image($r('app.media.' + this.messageVM.faceURL))
              .width('100%')
              .height('100%')
              .objectFit(ImageFit.Fill)
          } else {
            if (this.messageVM.faceURL.length > 0 && messageAccessSync(this.messageVM.faceURL)) {
              Image(this.messageVM.faceURL)
                .width('100%')
                .height('100%')
                .objectFit(ImageFit.Fill)
            } else {
              ForEach(this.messageVM.memberAvatarList, (rowAvatarList: string[]) => {
                Row({ space: this.messageVM.memberInfoList.length > 4 ? 2 : 4 }) {
                  ForEach(rowAvatarList, (avatar: string) => {
                    Image($r('app.media.' + avatar))
                      .width(this.messageVM.memberInfoList.length < 5 ? $r('app.float.vp_20') : 40 / 3.0)
                      .aspectRatio(1)
                      .objectFit(ImageFit.Fill)
                  }, (avatar: string, index: number) => avatar + index);
                }
                .justifyContent(FlexAlign.Center)
                .alignItems(VerticalAlign.Center)
              }, (rowAvatarList: string[], index: number) => rowAvatarList.join() + index.toString());
            }
          }
        }
        .width($r('app.float.vp_48'))
        .height($r('app.float.vp_48'))
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .backgroundColor($r('app.color.color_F1F3F5'))
        .borderRadius($r('sys.float.corner_radius_level6'))
        .clip(true)
      }
      .position({ x: 0, y: $r('app.float.vp_8') })
      .clip(true)

      Text(this.messageVM.unreadCount > 99 ? '99+' : this.messageVM.unreadCount.toString())
        .fontSize($r('sys.float.Body_S'))
        .fontColor(Color.White)
        .backgroundColor('#E84026')
        .lineHeight($r('app.float.vp_16'))
        .borderRadius($r('sys.float.corner_radius_level4'))
        .padding({
          left: $r('app.float.vp_4'),
          right: $r('app.float.vp_4')
        })
        .visibility(this.messageVM.unreadCount === 0 ? Visibility.None : Visibility.Visible)
    }
    .width($r('app.float.vp_56'))
    .height($r('app.float.vp_64'))
  }

  @Computed
  get lastMsgContent() {
    if (this.messageVM.type === CMChatConversationType.CHAT_C2C) {
      return this.chatContent;
    } else {
      if (this.messageVM.memberInfoList.length === 0) {
        return '系统：你已不在群中';
      } else if (this.messageVM.lastMessage.friendRemark.length > 0) {
        return this.messageVM.lastMessage.friendRemark + '：' + this.chatContent;
      } else if (this.messageVM.lastMessage.nickName.length > 0) {
        return this.messageVM.lastMessage.nickName + '：' + this.chatContent;
      } else {
        return '系统：' + this.chatContent;
      }
    }
  }

  @Computed
  get chatContent() {
    if (this.messageVM.lastMessage.elemType === CMChatElemType.CHAT_ELEM_TYPE_TEXT) {
      return this.messageVM.lastMessage.textElem
    } else if (this.messageVM.lastMessage.elemType === CMChatElemType.CHAT_ELEM_TYPE_IMAGE) {
      return '[图片]';
    } else if (this.messageVM.lastMessage.elemType === CMChatElemType.CHAT_ELEM_TYPE_SOUND) {
      return '[语音]';
    } else if (this.messageVM.lastMessage.elemType === CMChatElemType.CHAT_ELEM_TYPE_VIDEO) {
      return '[视频]';
    } else if (this.messageVM.lastMessage.elemType === CMChatElemType.CHAT_ELEM_TYPE_LOCATION) {
      return '[位置]';
    } else if (this.messageVM.lastMessage.elemType === CMChatElemType.CHAT_ELEM_GROUP_TIPS) {
      return '[提醒]';
    }
    return '';
  }
}