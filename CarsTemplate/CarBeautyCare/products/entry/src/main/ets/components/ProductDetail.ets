import { ProductVM } from '@ohos_agcit/car_beauty_care_product'
import { CommonConstants } from '@ohos_agcit/car_beauty_care_commonlib'

@Builder
export function ProductDetailBuilder() {
  ProductDetail()
}

@ComponentV2
export struct  ProductDetail {
  @Consumer('appPathStack') appPathStack: NavPathStack = new NavPathStack();
  productVM: ProductVM = ProductVM.instance;
  topRectHeight: number = 0;
  aboutToAppear(): void {
    this.topRectHeight = AppStorage.get('topRectHeight') || 0;
  }

  build() {
    NavDestination() {
      RelativeContainer() {
        Column() {
          Row() {
            Row() {
              Text('￥')
                .fontSize(12)
                .fontColor('#EE3B55')
                .offset({
                  y: 4
                })
              Text(`${this.productVM.viewProductDetailData.price}`)
                .fontSize(20)
                .fontColor('#EE3B55')
                .lineHeight(28)
            }

            Text() {
              Span($r('app.string.sold'))
              Span(`${this.productVM.viewProductDetailData.soldQuantity}`)
            }
              .height(20)
              .fontSize(12)
          }
          .width(CommonConstants.FULL_WIDTH)
          .justifyContent(FlexAlign.SpaceBetween)

          Text(this.productVM.viewProductDetailData.productContent)
            .fontSize(18)
            .margin({
              top:10
            })
        }
        .padding(16)
        .alignItems(HorizontalAlign.Start)

        Row() {
          Row() {
            Text('￥')
              .fontSize(12)
              .fontColor('#EE3B55')
              .offset({
                y: 4
              })
            Text(`${this.productVM.viewProductDetailData.price}`)
              .fontSize(20)
              .fontColor('#EE3B55')
              .lineHeight(28)
          }

          Button($r('app.string.join_list'))
            .backgroundColor('#EE3B55')
            .onClick(() => {
              this.productVM.addSelectProduct(this.productVM.viewProductDetailData)
              this.appPathStack.pop();
            })
        }
        .width(CommonConstants.FULL_WIDTH)
        .padding({
          left: 16,
          right: 16
        })
        .justifyContent(FlexAlign.SpaceBetween)
        .alignRules({
           bottom:{anchor:'__container__',align:VerticalAlign.Bottom}
        })
      }
    }
    .title('服务详情')
    .margin({
      top:px2vp(this.topRectHeight)
    })
    .onBackPressed(() => {
      this.appPathStack.pop();
      return true;
    })
  }
}