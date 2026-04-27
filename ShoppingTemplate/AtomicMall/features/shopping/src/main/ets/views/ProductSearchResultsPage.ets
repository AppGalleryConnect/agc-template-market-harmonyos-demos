import {
  routerStack, RouterMap, ProductInfoPageParam, ProductSearchResultsPageParam,
} from 'lib_foundation';
import { CommonSymbol } from 'lib_widget';
import { ProductWaterFlow } from 'module_global_feature';
import { FilterSelectionItem, ProductFilter } from 'module_product_filter';
import { SearchBar } from 'module_product_search';
import { SortTypeMap } from '../commons/Enums';
import { SortBar } from '../components/SortBar';

@ComponentV2
struct ProductSearchResultsPage {
  @Local
  keywords?: string;
  @Local
  searchImg?: PixelMap
  @Local
  slotId?: string
  @Local
  isGrid: boolean = false
  @Local
  sortType: SortTypeMap = SortTypeMap.DEFAULT
  @Local
  filterList: FilterSelectionItem[] = []

  build() {
    NavDestination() {
      this.buildHeader()

      Row() {
        SortBar({
          handleSortTypeChange: (type) => {
            this.sortType = type
          },
        })
        Blank()
        Row() {
          Text('筛选')
            .fontSize($r('app.float.font_size_14'))
            .fontColor($r('app.color.font_color_level2'))
            .margin({ right: $r('app.float.space_s') })
          SymbolGlyph($r('sys.symbol.funnel'))
            .fontSize(16)
            .fontColor([$r('sys.color.icon_secondary')])
        }
        .margin({
          right: $r('app.float.space_l'),
        })
        .onClick(() => {
          ProductFilter.show({
            initFilter: this.filterList,
            handleConfirm: (res) => {
              this.filterList = res
            },
          }, this.getUIContext())
        })
      }
      .width($r('app.string.size_percent_full'))
      .padding({
        bottom: $r('app.float.space_m'),
        left: $r('app.float.space_m'),
      })
      .backgroundColor($r('app.color.background_color_primary'))

      Column() {
        ProductWaterFlow({
          keyword: this.keywords,
          slotId: this.slotId,
          sortType: this.sortType,
          filterList: this.filterList,
          isGrid: this.isGrid,
          handleProductClick: (id) => {
            routerStack.pushPath({
              name: RouterMap.PRODUCT_INFO,
              param: {
                productId: id,
                slotId: this.slotId,
              } as ProductInfoPageParam,
            });
          },
        })
          .layoutWeight(1)
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM]);

      }
      .padding({
        left: $r('app.float.space_l'),
        right: $r('app.float.space_l'),
        top: $r('app.float.space_l'),
      })
      .layoutWeight(1)
      .backgroundColor($r('app.color.background_color_grey'))
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM]);
    }
    .hideTitleBar(true)
    .backgroundColor($r('app.color.background_color_grey'))
    .expandSafeArea([SafeAreaType.SYSTEM, SafeAreaType.CUTOUT], [SafeAreaEdge.BOTTOM, SafeAreaEdge.TOP])
    .onReady((context) => {
      const param = context.pathInfo.param as ProductSearchResultsPageParam
      this.keywords = param.keywords;
      this.searchImg = param.searchImg
      this.slotId = param.slotId
    })
  }

  @Builder
  buildHeader() {
    Row() {
      SearchBar({
        searchWords: this.keywords,
        disabled: true,
        clickBack: () => {
          routerStack.pop(false);
        },
      })
        .layoutWeight(1)

      CommonSymbol({ src: this.isGrid ? $r('sys.symbol.list_bullet') : $r('sys.symbol.grid') })
        .onClick(() => {
          this.isGrid = !this.isGrid;
        })
        .margin({ right: $r('app.float.space_l'), bottom: $r('app.float.space_s') })
    }
    .backgroundColor($r('app.color.background_color_primary'))
    .alignItems(VerticalAlign.Bottom)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
    .padding({ bottom: $r('app.float.space_l') })
  }
}

@Builder
export function buildProductSearchResultsPage() {
  ProductSearchResultsPage();
}
