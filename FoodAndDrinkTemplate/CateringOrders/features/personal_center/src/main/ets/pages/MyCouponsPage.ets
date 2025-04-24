import { Constants, CouponCard, CouponStateEnum, getMyCouponsUtil, MyCouponResp, NavHeaderBar } from 'common/Index';

@Component
export struct MyCouponsPage {
  @Consume('pageStack') pageStack: NavPathStack
  @State windowBottomHeight: number = AppStorage.get('windowBottomHeight') as number || 28
  @State currentIndex: number = 0
  @State myCouponsAll: Array<MyCouponResp> = []
  @State myCouponsUsable: Array<MyCouponResp> = []
  @State myCouponsExpired: Array<MyCouponResp> = []
  @State myCouponsUsed: Array<MyCouponResp> = []

  aboutToAppear() {
    this.getMyCoupon()
  }

  getMyCoupon() {
    getMyCouponsUtil().then((res) => {
      res.forEach(item => {
        // 过滤可使用的优惠券 1.类型为优惠券 2.适用范围店内、外卖和店内  3.满减金额小于订单金额 4.日期在有效期内
        if (item.type === Constants.COUPON &&
        [Constants.COUPON_TYPE_STORE, Constants.COUPON_TYPE_ALL].includes(item.couponType)) {
          this.myCouponsAll.push(item)
          if (item.state === CouponStateEnum.USED) {
            this.myCouponsUsed.push(item)
          } else if (new Date(`${item.endTime} 23:59:59`).getTime() > new Date().getTime()) {
            this.myCouponsUsable.push(item)
          } else {
            this.myCouponsExpired.push(item)
          }
        }
      })
    })
  }

  @Styles
  listStyle(){
    .align(Alignment.Top).height(Constants.FULL_SIZE).padding({
      top: 8,
      left: 12,
      right: 12,
      bottom: 8,
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

  build() {
    NavDestination() {
      NavHeaderBar({ title: $r('app.string.my_coupon') })
      Scroll() {
        Tabs({ index: this.currentIndex }) {
          TabContent() {
            List({ space: 8 }) {
              ForEach(this.myCouponsAll, (item: MyCouponResp) => {
                ListItem() {
                  CouponCard({ coupon: item })
                }
              }, (item: MyCouponResp) => JSON.stringify(item))
            }.listStyle().scrollBar(BarState.Off)
          }.tabBar(this.tabBuilder(0, $r('app.string.all')))

          TabContent() {
            List({ space: 8 }) {
              ForEach(this.myCouponsUsable, (item: MyCouponResp) => {
                ListItem() {
                  CouponCard({ coupon: item })
                }
              }, (item: MyCouponResp) => JSON.stringify(item))
            }.listStyle().scrollBar(BarState.Off)
          }.tabBar(this.tabBuilder(1, $r('app.string.available')))

          TabContent() {
            List({ space: 8 }) {
              ForEach(this.myCouponsExpired, (item: MyCouponResp) => {
                ListItem() {
                  CouponCard({ coupon: item })
                }
              }, (item: MyCouponResp) => JSON.stringify(item))
            }.listStyle().scrollBar(BarState.Off)
          }.tabBar(this.tabBuilder(2, $r('app.string.expired')))

          TabContent() {
            List({ space: 8 }) {
              ForEach(this.myCouponsUsed, (item: MyCouponResp) => {
                ListItem() {
                  CouponCard({ coupon: item })
                }
              }, (item: MyCouponResp) => JSON.stringify(item))
            }.listStyle().scrollBar(BarState.Off)
          }.tabBar(this.tabBuilder(3, $r('app.string.coupon_used')))
        }
        .width(Constants.FULL_SIZE)
        .barHeight(50)
        .layoutWeight(1)
        .onAnimationStart((index: number, targetIndex: number, event: TabsAnimationEvent) => {
          this.currentIndex = targetIndex
        })
        .onChange((index) => {
          this.currentIndex = index;
        })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .align(Alignment.Top)
      .backgroundColor('#F2F1F3F5')
      .margin({ bottom: this.windowBottomHeight })
    }.hideTitleBar(true)
  }
}
