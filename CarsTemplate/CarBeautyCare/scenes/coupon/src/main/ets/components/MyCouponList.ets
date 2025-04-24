import { CouponModel } from '../mode/CouponModel';
import { CouponVM } from '../mode/CouponVM';
import { CouponCard } from './CouponCard';
import { CommonConstants } from '@ohos_agcit/car_beauty_care_commonlib'


@Builder
export function MyCouponListBuilder() {
  MyCouponList();
}

@ComponentV2
export struct MyCouponList {
  @Consumer('appPathStack') appPathStack: NavPathStack = new NavPathStack();
  topRectHeight: number = 0;
  couponVM: CouponVM = CouponVM.instance;

  aboutToAppear(): void {
    this.topRectHeight = AppStorage.get('topRectHeight') || 0;
  }

  build() {
    NavDestination() {
      Row() {
        List({ space: 12 }) {
          ForEach(this.couponVM.selectCoupon, (item: CouponModel) => {
            ListItem() {
              CouponCard({
                card: item,
              });
            }
            .backgroundColor(Color.White)
            .borderRadius(16)
            .padding(12);
          });
        }
        .width(CommonConstants.FULL_WIDTH)
        .scrollBar(BarState.On);
      }
      .height(CommonConstants.FULL_HEIGHT)
      .padding({
        top: 12,
        bottom: 12,
        left: 16,
        right: 16,
      })
      .alignItems(VerticalAlign.Top);
    }
    .title('我的优惠券')
    .margin({
      top: px2vp(this.topRectHeight),
    })
    .onBackPressed(() => {
      this.appPathStack.pop();
      return true;
    })
    .linearGradient({
      angle: 135,
      colors: [[$r('app.color.linerOne'), 0.0], [$r('app.color.linerTwo'), 0.4]],
    });

  }
}
