import {
  AccountUtil,
  BaseTextStyleModifier,
  CommonConstants,
  RouterMap,
  RouterModule,
  UserInfoModel,
} from 'lib_foundation';

@ComponentV2
export struct MineTop {
  @Local userInfo: UserInfoModel = AccountUtil.getUserInfo();

  @Computed
  get userIcon() {
    if (!this.userInfo.isLogin) {
      return $r('app.media.ic_user_unlogin');
    }

    return this.userInfo.avatar ? this.userInfo.avatar : $r('app.media.ic_user_default');
  }

  build() {
    Row() {
      Image(this.userIcon)
        .borderRadius(CommonConstants.HALF_PERCENT)
        .width(48)
        .aspectRatio(1)
        .clip(true)

      Text(!this.userInfo.isLogin ? '点击登录' :
        this.userInfo.nickname === '' ? '华为用户' : this.userInfo.nickname)
        .attributeModifier(new BaseTextStyleModifier('font_primary/Subtitle_L/Medium'))
        .layoutWeight(1)
        .textAlign(TextAlign.Start)
        .margin({ left: CommonConstants.SPACE_16, right: CommonConstants.SPACE_16 })

      SymbolGlyph($r('sys.symbol.chevron_right'))
        .fontSize($r('app.float.normal_img_size'))
        .fontColor([$r('sys.color.font_fourth')])
        .margin({ right: CommonConstants.SPACE_3 })
    }
    .width('100%')
    .backgroundColor($r('sys.color.comp_background_primary'))
    .borderRadius(16)
    .padding(12)
    .onClick(() => {
      RouterModule.push({ url: this.userInfo.isLogin ? RouterMap.PROFILE_EDIT : RouterMap.QUICK_LOGIN });
    })
  }
}