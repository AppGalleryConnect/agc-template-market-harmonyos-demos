import { PromptActionClass, CommonConstants } from '@ohos_agcit/car_beauty_care_commonlib';
import { CouponModel, COUPON_SHOW } from '../mode/CouponModel';
import { CouponVM } from '../mode/CouponVM';

const couponVM: CouponVM = CouponVM.instance;

@Builder
export function CouponDialog() {
  Column() {
    RelativeContainer() {
      Row() {
        Text($r('app.string.coupon'))
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.Black)
          .lineHeight(24);
      }
      .width(CommonConstants.FULL_WIDTH)
      .justifyContent(FlexAlign.Center);

      Image($r('app.media.ic_close_lined'))
        .width(24)
        .height(24)
        .alignRules({
          'right': { 'anchor': '__container__', 'align': HorizontalAlign.End },
        })
        .onClick(() => {
          PromptActionClass.closeDialog();
        });
    }
    .height(24)
    .margin({
      bottom: 22,
    });

    List({ space: 12 }) {
      ForEach(couponVM.couponList, (item: CouponModel) => {
        CouponItem({ coupon:item });
      })
    };
  }
  .backgroundColor(Color.White)
  .width(CommonConstants.FULL_WIDTH)
  .borderRadius({
    topLeft: 32,
    topRight: 32,
  })
  .padding(16);
}

let alignRue: Record<string, Record<string, string | VerticalAlign | HorizontalAlign>> = {
  'top': { 'anchor': '__container__', 'align': VerticalAlign.Top },
  'right': { 'anchor': '__container__', 'align': HorizontalAlign.End },
};

@ComponentV2
export struct CouponItem {
  @Param coupon: CouponModel = couponVM.couponList[0];
  @Local hasUse: boolean = false;

  build() {
    RelativeContainer() {
      Row() {
        Column() {
          Text(`￥${this.coupon.couponNumber}`)
            .fontColor($r('app.color.orange'))
            .fontSize(24)
            .lineHeight(32)
            .height(32);
          Text(this.coupon.threshold)
            .fontColor($r('app.color.orange'))
            .fontSize(12);
        };

        Line()
          .width(1)
          .startPoint([0, 0])
          .endPoint([0, 50])
          .strokeWidth(0.1)
          .stroke($r('app.color.orange'))
          .strokeDashArray([2, 2])
          .margin({
            left: 14,
            right: 14,
          });

        Row() {
          Column() {
            Text(this.coupon.name)
              .fontColor($r('app.color.orange'))
              .fontSize(14)
              .lineHeight(24)
              .fontWeight(FontWeight.Medium)
              .height('24.00vp');
            Text(this.coupon.channel)
              .fontColor($r('app.color.orange'))
              .fontSize(12)
              .lineHeight(18);

            Text(this.coupon.expirationTime)
              .fontColor($r('app.color.orange'))
              .fontSize(12)
              .lineHeight(18);
          }
          .alignItems(HorizontalAlign.Start);

          if (!this.coupon.hasPickUp) {
            Button($r('app.string.robbery'))
              .onClick(() => {
                this.coupon.hasPickUp = true;
                couponVM.addCoupon(this.coupon);
              })
              .border({
                width: 1,
                color: $r('app.color.orange'),
              })
              .backgroundColor(Color.Transparent)
              .fontColor($r('app.color.orange'))
              .height(28)
              .fontSize(12);
          }
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.SpaceBetween);
      }
      .backgroundColor($r('app.color.middle_yellow'))
      .width(CommonConstants.FULL_WIDTH)
      .height(96)
      .borderRadius(16)
      .padding({
        left: 16,
        right: 12,
      });

      if (this.coupon.hasPickUp) {
        Image($r('app.media.got'))
          .width(48)
          .height(48)
          .alignRules(alignRue);
      }

    }
    .width(CommonConstants.FULL_WIDTH)
    .height(96);
  }
}