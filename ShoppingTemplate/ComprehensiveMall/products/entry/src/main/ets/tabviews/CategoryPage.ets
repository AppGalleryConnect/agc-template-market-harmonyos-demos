import { routerStack, RouterMap } from 'lib_foundation';
import { CommonSymbol, NavTitleBar } from 'lib_widget';
import { CategoryItem, HomeApis, ProductSummaryItem } from 'lib_network';
import { ProductCategory } from 'module_product_category';

@ComponentV2
export struct CategoryPageContent {
  @Local
  initId: string = '';
  @Local
  isLoading: boolean = false;
  @Local
  categoryTabs: CategoryItem[] = [];
  @Local
  curIndex: number = 0;
  @Local
  productList: ProductSummaryItem[] = []
  @Local
  isChildRoute: boolean = false

  async getCategoryProductData(id: string) {
    this.isLoading = true;
    const res = await HomeApis.getCategoryProductList(id)
    if (res.code === 0) {
      this.productList = res.productList;
    }
    this.isLoading = false;
  }

  public aboutToAppear(): void {
    this.isLoading = true;
    HomeApis.getHomeConfig().then((res) => {
      if (res.code === 0) {
        this.categoryTabs = res.categoryList;
        const index = this.categoryTabs.findIndex((item) => item.id === this.initId);
        if (index >= 0) {
          this.curIndex = index;
          if (this.categoryTabs[0].subCategory?.length) {
            this.getCategoryProductData(this.categoryTabs[0].subCategory[0].id)
          }
        }
      }
    })
      .finally(() => {
        this.isLoading = false;
      })
  }

  build() {
    NavDestination() {
      Column() {
        NavTitleBar({
          title: '分类',
        }) {
          Row() {
            CommonSymbol({ src: $r('sys.symbol.magnifyingglass') })
              .onClick(() => {
                routerStack.pushPath({ name: RouterMap.PRODUCT_SEARCH });
              })
          }
          .layoutWeight(1)
          .justifyContent(FlexAlign.End)
        }

        ProductCategory({
          isChildRoute:this.isChildRoute,
          initIndex: this.curIndex,
          categoryTabs: this.categoryTabs,
          productList: this.productList,
          isLoading: this.isLoading,
          handleSubCategoryChange: (id) => {
            this.getCategoryProductData(id)
          },
          handleClickCard: (item) => {
            routerStack.pushPath({ name: RouterMap.PRODUCT_SUBCATEGORY, param: item })
          },
        })
      }
      .width('100%')
      .height('100%')
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
      .transition(TransitionEffect.OPACITY.animation({ duration: 600 }))
    }
    .hideTitleBar(true)
    .backgroundColor($r('app.color.background_color_grey'))
    .onReady((context)=>{
      if(context.pathInfo.param){
        this.isChildRoute = true
        this.initId = context.pathInfo.param as string
      }
    })
  }
}

@Builder
export function buildCategoryPage() {
  CategoryPageContent()
}
