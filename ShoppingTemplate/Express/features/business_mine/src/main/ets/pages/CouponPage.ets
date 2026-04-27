import { AppStorageV2, PersistenceV2 } from '@kit.ArkUI';
import { CouponsController, CouponItem, ReductionTypes, CouponStatus, MyCouponsView } from 'coupons';
import {
  CommonTitle,
  CommonUtil,
  HttpApi,
  RouterMap,
  RouterModule,
  UserInfoModel,
  WindowInfo,
} from 'lib_foundation';


@Builder
export function buildCouponPage() {
  CouponPage();
}

@ComponentV2
export struct CouponPage {
  @Local windowModel: WindowInfo = AppStorageV2.connect(WindowInfo, () => new WindowInfo())!;
  @Local userInfoModel: UserInfoModel = PersistenceV2.connect(UserInfoModel, () => new UserInfoModel())!;
  controller: CouponsController = new CouponsController();

  aboutToAppear() {
    this.controller.themeColor = $r('sys.color.font_emphasize');
    this.controller.onLoadCoupons = async () => {
      const resp = await HttpApi.queryUserCouponList(this.userInfoModel.id);
      let couponsList: CouponItem[] = [];
      if (resp.length > 0) {
        // 数据转换为优惠券组件需要的结构
        couponsList = resp.map((item) => {
          const data = {
            couponID: item.id.toString(),
            couponName: item.name,
            usageRestriction: item.usageRestriction,
            startTime: CommonUtil.formatDate(item.startTime, 'YYYY-MM-DD'),
            endTime: CommonUtil.formatDate(item.endTime, 'YYYY-MM-DD'),
            createdTime: CommonUtil.formatDate(item.createdTime, 'YYYY-MM-DD'),
            amountRule: {
              discountType: item.discountType as ReductionTypes,
              fullAmount: item.fullAmount.toString(),
              discountAmount: item.discountAmount.toString(),
              discountCoefficient: item.discountCoefficient.toString(),
            },
          } as CouponItem;
          if (item.couponStatus !== undefined) {
            data.couponStatus = item.couponStatus as CouponStatus
          }
          return data
        })
      }
      return couponsList;
    }
    this.controller.onUseNow = () => {
      RouterModule.push({ url: RouterMap.EXPRESS_PAGE })
    }
  }

  build() {
    NavDestination() {
      CommonTitle({
        title: '我的优惠券',
      })

      Column() {
        MyCouponsView({
          controller: this.controller,
        })
      }
      .width('100%')
      .padding({ bottom: this.windowModel.windowBottomPadding })
      .layoutWeight(1)
      .backgroundColor($r('sys.color.comp_background_gray'))
    }
    .hideTitleBar(true);
  }
}