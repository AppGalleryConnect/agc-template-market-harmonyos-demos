import { OrderItem, OrderSkuItem, ReviewMediaItem } from 'lib_network'
import { ContainerColumn } from 'lib_widget'
import { buildOrderBaseInfoCard } from '../components/OrderInfoCard'
import { formatFullDate } from '../utils'

@Builder
export function orderReviewInfoPageBuilder() {
  OrderReviewInfoPage()
}

@ComponentV2
export struct OrderReviewInfoPage {
  @Local
  orderItem?: OrderItem = undefined

  build() {
    NavDestination() {
      if (this.orderItem?.skuInfo) {
        List({ space: 32 }) {
          ForEach(this.orderItem.skuInfo, (sku: OrderSkuItem) => {
            if (sku.skuReview) {
              ListItem() {
                this.buildReviewCard(sku)
              }
            }
          }, (sku: OrderSkuItem, index: number) => index + JSON.stringify(sku.skuReview))
        }
        .scrollBar(BarState.Off)
        .divider({
          color: $r('sys.color.comp_divider'),
          strokeWidth: 0.5,
        })
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
      }
    }
    .title('评价详情')
    .onReady((context) => {
      this.orderItem = context.pathInfo.param as OrderItem | undefined
    })
    .backgroundColor($r('app.color.background_color_grey'))
  }

  @Builder
  buildReviewCard(sku: OrderSkuItem) {
    if (sku.skuReview) {
      Column({ space: 12 }) {
        if (sku.skuReview.mediaList) {
          Swiper() {
            ForEach(sku.skuReview.mediaList, (media: ReviewMediaItem) => {
              Image(media.uri)
                .width($r('app.string.size_percent_full'))
                .aspectRatio(1)
                .objectFit(ImageFit.Cover)
                .constraintSize({ maxHeight: '60%' })
                .draggable(false);
            }, (item: ReviewMediaItem, index: number) => index + JSON.stringify(item.uri))
          }
          .indicator(
            new DotIndicator()
              .color($r('sys.color.comp_background_secondary'))
              .selectedColor($r('app.color.theme_color')),
          )
        }
        Column({ space: 8 }) {
          Row() {
            Row({ space: 4 }) {
              ForEach([1, 2, 3, 4, 5], (item: number) => {
                Image((sku?.skuReview?.rating ?? 0) >= item ? $r('app.media.ic_star_filled') :
                  $r('app.media.ic_star_grey'))
                  .width(16)
                  .height(16)
              }, (item: number) => item.toString())
            }

            Text(formatFullDate(new Date(sku.skuReview.date)))
              .fontColor($r('app.color.font_color_level3'))
              .fontSize($r('app.float.font_size_12'))

          }
          .width($r('app.string.size_percent_full'))
          .justifyContent(FlexAlign.SpaceBetween)

          Text(sku.skuReview.content)
            .fontColor($r('app.color.font_color_level1'))
            .fontSize($r('app.float.font_size_14'))
            .width($r('app.string.size_percent_full'))
            .textAlign(TextAlign.Start)

          ContainerColumn() {
            buildOrderBaseInfoCard(sku)
          }
        }
        .width($r('app.string.size_percent_full'))
        .padding({
          left: $r('app.float.space_l'),
          right: $r('app.float.space_l'),
        })

      }
    }

  }
}