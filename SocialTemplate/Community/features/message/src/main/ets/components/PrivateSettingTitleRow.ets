import { AppStorageV2 } from '@kit.ArkUI';
import { BreakpointModel } from 'common';
import { PrivateChatSettingSingleEnum } from '../utils/MessageEnum';
import { PrivateChatSettingSingleModel } from '../viewmodel/PrivateChatSettingSingleModel';

@ComponentV2
export struct PrivateSettingTitleRow {
  @Param @Require settingVM: PrivateChatSettingSingleModel;
  @Param isBlackList: boolean = false;
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Event onSettingsClick: (settingVM: PrivateChatSettingSingleModel) => void =
    (_settingVM: PrivateChatSettingSingleModel) => {
    }
  @Event onToggleClick: (isOn: boolean) => void = (_isOn: boolean) => {
  }

  build() {
    Row() {
      Text(this.settingVM.title)
        .fontSize($r('sys.float.Body_M'))
        .fontColor(Color.Black)
        .fontWeight(FontWeight.Medium)
        .lineHeight($r('app.float.vp_20'))

      if (this.settingVM.type === PrivateChatSettingSingleEnum.SWITCH) {
        Toggle({ type: ToggleType.Switch, isOn: $$this.isBlackList })
          .selectedColor($r('sys.color.comp_background_emphasize'))
          .switchPointColor($r('sys.color.comp_background_primary_contrary'))
          .onTouchIntercept(() => {
            this.onToggleClick(this.isBlackList);
            return HitTestMode.None;
          })
      } else {
        Image($r('app.media.right_icon'))
          .width($r('app.float.vp_20'))
          .aspectRatio(1)
          .objectFit(ImageFit.Fill)
      }
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
    .backgroundColor(Color.White)
    .width('100%')
    .height($r('app.float.vp_60'))
    .padding({
      left: $r('app.float.vp_16'),
      right: $r('app.float.vp_16')
    })
    .borderRadius({
      topLeft: this.settingVM.isTopBorderRadius ? $r('app.float.vp_12') : 0,
      topRight: this.settingVM.isTopBorderRadius ? $r('app.float.vp_12') : 0,
      bottomLeft: this.settingVM.isBottomBorderRadius ? $r('app.float.vp_12') : 0,
      bottomRight: this.settingVM.isBottomBorderRadius ? $r('app.float.vp_12') : 0
    })
    .onClick(() => {
      if (this.settingVM.type === PrivateChatSettingSingleEnum.TITLE) {
        this.onSettingsClick(this.settingVM);
      }
    })
  }
}