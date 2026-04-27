import { ProductSearchPageParam, ProductSearchResultsPageParam, RouterMap, routerStack } from 'lib_foundation';
import { SearchView } from 'module_product_search';
import { CardLongTakeDelegate, LongTakeAnimationProperties, LongTakeTransitionParam } from 'module_transition';

@Builder
export function buildProductSearchPage() {
  ProductSearchPage();
}

@ComponentV2
struct ProductSearchPage {
  @Local
  img: PixelMap | undefined = undefined
  @Local
  defaultSearch: string = ''
  @Local
  longTakeSession: LongTakeAnimationProperties = new LongTakeAnimationProperties();
  @Local
  longTakeTransitionParam: LongTakeTransitionParam | undefined = undefined;
  @Local
  slotId: string = ''

  build() {
    NavDestination() {
      if (this.img) {
        Image(this.img)
          .width(220)
      }
      CardLongTakeDelegate({
        longTakeSession: this.longTakeSession,
      }) {
        SearchView({
          defaultSearch: this.defaultSearch,
          routerStack: routerStack.getActiveStack(),
          showGuessLike: !this.slotId,
          showHotSearch: !this.slotId,
          handleSearch: (value) => {
            routerStack.pushPath({
              name: RouterMap.PRODUCT_SEARCH_RESULTS,
              param: {
                keywords: value,
                slotId: this.slotId,
              } as ProductSearchResultsPageParam,
            }, false);
          },
        });
      }
    }
    .hideTitleBar(true)
    .onReady((context) => {
      this.defaultSearch = context.pathInfo.param as string
    })
    .onReady((navDestContext: NavDestinationContext) => {
      let param = navDestContext.pathInfo?.param as ProductSearchPageParam;
      if (param) {
        this.longTakeTransitionParam = param.longTakeTransitionParam as LongTakeTransitionParam;
        if (this.longTakeTransitionParam) {
          this.longTakeSession.init(navDestContext, this.longTakeTransitionParam, {
            pop: () => {
              routerStack.pop()
            },
          });
        }
        this.defaultSearch = param.defaultSearch as string
        this.slotId = param.slotId ?? ''
      }
    })
    .onSizeChange((_oldValue: SizeOptions, newValue: SizeOptions) => {
      this.longTakeSession.setNewSize(newValue);
    })
  }
}