import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError, emitter } from '@kit.BasicServicesKit';
import { promptAction } from '@kit.ArkUI';

import { AvatarIcon, SelectAvatarCard } from './SelectAvatarCard';
import { Constants, TCRouter, UserInfo } from 'common';

@ComponentV2
export struct UserMsgCard {
  @Local userName: string = ''
  @Local userTel: string = ''
  @Local isLogin: boolean = false
  @Local avatarIcon: AvatarIcon = new AvatarIcon('');

  aboutToAppear(): void {
    this.loginPost();
    emitter.on(Constants.LOGIN_CHANGE, () => {
      this.loginPost();
    })
    this.change();
  }

  loginPost() {
    let userInfo: UserInfo = AppStorage.get('userInfo') as UserInfo;
    if (userInfo) {
      this.userName = userInfo.nickName;
      this.userTel = userInfo.telephone as string;
      this.avatarIcon.avatarUrl = userInfo.avatarUrl as string;
      this.isLogin = true;
    } else {
      this.userName = '';
      this.userTel = '';
      this.avatarIcon.avatarUrl = '';
      this.isLogin = false;
    }
  }

  change() {
    if (this.userTel) {
      this.userTel =
        `${this.userTel.substring(0, this.userTel.length - 8)}****${this.userTel.substring(this.userTel.length - 4)}`
    }
    this.isLogin = !!this.userTel
  }

  build() {
    Row() {
      Row() {
        if (this.isLogin) {
          SelectAvatarCard({ avatarIcon: this.avatarIcon })
        } else {
          Image($r('app.media.ic_default_hd'))
            .width(64)
            .height(64)
            .borderRadius(50)
            .onClick(() => {
              TCRouter.push(Constants.LOGIN_ROUTE);
            })
        }

        Column() {
          if (this.isLogin) {
            Text(this.userName)
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.font_primary'))

            Row() {
              Image($r('app.media.icon_phone')).width(16)
              Text(this.userTel)
                .fontSize($r('sys.float.Body_M'))
                .fontColor($r('sys.color.font_secondary'))
                .margin({ left: 2 })
            }.margin({ top: 12, left: 1 })
          } else {
            Text($r('app.string.no_relative')).fontSize(18)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.font_secondary'))
              .onClick(() => {
                TCRouter.push(Constants.LOGIN_ROUTE);
              })
          }
        }
        .alignItems(HorizontalAlign.Start)
        .margin({ left: 12 })
      }
    }
    .width(Constants.FULL_SIZE)
    .justifyContent(FlexAlign.SpaceBetween)
    .height(112)
    .borderRadius(16)
    .padding({
      left: 16,
      right: 16,
      top: 24,
      bottom: 24,
    })
  }

  // 错误处理
  dealAllError(error: BusinessError<Object>): void {
    hilog.error(0x0000, 'testTag',
      `Failed to login, errorCode is ${error.code}, errorMessage is ${error.message}`);
    promptAction.showToast({ message: '账号关联失败' })
  }
}
