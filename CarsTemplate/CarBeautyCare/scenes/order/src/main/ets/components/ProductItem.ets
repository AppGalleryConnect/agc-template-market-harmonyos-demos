import { ProductCard , MAINTENANCE_DATA} from '@ohos_agcit/car_beauty_care_product'
import { CommonConstants } from '@ohos_agcit/car_beauty_care_commonlib'

@ComponentV2
export struct ProductItem {
  @Param card: ProductCard = MAINTENANCE_DATA[0];
  build() {
    Row() {
      Image(this.card.coverImg)
        .width(72)
        .height(72)
        .borderRadius(8)

      Column() {
        Row() {
          Text(this.card.productContent)
            .fontSize(14)
            .fontColor('rgba(0,0,0,0.9)')

          Blank()

          Text(this.card.price.toString())
            .fontSize(14)
            .fontColor('rgba(0,0,0,0.9)')
        }
        .width(CommonConstants.FULL_WIDTH)

        Text('X1')
          .fontSize(12)
          .fontColor('rgba(0,0,0,0.4)')

        Blank()
        Divider()

      }
      .height(CommonConstants.FULL_HEIGHT)
      .layoutWeight(1)
      .margin({
        left:10
      })
      .alignItems(HorizontalAlign.End)
    }
    .height(72)
    .width(CommonConstants.FULL_WIDTH)
    .alignItems(VerticalAlign.Top)
  }
}