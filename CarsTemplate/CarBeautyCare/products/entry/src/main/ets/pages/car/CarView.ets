
import { ShowCardView, LocationVM } from '@ohos_agcit/car_beauty_care_shop'
import { PromptActionClass } from '@ohos_agcit/car_beauty_care_commonlib'
import { AddCar } from '@ohos_agcit/car_beauty_care_componentlib'
import { Drawer } from '../../components/Drawer.component'
import { PRODUCT_CLASSIFICATION, ProductVM } from '@ohos_agcit/car_beauty_care_product'
import { ComponentContent } from '@kit.ArkUI'
import { CouponDialog } from '@ohos_agcit/car_beauty_care_coupon'
import { ShoppingCar } from '../../components/ShoppingCar'
import { CommonModel, CommonConstants } from '@ohos_agcit/car_beauty_care_commonlib'


@ComponentV2
export struct CarView {
  locationVM: LocationVM = LocationVM.instance;
  productVM: ProductVM = ProductVM.instance;
  vm:CommonModel = CommonModel.instance;
  topRectHeight: number = 0;
  private ctx: UIContext = this.getUIContext();
  private contentNode: ComponentContent<object> = new ComponentContent(this.ctx,wrapBuilder(CouponDialog))
  useShopDetail: boolean = true;
  @Builder tabBuilder(title: string, targetIndex: number) {
    Column() {
      Text(title)
        .fontColor(this.vm.secondTabIndex === targetIndex ? '#000' : '#737373')
        .fontSize(this.vm.secondTabIndex === targetIndex ? 18 : 16)
      if (this.vm.secondTabIndex === targetIndex) {
        Divider()
          .strokeWidth(3)
          .color('#EE3B55')
          .margin({
            top:4
          })
          .width(32)
      }
    }
    .onClick(() => {
      this.vm.secondTabIndex = targetIndex;
    })
  }

  openCuponDialog() {
    PromptActionClass.setContext(this.ctx);
    PromptActionClass.setContentNode(this.contentNode);
    PromptActionClass.setOptions({alignment:DialogAlignment.Bottom,offset:{dx:0, dy:0}})
    PromptActionClass.openDialog();
  }

  aboutToAppear(): void {
    this.topRectHeight = AppStorage.get('topRectHeight') || 0;
  }

  build() {
    Stack() {
      RelativeContainer() {
        Image($r('app.media.service_bg'))
          .width(CommonConstants.FULL_WIDTH)
          .height(120)

        Row() {
          Text('营业中8:00-22:00')
            .fontSize(12)
            .fontColor(Color.White)
        }
        .width(123)
        .height(36)
        .borderRadius(18)
        .backgroundColor('rgba(0,0,0,0.4)')
        .id('timeCard')
        .margin({
          left: 16,
          top:px2vp(this.topRectHeight) + 10,
        })
        .justifyContent(FlexAlign.Center)


        Column() {

          // 店铺信息展示
          Column() {
            ShowCardView({
              useShopDetail:true,
              showToggle: true,
              card:this.locationVM.selectShopData
            })

            Row() {
              Column() {
                Text($r('app.string.exclusive_to_newcomers'))
                  .fontColor('#EE3B55')
                  .fontSize(10)
              }
              .border({
                width:1,
                color:'#EE3B55'
              })
              .padding({
                left:4,
                right: 4
              })
              .borderRadius(4)
              .height(16)
              .justifyContent(FlexAlign.Center)


              Row() {
                Text($r('app.string.pick_up_coupon'))
                  .fontSize(12)
                  .fontColor('#EE3B55')
                  .margin({
                    right:2
                  })

                Image($r('app.media.ic_right_arrow_lined'))
                  .width(12)
                  .height(12)
                  .fillColor('red')

              }
              .onClick(() => {
                this.openCuponDialog();
              })
            }
            .width(CommonConstants.FULL_WIDTH)
            .justifyContent(FlexAlign.SpaceBetween)
            .margin({
              top:10
            })
          }
          .padding({
            top: 18,
            left:16,
            right: 16,
            bottom: 16
          })
          .borderRadius({
            topLeft:16,
            topRight:16,
            bottomLeft:16,
            bottomRight:16
          })
          .backgroundColor('#fff')

          // 添加车辆入口
          Row() {
            AddCar()
          }
          .margin({
            top:10,
            left:10,
            right:10
          })

          // 商品服务列表
          Column() {
            Row({space:32}) {
              this.tabBuilder(PRODUCT_CLASSIFICATION.BEAUTY, 0)
              this.tabBuilder(PRODUCT_CLASSIFICATION.TIRE, 1)
              this.tabBuilder(PRODUCT_CLASSIFICATION.MAINTENANCE, 2)
            }
            .width(CommonConstants.FULL_WIDTH)
            .justifyContent(FlexAlign.Start)
            .margin({
              top:12,
              left: 16,
              bottom: 16
            })

            Row() {
              Tabs({index: this.vm.secondTabIndex}) {
                TabContent() {
                  Drawer({
                    productType:PRODUCT_CLASSIFICATION.BEAUTY
                  })
                }
                .align(Alignment.TopStart)

                TabContent() {
                  Drawer({
                    productType:PRODUCT_CLASSIFICATION.TIRE
                  })
                }
                .align(Alignment.TopStart)

                TabContent() {
                  Drawer({
                    productType:PRODUCT_CLASSIFICATION.MAINTENANCE
                  })
                }
                .align(Alignment.TopStart)
              }
              .barHeight(0)
              .onChange((index:number) => {
                this.vm.secondTabIndex = index;
              })
            }
            .layoutWeight(1)
          }
          .width(CommonConstants.FULL_WIDTH)
          .backgroundColor('#fff')
          .margin({
            top:10
          })
          .borderRadius(8)
          .layoutWeight(1)
        }
        .width(CommonConstants.FULL_WIDTH)
        .alignRules({
          top:{anchor:'timeCard', align:VerticalAlign.Bottom}
        })
        .margin({
          top:18,
          bottom:78
        })

        if (this.productVM.selectProduct.length > 0) {
          ShoppingCar()
            .alignRules({
              bottom:{anchor:'__container__', 'align': VerticalAlign.Bottom }
            })
        }
      }
    }
    .backgroundColor('#eee')

  }
}