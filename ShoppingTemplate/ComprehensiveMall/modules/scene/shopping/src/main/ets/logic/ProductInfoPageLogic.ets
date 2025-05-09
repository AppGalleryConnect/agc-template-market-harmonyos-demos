import { client } from '@common/network';
import { CartDto, LoadingStatus,
  PreOrderItem,
  PreOrderRequest } from '@common/customtypes';
import { ProductInfo } from '@common/customtypes';

import { promptAction } from '@kit.ArkUI';

import { SkuSelectorLogic } from './SkuSelectorLogic';
import { iData } from '@common/data';
import { router } from '@common/router';

@ObservedV2
export class ProductInfoPageLogic {

  @Trace
  public loadingStatus: LoadingStatus = LoadingStatus.LOADING;

  @Trace
  public info: ProductInfo = {
    id: '',
    banners: [],
    price: '',
    dashPrice: '',
    sales: '',
    title: '',
    tags: [],
    logistics: [],
    service: [],
    pictures: [],
    selectionInfo: {
      defaultBanner: '',
      priceRange: '',
      basicPrice: '',
      priceRemark: '',
      totalPriceRemark: '',
      services: [],
      skuItems: [],
      specOptions: [],
      specOptionWithImage: null
    }
  };

  @Trace
  public skuSelectorLogic: SkuSelectorLogic = new SkuSelectorLogic(this.info.selectionInfo);

  @Trace
  public selectIndex: number = 0;

  @Trace
  public isPaymentBtnActive: boolean = false;

  @Trace
  public isAddCartBtnActive: boolean = false;

  public readonly onAnimationStart = (_: number, target: number): void => {
    this.selectIndex = target;
  }

  public readonly onPaymentBtnClick = (): void => {
    if (!this.isAddCartBtnActive) {
      this.isPaymentBtnActive = true;
    }
  }

  public readonly onAddCartBtnClick = (): void => {
    if (!this.isPaymentBtnActive) {
      this.isAddCartBtnActive = true;
    }
  }

  public load = async (productId: string): Promise<void> => {
    try {
      const info: ProductInfo = await client.product.getInfo(productId);
      if (info) {
        this.info = info;
        this.loadingStatus = LoadingStatus.SUCCESS;
        this.initSkuSelector();
      } else {
        throw new Error();
      }
    } catch (e) {
      this.loadingStatus = LoadingStatus.FAIL;
    }
  }

  private initSkuSelector = (): void => {
    if (this.info) {
      this.skuSelectorLogic = new SkuSelectorLogic(this.info.selectionInfo);
      this.skuSelectorLogic.onBackCallback = () => {
        this.isPaymentBtnActive = false;
        this.isAddCartBtnActive = false;
      };
      this.skuSelectorLogic.onAgreeCallback = (skuCode: string, count: number) => {
        if (this.isPaymentBtnActive) {
          this.isPaymentBtnActive = false;
          const preOrderItem: PreOrderItem = {
            skuCode: skuCode,
            quantity: count
          };
          const preOrderRequest: PreOrderRequest = {
            items: [preOrderItem],
            removeFromCart: false
          };
          router.pushPathByName('OrderSubmitPage', preOrderRequest);
        } else if (this.isAddCartBtnActive) {
          this.isAddCartBtnActive = false;
          client.cart.addSkuToCart(skuCode, count).then((cartDto: CartDto) => {
            iData.global.cartVersion = cartDto.version;
            iData.global.cartTotal = cartDto.total;
            promptAction.showToast({ message: '成功加入购物车' });
          });
        }
      };
    }
  }

}
