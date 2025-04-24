import { Constants } from 'utils';
import { PersonalProfileViewModel } from '../viewmodel/PersonalProfileViewModel';

@ComponentV2
export struct PersonalProfileView {
  @Param @Require isLogin: boolean;
  @Param pathStack: NavPathStack = new NavPathStack();
  personalProfileViewModel: PersonalProfileViewModel = new PersonalProfileViewModel();

  @Builder
  BuildAvatarNickName() {
    Row() {
      if (this.isLogin) {
        Image(this.personalProfileViewModel.avatar)
          .height(40)
          .width(40)
          .borderRadius(100)
        Text(this.personalProfileViewModel.nickName ? this.personalProfileViewModel.nickName : '华为用户')
          .fontWeight(FontWeight.Medium)
          .fontSize(18)
          .margin({ left: 10 })
      } else {
        Image($r('app.media.login'))
          .height(40)
          .width(40)
          .borderRadius(100)
        Text('点击登录')
          .fontWeight(FontWeight.Medium)
          .fontSize(18)
          .margin({ left: 10 })
      }
    }
    .margin({
      left: 15,
    })
    .height(40)
  }

  @Builder
  BuildLoginButton() {
    if (!this.isLogin) {
      Image($r('app.media.chevron_right'))
        .size({ width: 14, height: 14 })
        .opacity(0.6)
        .margin({ right: 15 })
    }
  }

  build() {
    Row() {
      this.BuildAvatarNickName()
      Blank()
      this.BuildLoginButton()
    }
    .width('90%')
    .height(64)
    .borderRadius(12)
    .backgroundColor(Constants.COMMON_BAR_BACKGROUND_COLOR)
    .onClick(() => {
      if (this.isLogin) {
        this.pathStack.pushPathByName('PersonalCenterPage', null);
      } else {
        this.pathStack.pushPathByName('QuickLoginPage', null);
      }
    });
  }
}