import { RouterMap, routerStack, iData } from 'lib_foundation';
import { CouponApis } from 'lib_network';
import { NavTitleBar } from 'lib_widget';
import { CouponsController, MyCouponsView } from 'coupons';

@Builder
export function buildCouponPage() {
  CouponPage();
}

@ComponentV2
export struct CouponPage {
  controller: CouponsController = new CouponsController();

  aboutToAppear() {
    this.controller.themeColor = $r('app.color.theme_color');
    this.controller.onLoadCoupons = async () => {
      const res = await CouponApis.getCoupons({ userId: iData.global.userInfo.phone })
      return res.code === 0 ? res.couponsList : []
    }
    this.controller.onUseNow = () => {
      routerStack.pushPath({ name: RouterMap.PRODUCT_CATEGORY });
    }
    this.controller.loadCoupons();
  }

  build() {
    NavDestination() {
      NavTitleBar({ title: '我的优惠券', bgColor: $r('app.color.background_color_grey') })

      MyCouponsView({
        controller: this.controller,
      })
        .layoutWeight(1)
        .expandSafeArea()
    }
    .hideTitleBar(true);
  }
}
