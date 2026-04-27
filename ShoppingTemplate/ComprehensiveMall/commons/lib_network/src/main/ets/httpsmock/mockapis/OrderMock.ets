import { AxiosRequestConfig, HttpStatusCode } from '@ohos/axios';
import AxiosMockAdapter from '@hw-agconnect/axios-mock-adapter';
import { RequestUrlMap } from '../../constants/RequestUrlMap';
import { PriceType, ShippingOption } from '../../types/EnumTypes';
import {
  AddressInfo,
  OrderItem,
  OrderInfo,
  OrderSkuItem,
  OrderExpressInfo,
} from '../../types/OrderTypes';
import {
  OrderCreateReq, OrderReviewReq, OrderUpdateReq, PreOrderInfoReq,
} from '../../types/RequestTypes';
import { BaseResponse } from '../../types/responses/BaseResponse';
import { PreOrderResp, OrderListResp, OrderExpressResp, OrderCreateResp, DefaultPickupStoreResp } from '../../types/responses/OrderResponse';
import { DEFAULT_PICKUP_STORE, mockExpress, MockOrderData } from '../mockdata/MockOrderData';
import { MockProductData } from '../mockdata/MockProductData';
import { MockSeckillData } from '../mockdata/MockSeckillData';

const PICKUP_CODE_CHARS: string = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';

function generateRandomPickupCode(len: number): string {
  let result: string = '';
  for (let i = 0; i < len; i++) {
    const idx = Math.floor(Math.random() * PICKUP_CODE_CHARS.length);
    result += PICKUP_CODE_CHARS.charAt(idx);
  }
  return result;
}

export class OrderMockApis {
  private readonly PAGE_SIZE = 6;
  private _orderList: OrderItem[] = MockOrderData.getOrderList();

  public start(adapter: AxiosMockAdapter) {
    // 获取预支付商品信息
    adapter
      .onGet(RequestUrlMap.ORDER_PRE_INFO)
      .reply((config: AxiosRequestConfig) => {
        const data: PreOrderInfoReq = config.params;
        const skuList: OrderSkuItem[] = [];
        data.items.forEach((item) => {
          const skuItem = MockProductData.PRODUCT_SKU_TABLE.find(
            (sku) => sku.skuCode === item.skuCode,
          );
          if (skuItem) {
            const orderSku: OrderSkuItem = {
              productId: skuItem.productId,
              skuCode: skuItem.skuCode,
              skuDesc: skuItem.skuDesc,
              count: item.count,
              stock: skuItem.stock,
              banner: skuItem.banner,
              title: skuItem.title,
              serviceDesc: skuItem.serviceDesc,
              dashPrice: skuItem.dashPrice ?? skuItem.price,
              price: skuItem.price,
              priceType: skuItem.priceType,
            };
            // 若为秒杀商品 获取秒杀价格
            if (item.priceType === PriceType.SECKILL && item.seckillInfo) {
              const seckillPrice = MockSeckillData.getSeckillPrice(item.seckillInfo.productId);
              orderSku.price = seckillPrice ?? skuItem.price;
              orderSku.slotId = item.seckillInfo.slotId;
            }
            skuList.push(orderSku);
          }
        });
        const totalPriceTemp = skuList.reduce(
          (pre, cur) => pre + cur.price * cur.count * 100,
          0,
        );
        const res: PreOrderResp = {
          code: 0,
          skuList,
          totalPrice: totalPriceTemp / 100,
        };
        return [HttpStatusCode.Ok, res];
      });

    // 获取默认自提地址（门店）
    adapter
      .onGet(RequestUrlMap.ORDER_DEFAULT_PICKUP)
      .reply(() => {
        const res: DefaultPickupStoreResp = {
          code: 0,
          data: DEFAULT_PICKUP_STORE,
        };
        return [HttpStatusCode.Ok, res];
      });

    // 获取订单列表
    adapter
      .onGet(RequestUrlMap.ORDER_LIST)
      .reply((config: AxiosRequestConfig) => {
        const page: number = config.params.curPage;
        const status: number[] = config.params.status;
        const keywords: string | undefined = config.params.keywords;
        const startIndex = (page - 1) * this.PAGE_SIZE;
        const endIndex = startIndex + this.PAGE_SIZE;
        let list = this._orderList.filter((order) =>
        status.includes(order.orderInfo.status),
        );
        if (keywords) {
          list = list.filter((order) => {
            const titles = order.skuInfo.map((sku) => sku.title);
            return titles.some((title) => title.includes(keywords));
          });
        }
        const orders = list.slice(startIndex, endIndex);
        const isFinal = orders.length < this.PAGE_SIZE;
        const total = list.length;
        const res: OrderListResp = {
          code: 0,
          orderList: orders,
          curPage: page,
          total,
          isFinal,
        };
        return [HttpStatusCode.Ok, res];
      });

    // 获取订单详情
    adapter
      .onGet(RequestUrlMap.ORDER_DETAIL)
      .reply((config: AxiosRequestConfig) => {
        const orderId: string = config.params.orderId;
        const order = this._orderList.find(
          (item) => item.orderInfo.orderNo === orderId,
        );
        if (!order) {
          return [
            HttpStatusCode.Ok,
            {
              code: 1,
              msg: '订单不存在',
            },
          ];
        }
        return [
          HttpStatusCode.Ok,
          {
            code: 0,
            detail: order,
          },
        ];
      });

    // 获取订单物流信息
    adapter
      .onGet(RequestUrlMap.ORDER_EXPRESS)
      .reply((config: AxiosRequestConfig) => {
        const orderId = config.params.orderId as string;
        const express = JSON.parse(JSON.stringify(mockExpress)) as OrderExpressInfo;
        express.orderId = orderId;
        const order = this._orderList.find(
          (item) => item.orderInfo.orderNo === orderId,
        );
        if (order?.orderInfo?.addressInfo) {
          express.destination = {
            latitude: order.orderInfo.addressInfo.latitude ?? MockOrderData.DEFAULT_LATITUDE,
            longitude: order.orderInfo.addressInfo.longitude ?? MockOrderData.DEFAULT_LONGITUDE,
          };
          express.getPosition = order.orderInfo.addressInfo.city ?? '';
        }
        const res: OrderExpressResp = {
          code: 0,
          info: express,
        };
        return [HttpStatusCode.Ok, res];
      });

    // 创建订单
    adapter
      .onPost(RequestUrlMap.ORDER_CREATE)
      .reply((config: AxiosRequestConfig) => {
        const data = JSON.parse(config.data ?? '{}') as OrderCreateReq;
        const orderTime = new Date().getTime();
        const orderNo = 'mock_order_' + orderTime;
        const remainingTime = orderTime + 60 * 60 * 1000 * 24;
        const isSelfPickup = data.orderInfo.receivingMethod === ShippingOption.SELF_PICK_UP;
        const storeAddressInfo: AddressInfo = {
          name: DEFAULT_PICKUP_STORE.storeName,
          cellphone: DEFAULT_PICKUP_STORE.cellphone,
          address: DEFAULT_PICKUP_STORE.address,
          latitude: DEFAULT_PICKUP_STORE.latitude,
          longitude: DEFAULT_PICKUP_STORE.longitude,
        };
        const orderInfo: OrderInfo = {
          status: 0,
          orderNo,
          addressInfo: isSelfPickup ? storeAddressInfo : data.orderInfo.addressInfo,
          orderTime,
          remark: data.orderInfo.remark ?? '',
          originalPrice: data.orderInfo.originalPrice,
          finalPrice: data.orderInfo.finalPrice,
          discounts: data.orderInfo.discounts,
          couponId: data.orderInfo.couponId,
          remainingTime,
          receivingMethod: data.orderInfo.receivingMethod,
        };
        if (isSelfPickup) {
          orderInfo.pickupCode = generateRandomPickupCode(6);
          orderInfo.pickupStoreInfo = DEFAULT_PICKUP_STORE
        }
        const orderItem: OrderItem = {
          skuInfo: data.skuList,
          logisticInfo: [],
          orderInfo,
        };
        this._orderList.unshift(orderItem);
        const res: OrderCreateResp = {
          code: 0,
          msg: '创建成功',
          orderNo,
          orderStr: orderNo,
          detail: orderItem,
        };
        return [HttpStatusCode.Ok, res];
      });

    // 更新订单
    adapter
      .onPut(RequestUrlMap.ORDER_UPDATE)
      .reply((config: AxiosRequestConfig) => {
        const orderId: string = config.params.orderId;
        const data: OrderUpdateReq = JSON.parse(config.data ?? '{}');
        const order = this._orderList.find(
          (item) => item.orderInfo.orderNo === orderId,
        );
        const res: BaseResponse = {
          code: 1,
          msg: '订单不存在',
        };
        if (order) {
          if (data.status) {
            order.orderInfo.status = data.status;
          }
          if (data.addressInfo) {
            order.orderInfo.addressInfo = data.addressInfo;
          }
          res.code = 0;
          res.msg = '更新成功';
        }
        return [HttpStatusCode.Ok, res];
      });

    // 删除订单
    adapter
      .onDelete(RequestUrlMap.ORDER_DELETE)
      .reply((config: AxiosRequestConfig) => {
        const orderId: string = config.params.orderId;
        const idx = this._orderList.findIndex(
          (item) => item.orderInfo.orderNo === orderId,
        );
        const res: BaseResponse = {
          code: 1,
          msg: '订单不存在',
        };
        if (idx >= 0) {
          this._orderList.splice(idx, 1);
          res.code = 0;
          res.msg = '删除成功';
        }
        return [HttpStatusCode.Ok, res];
      });

    // 添加订单评论
    adapter
      .onPost(RequestUrlMap.ORDER_ADD_COMMENT)
      .reply((config: AxiosRequestConfig) => {
        const orderId: string = config.params.orderId;
        const data: OrderReviewReq = JSON.parse(config.data ?? '{}');
        const order = this._orderList.find(
          (item) => item.orderInfo.orderNo === orderId,
        );
        const res: BaseResponse = {
          code: 1,
          msg: '订单不存在',
        };
        if (order) {
          if (order.skuInfo.length && data.reviews?.length) {
            order.skuInfo.forEach((item) => {
              const review = data.reviews.find(
                (review) => review.skuCode === item.skuCode,
              );
              item.skuReview = review;
            });
            order.orderInfo.status = 5;
          }
          res.code = 0;
          res.msg = '评论添加成功';
        }
        return [HttpStatusCode.Ok, res];
      });
  }
}
