import { AxiosInstance, HttpStatusCode, AxiosRequestConfig } from '@ohos/axios';

import {
  Any,
  ApiResponse,
  OrderCardDto,
  OrderInfo,
  OrderSkuDto,
  PreOrderInfoDto,
  PreOrderRequest,
} from '@common/customtypes';
import { iResourceMgr } from '@common/resource';

import { MathUtil } from './utils/MathUtil';
import { AxiosMock, MockResponse } from './utils/MockUtil';
import { MockDataMgr } from './mock/MockDataMgr';
import { MockDatabase } from './mock/MockDatabase';
import util from '@ohos.util';

export class MockServer {
  private mock: AxiosMock;

  public start(): void {
    /**
     * 搜索词轮播数据
     *
     * Delay: 100 ~ 200ms
     * Controller: 随机选择一个相关 json 返回
     */
    this.mock.onGet('/api/v1/search/suggestions').reply(() => {
      const index: number = MathUtil.generateInt32InRange(0, 3);
      const file: string = `dev/database/search/suggestions-${index}.json`;
      return this.mockResponse(file, [100, 200]);
    });
    /**
     * 搜索内容联想数据
     *
     * Delay: 0 ~ 100ms
     * Controller: 根据用户当前输入字数索引对应数据, 模拟服务端实时根据用户输入变化来联想候选词
     */
    this.mock.onPost('/api/v1/search/candidate').reply(
      (config: AxiosRequestConfig): Promise<MockResponse> => {
        const key: string = JSON.parse(config.data).key;
        let index: number = key.length % 3;
        if (key.length > 6) {
          index = 3;
        }
        return this.mockResponse(`dev/database/search/candidate-${index}.json`, [0, 100]);
      },
    );
    /**
     * 首页核心数据
     *
     * Delay: 300 ~ 1500ms
     * Controller: 20% 的概率获取失败, 模拟网络异常
     */
    this.mock.onGet('/api/v1/homepage/home').reply(
      (_: AxiosRequestConfig): Promise<MockResponse> => {
        // const target: number = MathUtil.generateInt32InRange(0, 100);
        // if (target < 0) {
        //   return this.mockSimpleResponse(1500, HttpStatusCode.RequestTimeout);
        // }
        return this.mockResponse('dev/database/homepage/home.json', [0, 100]);
      },
    );
    /**
     * 卡片列表数据
     *
     * Delay: 200 ~ 800ms
     * Controller: 随机选择相关 json, 模拟推荐算法
     */
    this.mock.onPost('/api/v1/cardlist/guesslike').reply(
      (config: AxiosRequestConfig): Promise<MockResponse> => {
        const index: number = JSON.parse(config.data).index;
        if (index >= 2) {
          return this.mockResponse('dev/database/cardlist/guesslike-final.json', [200, 800]);
        }
        return this.mockResponse('dev/database/cardlist/guesslike.json', [200, 800]);
      },
    );
    /**
     * 商品详情数据
     *
     * Delay: 200 ~ 500ms
     * Controller: 根据 id 选择 json
     */
    this.mock.onPost('/api/v1/product/info').reply(
      (config: AxiosRequestConfig): Promise<MockResponse> => {
        const id: string = JSON.parse(config.data).id;
        return this.mockResponse('dev/database/product/' + id + '.json', [200, 500]);
      },
    );
    /**
     * 模拟登录
     *
     * Delay: 200 ~ 500ms
     * Controller: 返回默认 json
     */
    this.mock.onPost('/api/v1/user/login').reply(
      (_: AxiosRequestConfig): Promise<MockResponse> => {
        return this.mockResponse('dev/database/user/user.json', [200, 500]);
      },
    );
    /**
     * 购物车数据
     *
     */
    this.mock.onPost('/api/v1/cart').reply(
      (_: AxiosRequestConfig): Promise<MockResponse> => {
        let obj = MockDataMgr.getCartData();
        obj.version = util.generateRandomUUID(false);
        return this.mockResponseByObj(obj, [200, 500]);
      },
    );
    /**
     * 添加商品到购物车
     *
     */
    this.mock.onPost('/api/v1/cart/add').reply(
      (config: AxiosRequestConfig): Promise<MockResponse> => {
        const skuCode: string = JSON.parse(config.data).skuCode;
        const count: number = JSON.parse(config.data).count;
        let data = MockDataMgr.getCartData();
        let needAdd: boolean = true;
        for (let cartCard of data.cards) {
          if (cartCard.skuCode === skuCode) {
            cartCard.count = Math.min(cartCard.stock, cartCard.count + count);
            needAdd = false;
            break;
          }
        }
        if (needAdd) {
          for (let sku of MockDatabase.PRODUCT_TABLE) {
            if (sku.skuCode === skuCode) {
              data.cards.push({
                productId: sku.productId,
                skuCode: sku.skuCode,
                skuDesc: sku.skuDesc,
                stock: sku.stock,
                count: Math.min(sku.stock, count),
                banner: sku.banner,
                title: sku.title,
                serviceDesc: sku.serviceDesc,
                price: sku.price,
                isSelected: false,
              });
            }
          }
        }
        data.total = data.cards.length;
        data.version = util.generateRandomUUID(false);
        MockDataMgr.setCartData(data);
        return this.mockResponseByObj(data, [200, 500]);
      },
    );
    /**
     * 修改购物车中商品数量
     *
     */
    this.mock.onPost('/api/v1/cart/count').reply(
      (config: AxiosRequestConfig): Promise<MockResponse> => {
        const skuCode: string = JSON.parse(config.data).skuCode;
        const count: number = JSON.parse(config.data).count;
        let data = MockDataMgr.getCartData();
        for (let cartCard of data.cards) {
          if (cartCard.skuCode === skuCode) {
            cartCard.count = Math.min(cartCard.stock, count);
            break;
          }
        }
        data.total = data.cards.length;
        data.version = util.generateRandomUUID(false);
        MockDataMgr.setCartData(data);
        return this.mockResponseByObj(null, [0, 0]);
      },
    );
    /**
     * 从购物车删除商品
     *
     */
    this.mock.onPost('/api/v1/cart/delete').reply(
      (config: AxiosRequestConfig): Promise<MockResponse> => {
        const skuCodes: string[] = JSON.parse(config.data).skuCodes;
        let data = MockDataMgr.getCartData();
        data.cards = data.cards.filter(card => !skuCodes.includes(card.skuCode));
        data.total = data.cards.length;
        data.version = util.generateRandomUUID(false);
        MockDataMgr.setCartData(data);
        return this.mockResponseByObj(data, [50, 300]);
      },
    );
    /**
     * 请求预下单数据
     *
     */
    this.mock.onPost('/api/v1/order/preorder').reply(
      (config: AxiosRequestConfig): Promise<MockResponse> => {
        const req: PreOrderRequest = JSON.parse(config.data).preOrderRequest;
        let totalPrice: number = 0;
        let skuList: OrderSkuDto[] = [];
        for (let item of req.items) {
          for (let product of MockDatabase.PRODUCT_TABLE) {
            if (item.skuCode === product.skuCode) {
              let sku: OrderSkuDto = {
                skuCode: product.skuCode,
                skuDesc: product.skuDesc,
                count: item.quantity,
                banner: product.banner,
                title: product.title,
                serviceDesc: product.serviceDesc,
                price: product.price,
              };
              skuList.push(sku);
              totalPrice = totalPrice + product.price * item.quantity;
              break;
            }
          }
        }
        let info: PreOrderInfoDto = {
          skuList: skuList,
          totalPrice: totalPrice,
          addressDesc: '南京市雨花台区雨花客厅XX栋0000',
          nickname: '李华',
          phone: '00000000000',
        };

        return this.mockResponseByObj(info, [300, 700]);
      },
    );
    /**
     * 订单列表
     *
     */
    this.mock.onPost('/api/v1/order/list').reply(
      (config: AxiosRequestConfig): Promise<MockResponse> => {
        const type: number = JSON.parse(config.data).type;
        const list: OrderCardDto[] = [];
        for (let card of MockDataMgr.getOrderListData()) {
          if (type === 0) {
            list.push(card);
          } else if (type === card.type) {
            list.push(card);
          }
        }
        return this.mockResponseByObj(list, [300, 700]);
      }
    );
    this.mock.onPost('/api/v1/order/delete').reply(
      (config: AxiosRequestConfig): Promise<MockResponse> => {
        const code: string = JSON.parse(config.data).code;
        const mock: OrderCardDto[] = MockDataMgr.getOrderListData();
        const list: OrderCardDto[] = [];
        for (let card of mock) {
          if (card.orderCode !== code) {
            list.push(card);
          }
        }
        MockDataMgr.setOrderListData(list);
        return this.mockResponseByObj(list, [100, 300]);
      }
    );
    this.mock.onPost('/api/v1/order/refund').reply(
      (config: AxiosRequestConfig): Promise<MockResponse> => {
        const code: string = JSON.parse(config.data).code;
        const mock: OrderCardDto[] = MockDataMgr.getOrderListData();
        const list: OrderCardDto[] = [];
        for (let card of mock) {
          if (card.orderCode === code) {
            card.type = 4;
            card.statusDesc = '商家处理中';
          }
          list.push(card);
        }
        MockDataMgr.setOrderListData(list);
        return this.mockResponseByObj(list, [100, 300]);
      }
    );
    this.mock.onPost('/api/v1/order/agree').reply(
      (config: AxiosRequestConfig): Promise<MockResponse> => {
        const code: string = JSON.parse(config.data).code;
        const mock: OrderCardDto[] = MockDataMgr.getOrderListData();
        const list: OrderCardDto[] = [];
        for (let card of mock) {
          if (card.orderCode === code) {
            card.type = 0;
            card.statusDesc = '已完成';
          }
          list.push(card);
        }
        MockDataMgr.setOrderListData(list);
        return this.mockResponseByObj(list, [100, 300]);
      }
    );
    /**
     * 分类列表数据
     *
     */
    this.mock.onGet('/api/v1/cardlist/category/list').reply(
      (_: AxiosRequestConfig): Promise<MockResponse> => {
        return this.mockResponse('dev/database/cardlist/category-list.json', [0, 100]);
      }
    );
    /**
     * 卡片列表数据
     *
     */
    this.mock.onPost('/api/v1/cardlist/category/cards').reply(
      (config: AxiosRequestConfig): Promise<MockResponse> => {
        const index: number = JSON.parse(config.data).index;
        if (index >= 2) {
          return this.mockResponse('dev/database/cardlist/guesslike-final.json', [200, 800]);
        }
        return this.mockResponse('dev/database/cardlist/guesslike.json', [200, 800]);
      }
    );
    /**
     * 拦截其它任何可能的请求并响应 400 错误码
     */
    this.mock.onAny().reply(() => Promise.resolve<MockResponse>({
      status: HttpStatusCode.BadRequest,
    }));
  }

  private mockSimpleResponse(delay: number, status: number = HttpStatusCode.Ok): Promise<MockResponse> {
    return new Promise((resolve) => {
      setTimeout(() => resolve({ status: status }), delay);
    });
  }

  private mockResponse(jsonPath: string, range: [number, number]): Promise<MockResponse> {
    return new Promise((resolve) => {
      const delay: number = MathUtil.generateInt32InRange(range[0], range[1] + 1);
      setTimeout(() => {
        resolve({
          status: HttpStatusCode.Ok,
          data: this.getMockDataByJson(jsonPath),
        });
      }, delay);
    });
  }

  private mockResponseByObj(obj: Any, range: [number, number]): Promise<MockResponse> {
    const res: ApiResponse<Any> = {
      code: 0,
      message: '',
      data: obj,
    };
    return new Promise((resolve) => {
      const delay: number = MathUtil.generateInt32InRange(range[0], range[1] + 1);
      setTimeout(() => {
        resolve({
          status: HttpStatusCode.Ok,
          data: res,
        });
      }, delay);
    });
  }

  private getMockDataByJson(path: string): Any {
    try {
      return JSON.parse(iResourceMgr.readResourceAsString(path));
    } catch (e) {
      return JSON.parse(`{"code":-1,"message":"Mock_JsonParser:${e.message || 'Unknown error'}","data":{}}`);
    }
  }

  constructor(axiosInstance: AxiosInstance) {
    this.mock = new AxiosMock(axiosInstance);
  }
}
