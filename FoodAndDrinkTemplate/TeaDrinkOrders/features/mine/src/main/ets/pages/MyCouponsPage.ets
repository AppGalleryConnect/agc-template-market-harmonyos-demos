import {
  Constants,
  CouponCard,
  CouponStateEnum,
  EmptyComp,
  HttpRequest,
  MyCoupon,
  NavHeaderBar,
  WindowModel,
} from 'common/Index';
import { AppStorageV2 } from '@kit.ArkUI';

@Builder
export function MyCouponsPageBuilder() {
  MyCouponsPage()
}

@ComponentV2
struct MyCouponsPage {
  @Consumer('pageStack') pageStack?: NavPathStack
  @Local windowModel: WindowModel = AppStorageV2.connect(WindowModel, () => new WindowModel())!
  @Local currentIndex: number = 0
  @Local myCouponsAll: Array<MyCoupon> = []
  @Local myCouponsUsable: Array<MyCoupon> = []
  @Local myCouponsExpired: Array<MyCoupon> = []
  @Local myCouponsUsed: Array<MyCoupon> = []

  aboutToAppear() {
    this.getMyCoupon()
  }

  getMyCoupon() {
    HttpRequest.getMyCoupons().then((res) => {
      res.forEach(item => {
        this.myCouponsAll.push(item)
        // 过滤可使用的优惠券 日期在有效期内
        if (item.state === CouponStateEnum.USED) {
          this.myCouponsUsed.push(item)
        } else if (new Date(`${item.endTime} 23:59:59`).getTime() > new Date().getTime()) {
          this.myCouponsUsable.push(item)
        } else {
          this.myCouponsExpired.push(item)
        }
      })
    })
  }

  @Styles
  listStyle(){
    .align(Alignment.Top)
    .height(Constants.FULL_SIZE)
    .layoutWeight(1)
    .padding({
      left: 16,
      right: 16,
    })
  }

  @Builder
  tabBuilder(index: number, name: Resource) {
    Column() {
      Text(name)
        .fontColor(this.currentIndex === index ? $r('app.color.mainColor') : '#66000000')
        .fontSize(16)
        .fontWeight(this.currentIndex === index ? 500 : 400)
        .lineHeight(21)
        .margin({ top: 13.5, bottom: 15.5 })
    }
    .width(Constants.FULL_SIZE)
    .height(50)
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .backgroundColor($r('sys.color.background_primary'))
  }

  build() {
    NavDestination() {
      NavHeaderBar({ title: $r('app.string.my_coupon') })
      Column() {
        Tabs({ index: this.currentIndex }) {
          TabContent() {
            this.tabContentBuilder(this.myCouponsAll)
          }.tabBar(this.tabBuilder(0, $r('app.string.all')))

          TabContent() {
            this.tabContentBuilder(this.myCouponsUsable)
          }.tabBar(this.tabBuilder(1, $r('app.string.available')))

          TabContent() {
            this.tabContentBuilder(this.myCouponsExpired)
          }.tabBar(this.tabBuilder(2, $r('app.string.expired')))

          TabContent() {
            this.tabContentBuilder(this.myCouponsUsed)
          }.tabBar(this.tabBuilder(3, $r('app.string.used')))
        }
        .width(Constants.FULL_SIZE)
        .barHeight(50)
        .layoutWeight(1)
        .onChange((index) => {
          this.currentIndex = index;
        })
      }
      .padding({ bottom: this.windowModel.getWindowBottomHeight() })
      .layoutWeight(1)
      .backgroundColor($r('sys.color.background_secondary'))
    }.hideTitleBar(true)
  }

  @Builder
  tabContentBuilder(myCoupons: Array<MyCoupon>) {
    Column() {
      List({ space: 8 }) {
        ForEach(myCoupons, (item: MyCoupon) => {
          ListItem() {
            CouponCard({ coupon: item })
          }
        }, (item: MyCoupon) => JSON.stringify(item))
      }
      .listStyle()
      .scrollBar(BarState.Off)
      .contentStartOffset(12)
      .contentEndOffset(12)
      .visibility(myCoupons.length ? Visibility.Visible : Visibility.None)

      Column() {
        EmptyComp()
      }
      .justifyContent(FlexAlign.Center)
      .layoutWeight(1)
      .visibility(myCoupons.length ? Visibility.None : Visibility.Visible)
    }.layoutWeight(1)
  }
}
