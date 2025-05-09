import { promptAction } from '@kit.ArkUI';
import { commonToast, UserInfo } from 'common';

@Component
export struct Login {
  @State isAgree: boolean = false;
  @State verifyCodeTime: number = 0;
  @StorageLink('isLogin') isLogin: boolean = false;
  @Consume('pageInfos') pageInfos: NavPathStack
  @State phoneNum: string = '';
  @State verifyCode: string = ''

  build() {
    NavDestination() {
      Column() {
        Column() {
          // 登录图标
          this.buildLogInSymbolView();

          // 登录信息输入视图
          this.buildLogInfoInputView();
        }

        this.buildUserPrivacySelectView();
      }
      .width('100%')
      .height('100%')
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.SpaceBetween)
      .backgroundColor('#FFFFFFFF')
    }
    .title('登录')
    .padding({ top: Number(AppStorage.get('topRectHeight')) })
  }

  @Builder
  buildLogInSymbolView() {
    Image($r('app.media.ic_start_icon'))
      .width(100)
      .height(100)
      .margin({ top: 38, bottom: 38 })
      .objectFit(ImageFit.Cover)
  }

  @Builder
  buildLogInfoInputView() {
    Row() {
      TextInput({ placeholder: $r('app.string.mobile_number') })
        .width('50%')
        .borderRadius($r('sys.float.corner_radius_level8'))
        .backgroundColor($r('sys.color.background_primary'))
        .placeholderColor($r('sys.color.font_secondary'))
        .placeholderFont({ size: $r('sys.float.Body_L') })
        .onChange((value) => this.phoneNum = value);
    }
    .width('90%')
    .height(50)
    .borderWidth($r('sys.float.border_larger'))
    .borderColor('#D6D6D6')
    .borderRadius($r('sys.float.corner_radius_level8'))
    .padding({ right: 10 })
    .justifyContent(FlexAlign.SpaceBetween)
    .margin({ bottom: 20 })

    Row() {
      TextInput({ placeholder: $r('app.string.verification_code') })
        .width('50%')
        .borderRadius($r('sys.float.corner_radius_level8'))
        .backgroundColor($r('sys.color.background_primary'))
        .placeholderColor($r('sys.color.font_secondary'))
        .placeholderFont({ size: $r('sys.float.Body_L') })
        .onChange((value) => this.verifyCode = value);

      if (this.verifyCodeTime === 0) {
        Text($r('app.string.obtaining_verification_code'))
          .width(85)
          .fontColor('#989898')
          .fontSize($r('sys.float.Body_L'))
          .textAlign(TextAlign.End)
          .onClick(() => {
            commonToast.show({
              type: 'dialog',
              hasTitle: $r('app.string.tips'),
              message: $r('app.string.verifyCode_tips'),
              confirmAction: () => {
                commonToast.hide()
              },
            })
            this.verifyCodeTime = 60;
            this.getVerifyCode();
          });
      } else {
        Row() {
          Text(`${this.verifyCodeTime}`)
            .height(11)
            .fontColor('#989898')
            .fontSize($r('sys.float.Body_L'))
          Text($r('app.string.obtain_in_seconds'))
            .height(11)
            .fontColor('#989898')
            .fontSize($r('sys.float.Body_L'))
        };
      }
    }
    .width('90%')
    .height(50)
    .borderWidth($r('sys.float.border_larger'))
    .borderColor('#D6D6D6')
    .borderRadius($r('sys.float.corner_radius_level8'))
    .padding({ right: 10 })
    .justifyContent(FlexAlign.SpaceBetween)


    Button($r('app.string.login'))
      .width('80%')
      .height(38)
      .backgroundColor(this.isAgree ? '#007DFF' : '#D2D2D2')
      .fontColor($r('sys.color.font_on_primary'))
      .margin({ top: 50, bottom: 14 })
      .onClick(() => this.clickLogInButton())
    Column() {
      Text($r('app.string.login_in_other')).fontColor('#999')
    }
    .margin({ top: 40, bottom: 20 })

    Column({ space: 10 }) {
      Image($r('app.media.huawei_count'))
        .width(38)
        .height(38)
        .objectFit(ImageFit.Cover);
      Text($r('app.string.quickly_login'))
        .fontColor('#999')
        .margin({ right: 4 })
        .fontSize(12)
    }
    .onClick(() => {
      this.pageInfos.replacePathByName('LoginWithHuaweiIDComponent', null);
    })
  }

  @Builder
  buildUserPrivacySelectView() {
    Row() {
      Checkbox()
        .width(14)
        .height(14)
        .margin({ left: 12, right: 12 })
        .select(this.isAgree)
        .onChange((value) => this.isAgree = value);
      Text($r('app.string.read_and_agree'))
        .fontColor('#2E2E2E')
        .fontSize($r('sys.float.Body_M'))
      Text($r('app.string.user_privacy_agreement'))
        .fontColor('#328DFF')
        .fontSize($r('sys.float.Body_M'))
        .onClick(() => {
          this.pageInfos.pushPathByName('PrivacyPolicyPage', null)
        })
    }
    .margin({ bottom: 37 })
  }

  /**
   * 点击登录按钮
   **/
  validateLogin(): boolean {
    if (this.verifyCode === '' || this.phoneNum === '') {
      promptAction.showToast({ message: '手机号或验证码不能为空！' })
      return false
    }
    if (!/^\d{6}$/.test(this.verifyCode)) {
      promptAction.showToast({ message: '验证码不正确！' })
      return false
    }
    if (!/^1[3-9]\d{9}$/.test(this.phoneNum)) {
      promptAction.showToast({ message: '手机号码不正确！' })
      return false
    }
    return true
  }

  /**
   * 点击登录按钮
   **/
  clickLogInButton(): void {
    // 先勾选协议
    if (!this.isAgree) {
      promptAction.showToast({
        message: $r('app.string.select_the_agreement'),
        duration: 1500,
        bottom: 80,
      });
      return;
    }

    if (!this.validateLogin()) {
      return
    }
    this.isLogin = true;
    let mockUserInfo: UserInfo = {
      'idToken': '',
      'userName': '华为用户',
      'avatar': $r('app.media.avatar'),
      'phoneNumber': this.phoneNum,
    }
    AppStorage.setOrCreate('userInfo', mockUserInfo)
    this.pageInfos.pop();
  }

  /**
   * 获取验证码计数
   **/
  getVerifyCode(): void {
    let timer = setInterval(() => {
      this.verifyCodeTime--;
      if (!this.verifyCodeTime) {
        clearInterval(timer)
      }
    }, 1000)
  }
}