import { AppStorageV2 } from '@kit.ArkUI';
import { BreakpointModel } from 'common';
import { PrivateChatSettingSingleModel } from '../viewmodel/PrivateChatSettingSingleModel';

@ComponentV2
export struct PrivateSettingAvatarRow {
  @Param @Require settingVM: PrivateChatSettingSingleModel;
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Event onContactAvatarClick: () => void = () => {
  }
  @Event onAddGroupClick: () => void = () => {
  }

  build() {
    Row() {
      Image($r('app.media.' + this.settingVM.icon))
        .width($r('app.float.vp_48'))
        .aspectRatio(1)
        .objectFit(ImageFit.Fill)
        .borderRadius($r('sys.float.corner_radius_level6'))
        .onClick(() => this.onContactAvatarClick())

      Blank().width($r('app.float.vp_12'));
      Image($r('app.media.chat_setting_add'))
        .width($r('app.float.vp_48'))
        .aspectRatio(1)
        .borderRadius($r('sys.float.corner_radius_level6'))
        .padding($r('app.float.vp_14'))
        .backgroundColor($r('app.color.color_F1F3F5'))
        .onClick(() => this.onAddGroupClick())
    }
    .justifyContent(FlexAlign.Start)
    .alignItems(VerticalAlign.Center)
    .backgroundColor(Color.White)
    .width('100%')
    .height($r('app.float.vp_72'))
    .padding($r('app.float.vp_12'))
    .borderRadius({
      topLeft: this.settingVM.isTopBorderRadius ? $r('app.float.vp_12') : 0,
      topRight: this.settingVM.isTopBorderRadius ? $r('app.float.vp_12') : 0,
      bottomLeft: this.settingVM.isBottomBorderRadius ? $r('app.float.vp_12') : 0,
      bottomRight: this.settingVM.isBottomBorderRadius ? $r('app.float.vp_12') : 0
    })
  }
}