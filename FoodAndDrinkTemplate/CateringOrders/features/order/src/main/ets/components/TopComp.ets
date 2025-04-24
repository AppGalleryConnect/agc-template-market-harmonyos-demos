import {
  Constants,
  CouponResp,
  DishesType,
  getCouponListUtil,
  getLqCouponsUtil,
  Reduction,
  StoreSet,
} from 'common/Index';
import { DiscountModel } from '../models/DiscountModel';
import { promptAction } from '@kit.ArkUI';

@Preview
@Component
export struct TopComp {
  @Consume('showShopDiscount') showShopDiscount: boolean
  @Consume('storeSet') storeSet: StoreSet
  @Consume('couponList') @Watch('initCoupons') couponList?: Array<CouponResp>
  @Consume('reductionList') @Watch('storeUpdate') reductionList: Array<Reduction>
  @State discountList: Array<DiscountModel> = []
  // swiper组件当前索引值
  @State swiperIndex: number = 0;
  // 当前搜索关键字
  @State searchText: string = '';
  @State showCouponList: Array<CouponResp> = []
  // 原始商品列表
  @Consume('dishesListOri') dishesListOri: Array<DishesType>
  // 展示的商品列表
  @Consume('dishesList') dishesList: Array<DishesType>

  aboutToAppear(): void {
    this.storeUpdate()
    this.initCoupons()
  }

  initCoupons() {
    // 过滤可领取的优惠券 1.剩余数量大于0 2.类型为优惠券  3.适用范围店内、外卖和店内
    this.showCouponList = this.couponList?.filter(item => Number(item.stock) > 0 && item.type === Constants.COUPON &&
    [Constants.COUPON_TYPE_STORE, Constants.COUPON_TYPE_ALL].includes(item.couponsType)) ?? []
  }

  storeUpdate() {
    this.discountList = []
    this.discountList.push(new DiscountModel($r('app.media.icon'),
      $r('app.string.new_user_discount', this.storeSet.xyhMoney)))
    this.reductionList.forEach(item => {
      this.discountList.push(new DiscountModel($r('app.media.icon'), item.name ?? ''))
    })
  }

  build() {
    Column({ space: 8 }) {
      Row() {
        Swiper() {
          ForEach(this.discountList, (item: DiscountModel) => {
            Row() {
              Image($r('app.media.notice')).width(16).margin({ left: 8 })
              Text(item.content)
                .fontColor($r('sys.color.multi_color_09'))
                .fontSize($r('sys.float.Caption_M'))
                .textAlign(TextAlign.Start)
                .margin({ left: 4 })
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .layoutWeight(1)
            }.layoutWeight(1)

          }, (item: DiscountModel) => (JSON.stringify(item)))
        }
        .displayMode(SwiperDisplayMode.STRETCH)
        .loop(true)
        .autoPlay(true)
        .vertical(true)
        .indicator(false)
        .interval(2000)
        .layoutWeight(1)
        .onChange((index) => {
          this.swiperIndex = index;
        })

        Image($r('app.media.down')).width('10').margin({ left: 8, right: '12' })
      }
      .width(Constants.FULL_SIZE)
      .height(22)
      .justifyContent(FlexAlign.SpaceBetween)
      .borderRadius(2)
      .backgroundColor('#1ADB6B42')
      .onClick(() => {
        this.showShopDiscount = true
      })

      if (this.showCouponList.length) {
        Row() {
          List({ space: 4 }) {
            ForEach(this.showCouponList, (item: CouponResp, index: number) => {
              ListItem() {
                if (Number(item.stock) > 0) {
                  Column() {
                    Text() {
                      Span($r('app.string.currency_symbol'))
                        .fontColor($r('sys.color.font_on_primary'))
                        .fontSize($r('sys.float.Caption_M'))
                      Span(`${Number(item.reduce)}`)
                        .fontColor($r('sys.color.font_on_primary'))
                        .fontSize($r('sys.float.Subtitle_L'))
                    }

                    Text(item.name)
                      .fontColor($r('sys.color.font_on_primary'))
                      .fontSize(8)
                      .margin({ top: 2 })
                    Column() {
                      Text(item.state === Constants.COUPON_STATE_NOT_COLLECT ? $r('app.string.claim_now') :
                      $r('app.string.collected'))
                        .fontColor($r('sys.color.multi_color_09'))
                        .fontSize($r('sys.float.Caption_S'))
                        .opacity(item.state === Constants.COUPON_STATE_NOT_COLLECT ? 1 : 0.6)
                        .backgroundColor(item.state === Constants.COUPON_STATE_NOT_COLLECT ? '#FFFFFF' : '#99FFFFFF')
                        .margin({ top: 9 })
                        .borderRadius(7)
                        .padding({
                          left: 6,
                          right: 6,
                          top: 2,
                          bottom: 2,
                        })
                    }
                  }
                  .width(68)
                  .backgroundImage($r(`app.media.coupon_${index % 4}`))
                  .padding({ top: 4, bottom: 4 })
                  .backgroundImageSize({ width: 68, height: 63 })
                  .onClick(() => {
                    if (item.state === Constants.COUPON_STATE_NOT_COLLECT) {
                      getLqCouponsUtil(item.id).then(() => {
                        promptAction.showToast({ message: $r('app.string.claiming_succeeded') })
                        this.getCoupons()
                      }).catch((e: string) => {
                        let msg = e ?? $r('app.string.claiming_failed')
                        promptAction.showToast({ message: msg })
                      })
                    }
                  })
                }
              }
            }, (item: string, index: number) => JSON.stringify(item))
          }.listDirection(Axis.Horizontal).scrollBar(BarState.Off)
        }.height(63).justifyContent(FlexAlign.Start).width(Constants.FULL_SIZE)
      }

      Row() {
        Search({ value: $$this.searchText, placeholder: $r('app.string.search_goods') })
          .textFont({ size: $r('sys.float.Body_L') })
          .width(Constants.FULL_SIZE)
          .placeholderFont({ size: $r('sys.float.Body_L') })
          .maxLength(20)
          .onChange((value: string) => {
            if (value) {
              this.dishesList = this.dishesList.map((item) => {
                item.good = item.good.filter(i => i.name?.includes(value))
                return item
              })
            } else {
              this.dishesList = JSON.parse(JSON.stringify(this.dishesListOri))
            }
          })
      }.height(28).margin({ top: 12, bottom: 12 })
    }.width(Constants.FULL_SIZE).constraintSize({ maxWidth: Constants.FULL_SIZE }).margin({
      left: 12,
      right: 12,
      top: 8,
      bottom: 8,
    })
  }

  getCoupons() {
    getCouponListUtil().then((resp: Array<CouponResp>) => {
      this.couponList = resp
      this.initCoupons()
    })
  }
}