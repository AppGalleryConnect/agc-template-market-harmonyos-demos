import { PersistenceV2, Type } from '@kit.ArkUI';
import { AxiosRequestConfig, HttpStatusCode } from '@ohos/axios';
import { iData } from 'lib_foundation';
import AxiosMockAdapter from '@hw-agconnect/axios-mock-adapter';
import { RequestUrlMap } from '../../constants/RequestUrlMap';
import { SkuReview } from '../../types/OrderTypes';
import {
  BaseID,
  ProductCardItem,
  ProductInfo,
  ProductReviewItem,
  SeckillProductInfo,
  SeckillTimeSlot,
} from '../../types/ProductTypes';
import { ProductDetailReq, ProductListReq } from '../../types/RequestTypes';
import { BaseResponse } from '../../types/responses/BaseResponse';
import {
  ProductCollectStatusResp,
  ProductListResp,
  ProductDetailResp,
  ProductReviewResp,
  ProductStockResp,
} from '../../types/responses/ProductResponse';
import { MockOrderData } from '../mockdata/MockOrderData';
import { MockProductData } from '../mockdata/MockProductData';
import { MockSeckillData } from '../mockdata/MockSeckillData';

// ==================== 持久化数据类 ====================

class BaseIDModel implements BaseID{
  productId: string = '';
  slotId?: string;
}

@ObservedV2
class CollectedProduct {
  @Type(BaseIDModel)
  @Trace list: BaseIDModel[] = [];
}

@ObservedV2
class ViewHistoryProduct {
  @Type(BaseIDModel)
  @Trace list: BaseIDModel[] = [];
}

const enum MockPersistenceMap {
  COLLECTION = 'collection',
  VIEW_HISTORY = 'viewHistory',
}

// ==================== Mock API 类 ====================

export class ProductMockApis {
  private readonly PAGE_SIZE = 8;
  private readonly REVIEW_PAGE_SIZE = 10;
  private _mockList: ProductCardItem[] = JSON.parse(
    JSON.stringify(MockProductData.PRODUCT_CARD_LIST),
  );

  public start(adapter: AxiosMockAdapter) {
    this._setupProductListApi(adapter);
    this._setupProductDetailApi(adapter);
    this._setupProductReviewApi(adapter);
    this._setupCollectionApi(adapter);
    this._setupViewHistoryApi(adapter);
  }

  // ==================== 商品列表相关 API ====================

  /**
   * 设置商品列表相关API
   */
  private _setupProductListApi(adapter: AxiosMockAdapter) {
    /** 获取商品列表 */
    adapter
      .onGet(RequestUrlMap.PRODUCT_LIST)
      .reply((config: AxiosRequestConfig) => {
        const params = config.params as ProductListReq;
        const slotId = params.slotId; // 获取 slotId 参数

        let targetList = this._mockList;
        // 如果存在 slotId，说明是请求秒杀会场的商品列表
        if (slotId) {
          // 1. 获取该场次的所有秒杀商品信息（包含秒杀价）
          const seckillProducts = MockSeckillData.getProductsBySlotId(slotId);
          const tempSeckillList: ProductCardItem[] = [];
          // 2. 遍历并组装商品卡片数据
          // 使用 forEach + push 替代 map + filter，避免处理 null 和 is 类型断言
          seckillProducts.forEach((sp) => {
            // 获取原始商品卡片信息（图片、标题等）
            const originalCard = MockProductData.getProductCardById(sp.productId);

            if (originalCard) {
              const newItem: ProductCardItem = {
                productId: originalCard.productId,
                title: originalCard.title,
                banner: originalCard.banner,
                // 【关键逻辑】列表展示秒杀价
                price: sp.seckillPrice,
                // 【关键逻辑】划线价展示原价
                dashPrice: originalCard.price,
                categoryId: sp.categoryId,
                promotion: originalCard.promotion,
                label: originalCard.label,
                summary: originalCard.summary,
                sales: originalCard.sales,
              };
              tempSeckillList.push(newItem);
            }
          });

          targetList = tempSeckillList;
        }
        // 3. 复用原有的过滤、排序和分页逻辑
        const res = this._getFilteredList(targetList, config.params);
        return [HttpStatusCode.Ok, res];
      });
  }

  /**
   * 设置商品详情相关API
   */
  private _setupProductDetailApi(adapter: AxiosMockAdapter) {
    /** 获取商品详情（包含秒杀信息） */
    adapter
      .onGet(RequestUrlMap.PRODUCT_DETAIL)
      .reply((config: AxiosRequestConfig) => {
        const params: ProductDetailReq = config.params;
        const productId = params.productId;

        // 获取商品详情
        const productDetail = MockProductData.getProductDetailById(productId);

        if (!productDetail) {
          const errorRes: BaseResponse = {
            code: 404,
            msg: '商品不存在',
          };
          return [HttpStatusCode.NotFound, errorRes];
        }

        // 检查是否在秒杀中
        const slotId = params.slotId;
        let seckillInfo: SeckillProductInfo | undefined = undefined;
        let timeSlot: SeckillTimeSlot | undefined = undefined;
        if (slotId) {
          const seckillProducts = MockSeckillData.getProductsBySlotId(slotId);
          const seckillProduct = seckillProducts.find(p => p.productId === productId);

          if (seckillProduct) {
            seckillInfo = {
              seckillId: seckillProduct.seckillId,
              slotId: seckillProduct.slotId,
              categoryId: seckillProduct.categoryId,
              seckillPrice: seckillProduct.seckillPrice,
              productId: productDetail.productId,
              title: productDetail.title,
              banner: productDetail.banner,
              price: productDetail.price,
              dashPrice: productDetail.dashPrice,
              totalStock: seckillProduct.totalStock,
              remainStock: seckillProduct.remainStock,
            } as SeckillProductInfo;
          }
          timeSlot = MockSeckillData.getSlotBySlotId(slotId);
        }

        // 校验用户是否已购买
        // 注意：MockOrderData.getOrderList() 是 MockOrderData 的方法，
        // 如果之前没有定义 getOrderList，可能需要用 MockSeckillData.checkUserHasPurchased 替代
        // 这里沿用你提供的现有逻辑，或结合之前的 MockSeckillData 修改
        const existOrder = MockOrderData.getOrderList().find(order => {
          // 匹配用户、商品、场次
          const isMatch = order.skuInfo.some((sku) => sku.productId === productId &&
            sku.slotId === slotId);
          const validStatus: number[] = [0, 2, 3, 4, 5, 6]; // 假设状态码
          const isValidStatus = validStatus.includes(order.orderInfo.status);

          return isMatch && isValidStatus;
        });

        const productInfo: ProductInfo = {
          productDetail,
          seckillInfo,
          timeSlot,
          hasPurchased: !!existOrder,
        };

        const res: ProductDetailResp = {
          code: 0,
          data: productInfo,
        };
        return [HttpStatusCode.Ok, res];
      });

    /** 获取商品库存信息 */
    adapter
      .onGet(RequestUrlMap.PRODUCT_STOCK)
      .reply((config: AxiosRequestConfig) => {
        const productId: string = config.params.id;
        const productDetail = MockProductData.getProductDetailById(productId);

        if (!productDetail) {
          const errorRes: BaseResponse = {
            code: 404,
            msg: '商品不存在',
          };
          return [HttpStatusCode.NotFound, errorRes];
        }

        const res: ProductStockResp = {
          code: 0,
          data: productDetail.selectionInfo,
        };
        return [HttpStatusCode.Ok, res];
      });
  }

  /**
   * 设置商品评价相关API
   */
  private _setupProductReviewApi(adapter: AxiosMockAdapter) {
    /** 获取商品评价列表 */
    adapter
      .onGet(RequestUrlMap.PRODUCT_REVIEW)
      .reply((config: AxiosRequestConfig) => {
        const productId: string = config.params.id;
        const curPage: number = config.params.curPage || 1;

        const allReviews = MockProductData.getProductReviewListMock(productId);
        const startIndex = (curPage - 1) * this.REVIEW_PAGE_SIZE;
        const endIndex = startIndex + this.REVIEW_PAGE_SIZE;
        const list = allReviews.slice(startIndex, endIndex);
        const isFinal = list.length < this.REVIEW_PAGE_SIZE || endIndex >= allReviews.length;

        const res: ProductReviewResp = {
          code: 0,
          list,
          curPage,
          isFinal,
          total: allReviews.length,
          avgRating: this._calculateAvgRating(allReviews),
        };
        return [HttpStatusCode.Ok, res];
      });

    /** 创建商品评价 */
    adapter
      .onPost(RequestUrlMap.PRODUCT_REVIEW)
      .reply((config: AxiosRequestConfig) => {
        const data = JSON.parse(config.data ?? '[]') as SkuReview[];
        const userData = iData.global.userInfo;
        const name = userData.nickname.slice(0, 2) + '**';
        const reviewList: ProductReviewItem[] = data.map((review) => {
          return {
            productId: review.productId,
            userAvatar: userData.avatar,
            userName: name,
            skuCode: review.skuCode,
            skuDesc: [review.skuDesc],
            rating: review.rating,
            date: review.date,
            content: review.content ? review.content : '该用户觉得商品非常好，给出好评',
            mediaList: review.mediaList,
          } as ProductReviewItem;
        });
        MockProductData.setProductReviewListMock(reviewList);
        const res: BaseResponse = {
          code: 0,
        };
        return [HttpStatusCode.Ok, res];
      });
  }

  /**
   * 设置收藏相关API
   */
  private _setupCollectionApi(adapter: AxiosMockAdapter) {
    /** 收藏商品 */
    adapter
      .onGet(RequestUrlMap.PRODUCT_COLLECT)
      .reply((config: AxiosRequestConfig) => {
        const baseId: BaseID = config.params;
        const collectedList = this._getCollectionList();

        if (!collectedList.list.find((item)=>item.productId === baseId.productId)) {
          collectedList.list.unshift(baseId as BaseIDModel);
        }

        const res: BaseResponse = {
          code: 0,
          msg: '收藏成功',
        };
        return [HttpStatusCode.Ok, res];
      });

    /** 取消收藏商品 */
    adapter
      .onDelete(RequestUrlMap.PRODUCT_COLLECT)
      .reply((config: AxiosRequestConfig) => {
        const productIds: string = config.params.productIds;
        const collectedList = this._getCollectionList();

        collectedList.list = collectedList.list.filter(
          (item) => !productIds.includes(item.productId),
        );

        const res: BaseResponse = {
          code: 0,
          msg: '取消收藏成功',
        };
        return [HttpStatusCode.Ok, res];
      });

    /** 获取收藏商品列表 */
    adapter
      .onGet(RequestUrlMap.PRODUCT_COLLECTED_LIST)
      .reply((config: AxiosRequestConfig) => {
        const collectedList = this._getCollectionList();
        const initList: ProductCardItem[] = [];

        collectedList.list.forEach((item) => {
          const productItem = MockProductData.PRODUCT_CARD_LIST.find(
            (product) => product.productId === item.productId,
          );
          if (productItem) {
            productItem.slotId = MockSeckillData.getSlotIdByProductId(productItem.productId);
            initList.push(productItem);
          }
        });

        const res = this._getFilteredList(initList, config.params);
        return [HttpStatusCode.Ok, res];
      });

    /** 获取商品是否收藏的状态 */
    adapter
      .onGet(RequestUrlMap.PRODUCT_COLLECT_STATUS)
      .reply((config: AxiosRequestConfig) => {
        const productId: string = config.params.productId;
        const collectedList = this._getCollectionList();
        const isCollected: boolean = collectedList.list.some((item)=>item.productId === productId);

        const res: ProductCollectStatusResp = {
          code: 0,
          status: isCollected ? 1 : 0,
        };
        return [HttpStatusCode.Ok, res];
      });
  }

  /**
   * 设置浏览记录相关API
   */
  private _setupViewHistoryApi(adapter: AxiosMockAdapter) {
    /** 添加浏览记录 */
    adapter
      .onPost(RequestUrlMap.PRODUCT_VIEW_HISTORY)
      .reply((config: AxiosRequestConfig) => {
        const baseId: BaseID = JSON.parse(config.data);
        const historyList = this._getMockHistoryList();

        // 如果已存在,先删除再添加到最前面
        historyList.list = historyList.list.filter((item) => item.productId !== baseId.productId);
        historyList.list.unshift(baseId as BaseIDModel);

        // 限制浏览记录最多100条
        if (historyList.list.length > 100) {
          historyList.list = historyList.list.slice(0, 100);
        }

        const res: BaseResponse = {
          code: 0,
          msg: '添加浏览记录成功',
        };
        return [HttpStatusCode.Ok, res];
      });

    /** 删除浏览记录 */
    adapter
      .onDelete(RequestUrlMap.PRODUCT_VIEW_HISTORY)
      .reply((config: AxiosRequestConfig) => {
        const productIds: string = config.params.productIds;
        const historyList = this._getMockHistoryList();

        historyList.list = historyList.list.filter(
          (item) => !productIds.includes(item.productId),
        );

        const res: BaseResponse = {
          code: 0,
          msg: '删除浏览记录成功',
        };
        return [HttpStatusCode.Ok, res];
      });

    /** 获取浏览记录列表 */
    adapter
      .onGet(RequestUrlMap.PRODUCT_VIEW_HISTORY_LIST)
      .reply((config: AxiosRequestConfig) => {
        const historyList = this._getMockHistoryList();
        const initList: ProductCardItem[] = [];

        historyList.list.forEach((item) => {
          const productItem = MockProductData.PRODUCT_CARD_LIST.find(
            (product) => product.productId === item.productId,
          );
          if (productItem) {
            productItem.slotId = MockSeckillData.getSlotIdByProductId(productItem.productId);
            initList.push(productItem);
          }
        });

        const res = this._getFilteredList(initList, config.params);
        return [HttpStatusCode.Ok, res];
      });
  }

  // ==================== 工具方法 ====================

  /**
   * 获取收藏列表
   */
  private _getCollectionList(): CollectedProduct {
    const data = PersistenceV2.connect(
      CollectedProduct,
      MockPersistenceMap.COLLECTION,
      () => new CollectedProduct(),
    )!;
    return data;
  }

  /**
   * 获取浏览记录列表
   */
  private _getMockHistoryList(): ViewHistoryProduct {
    const data = PersistenceV2.connect(
      ViewHistoryProduct,
      MockPersistenceMap.VIEW_HISTORY,
      () => new ViewHistoryProduct(),
    )!;
    return data;
  }

  /**
   * 计算平均评分
   */
  private _calculateAvgRating(reviews: ProductReviewItem[]): number {
    if (reviews.length === 0) {
      return 0;
    }
    const sum = reviews.reduce((acc, review) => acc + review.rating, 0);
    return Math.round((sum / reviews.length) * 10) / 10; // 保留一位小数
  }

  /**
   * 获取过滤和排序后的商品列表
   */
  private _getFilteredList(
    initList: ProductCardItem[],
    params: ProductListReq,
  ): ProductListResp {
    const curPage = params.curPage || 1;
    const sortType = params.sortType || 0;
    const filterList = params.filterList;
    const categoryId = params.categoryId;
    const keyword = params.keyword;
    const targetId = params.targetId;
    const pageSize = this.PAGE_SIZE;
    const startIndex = (curPage - 1) * pageSize;
    let filteredList = [...initList];

    // 根据分类ID过滤
    if (categoryId) {
      const category = categoryId.split('_');
      filteredList = filteredList.filter((item) => {
        return item.categoryId.startsWith(category[0]);
      });
    }

    // 根据关键字过滤
    if (keyword) {
      filteredList = filteredList.filter((item) =>
      item.title.toLowerCase().includes(keyword.toLowerCase()),
      );
    }

    // 根据筛选条件过滤
    if (filterList && filterList.length > 0) {
      filteredList = filteredList.filter((item) => {
        return filterList.every((filter) => {
          if (filter.value.includes('all')) {
            return true;
          }

          if (filter.id === 'size') {
            return item.summary.size.some((size) =>
            filter.value.includes(size),
            );
          }

          if (filter.id === 'price') {
            const prices = filter.value[0]
              .split('-')
              .map((item) => Number(item));
            return (
              item.summary.maxPrice >= prices[0] &&
                item.summary.minPrice <= prices[1]
            );
          }

          if (filter.id === 'place') {
            return filter.value.includes(item.summary.place);
          }

          return true;
        });
      });
    }

    // 排序逻辑
    switch (sortType) {
      case 1: // 价格从低到高
        filteredList.sort((a, b) => a.price - b.price);
        break;
      case 2: // 价格从高到低
        filteredList.sort((a, b) => b.price - a.price);
        break;
      case 3: // 销量从高到低
        filteredList.sort((a, b) => b.sales - a.sales);
        break;
      default: // 默认排序(综合)
        break;
    }

    // 传入targetId时获取指定商品放在第一个
    if (targetId && curPage === 1) {
      const targetProduct = this._mockList.find(
        (item) => item.productId === targetId,
      );
      if (targetProduct) {
        filteredList = filteredList.filter(
          (product) => product.productId !== targetId,
        );
        filteredList.unshift(targetProduct);
      }
    }

    const endIndex = startIndex + pageSize;
    const list = filteredList.slice(startIndex, endIndex);
    const isFinal =
      list.length < pageSize || endIndex >= filteredList.length;
    const total = filteredList.length;

    const res: ProductListResp = {
      code: 0,
      isFinal,
      list,
      curPage,
      total,
    };
    return res;
  }
}
