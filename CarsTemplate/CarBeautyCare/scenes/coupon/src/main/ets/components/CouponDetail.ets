import { CouponModel } from '../mode/CouponModel';
import { CouponVM } from '../mode/CouponVM';
import { TitleBarView } from '@ohos_agcit/car_beauty_care_componentlib';
import { LocationVM, ShowCardView } from '@ohos_agcit/car_beauty_care_shop';
import { CommonConstants } from '@ohos_agcit/car_beauty_care_commonlib';


@Builder
export function CouponDetailPageBuilder() {
  CouponDetailPage();
}

@ComponentV2
struct CouponDetailPage {
  @Consumer('appPathStack') appPathStack: NavPathStack = new NavPathStack();
  topRectHeight: number = 0;
  couponVM: CouponVM = CouponVM.instance;
  list: CouponModel[] = this.couponVM.couponList;
  locationVM: LocationVM = LocationVM.instance;
  card: CouponModel = this.list[0];

  aboutToAppear(): void {
    this.topRectHeight = AppStorage.get('topRectHeight') || 0;
    this.card = this.appPathStack.getParamByIndex(this.appPathStack.size() - 1) as CouponModel;
  }

  build() {
    NavDestination() {
      Column({ space: 16 }) {
        Column({ space: 8 }) {
          Row() {
            Column({ space: 4 }) {
              Text(this.card.couponNumber.toString())
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .textAlign(TextAlign.Center)
                .fontColor(Color.Red);

              Text(this.card.threshold)
                .fontSize(12)
                .textAlign(TextAlign.Center)
                .fontColor(Color.Red);
            }
            .width(80)
            .justifyContent(FlexAlign.Center)
            .margin({ right: 50 });

            Column({ space: 4 }) {
              Text(this.card.name)
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor(Color.Red)
                .alignSelf(ItemAlign.Start);

              Text(this.card.channel)
                .fontSize(12)
                .opacity(0.6)
                .alignSelf(ItemAlign.Start);
              Text(this.card.expirationTime)
                .fontSize(12)
                .opacity(0.6)
                .alignSelf(ItemAlign.Start);
            }
            .width(200);
          };

          Divider()
            .strokeWidth(1)
            .color('#0D000000')
            .margin({ top: 8, bottom: 8 });

          Column({ space: 8 }) {
            Text($r('app.string.instruction'))
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .alignSelf(ItemAlign.Start);
          }
          .width(CommonConstants.FULL_WIDTH);

          Column({ space: 8 }) {
            ForEach(this.card.detailList, (item: string) => {
              Text(item)
                .fontSize(12)
                .opacity(0.6)
                .fontWeight(FontWeight.Medium)
                .alignSelf(ItemAlign.Start);
            });
          }
          .width(CommonConstants.FULL_WIDTH);
        }
        .width(CommonConstants.FULL_WIDTH)
        .height(200)
        .backgroundColor(Color.White)
        .borderRadius(16)
        .padding(16);

        Column() {
          TitleBarView({
            title: '推荐使用门店',
            routePath: 'shop',
            showRight: false,
          })
            .margin({
              bottom: 16,
            });

          ShowCardView({
            card: this.locationVM.nearByGoodShop,
          });
        }
        .width(CommonConstants.FULL_WIDTH)
        .height(200)
        .backgroundColor(Color.White)
        .borderRadius(16)
        .padding({
          top: 24,
          bottom: 16,
          left: 16,
          right: 16,
        });
      }
      .width(CommonConstants.FULL_WIDTH)
      .height(CommonConstants.FULL_HEIGHT)
      .padding(16);

    }
    .title('优惠券详情')
    .margin({
      top: px2vp(this.topRectHeight),
    })
    .linearGradient({
      angle: 135,
      colors: [[$r('app.color.linerOne'), 0.0], [$r('app.color.linerTwo'), 0.4]],
    })
    .onBackPressed(() => {
      this.appPathStack.pop();
      return true;
    });
  }
}

