import { ChatContentSingleModel } from 'chat_base';
import { BubbleMsgItem, POP_MENU_TYPE } from '../model/BubbleMsgModel';
import { PromptActionClass } from '../utils/PromptActionClass';

@ComponentV2
export struct popMenuItemComponent {
  @Param @Require item: BubbleMsgItem
  @Param @Require chatVM: ChatContentSingleModel
  @Local deviceType: number = PromptActionClass.getDeviceType()
  @Local videoMutyStatus: boolean = PromptActionClass.getVideoMutyStatus()

  build() {
    Column() {
      if (this.item.type === POP_MENU_TYPE.PLAY_SPEAKER) {
        Image(this.deviceType === 0 ? this.item.icon : $r('app.media.ic_play_speaker_active'))
          .width(20)
          .height(20)
          .margin({ bottom: 6 })
        Text(this.item.title).fontSize(10).fontColor(this.deviceType === 0 ? Color.White : '#FFD549')
      } else if (this.item.type === POP_MENU_TYPE.PLAY_MUTE) {
        Image(this.videoMutyStatus === true ? this.item.icon : $r('app.media.ic_muty_active'))
          .width(20)
          .height(20)
          .margin({ bottom: 6 })
        Text(this.item.title).fontSize(10).fontColor(this.videoMutyStatus === true ? Color.White : '#FFD549')
      } else {
        Image(this.item.icon).width(20).height(20).margin({ bottom: 6 })
        Text(this.item.title).fontSize(10).fontColor(Color.White)
      }
    }.margin({ top: 14 })
    .onClick(() => {
      PromptActionClass.menuClick(this.chatVM, this.item.type)
      this.deviceType = PromptActionClass.getDeviceType()
      this.videoMutyStatus = PromptActionClass.getVideoMutyStatus()
    })
  }
}