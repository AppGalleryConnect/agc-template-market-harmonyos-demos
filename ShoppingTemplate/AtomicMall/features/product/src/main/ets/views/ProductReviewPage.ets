import { ProductApis, ProductReviewItem } from 'lib_network';
import { ProductReviewCard } from '../components/ProductReviewCard'

@Builder
export function buildProductReviewPage() {
  ProductReviewPage()
}

@ComponentV2
export struct ProductReviewPage {
  @Local
  reviewList: ProductReviewItem[] = []
  @Local
  productId: string = ''
  @Local
  isLoading: boolean = false;
  @Local
  isRefreshing: boolean = false;
  @Local
  curPage: number = 1
  @Local
  totalNum: number = 0
  @Local
  reachEnd: boolean = false;

  build() {
    NavDestination() {
      List({ space: 32 }) {
        Repeat<ProductReviewItem>(this.reviewList)
          .each((ri: RepeatItem<ProductReviewItem>) => {
            ListItem() {
              ProductReviewCard({ reviewItem: ri.item })
            }
          })
        if (this.isLoading) {
          ListItem() {
            Row() {
              LoadingProgress()
                .width(20)
                .margin({ right: $r('app.float.space_s') })
              Text('加载中')
                .fontSize($r('app.float.font_size_14'))
                .fontColor($r('app.color.font_color_level2'))
            }
            .width($r('app.string.size_percent_full'))
            .justifyContent(FlexAlign.Center)
            .height(60)
          }
        }

        if (this.reachEnd) {
          ListItem() {
            Text('已经到达底部')
              .fontSize($r('app.float.font_size_12'))
              .fontColor($r('app.color.font_color_level3'))
              .width($r('app.string.size_percent_full'))
              .textAlign(TextAlign.Center)
              .height(36)
          }
        }
      }
      .layoutWeight(1)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
      .scrollBar(BarState.Off)
      .onReachEnd(async () => {
        await this.getReviewList()
      })
      .padding({
        left: $r('app.float.space_l'),
        right: $r('app.float.space_l'),
        top: $r('app.float.space_m'),
      })
      .divider({ strokeWidth: 1, color: $r('sys.color.comp_divider') })

    }
    .title('全部评价')
    .onReady((context) => {
      const param = context.pathInfo.param as string
      if (param) {
        this.productId = param;
        this.refreshCommentList()
      }
    })
  }

  async refreshCommentList() {
    this.reachEnd = false
    this.curPage = 1
    this.totalNum = 0
    this.reviewList = []
    this.getReviewList(true)
  }

  async getReviewList(isRefresh: boolean = false) {
    if (this.reachEnd || this.isRefreshing || this.isLoading) {
      return;
    }
    if (isRefresh) {
      this.isRefreshing = true
    } else {
      this.isLoading = true
    }
    const res = await ProductApis.getProductReviewList(this.productId, this.curPage)
    if (res.code === 0) {
      this.totalNum = res.total
      const newList = res.list
      if (isRefresh) {
        this.reviewList = []
      }
      this.reviewList.push(...newList)
      if (res.isFinal) {
        this.reachEnd = true
      }
      this.curPage++
    }
    this.isRefreshing = false;
    this.isLoading = false;
  }
}