import { getColor, getMedia, getString, NAV_PAGE_NAME } from '@agctemplate/resources'
import { AppStorageKeys, FontModel, fp2pxUtil, StatusBarHeight, UserInfoModel } from '@agctemplate/widgets'
import { AppStorageV2 } from '@kit.ArkUI'
import { DaySignIn } from 'day_signin'
import { LookAD } from 'look_ad'
import { TaskList } from 'task_list'
import { Wheel } from 'wheel'
import { appRouter, WindowManager } from '@agctemplate/utils'

@ComponentV2
export struct AwardMainPage {
  @Local statusBarHeight: StatusBarHeight = AppStorageV2.connect(StatusBarHeight, AppStorageKeys.STATUS_BAR_HEIGHT,
    () => new StatusBarHeight())!;
  @Local userInfo: UserInfoModel = AppStorageV2.connect(UserInfoModel, 'userInfo', () => new UserInfoModel())!
  @Provider('balance') bonus: number = 0
  @Provider('leftCount') leftCount: number = 0
  @Provider('rightCount') rightCount: number = 0
  @Consumer('curTabIndex') currentIndex: number = 0
  @Local isUpdating: boolean = false;
  @Local fontModel: FontModel = AppStorageV2.connect(FontModel, () => new FontModel())!;

  @Monitor('bonus')
  bonusChange(monitor: IMonitor) {
    const bonusNow = monitor.value(monitor.dirty[0])?.now as number
    const bonusBefore = monitor.value(monitor.dirty[0])?.before as number
    if (bonusNow !== bonusBefore && !this.isUpdating) {
      this.isUpdating = true
      this.userInfo.bonus = bonusNow
      this.isUpdating = false
    }
  }

  @Monitor('userInfo.bonus')
  userInfoBonusChange(monitor: IMonitor) {
    const userInfoBonusNow = monitor.value(monitor.dirty[0])?.now as number;
    const userInfoBonusBefore = monitor.value(monitor.dirty[0])?.before as number;
    if (userInfoBonusNow !== userInfoBonusBefore && !this.isUpdating) {
      this.isUpdating = true
      this.bonus = userInfoBonusNow
      this.isUpdating = false
    }
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Top }) {
        Image(getMedia('app.media.award_hb_bg'))
          .width('100%')
          .height(325)

        Column() {
          Row() {
            Text(getString('app.string.reward_center'))
              .fontSize(fp2pxUtil(24))
              .fontWeight(FontWeight.Bold)
              .fontColor($r('sys.color.font_on_primary'))
          }
          .width('100%')
          .height(35)
          .margin({ top: 36, bottom: 29 })

          Scroll() {
            Column() {
              Row() {
                Image(getMedia('app.media.award_coin'))
                  .width(16)
                  .aspectRatio(1)

                Text(getString('app.string.point_balance'))
                  .margin({ left: 4 })
                  .fontSize(this.fontModel.getFg(16))
                  .fontWeight(FontWeight.Medium)
                  .fontColor($r('sys.color.font_on_primary'))

                Text(this.bonus + '')
                  .margin({ left: 4, bottom: 4 })
                  .fontSize(this.fontModel.getFg(24))
                  .fontWeight(FontWeight.Medium)
                  .fontColor($r('sys.color.font_on_primary'))
              }
              .width('100%')
              .height(this.fontModel.getDesFg(32))
              .margin({ bottom: 4 })

              Text(getString('app.string.daily_points_limit'))
                .fontColor($r('sys.color.font_on_primary'))
                .fontWeight(FontWeight.Regular)
                .margin({ top: 4 })
                .fontSize(this.fontModel.getFg(12))

              DaySignIn({
                onSignSuccess: (day: number, balance: number) => this.bonus += balance,
                isLogin: this.userInfo.isPhoneAssociated,
                loginFunc: () => {
                  this.login()
                }
              })

              LookAD({
                onLookSuccess: (balance: number) => this.bonus += balance,
                isLogin: this.userInfo.isPhoneAssociated,
                loginFunc: () => {
                  this.login()
                }
              })

              Wheel({
                onWheelSuccess: (balance: number) => this.bonus += balance,
                isLogin: this.userInfo.isPhoneAssociated,
                loginFunc: () => {
                  this.login()
                }
              })

              TaskList({
                onTaskSuccess: (balance: number) => this.bonus += balance,
                isLogin: this.userInfo.isPhoneAssociated,
                loginFunc: () => {
                  this.login()
                }
              })

              Row() {}
              .height(78).width('100%')
            }
            .alignItems(HorizontalAlign.Start)
          }
          .edgeEffect(EdgeEffect.Spring)
          .layoutWeight(1)
          .scrollBar(BarState.Off)
        }
        .width('100%')
        .padding({ right: 16, left: 16 })
      }
      .width('100%')
      .backgroundColor($r('sys.color.background_secondary'))
    }
    .hideTitleBar(true)
  }

  @Builder
  titleBuilder() {
    Text(getColor('app.string.reward_center'))
      .height('100%')
      .margin({
        left: 16
      })
      .fontSize(this.fontModel.getFg(24))
      .fontWeight(FontWeight.Bold)
      .fontColor(getColor('app.color.bold_font_color'))
  }

  login(){
    WindowManager.setWindowSystemBarProperties({ statusBarContentColor: '#e6000000' })
    appRouter.push({ builderName: NAV_PAGE_NAME.LoginPage.name, params: { isChange: true } })
  }
}

@Builder
export function AwardMainPageBuilder(index: number) {
  AwardMainPage()
}