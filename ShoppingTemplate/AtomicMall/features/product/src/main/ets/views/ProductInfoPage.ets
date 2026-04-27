import { BreakpointSystem, ProductInfoPageParam } from 'lib_foundation';
import { NavTitleBar } from 'lib_widget';
import { ProductInfoVM } from '../viewmodels/ProductInfoVM';
import {
  buildDivider,
  buildEmptySearch,
  buildLoadingPlaceholder,
  buildMemberCard,
  buildProductDesc,
  buildProductInfoCard,
  buildProductSwiper,
  buildReviewOverview,
} from '../components/ProductInfoCards';
import { ProductOperationButton } from '../components/ProductOperationButton';
import { SeckillStatus } from 'lib_network';

@Builder
export function buildProductInfoPage() {
  ProductInfoPage();
}

@ComponentV2
export struct ProductInfoPage {
  vm: ProductInfoVM = new ProductInfoVM()

  build() {
    NavDestination() {
      NavTitleBar({
        title: '商品详情',
      })

      Column() {
        if (this.vm.isLoading) {
          buildLoadingPlaceholder()
        } else if (!this.vm.productInfo) {
          buildEmptySearch()
        } else {
          if (BreakpointSystem.isTablet) {
            this.buildTabletDisplay()
          } else {
            this.buildPhoneDisplay()
          }
        }
      }
      .layoutWeight(1)

      // 底部操作栏
      this.buildBottomOperation();
    }
    .hideTitleBar(true)
    .backgroundColor(BreakpointSystem.isTablet ?
      $r('app.color.background_color_grey') :
      $r('app.color.background_color_primary'))
    .onReady((context) => {
      const params = context.pathInfo.param as ProductInfoPageParam | undefined;
      if (params) {
        this.vm.initData(params);
      }
    })
    .onShown(async () => {
      this.vm.getProductInfo()
      this.vm.countdown?.startCountdownTimer()
    })
    .onHidden(() => {
      this.vm.countdown?.stopCountdownTimer()
    })
  }

  @Builder
  buildTabletDisplay() {
    GridRow({
      columns: { lg: 2 },
      gutter: 12,
    }) {
      GridCol({ span: 1 }) {
        Column() {
          buildProductSwiper(this.vm.productInfo?.productDetail?.banners ?? [])
        }
        .layoutWeight(1)
      }

      GridCol({ span: 1 }) {
        Scroll() {
          Column() {
            buildProductInfoCard(this.vm.productInfo?.productDetail!, this.vm.productInfo?.seckillInfo)
            buildMemberCard(this.vm)
            buildDivider()
            buildReviewOverview(this.vm)
            buildDivider()
            buildProductDesc(this.vm.productInfo?.productDetail!)
          };
        }
        .edgeEffect(EdgeEffect.Spring)
        .scrollBar(BarState.Off)
        .layoutWeight(1);
      }
    }
    .backgroundColor($r('app.color.background_color_grey'))
    .layoutWeight(1);
  }

  @Builder
  buildPhoneDisplay() {
    Scroll() {
      Column() {
        buildProductSwiper(this.vm.productInfo?.productDetail?.banners ?? [])
        buildProductInfoCard(this.vm.productInfo?.productDetail!, this.vm.productInfo?.seckillInfo)
        buildMemberCard(this.vm)
        buildDivider()
        buildReviewOverview(this.vm)
        buildDivider()
        buildProductDesc(this.vm.productInfo?.productDetail!)
      };
    }
    .edgeEffect(EdgeEffect.Spring)
    .scrollBar(BarState.Off)
    .layoutWeight(1);
  }

  @Builder
  buildBottomOperation() {
    Row() {
      // 待开售的秒杀商品只展示预约按钮
      if (this.vm.productInfo?.timeSlot?.status === SeckillStatus.WAITING) {
        this.buildCollectionButton()

        Row() {
          SymbolGlyph($r('sys.symbol.bell_fill'))
            .fontSize(24)
            .fontColor([$r('app.color.font_color_level1_invert')])
            .margin({ right: $r('app.float.space_s') })
          Text(this.vm.reserveButtonLabel)
            .fontColor($r('app.color.font_color_level1_invert'))
            .fontSize($r('app.float.font_size_14'))
            .fontWeight(FontWeight.Medium)

          if (this.vm.isReserved && this.vm.countdown?.countdownLabel) {
            Text(`剩余${this.vm.countdown.countdownLabel}开抢`)
              .fontColor($r('app.color.font_color_level1_invert'))
              .fontSize($r('app.float.font_size_14'))
              .fontWeight(FontWeight.Medium)
              .margin({ left: $r('app.float.space_s') })
          }
        }
        .height(40)
        .borderRadius(20)
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .backgroundColor($r('app.color.theme_color_second'))
        .opacity(this.vm.isReserved ? 0.6 : 1)
        .onClick(() => {
          this.vm.handleClickReserveButton()
        })
      } else {
        Row() {
          this.buildCollectionButton()

          Column() {
            SymbolGlyph($r('sys.symbol.service'))
              .fontSize(24)
              .fontColor([$r('sys.color.icon_primary')])
              .margin({ bottom: 2 });

            Text('客服')
              .fontSize(12)
              .fontColor($r('app.color.font_color_level1'));
          }
          .width(40)
          .onClick(() => {
            this.vm.handleClickCustomService()
          })

          Badge({
            count: this.vm.isLogin ? this.vm.cartNum : 0,
            style: {
              badgeSize: 16,
              badgeColor: $r('app.color.theme_color'),
              fontWeight: FontWeight.Medium,
              fontSize: 10,
            },
            position: BadgePosition.RightTop,
          }) {
            Column() {
              SymbolGlyph($r('sys.symbol.cart'))
                .fontSize(24)
                .fontColor([$r('sys.color.icon_primary')])
                .margin({ bottom: 2 });
              Text('购物车')
                .fontSize(12)
                .fontColor($r('app.color.font_color_level1'));
            }
          }
          .width(40)
          .onClick(() => {
            this.vm.handleClickCart()
          });
        }
        .justifyContent(FlexAlign.Start)
        .constraintSize({ minWidth: '40%' })

        Blank();
        ProductOperationButton({
          productInfo: this.vm.productInfo,
        })
          .layoutWeight(1)
      }
    }
    .width('100%')
    .padding({
      left: 16,
      right: 16,
      top: 16,
    })
    .border({
      width: {
        top: '1px',
      },
      color: $r('app.color.background_color_grey'),
    })
    .backgroundColor($r('app.color.background_color_primary'))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }

  @Builder
  buildCollectionButton() {
    if (this.vm.productInfo) {
      Column() {
        SymbolGlyph(this.vm.collectedStatus ? $r('sys.symbol.star_fill') : $r('sys.symbol.star'))
          .fontSize(24)
          .fontColor([this.vm.collectedStatus ? $r('app.color.theme_color') : $r('sys.color.font_primary')])
          .margin({ bottom: 2 })

        Text('收藏')
          .fontSize(12)
          .fontColor($r('app.color.font_color_level1'));
      }
      .width(40)
      .onClick(() => {
        this.vm.changeCollectStatus()
      })
    }
  }
}
