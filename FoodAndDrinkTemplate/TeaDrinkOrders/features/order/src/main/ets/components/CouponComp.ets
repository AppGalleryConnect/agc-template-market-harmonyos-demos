import { Constants, CouponResp, CouponStateEnum, HttpRequest } from 'common/Index';
import { promptAction } from '@kit.ArkUI';

@ComponentV2
export struct CouponComp {
  @Local couponList: Array<CouponResp> = []
  @Local showCouponList: Array<CouponResp> = []

  aboutToAppear(): void {
    this.initCoupons()
  }

  initCoupons() {
    HttpRequest.getCouponList().then((resp: Array<CouponResp>) => {
      this.couponList = resp
      // 过滤可领取的优惠券 1.剩余数量大于0
      this.showCouponList = this.couponList?.filter(item => Number(item.stock) > 0 &&
        new Date().getTime() < new Date(`${item.endTime} 23:59:59`).getTime() &&
        new Date().getTime() > new Date(`${item.startTime} 00:00:00`).getTime()) ?? []
    })
  }

  build() {
    Column() {
      if (this.showCouponList.length) {
        Column() {
          Row() {
            Row() {
              Text($r('app.string.coupon_title')).fontSize($r('sys.float.Body_L')).fontWeight(FontWeight.Medium)
              Image($r('app.media.ic_vip')).width(16).height(16).margin({ left: 8 })
            }

            Row() {
              Text($r('app.string.coupon_desc')).fontSize(10).fontWeight(FontWeight.Regular)
              Image($r('app.media.ic_go')).width(16).height(16).margin({ left: 8 })
            }
          }
          .width(Constants.FULL_SIZE)
          .justifyContent(FlexAlign.SpaceBetween)
          .padding({
            left: Constants.BORDER_WIDTH,
            right: Constants.BORDER_WIDTH,
            top: 8,
            bottom: 8,
          })

          Row() {
            List({ space: 4 }) {
              ForEach(this.showCouponList, (item: CouponResp, index: number) => {
                ListItem() {
                  if (Number(item.stock) > 0) {
                    Column() {
                      Text() {
                        Span($r('app.string.currency_symbol')).fontColor(Color.White).fontSize(10).lineHeight(14)
                        Span(`${Number(item.reduce)}`).fontColor(Color.White).fontSize(18).lineHeight(20)
                      }

                      Text(item.name).fontColor(Color.White).fontSize(8).lineHeight(10).margin({ top: 2 })
                      Text(item.state === CouponStateEnum.NOT_PICKED_UP ? $r('app.string.claim_now') :
                      $r('app.string.collected'))
                        .height(14)
                        .fontColor(item.state === CouponStateEnum.NOT_PICKED_UP ? '#ED6F21' :
                          '#99ED6F21')
                        .fontSize(10)
                        .backgroundColor(item.state === CouponStateEnum.NOT_PICKED_UP ? '#FFFFFF' : '#99FFFFFF')
                        .margin({ top: 9 })
                        .borderRadius(7)
                        .padding({
                          left: 6,
                          right: 6,
                          top: 2,
                          bottom: 2,
                        })
                    }
                    .width(68)
                    .backgroundImage($r(`app.media.coupon_${index % 4}`))
                    .padding({
                      top: 4,
                      bottom: 4,
                    })
                    .backgroundImageSize({ width: 68, height: 63 })
                    .onClick(() => {
                      if (item.state === CouponStateEnum.NOT_PICKED_UP) {
                        HttpRequest.getLqCoupons(item.id).then(() => {
                          promptAction.showToast({ message: $r('app.string.claiming_succeeded') })
                          this.initCoupons()
                        }).catch((e: string) => {
                          let msg = e ?? $r('app.string.claiming_failed')
                          promptAction.showToast({ message: msg })
                        })
                      }
                    })
                  }
                }
              }, (item: string) => JSON.stringify(item))
            }.listDirection(Axis.Horizontal).scrollBar(BarState.Off)
          }
          .height(75)
          .justifyContent(FlexAlign.Start)
          .width('100%')
          .backgroundColor(Color.White)
          .padding({
            left: 22,
            top: 6,
            bottom: 6,
          })
        }
      }
    }
    .width(Constants.FULL_SIZE)
  }

  getCoupons() {
    HttpRequest.getCouponList().then((resp: Array<CouponResp>) => {
      this.couponList = resp
      this.initCoupons()
    })
  }
}