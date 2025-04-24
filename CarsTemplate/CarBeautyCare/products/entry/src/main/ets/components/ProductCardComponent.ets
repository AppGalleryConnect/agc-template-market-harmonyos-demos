import { ProductCard, BEAUTY, ProductVM } from '@ohos_agcit/car_beauty_care_product'
import { CommonConstants } from '@ohos_agcit/car_beauty_care_commonlib'


@ComponentV2
export struct ProductCardComponent {
  productVM: ProductVM = ProductVM.instance;
  @Consumer('appPathStack') appPathStack: NavPathStack = new NavPathStack();
  @Param card: ProductCard = {
    coverImg:$r('app.media.banner1'),
    productContent: '全车打蜡（小轿车）',
    soldQuantity: 8,
    introduction:  '洗完车打蜡，让爱车光彩熠熠',
    price: 188,
    classifieds: BEAUTY.WAXING,
    id: 'P001',
    shopId:'0001'
  };

  @Local checked: boolean = false;

  @Monitor('productVM.paidAmount')
  setCheckedStatus() {
    this.checked = this.productVM.selectProduct.some((item:ProductCard) => {
      return item.id === this.card.id;
    })
  }


  handleProductData(selected: boolean) {
    if (selected) {
      this.productVM.addSelectProduct(this.card)
    } else {
      this.productVM.removeSelectProduct(this.card)
    }
    console.log(JSON.stringify(this.productVM.selectProduct))
  }

  build() {
    Row() {
      Image(this.card.coverImg)
        .width(80)
        .height(80)
        .borderRadius(8)
        .margin({
          right: 10
        })

      Column() {
        Row() {
          Text(this.card.productContent)
            .fontSize(12)
            .fontColor('#000')

          Checkbox({ name: 'checkbox1', group: 'checkboxGroup' })
            .select(this.checked)
            .selectedColor('#EE3B55')
            .shape(CheckBoxShape.CIRCLE)
            .onChange((value: boolean) => {
              this.handleProductData(value)
            })
        }
        .width(CommonConstants.FULL_WIDTH)
        .justifyContent(FlexAlign.SpaceBetween)


        Text(this.card.introduction)
          .fontSize(10)
          .fontColor('#666')
          .width(CommonConstants.FULL_WIDTH)
          .margin({
            top:8
          })
        Blank()

        Row() {
            Text(`￥${this.card.price}`)
              .fontSize(14)
              .fontColor('red')

          Text() {
              Span($r('app.string.sold'))
              Span(`${this.card.soldQuantity}`)
          }
            .height(20)
            .fontSize(12)
        }
        .width(CommonConstants.FULL_WIDTH)
        .justifyContent(FlexAlign.SpaceBetween)
        .alignItems(VerticalAlign.Bottom)

      }
      .height(80)
      .layoutWeight(1)
    }
    .width(CommonConstants.FULL_WIDTH)
    .alignItems(VerticalAlign.Top)
    .onClick(() => {
      this.productVM.updateProductDetail(this.card)
      this.appPathStack.pushPathByName('productDetail', true)
    })
  }
}