import { promptAction } from '@kit.ArkUI';
import { BaseNavTitle, baseToast } from 'base_apis';
import { LoginParams } from '../../model/Model';
import { LoginEventDispatcher } from '../../utils/Utils';
import { ToastUtils } from 'base_apis/src/main/ets/utils/ToastUtils';

@Builder
export function BaseLoginBuilder() {
  BaseLogin()
}

@ComponentV2
export struct BaseLogin {
  @Local routerModule: NavPathStack = new NavPathStack()
  @Local isAgree: boolean = false;
  @Local verifyCodeTime: number = 0;
  @Local phoneNum: string = '';
  @Local verifyCode: string = ''
  /*
   * 登录按钮颜色
   * */
  @Param btnColor: ResourceStr = '#4f616d';
  /*
   * 华为一键登录点击事件
   * */
  @Event onLoginWithHuaweiID: () => void = () => {
  }
  /*
   * 隐私协议点击事件
   * */
  @Event onPrivacyPolicy: () => void = () => {}


  build() {
    NavDestination() {
      BaseNavTitle({
        title: '登录',
        routerModule:this.routerModule
      })
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
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.SpaceBetween)
      .backgroundColor('#FFFFFFFF')
    }
    .onReady((ctx) => {
      this.routerModule = ctx.pathStack
    })
    .hideTitleBar(true)
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
            baseToast.show(this.getUIContext(),{
              type: 'dialog',
              hasTitle: $r('app.string.tips'),
              message: $r('app.string.verifyCode_tips'),
              confirmAction: () => {
                baseToast.hide()
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
      .backgroundColor(this.isAgree ? this.btnColor : '#D2D2D2')
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
      this.routerModule.replacePathByName('LoginWithHuaweiID', null);
      this.onLoginWithHuaweiID()
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
          this.onPrivacyPolicy()
        })
    }
    .margin({ bottom: 37 })
  }

  /**
   * 点击登录按钮
   **/
  validateLogin(): boolean {
    if (this.verifyCode === '' || this.phoneNum === '') {
      ToastUtils.showToast({ message: '手机号或验证码不能为空！' })
      return false
    }
    if (!/^\d{6}$/.test(this.verifyCode)) {
      ToastUtils.showToast({ message: '验证码不正确！' })
      return false
    }
    if (!/^1[3-9]\d{9}$/.test(this.phoneNum)) {
      ToastUtils.showToast({ message: '手机号码不正确！' })
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
      ToastUtils.showToast({
        message: $r('app.string.select_the_agreement'),
        duration: 1500,
        bottom: 80,
      });
      return;
    }

    if (!this.validateLogin()) {
      return
    }
    let loginParams:LoginParams = {
      phoneNumber:this.phoneNum
    }
    LoginEventDispatcher.dispatchToLogin(loginParams)
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