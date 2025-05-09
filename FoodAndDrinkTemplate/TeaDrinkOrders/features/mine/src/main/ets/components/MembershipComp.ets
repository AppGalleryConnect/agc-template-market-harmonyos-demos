import { Constants, CouponStateEnum, HttpRequest, IndexPageRouter, RouterMap, TabBarType, UserInfoModel } from 'common';
import { AppStorageV2 } from '@kit.ArkUI';

@ComponentV2
export struct MembershipComp {
  @Consumer('currentIndex') currentIndex?: TabBarType
  @Consumer('pageStack') pageStack?: NavPathStack
  @Local userInfo: UserInfoModel = AppStorageV2.connect(UserInfoModel, () => new UserInfoModel())!;
  @Local myCouponsNum: number = 0

  @Computed
  get myCouponsStr() {
    return this.myCouponsNum > 5 ? '5+' : this.myCouponsNum.toString()
  }

  @Monitor('currentIndex')
  infoChange(monitor: IMonitor) {
    if (monitor.value()?.now === TabBarType.MINE) {
      this.getMyCoupon()
    }
  }

  build() {
    Column() {
      Row() {
        Row() {
          Image(this.userInfo.isRelative ? $r('app.media.ic_drink') : $r('app.media.ic_drink_grey')).width(40)
          Column() {
            Row() {
              Text($r('app.string.drink_value'))
                .fontSize(14)
                .fontColor(this.userInfo.isRelative ? $r('sys.color.font_primary') : $r('sys.color.font_secondary'))
              if (this.userInfo.isRelative) {
                Text($r('app.string.drink_process', this.userInfo.userInfo.sixProcess))
                  .fontSize(10)
                  .fontColor('#E6FFFFFF')
                  .margin({ left: 11 })
              }
            }.margin({ top: 2 })

            Row() {
              Text(this.userInfo.isRelative ? $r('app.string.lv_value', this.userInfo.userInfo.level) :
              $r('app.string.lv_undefined'))
                .fontSize(10)
                .fontColor(this.userInfo.isRelative ? $r('sys.color.font_primary') : $r('sys.color.font_secondary'))

              Progress({
                value: this.userInfo.isRelative ? this.userInfo.userInfo.sixProcess : 0,
                total: Constants.DRINK_PROCESS_MAX,
                type: ProgressType.Linear,
              })
                .width(162)
                .height(6)
                .color('#486602')
                .borderRadius(6)
                .margin({ left: 4, right: 4 })
              Text(this.userInfo.isRelative ? $r('app.string.lv_value', this.userInfo.userInfo.level + 1) :
              $r('app.string.lv_undefined'))
                .fontSize(10)
                .fontColor(this.userInfo.isRelative ? $r('sys.color.font_primary') : $r('sys.color.font_secondary'))
            }.margin({ top: 2 })
          }.margin({ left: 8 }).alignItems(HorizontalAlign.Start)
        }

        if (this.userInfo.isRelative) {
          Column() {
            Image($r('app.media.ic_qrcode')).width(24)
            Text($r('app.string.membership_code'))
              .fontSize(10)
              .fontColor($r('sys.color.font_primary'))
              .margin({ top: 2 })
          }.onClick(() => {
            this.pageStack?.pushPathByName(RouterMap.MEMBER_CODE_PAGE, null)
          })
        }
      }.width(Constants.FULL_SIZE).justifyContent(FlexAlign.SpaceBetween)

      Row() {
        Column() {
          Text(this.myCouponsStr).fontSize(18).fontColor($r('sys.color.white'))
          Text($r('app.string.coupon_label')).fontSize(12).fontColor($r('sys.color.white')).margin({ top: 2 })
        }.width(120).height(54).justifyContent(FlexAlign.Center)
        .onClick(() => {
          this.pageStack?.pushPathByName(RouterMap.MY_COUPONS_PAGE, null, (popInfo: PopInfo) => {
            let result = popInfo.result as IndexPageRouter
            this.currentIndex = result.index ?? TabBarType.HOME_PAGE;
          })
        })

        Divider()
          .color($r('sys.color.mask_tertiary'))
          .vertical(true)
          .height(40)
          .color($r('sys.color.white'))
          .margin({ left: 20, right: 20 })
        Column() {
          Text(this.userInfo.isRelative ? $r('app.string.points_param', `${this.userInfo.userInfo.totalScore}`) : '0')
            .fontSize(18)
            .fontColor($r('sys.color.white'))
          Text($r('app.string.points')).fontSize(12).fontColor($r('sys.color.white')).margin({ top: 2 })
        }.width(120).height(54).justifyContent(FlexAlign.Center)
      }.width(Constants.FULL_SIZE).justifyContent(FlexAlign.Center).margin({ top: 12, bottom: 4 })

    }
    .width(Constants.FULL_SIZE)
    .constraintSize({ maxWidth: Constants.FULL_SIZE })
    .borderRadius(12)
    .padding(this.userInfo.isRelative ? 12 : { left: 19, top: 16, bottom: 18 })
    .backgroundColor(this.userInfo.isRelative ? '#BACD3C' : '#D1D1D6')
  }

  getMyCoupon() {
    this.myCouponsNum = 0
    HttpRequest.getMyCoupons().then((res) => {
      res.forEach(item => {
        // 过滤可使用的优惠券 日期在有效期内
        if (new Date().getTime() < new Date(`${item.endTime} 23:59:59`).getTime() &&
          item.state === CouponStateEnum.USABLE) {
          this.myCouponsNum++
        }
      })
    })
  }
}