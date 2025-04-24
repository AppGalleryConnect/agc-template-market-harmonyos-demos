import { CouponModel } from '../mode/CouponModel';
import { CouponVM } from '../mode/CouponVM';
import { CommonConstants } from '@ohos_agcit/car_beauty_care_commonlib'

@ComponentV2
export struct CouponCard {
  @Consumer('appPathStack') appPathStack: NavPathStack = new NavPathStack();
  couponVM: CouponVM = CouponVM.instance;
  list: CouponModel[] = this.couponVM.couponList;
  @Param card: CouponModel = this.list[0];

  build() {
    Column() {
      Row() {
        Column() {
          Text( this.card.couponNumber.toString())
            .fontSize(18)
            .fontFamily($r('app.string.font_regular'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.red'))
            .height(32)
            .width(48);

          Text(this.card.threshold)
            .fontSize(10)
            .fontColor($r('app.color.red'))
            .height(16)
            .width(48);
        }
        .margin({ right: 16 });

        Column() {
          Text(this.card.name)
            .fontSize(16)
            .fontFamily($r('app.string.font_regular'))
            .fontWeight(FontWeight.Medium)
            .lineHeight(22);

          Text(this.card.channel)
            .fontSize(14)
            .fontColor($r('app.color.color_middleGrey'))
            .margin({ top: 4 });

          Text(this.card.expirationTime)
            .fontSize(14)
            .fontColor($r('app.color.color_littleGrey'))
            .margin({ top: 4 });
        }
        .alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.Start)
        .margin({ left: 16 })
        .layoutWeight(1);

        if (this.card.overdue) {
          Image($r('app.media.expired'))
            .height(48)
            .width(48)
            .position({ x: '85%', y: 0 });
        } else if (this.card.used) {
          Image($r('app.media.used'))
            .height(48)
            .width(48)
            .position({ x: '85%', y: 0 });
        } else {
          Image($r('app.media.noused'))
            .height(48)
            .width(48)
            .position({ x: '85%', y: 0 });
        }
      }
      .padding(3)
      .alignItems(VerticalAlign.Center);
    }
    .width(CommonConstants.FULL_WIDTH)
    .height(76)
    .onClick(() => {
      const size = this.appPathStack.size() - 1;
      const allPahtName:string[] = this.appPathStack.getAllPathName();
      const prePathName = allPahtName[size - 1];
      if (!this.card.used && !this.card.overdue && prePathName === 'confirmOrder') {
        this.couponVM.willUserCoupon = this.card;
        this.appPathStack.pop();
      } else if ( prePathName !== 'confirmOrder') {
        this.appPathStack.pushPathByName('couponDetail', this.card);
      }
    })
  }
}