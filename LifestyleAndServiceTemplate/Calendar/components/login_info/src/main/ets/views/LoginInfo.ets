import { BaseTextStyleModifier, ToastUtils } from 'base_apis';
import { AvatarFunctionButton } from '../components/AvatarFunctionButton';
import { LoginParams, UserInfo } from '../model/Model'
import { LoginEventDispatcher } from '../utils/Utils';
import { ThemeVM } from '../viewModel/ThemeController';

@ComponentV2
export struct LoginInfo {
  /*
   * 登录用户信息
   * */
  @Require @Param userInfo: UserInfo;
  /*
   * 登录状态
   * */
  @Param isLogin: boolean = false;
  /*
    * 登录用户信息
    * */
  @Param routerModule: NavPathStack = new NavPathStack();
  /*
  * selectColor
  * */
  @Param selectColor: ResourceStr = '#c4272b';
  /*
    * titleColor
    * */
  @Param titleColor: ResourceStr = '#ffffff';
  /*
   * 登录卡片点击事件
   * */
  @Event onLoginCellClick: () => void = () => {
  }
  /*
    * 登录事件
    * */
  @Event onLogin: (loginParams: LoginParams) => void = () => {
  }
  /*
  * 华为账号一键登录事件
  * */
  @Event onHuaweiLogin: (loginParams: LoginParams) => void = () => {
  }
  /*
   * 会员开通、权益点击事件
   * */
  @Event onVipClick: () => void = () => {
  }
  @Local themeVM: ThemeVM = ThemeVM.instance;

  @Monitor('selectColor')
  selectColorChange() {
    this.themeVM.setTheme(this.selectColor, this.titleColor)
  }

  aboutToAppear(): void {
    ToastUtils.setUIContext(this.getUIContext())
    LoginEventDispatcher.loginCallback = (loginParams: LoginParams) => {
      this.onLogin(loginParams)
    }
    LoginEventDispatcher.huaweiLoginCallback = (loginParams: LoginParams) => {
      this.onHuaweiLogin(loginParams)
    }
    this.themeVM.setTheme(this.selectColor, this.titleColor)
  }

  build() {
    Column() {
      Row() {
        Flex({ alignItems: ItemAlign.Center }) {
          if (!this.userInfo.userName) {
            Column() {
              Image(
                $r('app.media.avatar_grey'))
                .width(48)
                .height(48)
                .borderRadius($r('sys.float.corner_radius_level10'))
                .margin({ right: 12 })
            }
          } else {
            Column() {
              // 声明FunctionalButton
              AvatarFunctionButton({
                avatarSize: 60,
                userInfo: this.userInfo,
                isLogin: this.isLogin,
              })
            }
          }
          Row() {
            if (this.isLogin) {
              Column({ space: 10 }) {
                Text(this.userInfo.userName as string || $r('app.string.certification_nickname'))
                  .attributeModifier(new BaseTextStyleModifier('font_primary/Subtitle_L/Medium'))
                Row({ space: 5 }) {
                  Image(this.userInfo.vipInfo.isVip ? $r('app.media.vip_logo') : $r('app.media.svip'))
                    .width(12)
                    .height(12)
                  Text(this.userInfo.vipInfo.isVip ? '万年历会员' : '未开通')
                    .attributeModifier(new BaseTextStyleModifier('font_secondary/Body_S/Regular'))
                }
                .backgroundColor(this.userInfo.vipInfo.isVip ? '#F8E6CF' : '#F2F2F2')
                .borderRadius(4)
                .padding({
                  top: 2,
                  left: 4,
                  right: 4,
                  bottom: 2,
                })
              }.width('100%').alignItems(HorizontalAlign.Start)
            }
            if (!this.isLogin) {
              Text('点击登录')
                .attributeModifier(new BaseTextStyleModifier('font_primary/Subtitle_L/Medium'))
            }
            Row({ space: 5 }) {
              Image($r('app.media.chevron_right')).width(12).height(24)
            }
          }
          .flexGrow(1)
          .justifyContent(FlexAlign.SpaceBetween)
          .padding({ right: 8 })
          .onClick(() => {
            if (this.isLogin) {
              this.routerModule.pushPathByName('PersonInformation', this.userInfo)
              return
            }
            this.routerModule.pushPathByName('LoginWithHuaweiID', null)
            this.onLoginCellClick()
          })
        };
      }
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width('100%')
    .backgroundColor($r('sys.color.background_primary'))
    .borderRadius(16)
    .padding(12)
  }
}
