import {
  BreakpointStorage,
  BreakpointSystem,
  iData,
  ProductInfoPageParam,
  RouterMap,
  routerStack,
} from 'lib_foundation'
import { ProductApis, ProductCardItem, ProductInfo } from 'lib_network'
import { NavTitleBar } from 'lib_widget'
import { CardLongTakeDelegate, LongTakeAnimationProperties, LongTakeTransitionParam } from 'module_transition'
import { ProductOperationButton } from '../components/ProductOperationButton'

@Builder
export function buildProductSwiperPage() {
  ProductSwiperPage()
}

@ComponentV2
export struct ProductSwiperPage {
  @Local
  stack: NavPathStack = new NavPathStack()
  @Local
  dataList: ProductCardItem[] = [];
  @Local
  curIndex: number = 0
  @Local
  isLogin: boolean = iData.global.isLogin;
  @Local
  curBreakpoint: BreakpointStorage = BreakpointSystem.currentBreakpoint
  @Local
  productInfo?: ProductInfo
  @Local
  longTakeSession: LongTakeAnimationProperties = new LongTakeAnimationProperties();
  @Local
  longTakeTransitionParam: LongTakeTransitionParam | undefined = undefined;

  @Computed
  get curProduct() {
    if (!this.dataList.length) {
      return undefined
    }
    return this.dataList[this.curIndex]
  }

  build() {
    NavDestination() {
      CardLongTakeDelegate({
        longTakeSession: this.longTakeSession,
      }) {
        Column() {
          NavTitleBar({
            title: '推荐商品',
          })
          Swiper() {
            ForEach(this.dataList, (card: ProductCardItem) => {
              this.buildProductCard(card)
            }, (card: ProductCardItem) => card.productId)
          }
          .cachedCount(3)
          .backgroundColor($r('app.color.background_color_grey'))
          .vertical(true)
          .autoPlay(false)
          .indicator(false)
          .loop(false)
          .index($$this.curIndex)
          .disableSwipe(false)
          .displayCount(1)
          .nextMargin(100, true)
          .expandSafeArea([SafeAreaType.SYSTEM])
          .onChange(async () => {
            this.getProductInfo(this.curProduct?.productId)
          })
          .height('calc(100% - 90vp)')
        }
        .expandSafeArea()
      }

      this.buildCartButton()
    }
    .hideTitleBar(true)
    .onReady((navDestContext: NavDestinationContext) => {
      let param = navDestContext.pathInfo?.param as Record<string, Object>;
      this.longTakeTransitionParam = param.longTakeTransitionParam as LongTakeTransitionParam;
      if (this.longTakeTransitionParam) {
        this.longTakeSession.init(navDestContext, this.longTakeTransitionParam, {
          pop: () => {
            routerStack.pop()
          },
        });
      }
      this.dataList = param.dataList as ProductCardItem[]
      this.getProductInfo(this.dataList[0]?.productId)
    })
    .onSizeChange((oldValue: SizeOptions, newValue: SizeOptions) => {
      this.longTakeSession.setNewSize(newValue);
    })
  }

  @Builder
  buildProductCard(card: ProductCardItem) {
    Column() {
      Image(card.banner)
        .width($r('app.string.size_percent_full'))
        .objectFit(ImageFit.Contain)
        .layoutWeight(1)
        .margin({ bottom: $r('app.float.space_l') })
        .onClick(() => {
          routerStack.pushPath({
            name: RouterMap.PRODUCT_INFO,
            param: { productId: card.productId } as ProductInfoPageParam,
          });
        })
        .backgroundColor($r('app.color.background_color_grey'))

      Column() {
        Row() {
          Text(card.title)
            .fontColor($r('app.color.font_color_level1'))
            .margin({ right: $r('app.float.space_m') })
            .layoutWeight(1)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          Row() {
            Text('详情')
              .fontColor($r('sys.color.icon_emphasize'))
              .margin({ right: $r('app.float.space_xs') })
            SymbolGlyph($r('sys.symbol.chevron_right'))
              .fontColor([$r('sys.color.icon_emphasize')])
              .width(12)
              .height(24)
              .fontSize(24)
          }
          .onClick(() => {
            routerStack.pushPath({
              name: RouterMap.PRODUCT_INFO,
              param: { productId: card.productId } as ProductInfoPageParam,
            })
          })
        }
        .width($r('app.string.size_percent_full'))
        .margin({ bottom: $r('app.float.space_m') })
        .justifyContent(FlexAlign.Start)

        Row() {
          Text() {
            Span('¥')
              .fontSize($r('app.float.font_size_12'))
              .fontColor($r('app.color.theme_color'))
            Span(card.price.toString())
              .fontSize($r('app.float.font_size_24'))
              .fontColor($r('app.color.theme_color'))
              .fontWeight(FontWeight.Medium)

            Span(' ').letterSpacing(2)
            if (card.dashPrice) {
              Span('¥')
                .fontSize($r('app.float.font_size_12'))
                .decoration({ type: TextDecorationType.LineThrough })
              Span(card.dashPrice.toString())
                .fontSize($r('app.float.font_size_12'))
                .decoration({ type: TextDecorationType.LineThrough })
            }
          }
          .fontColor($r('app.color.font_color_level2'))
          .layoutWeight(1)

          Text(`已售${card.sales}+`)
            .fontColor($r('app.color.font_color_level2'))
            .fontSize($r('app.float.font_size_14'))
        }
        .width($r('app.string.size_percent_full'))
        .margin({ bottom: $r('app.float.space_m') })

        ProductOperationButton({
          productInfo: this.productInfo,
        })
      }
      .alignItems(HorizontalAlign.Start)
      .backgroundColor($r('app.color.background_color_primary'))
      .padding({
        left: $r('app.float.space_l'),
        right: $r('app.float.space_l'),
      })
      .margin({ bottom: $r('app.float.space_l') })
    }
    .backgroundColor($r('app.color.background_color_primary'))
    .height('70%')
    .margin({ bottom: $r('app.float.space_l') })
  }

  @Builder
  buildCartButton() {
    Row() {
      SymbolGlyph($r('sys.symbol.cart'))
        .fontSize(24)
        .fontWeight(FontWeight.Medium)
        .fontColor([$r('app.color.theme_color')])
    }
    .width(48)
    .height(48)
    .borderRadius(24)
    .backgroundColor($r('app.color.background_color_primary'))
    .justifyContent(FlexAlign.Center)
    .shadow(ShadowStyle.OUTER_FLOATING_SM)
    .position({ right: 16, bottom: 36 })
    .onClick(() => {
      routerStack.push({ name: RouterMap.PRODUCT_CART })
    })
  }

  async getProductInfo(productId?: string) {
    if (productId) {
      const res = await ProductApis.getProductDetail(productId)
      if (res.code === 0) {
        this.productInfo = res.data;
      }
    }
  }
}