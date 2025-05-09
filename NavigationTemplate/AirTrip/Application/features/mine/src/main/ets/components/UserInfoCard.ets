import {
  AppRouter,
  AuthenticationUtil,
  Constants,
  maskPhone,
  UserApi,
  UserInfo,
  UserInfoResult,
  UserInfoStorage,
} from 'common';
import { BusinessError } from '@kit.BasicServicesKit';
import { PersistenceV2 } from '@kit.ArkUI';
import { fileIo as fs } from '@kit.CoreFileKit';
import { GlobalDialog } from 'components';

@ComponentV2
export struct UserInfoCard {
  // 用户信息缓存
  @Local userInfoStorage: UserInfoStorage =
    PersistenceV2.connect(UserInfoStorage, 'UserInfoStorage', () => new UserInfoStorage())!
  @Local loading: boolean = false

  getUserAvatar(): ResourceStr {
    // 用户登录
    if (this.userInfoStorage.isLogin) {
      let userInfoAvatar = this.userInfoStorage.userInfo.avatar
      // 判断是否是沙箱路径
      if (userInfoAvatar.startsWith('file://')) {
        let sandboxPath = userInfoAvatar.split('file://')[1]
        // 判断沙箱路径的图片是否存在，不存在，则使用默认头像
        if (!fs.accessSync(sandboxPath)) {
          return $r('app.media.ic_default_avatar')
        }
      }
      return userInfoAvatar || $r('app.media.ic_default_avatar')
    }
    return $r('app.media.ic_default_avatar')
  }

  build() {
    Row() {
      Row() {
        Image(this.getUserAvatar())
          .width(64)
          .height(64)
          .borderRadius(50)

        Column() {
          if (this.userInfoStorage.isLogin) {
            Text(this.userInfoStorage.userInfo.userName)
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.font_primary'))

            Row() {
              Image($r('app.media.ic_phone')).width(16)
              Text(maskPhone(this.userInfoStorage.userInfo.phoneNumber))
                .fontSize($r('sys.float.Body_M'))
                .fontColor($r('sys.color.font_secondary'))
                .margin({ left: 2 })
            }.margin({ top: 12, left: 1 })
          } else {
            Text($r('app.string.no_relative')).fontSize(18)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.font_secondary'))
          }
        }
        .alignItems(HorizontalAlign.Start)
        .margin({ left: 12 })
      }
      .onClick(() => {
        if (this.userInfoStorage.isLogin) {
          AppRouter.push({
            url: 'UserInfoSettingPage',
          })
        }
      })

      Row() {
        Row() {
          if (this.loading) {
            LoadingProgress()
              .color($r('app.color.color_btn_emphasize_bg'))
              .width(12)
              .height(12)
              .margin({ right: 4 })
          } else {
            Image($r('app.media.ic_link'))
              .width(12)
              .height(12)
              .margin({ right: 4 })
              .fillColor(this.userInfoStorage.isLogin ? $r('app.color.color_btn_emphasize_bg') :
              $r('sys.color.ohos_id_color_text_primary'))
          }
          Text(this.userInfoStorage.isLogin ? $r('app.string.disassociate') : $r('app.string.associate_account'))
            .fontSize($r('sys.float.Body_S'))
            .fontColor(this.userInfoStorage.isLogin ? $r('app.color.color_btn_emphasize_bg') :
            $r('sys.color.ohos_id_color_text_primary'))
        }
        .padding({
          left: 10,
          right: 10,
          top: 6,
          bottom: 6,
        })
        .borderRadius(14)
        .backgroundColor(this.userInfoStorage.isLogin ? $r('app.color.color_link_bg') :
        $r('sys.color.ohos_id_background_secondary'))
        .onClick(() => {
          if (this.userInfoStorage.isLogin) {
            GlobalDialog.showTextDialog({
              title: '账号解除关联',
              content: '请确认是否解除账号关联？',
              primaryButName: '确定',
              secondaryButName: '取消',
              primaryButAction: () => {
                this.loading = true
                this.cancelRelative()
                GlobalDialog.close()
              },
              secondaryButAction: () => {
                GlobalDialog.close()
              },
            })
          } else {
            GlobalDialog.showLoadingDialog()
            this.getQuickLoginAnonymousPhone()
          }
        })
      }
      .alignItems(this.userInfoStorage.isLogin ? VerticalAlign.Top : VerticalAlign.Center)
    }
    .width(Constants.FULL_PERCENT_WIDTH)
    .justifyContent(FlexAlign.SpaceBetween)
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .borderRadius(16)
    .padding({
      left: 16,
      right: 16,
      top: 24,
      bottom: 24,
    })
  }

  getQuickLoginAnonymousPhone() {
    AuthenticationUtil.authenticationLogin().then((code: string) => {
      if (code) {
        UserApi.userLogin(code).then((userInfo) => {
          let result = userInfo.result as UserInfoResult
          if (result.ret.code === 0) {
            this.userInfoStorage.isLogin = true
            this.userInfoStorage.userInfo = new UserInfo(result.result[0])
          } else {
            GlobalDialog.showToast('账号关联失败，请重试~')
            this.cancelRelative()
          }
        }).catch(() => {
          GlobalDialog.showToast('账号关联失败')
          this.cancelRelative()
        }).finally(() => {
          GlobalDialog.close()
        })
      }
    }).catch((error: BusinessError) => {
      // 用户取消授权
      if (error.code === 1001502012) {
        GlobalDialog.showToast('取消关联手机号')
      } else {
        GlobalDialog.showToast('账号关联失败')
      }
      this.cancelRelative()
    }).finally(() => {
      GlobalDialog.close()
    })
  }

  cancelRelative() {
    AuthenticationUtil.cancelAuthentication().then(() => {
      this.userInfoStorage.isLogin = false
    }).finally(() => {
      this.loading = false
    })
  }
}