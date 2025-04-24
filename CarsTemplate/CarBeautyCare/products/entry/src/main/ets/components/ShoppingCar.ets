import { ProductVM , ProductCard} from '@ohos_agcit/car_beauty_care_product'
import { CommonConstants } from '@ohos_agcit/car_beauty_care_commonlib'

@ComponentV2
export struct ShoppingCar {
  productVM: ProductVM = ProductVM.instance;
  @Consumer('appPathStack') appPathStack: NavPathStack = new NavPathStack();
  @Local showModel: boolean = false;
  build() {
    Column() {
      if (this.showModel) {
        Row() {
          Column() {
            Row() {
              Text($r('app.string.shopping_list'))
                .fontSize(20)
                .lineHeight(28)
                .fontWeight(FontWeight.Bold)
              Image($r('app.media.close_btn'))
                .width(40)
                .height(40)
                .onClick(() => {
                  this.showModel = false;
                })
            }
            .height(40)
            .width(CommonConstants.FULL_WIDTH)
            .justifyContent(FlexAlign.SpaceBetween)
            .margin({
              bottom:8
            })

            List({space:18}) {
              ForEach(this.productVM.selectProduct, (item: ProductCard) => {
                ListItem() {
                  Row() {
                    Column() {
                      Text(item.productContent)
                        .fontSize(16)
                        .fontColor(Color.Black)
                        .fontWeight(FontWeight.Medium)
                        .lineHeight(24)
                        .margin({
                          bottom:5
                        })
                      Row() {
                        Text('￥')
                          .fontSize(12)
                          .fontColor('#EE3B55')
                          .fontWeight(FontWeight.Medium)
                          .offset({
                            y:2
                          })
                        Text(item.price.toString())
                          .fontSize(16)
                          .fontColor('#EE3B55')
                          .lineHeight(20)
                          .fontWeight(FontWeight.Medium)
                      }
                    }
                    .alignItems(HorizontalAlign.Start)

                    Image($r('app.media.ic_checkmask_lined'))
                      .height(20)
                      .width(20)
                      .onClick(() => {
                        this.productVM.removeSelectProduct(item)
                      })

                  }
                  .width(CommonConstants.FULL_WIDTH)
                  .justifyContent(FlexAlign.SpaceBetween)
                }
              })
            }
            .layoutWeight(1)
            .divider({
              strokeWidth:1,
              color:'rgba(0,0,0,0.2)',
              startMargin:0,
              endMargin:0
            })
          }
          .width(CommonConstants.FULL_WIDTH)
          .height(400)
          .backgroundColor(Color.White)
          .borderRadius({
            topRight:32,
            topLeft:32
          })
          .padding(16)
        }
        .width(CommonConstants.FULL_WIDTH)
        .layoutWeight(1)
        .backgroundColor('rgba(0,0,0,0.4)')
        .alignItems(VerticalAlign.Bottom)
        .zIndex(100)
      }

      Row() {
        Badge({
          count: this.productVM.selectProduct.length,
          style: {},
          position: BadgePosition.RightTop,
        }) {
          Image($r('app.media.shopping_bag'))
            .width(40)
            .height(40)
        }
        .width(40)
        .onClick(() => {
          this.showModel = !this.showModel;
        })

        Column() {
          Row() {
            Text('￥')
              .fontSize(12)
              .fontColor('#EE3B55')
              .offset({
                y: 4
              })
            Text(`${this.productVM.paidAmount}`)
              .fontSize(20)
              .fontColor('#EE3B55')
              .lineHeight(28)
          }

          Row() {
            Text($r('app.string.total_offer'))
              .fontSize(10)
              .fontColor('rgba(0,0,0,0.4)')
            Text('￥0')
              .fontSize(10)
              .fontColor('#EE3B55')
          }
        }
        .margin({
          left:12
        })
        .alignItems(HorizontalAlign.Start)

        Blank()

        Button($r('app.string.buy_now'))
          .backgroundColor('#EE3B55')
          .onClick(() => {
            this.appPathStack.pushPathByName('confirmOrder', true)
          })
      }
      .width(CommonConstants.FULL_WIDTH)
      .backgroundColor(Color.White)
      .padding({
        top:10,
        bottom:10,
        left:16,
        right: 16
      })
      .shadow({
        radius: 10,
        color: '#ddd',
        offsetY: -1
      })
    }
  }
}