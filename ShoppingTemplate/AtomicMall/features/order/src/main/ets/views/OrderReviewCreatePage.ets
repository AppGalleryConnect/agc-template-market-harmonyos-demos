import { routerStack } from 'lib_foundation'
import { ProductReviewCreation } from 'module_product_review'
import { OrderItem, OrderSkuItem, SkuReview } from 'lib_network'
import { OrderReviewReq } from 'lib_network'
import { OrderUtil } from '../utils/OrderUtil'

@Builder
export function orderReviewCreatePageBuilder() {
  OrderReviewCreatePage()
}

@ComponentV2
struct OrderReviewCreatePage {
  @Local
  skuList: OrderSkuItem[] = []
  @Local
  order?: OrderItem = undefined

  build() {
    NavDestination() {
      ProductReviewCreation({
        skuList: this.skuList,
        handleSubmit: (draft) => {
          const reviews: SkuReview[] = draft.reviewList.map((item) => ({
            productId: item.productId,
            skuCode: item.skuCode,
            skuDesc: item.skuDesc,
            rating: item.rating,
            content: item.content,
            mediaList: item.mediaList,
            date: new Date().getTime(),
          }) as SkuReview);
          OrderUtil.handleReview({
            orderNo: this.order!.orderInfo.orderNo,
            data: { reviews } as OrderReviewReq,
            callback: () => {
              routerStack.pop(1)
            },
          })
        },
      })
    }
    .title('发表评价', { backgroundColor: $r('app.color.background_color_grey') })
    .backgroundColor($r('app.color.background_color_grey'))
    .onReady((context) => {
      const param = context.pathInfo.param as OrderItem | undefined
      if (param) {
        this.order = param
        this.skuList = param.skuInfo
      }
    })
  }
}