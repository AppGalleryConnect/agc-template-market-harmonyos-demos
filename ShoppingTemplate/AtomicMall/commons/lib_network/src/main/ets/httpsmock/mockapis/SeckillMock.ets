import { PersistenceV2, Type } from '@kit.ArkUI';
import { AxiosRequestConfig, HttpStatusCode } from '@ohos/axios';
import AxiosMockAdapter from '@hw-agconnect/axios-mock-adapter';
import { RequestUrlMap } from '../../constants/RequestUrlMap';
import {
  ReservedProductInfo, SeckillProductInfo, SeckillSession,
} from '../../types/ProductTypes';
import {
  SeckillProductListReq, SeckillReserveReq,
} from '../../types/RequestTypes';
import { BaseResponse } from '../../types/responses/BaseResponse';
import {
  SeckillSessionListResp,
  SeckillProductListResp,
  SeckillReserveStatusResp,
  BatchReserveStatusResp,
} from '../../types/responses/ProductResponse';
import { MockProductData } from '../mockdata/MockProductData';
import { MockSeckillData } from '../mockdata/MockSeckillData';

// ==================== 持久化数据类 ====================

class ReservedProductInfoModel implements ReservedProductInfo {
  productId: string = '';
  slotId: string = '';
  eventId: number = 0;
}

@ObservedV2
class SeckillReservations {
  /** 已预约的商品ID集合 */
  @Type(ReservedProductInfoModel)
  @Trace reservedProducts: ReservedProductInfo[] = [];
}

const enum MockPersistenceMap {
  RESERVATIONS = 'seckill_reservations',
}

// ==================== Mock API 类 ====================

export class SeckillMockApis {
  private readonly PAGE_SIZE = 10;

  public start(adapter: AxiosMockAdapter) {
    this._setupSessionApi(adapter);
    this._setupProductApi(adapter);
    this._setupReservationApi(adapter);
  }

  // ==================== 场次相关 API ====================

  /**
   * 设置场次相关API
   */
  private _setupSessionApi(adapter: AxiosMockAdapter) {
    /** 获取秒杀场次列表 */
    adapter
      .onGet(RequestUrlMap.SECKILL_SESSIONS)
      .reply((config: AxiosRequestConfig) => {
        const sessions = MockSeckillData.getAllSessions();
        const currentSlotId = MockSeckillData.getCurrentSlotId();

        // 填充商品完整信息
        const fullSessions = sessions.map(session => {
          const productList = session.productList.map(seckillProduct => {
            const product = MockProductData.PRODUCT_CARD_LIST.find(
              p => p.productId === seckillProduct.productId,
            );

            if (product) {
              return {
                title: product.title,
                banner: product.banner,
                price: product.price,
                dashPrice: product.dashPrice,
                seckillId: seckillProduct.seckillId,
                slotId: seckillProduct.slotId,
                categoryId: seckillProduct.categoryId,
                productId: product.productId,
                seckillPrice: seckillProduct.seckillPrice,
                totalStock: seckillProduct.totalStock,
                remainStock: seckillProduct.remainStock,
              } as SeckillProductInfo;
            }

            return seckillProduct;
          }).filter((product) => product.title);
          return {
            timeSlot: session.timeSlot,
            productList,
          } as SeckillSession;
        });

        const res: SeckillSessionListResp = {
          code: 0,
          sessions: fullSessions,
          currentSlotId,
        };
        return [HttpStatusCode.Ok, res];
      });
  }

  // ==================== 商品相关 API ====================

  /**
   * 设置商品相关API
   */
  private _setupProductApi(adapter: AxiosMockAdapter) {
    /** 获取秒杀商品列表 */
    adapter
      .onGet(RequestUrlMap.SECKILL_PRODUCT_LIST)
      .reply((config: AxiosRequestConfig) => {
        const params: SeckillProductListReq = config.params;
        const slotId = params.slotId;
        const curPage = params.curPage || 1;
        const pageSize = params.pageSize || this.PAGE_SIZE;

        // 获取该时段的秒杀商品
        let seckillProducts = MockSeckillData.getProductsBySlotId(slotId);

        // 填充商品完整信息
        seckillProducts = seckillProducts.map(seckillProduct => {
          const product = MockProductData.PRODUCT_CARD_LIST.find(
            p => p.productId === seckillProduct.productId,
          );

          if (product) {
            return {
              seckillId: seckillProduct.seckillId,
              slotId: seckillProduct.slotId,
              categoryId: seckillProduct.categoryId,
              seckillPrice: seckillProduct.seckillPrice,
              title: product.title,
              banner: product.banner,
              price: product.price,
              dashPrice: product.dashPrice,
            } as SeckillProductInfo;
          }

          return seckillProduct;
        });

        // 分页
        const startIndex = (curPage - 1) * pageSize;
        const endIndex = startIndex + pageSize;
        const list = seckillProducts.slice(startIndex, endIndex);
        const isFinal = list.length < pageSize || endIndex >= seckillProducts.length;

        const res: SeckillProductListResp = {
          code: 0,
          list,
          curPage,
          isFinal,
          total: seckillProducts.length,
        };
        return [HttpStatusCode.Ok, res];
      });
  }

  // ==================== 预约相关 API ====================

  /**
   * 设置预约相关API
   */
  private _setupReservationApi(adapter: AxiosMockAdapter) {
    /** 预约秒杀 */
    adapter
      .onPost(RequestUrlMap.SECKILL_RESERVE)
      .reply(async (config: AxiosRequestConfig) => {
        const params: SeckillReserveReq = JSON.parse(config.data);
        const reservations = await this._getReservationData();

        if (!params.eventId) {
          const errorRes: BaseResponse = {
            code: 400,
            msg: '日历ID不存在',
          };
          return [HttpStatusCode.BadRequest, errorRes];
        }

        // 检查是否已预约
        if (this._getProductReserveInfo(reservations.reservedProducts, params)) {
          const errorRes: BaseResponse = {
            code: 400,
            msg: '已预约该商品',
          };
          return [HttpStatusCode.BadRequest, errorRes];
        }

        // 检查商品是否在秒杀中
        if (!MockSeckillData.isProductInSeckill(params.productId)) {
          const errorRes: BaseResponse = {
            code: 404,
            msg: '该商品未参与秒杀',
          };
          return [HttpStatusCode.NotFound, errorRes];
        }

        // 添加预约
        reservations.reservedProducts.unshift({
          productId: params.productId,
          slotId: params.slotId,
          eventId: params.eventId,
        });

        const res: BaseResponse = {
          code: 0,
          msg: '预约成功',
        };
        return [HttpStatusCode.Ok, res];
      });

    /** 取消预约 */
    adapter
      .onDelete(RequestUrlMap.SECKILL_RESERVE)
      .reply(async (config: AxiosRequestConfig) => {
        const eventId = config.params.eventId as number;
        const reservations = await this._getReservationData();

        // 移除预约
        reservations.reservedProducts = reservations.reservedProducts.filter(
          (item) => !(item.eventId === eventId),
        );

        const res: BaseResponse = {
          code: 0,
          msg: '取消预约成功',
        };
        return [HttpStatusCode.Ok, res];
      });

    /** 获取单个商品预约状态 */
    adapter
      .onGet(RequestUrlMap.SECKILL_RESERVE_STATUS)
      .reply(async (config: AxiosRequestConfig) => {
        const params: SeckillReserveReq = config.params;
        const reservations = await this._getReservationData();
        const info = this._getProductReserveInfo(reservations.reservedProducts, params);

        const res: SeckillReserveStatusResp = {
          code: 0,
          isReserved: Boolean(info),
          eventId: info?.eventId,
        };
        return [HttpStatusCode.Ok, res];
      });

    /** 批量获取预约状态 */
    adapter
      .onGet(RequestUrlMap.SECKILL_BATCH_RESERVE_STATUS)
      .reply(async (config: AxiosRequestConfig) => {
        const reservations = await this._getReservationData();

        const res: BatchReserveStatusResp = {
          code: 0,
          reservedProducts: reservations.reservedProducts,
        };
        return [HttpStatusCode.Ok, res];
      });
  }

  // ==================== 工具方法 ====================

  /**
   * 获取预约数据
   */
  private async _getReservationData(): Promise<SeckillReservations> {
    const data = PersistenceV2.connect(
      SeckillReservations,
      MockPersistenceMap.RESERVATIONS,
      () => new SeckillReservations(),
    )!;
    return data;
  }

  /**
   * 判断是否存在预约商品
   */
  private _getProductReserveInfo(list: ReservedProductInfo[], param: SeckillReserveReq) {
    const item = list.find((product) =>
    product.productId === param.productId &&
      product.slotId === param.slotId,
    );
    return item;
  }
}
