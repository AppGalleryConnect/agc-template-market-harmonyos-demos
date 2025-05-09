import { TitleBar } from '@components/titlebar';
import { Style } from '@common/const';
import { buildProductGhostSearchBar } from '@guis/search';
import { IWaterFlow } from '@components/iwaterflow';
import { ProductSearchResultsPageLogic } from '../logic/ProductSearchResultsPageLogic';
import { LoadingStatus } from '@common/customtypes';
import { cache } from '@common/cache';
import { router } from '@common/router';

@ComponentV2
struct ProductSearchResultsPage {

  private logic: ProductSearchResultsPageLogic = new ProductSearchResultsPageLogic();

  build() {
    NavDestination() {
      Column() {
        TitleBar({
          barPadding: { right: Style.MENU_BAR_MARGIN_RIGHT },
          barColor: Color.White
        }) {
          buildProductGhostSearchBar(cache.search.lastSubmit, () => router.pop(false))
        }
        Row() {
          Row() {
            Text('综合')
              .fontSize(13)
              .fontColor(this.logic.currentActiveType === 'default' ? '#FFE64566' : $r('sys.color.mask_tertiary'))
              .fontWeight(500)
          }
          .height(36)
          .width(80)
          .alignItems(VerticalAlign.Center)
          .justifyContent(FlexAlign.Center)
          .onClick(() => this.logic.onActive(0))
          Row() {
            Text('价格')
              .fontSize(13)
              .fontColor(this.logic.currentActiveType === 'priceDown' ||
                this.logic.currentActiveType === 'priceUp' ? '#FFE64566' : $r('sys.color.mask_tertiary'))
              .fontWeight(400)
          }
          .height(36)
          .width(80)
          .alignItems(VerticalAlign.Center)
          .justifyContent(FlexAlign.Center)
          .onClick(() => this.logic.onActive(1))
          Row() {
            Text('销量')
              .fontSize(13)
              .fontColor(this.logic.currentActiveType === 'sale' ? '#FFE64566' : $r('sys.color.mask_tertiary'))
              .fontWeight(400)
          }
          .height(36)
          .width(80)
          .alignItems(VerticalAlign.Center)
          .justifyContent(FlexAlign.Center)
          .onClick(() => this.logic.onActive(2))
        }
        .width('100%')
        .height(36)
        .padding({ left: 24, right: 24 })
        .backgroundColor(Color.White)
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.SpaceAround)
        if (this.logic.loadingStatus === LoadingStatus.SUCCESS) {
          IWaterFlow({
            logic: this.logic.iWaterFlowLogic,
            firstRowTopMargin: 10,
            footerPadding: { bottom: 48, top: 37 }
          })
            .padding({ left: 10, right: 10 })
        }
      }
      .width('100%')
      .height('100%')
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Start)
    }
    .hideTitleBar(true)
    .backgroundColor('#FFF1F3F5')
    .expandSafeArea([SafeAreaType.SYSTEM, SafeAreaType.CUTOUT], [SafeAreaEdge.BOTTOM, SafeAreaEdge.TOP])
  }
}

@Builder
export function buildProductSearchResultsPage() {
  ProductSearchResultsPage()
}
