import { util } from '@kit.ArkTS';
import { PersistenceV2 } from '@kit.ArkUI';
import { AxiosRequestConfig, HttpStatusCode } from '@ohos/axios';
import AxiosMockAdapter from '@hw-agconnect/axios-mock-adapter';
import { RequestUrlMap } from '../../constants/RequestUrlMap';
import { PriceType } from '../../types/EnumTypes';
import { CartProductInfo, DiscountItem, CartPrice, CartSkuItem, CartDto } from '../../types/ProductTypes';
import { UpdateCartReq, DeleteCartReq, CalcCartPriceReq } from '../../types/RequestTypes';
import { CartDataResp, CartListResp, CartPriceResp, CartUpdateResp } from '../../types/responses/CartResponse';
import { MockProductData } from '../mockdata/MockProductData';

@ObservedV2
export class MockCart {
  @Trace data: string = '';
}

@ObservedV2
export class ShoppingCartMockApis {
  private readonly SUCCESS_CODE = 0;
  private readonly SUCCESS_MSG = 'success';

  public start(adapter: AxiosMockAdapter) {
    adapter.onGet(RequestUrlMap.CART_INFO).reply(() => {
      let data = this._getCartData();
      const response: CartDataResp = { code: this.SUCCESS_CODE,
msg: this.SUCCESS_MSG,
data: data };
      return [HttpStatusCode.Ok, response];
    });
    // 获取购物车列表
    adapter
      .onGet(RequestUrlMap.CART_LIST)
      .reply(() => {
        let mockCart: MockCart = this._getMockCart();
        let resList: CartProductInfo[] = [];
        if (mockCart.data) {
          const resData = JSON.parse(mockCart.data) as CartDto;
          resList = resData.cards.map((item: CartSkuItem) => {
            // 显式映射
            return {
              productId: item.productId,
              skuCode: item.skuCode,
              skuDesc: item.skuDesc,
              stock: 10,
              count: item.count,
              banner: item.banner,
              title: item.title,
              serviceDesc: item.serviceDesc,
              price: item.price,
              dashPrice: item.dashPrice,
              priceType: item.priceType,
              slotId: item.slotId,
            } as CartProductInfo;
          });
        }
        const response: CartListResp = { code: this.SUCCESS_CODE,
msg: this.SUCCESS_MSG,
data: resList };
        return [HttpStatusCode.Ok, response];
      });
    // 新增购物车商品 (核心逻辑修改)
    adapter
      .onPost(RequestUrlMap.CART_PRODUCT)
      .reply((config: AxiosRequestConfig) => {
        const data = JSON.parse(config.data) as UpdateCartReq;
        const cartData = this._getCartData();

        // 1. 使用 skuCode AND priceType 联合查找
        const existingCard = cartData.cards.find(
          (item) => item.skuCode === data.skuCode && item.priceType === data.priceType,
        );
        if (existingCard) {
          // 2. 如果存在，叠加数量
          existingCard.count = Math.min(existingCard.stock, existingCard.count + data.count);
        } else {
          // 3. 如果不存在，查找商品库信息
          const skuItem = MockProductData.PRODUCT_SKU_TABLE.find(
            (sku) => sku.skuCode === data.skuCode,
          );

          if (skuItem) {
            // 4. 计算入车价格
            let finalPrice = skuItem.price;
            if (data.priceType === PriceType.SECKILL && data.seckillInfo) {
              finalPrice = data.seckillInfo.seckillPrice;
            }
            const cartItem: CartSkuItem = {
              productId: data.seckillInfo?.productId ?? skuItem.productId,
              skuCode: skuItem.skuCode,
              skuDesc: skuItem.skuDesc,
              stock: skuItem.stock,
              count: data.count,
              banner: skuItem.banner,
              title: skuItem.title,
              serviceDesc: skuItem.serviceDesc,
              price: finalPrice, // 使用计算后的价格
              dashPrice: skuItem.dashPrice, // 划线价始终展示原价
              isSelected: false,
              priceType: data.priceType,
              slotId: data.seckillInfo?.slotId,
            };
            cartData.cards.unshift(cartItem);
          }
        }

        cartData.version = util.generateRandomUUID(false);
        cartData.total = cartData.cards.length;
        this._setCartData(cartData);

        const response: CartUpdateResp = { code: this.SUCCESS_CODE,
msg: this.SUCCESS_MSG,
data: 0 };
        return [HttpStatusCode.Ok, response];
      });
    // 更新购物车商品数量
    adapter
      .onPut(RequestUrlMap.CART_PRODUCT)
      .reply((config: AxiosRequestConfig) => {
        const data = JSON.parse(config.data) as UpdateCartReq;
        let mockCartData = this._getCartData();

        // 联合查找
        const targetItem = mockCartData.cards.find(
          (item) => item.skuCode === data.skuCode && item.priceType === data.priceType,
        );
        if (targetItem) {
          targetItem.count = Number(data.count);
        }
        mockCartData.version = util.generateRandomUUID(false);
        this._setCartData(mockCartData);

        const response: CartUpdateResp = { code: this.SUCCESS_CODE,
msg: this.SUCCESS_MSG,
data: 0 };
        return [HttpStatusCode.Ok, response];
      });
    // 删除购物车商品
    adapter
      .onDelete(RequestUrlMap.CART_PRODUCT)
      .reply((config: AxiosRequestConfig) => {
        const data = JSON.parse(config.data) as DeleteCartReq;
        let mockCartData = this._getCartData();

        let remainList: CartSkuItem[] = mockCartData.cards.filter((item: CartSkuItem) => {
          // 判断当前项是否在删除列表中 (需同时匹配 skuCode 和 priceType)
          const isMatch = data.skuList.some(
            (delItem) => delItem.skuCode === item.skuCode && delItem.priceType === item.priceType,
          );
          return data.isRemain ? isMatch : !isMatch;
        });
        let cacheData: CartDto = {
          version: util.generateRandomUUID(false),
          total: remainList.length,
          cards: remainList,
        };

        this._setCartData(cacheData);
        const response: CartUpdateResp = { code: this.SUCCESS_CODE,
msg: this.SUCCESS_MSG,
data: 0 };
        return [HttpStatusCode.Ok, response];
      });
    // 计算购物车金额
    adapter
      .onGet(RequestUrlMap.CART_PRICE)
      .reply((config: AxiosRequestConfig) => {
        const data = config.params as CalcCartPriceReq;

        // 计算原价 (所有商品都按划线价/正价计算)
        const originalPrice = data.skuList.reduce((sum, item) => {
          // 注意：item.price 已经是根据类型存入的价格了，但 originalPrice 通常指未打折前的市场价
          // 这里逻辑：如果 item 有 dashPrice，用 dashPrice，否则用 item.price
          const marketPrice = item.dashPrice > 0 ? item.dashPrice : item.price;
          return sum + marketPrice * 100 * item.count;
        }, 0);

        // 计算现价 (购物车中实际存储的价格，秒杀商品这里已经是秒杀价了)
        let currentPriceTotal = data.skuList.reduce((sum, item) => {
          return sum + item.price * 100 * item.count;
        }, 0);
        // 基础优惠 = 市场价 - 现价
        const basicDiscount = originalPrice - currentPriceTotal;
        // 会员折扣 (假设只对正价商品生效，秒杀商品不参与会员折上折)
        // 需遍历列表单独计算
        let memberDiscountAmount = 0;
        if (data.isMember) {
          memberDiscountAmount = data.skuList.reduce((sum, item) => {
            // 只有 PriceType.NORMAL 参与会员折扣
            if (item.priceType === PriceType.NORMAL) {
              return sum + (item.price * 100 * item.count * 0.1); // 9折
            }
            return sum;
          }, 0);
        }
        const discountList: DiscountItem[] = [
          { type: 0,
label: '活动优惠',
discountPrice: this._getPriceNum(basicDiscount) },
          { type: 1,
label: '会员折扣',
discountPrice: this._getPriceNum(memberDiscountAmount) },
        ];
        // ... extraDiscount 逻辑保持不变 ...
        if (data.extraDiscount?.length) {
          discountList.push(...data.extraDiscount);
          currentPriceTotal -= data.extraDiscount.reduce((sum, item) => sum + item.discountPrice * 100, 0);
        }
        const finalPrice = currentPriceTotal - memberDiscountAmount;
        const cartPrice: CartPrice = {
          finalPrice: this._getPriceNum(Math.max(0, finalPrice)),
          originalPrice: this._getPriceNum(originalPrice),
          discountList: discountList.filter(d => d.discountPrice > 0),
        };

        const response: CartPriceResp = { code: this.SUCCESS_CODE,
msg: this.SUCCESS_MSG,
data: cartPrice };
        return [HttpStatusCode.Ok, response];
      });
  }

  private _getCartData() {
    let mockCart: MockCart = this._getMockCart();
    if (!mockCart.data) {
      return {
        version: 'mock_cart_version_empty',
        total: 0,
        cards: [],
      } as CartDto;
    } else {
      return JSON.parse(mockCart.data) as CartDto;
    }
  }

  private _setCartData(data: CartDto) {
    let mockCart: MockCart = this._getMockCart();
    mockCart.data = JSON.stringify(data);
  }

  private _getMockCart() {
    return PersistenceV2.connect(
      MockCart,
      'MockCart',
      () => new MockCart(),
    )!;
  }

  private _getPriceNum(num: number) {
    return Number((num / 100).toFixed(2));
  }
}
