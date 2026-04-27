import { BreakpointSystem, iData, RouterMap, routerStack, WindowUtil } from 'lib_foundation';
import {
  PreOrderInfoReq,
  PreOrderItem,
  PriceType,
  ProductInfo,
  SeckillStatus,
  ShoppingCartApis,
  UpdateCartReq,
} from 'lib_network';
import { ProductOperationType } from '../commons/Enums';
import { ProductSelector } from './ProductSelector';

@ComponentV2
export struct ProductOperationButton {
  @Param
  productInfo?: ProductInfo = undefined
  @Local
  showSheet: boolean = false
  @Local
  operationType: ProductOperationType = ProductOperationType.ADD_TO_CART

  @Computed
  get isSeckillOngoing() {
    return (this.productInfo &&
    this.productInfo.seckillInfo &&
      this.productInfo.timeSlot?.status === SeckillStatus.ONGOING)
  }

  build() {
    Row() {
      Button('加入购物车')
        .bottomButtonStyle(BreakpointSystem.isTablet)
        .borderColor($r('app.color.background_color_button_grey'))
        .fontColor($r('app.color.theme_color'))
        .backgroundColor($r('app.color.background_color_button_grey'))
        .borderRadius({
          topLeft: $r('sys.float.corner_radius_level10'),
          bottomLeft: $r('sys.float.corner_radius_level10'),
          topRight: 0,
          bottomRight: 0,
        })
        .onClick(() => {
          this.handleButtonClick(ProductOperationType.ADD_TO_CART);
        });

      Button(this.isSeckillOngoing ? '立即秒杀' : '立即购买')
        .bottomButtonStyle(BreakpointSystem.isTablet)
        .borderColor($r('app.color.theme_color'))
        .backgroundColor($r('app.color.theme_color'))
        .borderRadius({
          topLeft: 0,
          bottomLeft: 0,
          topRight: $r('sys.float.corner_radius_level10'),
          bottomRight: $r('sys.float.corner_radius_level10'),
        })
        .onClick(() => {
          this.handleButtonClick(ProductOperationType.PAY_NOW);
        });
    }
    .width($r('app.string.size_percent_full'))
    .justifyContent(FlexAlign.End)
    .bindSheet($$this.showSheet, this.buildProductSelector, {
      title: { title: '商品规格选择' },
      detents: [SheetSize.LARGE],
      preferType: SheetType.CENTER,
      backgroundColor: $r('app.color.background_color_primary'),
      onWillDismiss: (action: DismissSheetAction) => {
        if (action.reason === DismissReason.PRESS_BACK || action.reason === DismissReason.CLOSE_BUTTON) {
          action.dismiss();
        }
      },
    })
  }

  @Builder
  buildProductSelector() {
    ProductSelector({
      operationType: this.operationType,
      productInfo: this.productInfo?.productDetail,
      seckillInfo: this.productInfo?.seckillInfo,
      isSeckillOngoing: this.isSeckillOngoing,
      hasPurchased: this.productInfo?.hasPurchased,
      handleAddCart: this.handleAddCart,
      handlePayNow: this.handlePayNow,
    })
  }

  handleButtonClick(operationType: ProductOperationType) {
    if (!iData.global.isLogin) {
      routerStack.pushPath({ name: RouterMap.USER_LOGIN });
      return;
    }
    if (!this.productInfo) {
      return;
    }
    this.operationType = operationType;
    this.showSheet = true
  }

  handleAddCart = (skuCode: string, count: number) => {
    // 加入购物车
    const param = this._getPreOrderItem(skuCode, count)
    ShoppingCartApis.addSkuToCart(param as UpdateCartReq).then(async () => {
      const res = await ShoppingCartApis.getCartData()
      if (res.code === 0) {
        iData.global.cartVersion = res.data.version;
        iData.global.cartTotal = res.data.total;
        WindowUtil.toast('成功加入购物车');
        this.showSheet = false;
      }
    });
  }
  // 立即购买
  handlePayNow = (skuCode: string, count: number) => {
    const preOrderItem: PreOrderItem = this._getPreOrderItem(skuCode, count)
    const preOrderRequest: PreOrderInfoReq = {
      items: [preOrderItem],
    };
    routerStack.pushPathByName(RouterMap.ORDER_SUBMIT, preOrderRequest);
    this.showSheet = false;
  }

  private _getPreOrderItem(skuCode: string, count: number) {
    const param: PreOrderItem = {
      skuCode,
      count,
      priceType: this.isSeckillOngoing ? PriceType.SECKILL : PriceType.NORMAL,
    }
    // 若正在秒杀中，则传入秒杀信息
    if (this.isSeckillOngoing) {
      param.seckillInfo = {
        slotId: this.productInfo!.seckillInfo!.slotId,
        productId: this.productInfo!.productDetail.productId,
        seckillPrice: this.productInfo!.seckillInfo!.seckillPrice,
      }
    }
    return param
  }
}


@Extend(Button)
function bottomButtonStyle(isTablet: boolean = false) {
  .fontSize($r('sys.float.Body_M'))
  .borderWidth(1)
  .width(isTablet ? 200 : 'auto')
  .height(40)
  .type(ButtonType.Normal);
}