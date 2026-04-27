import { ChatTypeEnum } from 'chat_window';
import { CMChatGroupMemberInfo } from 'instant_messaging';
import { RelayDialogModel } from '../../model/RelayDialogModel';
import { MessageUtil } from '../../utils/MessageUtil';
import { messageAvatarBuilder } from './AvatarWrapperBuilder';
import { ImageMsgBody } from './ImageMsgBody';
import { MapMsgBody } from './MapMsgBody';
import { TextMsgBody } from './TextMsgBody';
import { VideoMsgBody } from './VideoMsgBody';

@ComponentV2
export struct RelayComponent {
  @Param @Require dialogVM: RelayDialogModel;

  getFaceUrl() {
    return this.dialogVM.type === 1 ? this.dialogVM.contactVM?.avatarUrl : this.dialogVM.groupInfoVM?.faceURL
  }

  getAvatarList(): string[][] {
    return this.dialogVM.type === 1 ? [] :
    MessageUtil.parseGroupAvatar(this.dialogVM.groupInfoVM?.memberInfoList as CMChatGroupMemberInfo[])
  }

  getName() {
    return this.dialogVM.type === 1 ? this.dialogVM.contactVM?.nickName : this.dialogVM.groupInfoVM?.groupName
  }

  build() {
    Column() {
      Text(this.dialogVM.title)
        .fontSize(14)
        .fontColor('#000000')
        .margin({ bottom: 18 })
      Row() {
        messageAvatarBuilder.builder(this.dialogVM.type, this.getFaceUrl(), this.getAvatarList(),
          this.dialogVM.groupInfoVM?.memberInfoList.length)
        Text(this.getName())
          .fontSize(14).fontColor('#0000000')
          .margin({ left: 12 })
      }.justifyContent(FlexAlign.Start)

      Blank().width('100%').height(16)
      Row() {
        if (this.dialogVM.chatVM.chatType === ChatTypeEnum.CHAT_TYPE_TEXT) {
          TextMsgBody({
            chatVM: this.dialogVM.chatVM
          })
        }
        if (this.dialogVM.chatVM.chatType === ChatTypeEnum.CHAT_TYPE_IMAGE) {
          ImageMsgBody({
            chatVM: this.dialogVM.chatVM
          })
        }
        if (this.dialogVM.chatVM.chatType === ChatTypeEnum.CHAT_TYPE_VIDEO) {
          VideoMsgBody({
            chatVM: this.dialogVM.chatVM
          })
        }
        if (this.dialogVM.chatVM.chatType === ChatTypeEnum.CHAT_TYPE_LOCATION) {
          MapMsgBody({
            chatVM: this.dialogVM.chatVM
          })
        }
      }.width('100%')
      .justifyContent(FlexAlign.Center)

      Row() {
        Text('取消')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .height(46)
          .halfLeading(true)
          .borderRadius(12)
          .fontSize(16)
          .fontColor('#000000')
          .backgroundColor('#E7E9EB')
          .onClick(() => {
            this.dialogVM.cancelCallBack?.()
          })
        Blank().width(16).height(46)
        Text('发送')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .height(46)
          .halfLeading(true)
          .borderRadius(12)
          .fontSize(16)
          .fontColor('#FFFFFF')
          .backgroundColor('#564AF7')
          .onClick(() => {
            this.dialogVM.sureCallBack?.()
          })
      }.width('100%').margin({ top: 24 })
    }
    .width('100%')
    .padding({
      left: 24,
      right: 24,
      top: 24,
      bottom: 44
    })
    .backgroundColor('#F1F3F5')
    .borderRadius({ topLeft: 24, topRight: 24 })
    .alignItems(HorizontalAlign.Start)
  }
}

@Builder
export function relayDialogBuilder(dialogVM: Object) {
  RelayComponent({ dialogVM: dialogVM as RelayDialogModel })
}