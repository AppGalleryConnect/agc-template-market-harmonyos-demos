import { ProductInfoPageParam, RouterMap, routerStack } from 'lib_foundation';
import { FilterSelectionItem, ProductSummaryItem } from 'lib_network';
import { ProductWaterFlow } from 'module_global_feature';
import { SortTypeMap } from '../commons/Enums';
import { SortBar } from '../components/SortBar';

@Builder
export function buildSubCategoryPage() {
  SubCategoryPage()
}

@ComponentV2
export struct SubCategoryPage {
  @Local
  title: string = ''
  @Local
  curCategoryId: string = ''
  @Local
  isGrid: boolean = false
  @Local
  sortType: SortTypeMap = SortTypeMap.DEFAULT
  @Local
  filterList: FilterSelectionItem[] = []

  build() {
    NavDestination() {
      Row() {
        SortBar({
          handleSortTypeChange: (type) => {
            this.sortType = type
          },
        })
      }
      .width($r('app.string.size_percent_full'))
      .padding($r('app.float.space_m'))
      .backgroundColor($r('app.color.background_color_primary'))

      Column() {
        ProductWaterFlow({
          bgColor: $r('app.color.background_color_grey'),
          categoryId: this.curCategoryId,
          sortType: this.sortType,
          filterList: this.filterList,
          isGrid: this.isGrid,
          handleProductClick: (id: string) => {
            routerStack.pushPath({
              name: RouterMap.PRODUCT_INFO,
              param: { productId: id } as ProductInfoPageParam,
            });
          },
        })
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
      }
      .padding({
        left: $r('app.float.space_l'),
        right: $r('app.float.space_l'),
        top: $r('app.float.space_l'),
      })
      .backgroundColor($r('app.color.background_color_grey'))
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    }
    .title(this.title)
    .onReady((context) => {
      const param = context.pathInfo.param as ProductSummaryItem | undefined
      if (param) {
        this.title = param.title
        this.curCategoryId = param.id
      }
    })
  }
}