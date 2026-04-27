import { common } from '@kit.AbilityKit';
import { BreakpointSystem, BreakpointTypeEnum, ProductInfoPageParam } from 'lib_foundation';
import { CommonSymbol, NavTitleBar } from 'lib_widget';
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
import { ShareUtil } from '../utils/ShareUtil';
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
      this.buildHeader()
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
        const abilityName: string =
          (this.getUIContext().getHostContext() as common.UIAbilityContext)?.abilityInfo?.name ??
            'EntryAbility';
        this.vm.initData(params, abilityName);
      }
      this.vm.registerWindowActiveListener()
    })
    .onShown(async () => {
      ShareUtil.registerGestureShare(this.getUIContext())
      this.vm.getProductInfo()
      this.vm.countdown?.startCountdownTimer()
    })
    .onHidden(() => {
      ShareUtil.unregisterGestureShare()
      this.vm.countdown?.stopCountdownTimer()
    })
    .onDisAppear(() => {
      this.vm.unregisterWindowActiveListener()
    })
  }

  @Builder
  buildHeader() {
    NavTitleBar({
      title: '商品详情',
    }) {
      Row({ space: 16 }) {
        if (this.vm.shareOptions.title) {
          CommonSymbol({
            src: this.vm.collectedStatus ? $r('sys.symbol.star_fill') : $r('sys.symbol.star'),
            color: this.vm.collectedStatus ? $r('app.color.theme_color') : $r('sys.color.font_primary'),
          })
            .onClick(() => {
              this.vm.changeCollectStatus()
            })

          CommonSymbol({ src: $r('sys.symbol.share') })
            .onClick(() => {
              this.vm.openShare()
            })

          if (BreakpointSystem.currentBreakpoint.value !== BreakpointTypeEnum.SM || this.vm.isSplitScreen) {
            CommonSymbol({
              src: this.vm.isSplitScreen
                ? $r('sys.symbol.arrow_down_right_and_arrow_up_left')
                : $r('sys.symbol.rectangle_split_2x1'),
            })
              .onClick(() => {
                if (this.vm.isSplitScreen) {
                  this.vm.mergeSplitScreen();
                } else {
                  this.vm.startSplitScreen();
                }
              })
          }
        }
      }
      .justifyContent(FlexAlign.End)
      .layoutWeight(1)
    };
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
        Column() {
          SymbolGlyph($r('sys.symbol.service'))
            .fontSize(24)
            .fontColor([$r('sys.color.icon_primary')])
            .margin({ bottom: 2 });

          Text('客服')
            .fontSize(12)
            .fontColor($r('app.color.font_color_level1'));
        }
        .onClick(() => {
          this.vm.handleClickCustomService()
        })
        .margin({ right: BreakpointSystem.isTablet ? $r('app.float.space_xl') : $r('app.float.space_l') })

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
          .padding(4);
        }
        .onClick(() => {
          this.vm.handleClickCart()
        });

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
    .backgroundColor($r('app.color.background_color_primary'))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }
}
