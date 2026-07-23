import { LoadingStatus } from '../commons/Constants';
import { PriceType } from 'lib_network';
import { ProductModel } from '../commons/Model';
import { CartControlPanel } from '../components/CartControlPanel';
import { CartListView } from '../components/CartListView';
import { CartPageHeader } from '../components/CartPageHeader';
import { CartPageVM } from '../viewmodel/ShoppingCartVM';

@ComponentV2
export struct ShoppingCart {
  // 购物车页面是否是作为子路由页面
  @Param isChildRoute: boolean = false;
  // 是否登录
  @Param isLogin: boolean = false;
  // 是否是会员
  @Param isMember: boolean = false;
  // 自定义模块
  @BuilderParam customContentBuilder: CustomBuilder;
  // 登录事件回调
  @Event onLogin: () => void = () => {
  };
  // 结算事件回调
  @Event
  public onCheckout: (selectedGoodList: ProductModel[]) => void = () => {
  };
  // 作为子页面时，返回事件回调
  @Event onBack: () => void = () => {
  };
  // 商品卡片事件回调
  @Event onCardClick: (id: string, slotId?: string) => void = () => {
  };
  // 规格行点击事件回调
  @Event onSpecRowClick: (productId: string, skuCode: string, count: number, priceType: PriceType,
    slotId?: string) => void = () => {
  };
  // 购物车刷新触发键，外部递增此值触发购物车重新加载
  @Param cartRefreshKey: number = 0;
  vm: CartPageVM = new CartPageVM();

  @Monitor('cartRefreshKey')
  onCartRefreshKeyChange() {
    this.vm.cartVersion = '';
    this.vm.init();
  }

  aboutToAppear(): void {
    this.vm.isLogin = this.isLogin;
    this.vm.isMember = this.isMember;
  }

  // 监听登录状态
  @Monitor('isLogin')
  onLoginStatusChange() {
    this.vm.isLogin = this.isLogin;
  }

  build() {
    Column() {
      // 用户已登录
      if (this.vm.isLogin) {
        // 页面加载
        if (this.vm.loading === LoadingStatus.LOADING) {
          this.loadingBuilder();
        } else if (this.vm.loading === LoadingStatus.SUCCESS) { // 加载完成
          Column() {
            // 头部
            CartPageHeader({
              isChildRoute: this.isChildRoute,
              isEdit: this.vm.isEdit,
              showEdit: this.vm.cartCards.length > 0,
              changeEdit: () => {
                this.vm.isEdit = !this.vm.isEdit;
              },
              onBack: () => {
                this.onBack && this.onBack();
              },
            })

            Refresh({
              refreshing: $$this.vm.isRefreshing,
              builder: this.customRefreshComponent,
            }) {
              Scroll() {
                Column() {
                  Column() {
                    // 购物车列表不为空
                    if (this.vm.cartCards.length) {
                      CartListView({
                        listData: this.vm.cartCards,
                        isEdit: this.vm.isEdit,
                        onCardClick: (id: string, slotId?: string) => {
                          this.onCardClick && this.onCardClick(id, slotId);
                        },
                        onSpecClick: (productId: string, skuCode: string, count: number, priceType: PriceType,
                          slotId?: string) => {
                          this.onSpecRowClick && this.onSpecRowClick(productId, skuCode, count, priceType, slotId);
                        },
                        onChangeCount: (skuCode: string) => {
                          // 更新购物车商品的数量
                          this.vm.updateProductCount(skuCode);
                        },
                        onDelete: (skuCode: string) => {
                          this.vm.onDeleteProduct(skuCode);
                        },
                      })
                    } else {
                      // 购物车列表为空
                      this.cartEmptyBuilder();
                    }
                  }
                  .width('100%')
                  .alignItems(HorizontalAlign.Center)
                  .justifyContent(FlexAlign.Start)

                  // 自定义模块，推荐商品
                  if (this.customContentBuilder) {
                    this.customContentBuilder();
                  }
                }
                .width('100%')
                .constraintSize({ minHeight: '100%' })
                .margin({ bottom: -28})
                .alignItems(HorizontalAlign.Center)
                .justifyContent(FlexAlign.Start)
                .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
              }
              .layoutWeight(1)
              .scrollBar(BarState.Off)
              .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
            }
            .layoutWeight(1)
            .onRefreshing(() => {
              setTimeout(() => {
                this.vm.init();
                this.vm.isRefreshing = false;
              }, 1000);
            })
            .pullToRefresh(true)
            .pullDownRatio(this.vm.ratio)
            .refreshOffset(64)
            .onStateChange((state: RefreshStatus) => {
              this.vm.onRefreshStateChange(state);
            })
            .onOffsetChange((offset: number) => {
              // 越接近最大距离，下拉跟手系数越小
              this.vm.ratio = 1 - Math.pow(offset / this.vm.maxRefreshingHeight, 3);
            })
            .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
          }
          .width('100%')
          .layoutWeight(1)
          .onClick(() => {
            // 用来清空步进器的焦点
            this.getUIContext().getFocusController().clearFocus();
          })
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])

          // 底部结算面板
          if (this.vm.cartCards.length) {
            CartControlPanel({
              isEdit: this.vm.isEdit,
              isChildRoute: this.isChildRoute,
              cartPrice: this.vm.cartPrice,
              quantity: this.vm.quantity,
              onSelectAll: () => {
                // 计算选择的商品个数
                this.vm.calcQuantity();
                // 计算总价
                this.vm.calcTotalPrice();
              },
              onDelete: () => {
                // 删除
                this.vm.onDeleteProduct();
              },
              onCheckout: () => {
                // 结算
                const selectedGoodList: ProductModel[] = this.vm.onCheckout();
                this.onCheckout && this.onCheckout(selectedGoodList);
              },
            })
          }
        }
      } else {
        // 用户未登录
        this.unauthenticatedBuilder();
      }
    }
    .width('100%')
    .layoutWeight(1)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    .onVisibleAreaChange([0.0, 1.0], (isExpanding: boolean) => {
      if (this.vm.isLogin && isExpanding) {
        this.vm.init();
      }
    })
  }

  @Builder
  unauthenticatedBuilder() {
    Column() {
      CartPageHeader({
        isChildRoute: this.isChildRoute,
        showEdit: false,
        onBack: () => {
          this.onBack && this.onBack();
        },
      })
      Scroll() {
        Column() {
          Image($r('app.media.empty_status_logo'))
            .width(160)
            .height(160)
            .draggable(false)
            .objectFit(ImageFit.Cover)
            .margin({ bottom: 12 })
          Text('登录后可同步购物车中的商品')
            .fontSize(14)
            .fontColor($r('sys.color.mask_secondary'))
            .margin({ bottom: 12 })
          Button() {
            Text('登录')
              .fontSize(14)
              .fontColor(Color.White)
              .fontWeight(600)
          }
          .width(100)
          .height(38)
          .type(ButtonType.Normal)
          .backgroundColor('#FFE64566')
          .borderRadius(21)
          .onClick(() => {
            this.onLogin && this.onLogin();
          })
        }
        .justifyContent(FlexAlign.Center)
        .margin({ bottom: 80 })
      }
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .borderRadius(12)
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Start)
    .backgroundColor(Color.White)
  }

  @Builder
  loadingBuilder() {
    Column() {
      LoadingProgress()
        .width(32).height(32)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  customRefreshComponent() {
    Stack() {
      if (this.vm.refreshStatus === RefreshStatus.Refresh) {
        LoadingProgress()
          .height(32)
      } else if (this.vm.refreshStatus === RefreshStatus.OverDrag) {
        Text('释放可刷新页面')
          .fontColor($r('sys.color.mask_secondary'))
          .fontSize(14)
      } else if (this.vm.refreshStatus === RefreshStatus.Drag) {
        Text('下拉刷新')
          .fontColor($r('sys.color.mask_secondary'))
          .fontSize(14)
      }
    }
    .align(Alignment.Bottom)
    .padding({ top: 16, bottom: 16 })
    .clip(true)
    .constraintSize({ minHeight: 32 })
    .width('100%')
  }

  @Builder
  cartEmptyBuilder() {
    Column() {
      Column() {
        Image($r('app.media.empty_status_logo'))
          .width(200)
          .height(200)
          .borderRadius(100)
          .draggable(false)
          .objectFit(ImageFit.Cover)
          .margin({ bottom: $r('app.float.space_l'), top: $r('app.float.space_l') })
        Text('购物车空空如也，去逛逛吧~')
          .fontSize(12)
          .fontColor($r('app.color.font_color_level2'))
      }
      .backgroundColor($r('app.color.background_color_primary'))
      .borderRadius(16)
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .height('45%')
    .constraintSize({ minHeight: 200 })
    .padding(16)
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)

  }
}