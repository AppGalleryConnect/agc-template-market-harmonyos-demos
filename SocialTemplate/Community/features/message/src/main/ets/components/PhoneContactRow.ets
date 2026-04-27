import { AppStorageV2 } from '@kit.ArkUI';
import { BreakpointModel } from 'common';
import { ContactSingleModel } from '../viewmodel/PhoneContactModel';

@ComponentV2
export struct PhoneContactRow {
  @Param @Require contactVM: ContactSingleModel;
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Event onContactClick: (contactVM: ContactSingleModel) => void =
    (_contactVM: ContactSingleModel) => {
    }
  @Event onAddFriendClick: (contactVM: ContactSingleModel) => void =
    (_contactVM: ContactSingleModel) => {
    }

  build() {
    Row() {
      Image($r('app.media.' + this.contactVM.avatarUrl))
        .width($r('app.float.vp_48'))
        .aspectRatio(1)
        .objectFit(ImageFit.Fill)
        .borderRadius($r('sys.float.corner_radius_level6'))

      Blank().width($r('app.float.vp_12'));

      Text(this.contactVM.nickName)
        .fontSize($r('sys.float.Body_M'))
        .fontColor(Color.Black)
        .fontWeight(FontWeight.Medium)
        .layoutWeight(1)
        .height('100%')
        .textAlign(TextAlign.Start)

      Button(this.contactVM.isFriend ?
      this.contactVM.buttonNormalTitle :
      this.contactVM.buttonLightTitle)
        .type(ButtonType.Normal)
        .width($r('app.float.vp_74'))
        .height($r('app.float.vp_28'))
        .fontSize($r('sys.float.Body_S'))
        .borderRadius($r('sys.float.corner_radius_level4'))
        .backgroundColor(this.contactVM.isFriend ? Color.White : '#564AF7')
        .fontColor(this.contactVM.isFriend ? $r('app.color.color_66000000') : Color.White)
        .hitTestBehavior(HitTestMode.Transparent)
        .onClick(() => this.onAddFriendClick(this.contactVM))
    }
    .justifyContent(FlexAlign.Start)
    .alignItems(VerticalAlign.Center)
    .backgroundColor(Color.White)
    .width('100%')
    .height($r('app.float.vp_64'))
    .padding({
      left: this.breakPointModel.pagePadding,
      right: this.breakPointModel.pagePadding
    })
    .onClick(() => this.onContactClick(this.contactVM))
  }
}