import { TitleBarView } from '@ohos_agcit/car_beauty_care_componentlib'
import { ShowCardView } from '@ohos_agcit/car_beauty_care_shop'
import { PackageCardModel } from '../model/packageModel'
import { PackageVM } from '../model/PackageVM'
import { CommonConstants } from '@ohos_agcit/car_beauty_care_commonlib'

@Builder
export function PackageDetailViewBuilder() {
  PackageDetailView()
}

@ComponentV2
struct PackageDetailView {
  packageVM:PackageVM = PackageVM.instance;
  topRectHeight: number = 0;
  @Consumer('appPathStack') appPathStack: NavPathStack = new NavPathStack();
  private scroller: Scroller = new Scroller();
  cardData:PackageCardModel = new PackageCardModel(
    $r('app.media.banner1'),
    '(会员日)前挡风玻璃去油全部',
    1000,
    '会员暖冬专享',
    '1000',
    '100',
    '001'
  )

  aboutToAppear(): void {
    this.topRectHeight = AppStorage.get('topRectHeight') || 0;
  }


  @Styles cardStyle() {
    .width(CommonConstants.FULL_WIDTH)
    .backgroundColor('#fff')
    .padding({
      top:24,
      bottom: 18,
      left: 12,
      right: 12
    })
    .borderRadius(16)
  }

  build() {
    NavDestination() {
      Scroll(this.scroller) {
        Column({space:12}) {
          Image($r('app.media.package_banner'))
            .width(CommonConstants.FULL_WIDTH)
            .borderRadius(8)
          Column() {
            Row() {
              Row() {
                Text(`￥${this.packageVM.selectPackageData.discountedPrice}`)
                  .fontSize(24)
                  .fontColor('#EE3B55')
                  .fontWeight(FontWeight.Medium)
                Text(`￥${this.packageVM.selectPackageData.markedPrice}`)
                  .fontSize(12)
                  .fontColor('#a6a6a6')
                  .decoration({
                    type:TextDecorationType.LineThrough
                  })
                  .margin({
                    left:5
                  })
              }
              .alignItems(VerticalAlign.Center)

              Blank()
              Text()  {
                Span($r('app.string.sold'))
                Span(`${this.packageVM.selectPackageData.buyTimes}`)
                Span($r('app.string.quantity'))
              }
                .fontColor('#a6a6a6')
                .fontSize(12)
            }
            .width(CommonConstants.FULL_WIDTH)
            .alignItems(VerticalAlign.Top)

            Text(this.packageVM.selectPackageData.packageContent)
              .fontSize(14)
              .fontColor(Color.Black)
              .margin({
                top:8
              })

            Text(this.packageVM.selectPackageData.introduction)
              .fontColor('#C79E63')
              .fontSize(10)
              .border({
                width:1,
                color:'#C79E63'
              })
              .margin({
                top:8
              })
              .padding({
                left:4,
                right:4
              })
              .borderRadius(4)
              .height(16)
          }
          .alignItems(HorizontalAlign.Start)
          .cardStyle()
          .padding({
            top:12,
            bottom: 18,
            left: 12,
            right: 12
          })

          // 适用门店
          Column() {
            TitleBarView({
              title:$r('app.string.applicable_stores'),
              routePath: 'shop',
              showRight: true
            })
              .margin({
                bottom:16
              })

            ShowCardView()
          }
          .cardStyle()

          Column() {
            TitleBarView({
              title:$r('app.string.package_content')
            })
              .margin({
                bottom:16
              })

            GridRow() {
              GridCol({
                span:6
              }) {
                Text($r('app.string.service_charge'))
                  .width(CommonConstants.FULL_WIDTH)
                  .fontSize(14)
                  .fontColor('#000')
                  .fontWeight(FontWeight.Medium)
              }
              GridCol({
                span:3
              }) {
                Text($r('app.string.unit_price'))
                  .width(CommonConstants.FULL_WIDTH)
                  .fontSize(14)
                  .fontColor('#000')
                  .fontWeight(FontWeight.Medium)
              }
              GridCol({
                span:3
              }) {
                Text($r('app.string.service_quantity'))
                  .width(CommonConstants.FULL_WIDTH)
                  .fontSize(14)
                  .fontColor('#000')
                  .fontWeight(FontWeight.Medium)
              }
            }
            .width(CommonConstants.FULL_WIDTH)
            .margin({
              bottom:8
            })

            GridRow() {
              GridCol({span:6}) {
                Text('前挡玻璃去油膜')
                  .width(CommonConstants.FULL_WIDTH)
                  .fontSize(12)
                  .fontColor('#1a1a1a')
              }
              GridCol({span:3}) {
                Text(`￥100`)
                  .width(CommonConstants.FULL_WIDTH)
                  .fontSize(12)
                  .fontColor('#999')
              }
              GridCol({span:3}) {
                Text('1')
                  .width(CommonConstants.FULL_WIDTH)
                  .fontSize(12)
                  .fontColor('#999')
              }
            }
            .width(CommonConstants.FULL_WIDTH)
            .margin({
              bottom:8
            })

            Text($r('app.string.buy_description'))
              .fontSize(10)
              .fontColor('#ee3b55')
          }
          .alignItems(HorizontalAlign.Start)
          .cardStyle()

          Column() {
            TitleBarView({
              title:$r('app.string.buying_instructions')
            })
              .margin({
                bottom:16
              })

            Image($r('app.media.package_banner'))
              .width(CommonConstants.FULL_WIDTH)

            Column({space:5}) {
              Text('1.此次活动每个用户一个项目每月仅能抢购一次')
                .fontSize(14)
                .fontColor('#999')
              Text('2.本次活动只支持适用门店')
                .fontSize(14)
                .fontColor('#999')
              Text('3.本套餐有效期仅为365天')
                .fontSize(14)
                .fontColor('#999')
            }
            .margin({
              top:16
            })
            .alignItems(HorizontalAlign.Start)
          }
          .cardStyle()
          .alignItems(HorizontalAlign.Start)
        }
      }
      .height(CommonConstants.FULL_HEIGHT)
      .align(Alignment.Top)
      .padding(10)
    }
    .title('套餐详情')
    .margin({
      top: px2vp(this.topRectHeight)
    })
    .onBackPressed(() => {
      this.appPathStack.pop();
      return true;
    })
    .linearGradient({
      angle:135,
      colors:[['#D2E2F5', 0.0], ['#F1F3F5', 0.4]]
    })

  }
}