import {
  Constants,
  CouponCard,
  CouponRouter,
  CouponStateEnum,
  getMyCouponsUtil,
  MyCouponResp,
  NavHeaderBar,
} from 'common/Index';

@Component
export struct SelectCouponPage {
  @Consume('pageStack') pageStack: NavPathStack
  @State windowTopHeight: number = AppStorage.get('windowTopHeight') as number || 38.77
  @State windowBottomHeight: number = AppStorage.get('windowBottomHeight') as number || 28
  // 订单总金额
  @State totalMoney: number = 0
  // 已选择优惠券id
  @State selectId: string = ''
  @State selectCouponMoney: string = '0'
  @State currentIndex: number = 0
  @State myCouponsUsable: Array<MyCouponResp> = []
  @State myCouponsUnUsable: Array<MyCouponResp> = []

  aboutToAppear() {
    this.getParams()
    this.getMyCoupon()
  }

  getParams() {
    let paramsArr: CouponRouter[] = this.pageStack.getParamByName('SelectCouponPage') as CouponRouter[]
    if (paramsArr.length) {
      let routerParam = paramsArr[paramsArr.length-1]
      this.totalMoney = routerParam?.totalMoney ?? 0
      this.selectId = routerParam?.selectId ?? ''
    }
  }

  getMyCoupon() {
    getMyCouponsUtil().then((res) => {
      res.forEach(item => {
        // 初始化优惠券金额
        if (item.id === this.selectId) {
          this.selectCouponMoney = item.reduce
        }
        // 优惠券过期时间精确到23：59：59
        let date = new Date(`${item.endTime} 23:59:59`)
        // 过滤可使用的优惠券 1.类型为优惠券 2.适用范围店内、外卖和店内  3.满减金额小于等于订单金额 4.日期在有效期内
        if (item.type === Constants.COUPON &&
        [Constants.COUPON_TYPE_STORE, Constants.COUPON_TYPE_ALL].includes(item.couponType) &&
          Number(item.full) <= this.totalMoney && date.getTime() > new Date().getTime()) {
          this.myCouponsUsable.push(item)
        } else {
          this.myCouponsUnUsable.push(item)
        }
      })
    })
  }

  @Builder
  tabBuilder(index: number, name: Resource) {
    Column() {
      Text(name)
        .fontColor(this.currentIndex === index ? $r('sys.color.multi_color_09') : $r('sys.color.font_secondary'))
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Medium)
      if (this.currentIndex === index) {
        Row()
          .width(42)
          .height(0)
          .borderWidth({ bottom: 2 })
          .borderColor($r('sys.color.multi_color_09'))
          .margin({ top: 4 })
      }
    }
    .width(Constants.FULL_SIZE)
    .height(50)
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Start)
    .padding({ top: 12, bottom: 12 })
    .backgroundColor($r('sys.color.comp_background_primary'))
  }

  @Styles
  listStyle(){
    .backgroundColor('#F2F1F3F5').align(Alignment.Top).height(Constants.FULL_SIZE).padding({
      top: 8,
      left: 12,
      right: 12,
      bottom: 8,
    })
  }

  build() {
    NavDestination() {
      NavHeaderBar({ title: $r('app.string.coupon_label') })

      Tabs({ index: this.currentIndex }) {
        TabContent() {
          List({ space: 8 }) {
            ForEach(this.myCouponsUsable, (item: MyCouponResp) => {
              ListItem() {
                CouponCard({
                  coupon: item,
                  isOrder: true,
                  selectId: this.selectId,
                  totalMoney: this.totalMoney,
                  selectCoupon: (coupon: MyCouponResp) => {
                    this.selectCoupon(coupon)
                  },
                })
              }
            }, (item: MyCouponResp) => JSON.stringify(item))
          }.listStyle().scrollBar(BarState.Off)
        }.tabBar(this.tabBuilder(0, $r('app.string.can_use')))

        TabContent() {
          List({ space: 8 }) {
            ForEach(this.myCouponsUnUsable, (item: MyCouponResp) => {
              ListItem() {
                CouponCard({ coupon: item, isOrder: true, totalMoney: this.totalMoney })
              }
            }, (item: MyCouponResp) => JSON.stringify(item))
          }.listStyle().scrollBar(BarState.Off)
        }.tabBar(this.tabBuilder(1, $r('app.string.can_not_use')))
      }
      .onAnimationStart((index: number, targetIndex: number, event: TabsAnimationEvent) => {
        this.currentIndex = targetIndex
      })
      .width(Constants.FULL_SIZE)
      .barHeight(70)
      .layoutWeight(1)
      .onChange((index) => {
        this.currentIndex = index;
      })

      if (this.currentIndex === 0) {
        Row() {
          Text($r('app.string.selected_coupon', `${this.selectId ? 1 : 0}`))
            .fontColor($r('sys.color.font_secondary'))
            .fontSize($r('sys.float.Caption_M'))
            .lineHeight(14)
          Row() {
            Text($r('app.string.currency_symbol'))
              .fontColor($r('sys.color.multi_color_09'))
              .fontSize(8)
              .fontWeight(FontWeight.Medium)
              .lineHeight(12)
              .margin({ bottom: 1 })
            Text(`${Number(this.selectCouponMoney)}`)
              .fontColor($r('sys.color.multi_color_09'))
              .fontSize($r('sys.float.Body_L'))
              .fontWeight(FontWeight.Medium)
              .lineHeight(18)
          }.margin({ left: 6 }).alignItems(VerticalAlign.Bottom)

          Button($r('app.string.confirm'))
            .fontColor($r('sys.color.comp_background_list_card'))
            .fontSize($r('sys.float.Body_L'))
            .fontWeight(700)
            .height(32)
            .backgroundColor($r('sys.color.multi_color_09'))
            .padding({
              top: 8,
              left: 32,
              right: 32,
              bottom: 8,
            })
            .margin({ left: 12 })
            .onClick(() => {
              this.pageStack.pop({ selectId: this.selectId, reduce: this.selectCouponMoney })
            })
        }
        .width(Constants.FULL_SIZE)
        .height(56)
        .padding({ top: 12, bottom: 12, right: 14 })
        .justifyContent(FlexAlign.End)
      }
    }.hideTitleBar(true).padding({ bottom: this.windowBottomHeight })
  }

  canUseCoupon(item: MyCouponResp) {
    if (new Date(`${item.endTime} 23:59:59`).getTime() > new Date().getTime() &&
      item.state === CouponStateEnum.USABLE) {
      return true
    } else {
      return false
    }

  }

  selectCoupon(coupon: MyCouponResp) {
    this.selectId = coupon.couponId
    this.selectCouponMoney = coupon.reduce
  }
}
