import { BaseResponse } from '../types/BaseResponse';
import axiosClient from '../models/AxiosRequest';
import {
  GetOrderDetailRequest,
  HotelListRequest,
  PrepayMealRequest,
  PrepayRoomRequest,
  RoomDetailRequest,
  RoomListRequest,
  SubmitCommentRequest,
  UpdateUserInfoRequest,
} from '../types/AxiosRequestParam';
import {
  GetBanquetHotelListResp,
  GetBanquetRoomDetailResp,
  GetBanquetRoomListResp,
  GetCommentListResp,
  GetGradeListResp,
  GetHotelListResp,
  GetHotelOrderDetailResp,
  GetHotelUserInfoResp,
  GetMealDetailResp,
  GetMealOrderDetailResp,
  GetNoticeDetailResp,
  GetNoticeListResp,
  GetOrderListResp,
  GetRestaurantInfoResp,
  GetRestaurantListResp,
  GetRoomDetailResp,
  GetRoomListResp,
  GetServiceBannerResp,
  GetShopListForCommentResp,
  GetTenantConfigResp,
  GetTenantInfoResp,
  GetTrafficDetailResp,
  HotelUserLoginResp,
  PrepayResp,
} from '../types/responseTypes';
import { RequestUrlMap } from './RequestUrlMap';
import { AccountUtil, AppStorageMap, HUAWEIAccountModel, Logger } from 'commonlib';

export function getTenantId() {
  const tenantId: number | undefined = AppStorage.get(AppStorageMap.TENANT_ID);
  if (!tenantId) {
    Logger.error('tenant id is not existed');
    return undefined;
  }
  return tenantId;
}

export function resetLoginToken() {
  const accountInfo: HUAWEIAccountModel = AccountUtil.getAccountInfo();
  accountInfo.loginToken = undefined;
  https.hotelUserLogin().then((res) => {
    if (res.code === 0) {
      accountInfo.loginToken = res.data.loginToken;
    }
  });
}

class HttpsApi {
  // 获取租户信息
  public getTenantInfo(): Promise<BaseResponse<GetTenantInfoResp>> {
    return axiosClient.get({
      url: RequestUrlMap.COMMON_TENANT_INFO,
      params: {
        bundleName: '',
      },
    });
  }

  // 查询商户页面配置信息
  public getTenantConfig(): Promise<BaseResponse<GetTenantConfigResp>> {
    return axiosClient.get({
      url: RequestUrlMap.COMMON_TENANT_CONFIG,
      params: {
        tenantId: getTenantId(),
      },
    });
  }

  // 获取交通信息
  public getTrafficDetail(): Promise<BaseResponse<GetTrafficDetailResp>> {
    return axiosClient.get({
      showLoading: true,
      url: RequestUrlMap.COMMON_TRAFFIC_DETAIL,
      params: {
        tenantId: getTenantId(),
      },
    });
  }

  // 查询会员等级列表及介绍
  public getGradeList(): Promise<BaseResponse<GetGradeListResp>> {
    return axiosClient.get({
      url: RequestUrlMap.COMMON_GRADE_LIST,
      showLoading: true,
      params: {
        tenantId: getTenantId(),
      },
    });
  }

  // 查询顶部banner
  public getServiceBanner(pageType: number): Promise<BaseResponse<GetServiceBannerResp>> {
    return axiosClient.get({
      url: RequestUrlMap.COMMON_PAGE_BANNER,
      showLoading: true,
      params: {
        pageType,
        tenantId: getTenantId(),
      },
    });
  }

  // 登录酒店用户
  public hotelUserLogin(): Promise<BaseResponse<HotelUserLoginResp>> {
    return axiosClient.get({
      url: RequestUrlMap.USER_LOGIN,
      params: {
        tenantId: getTenantId(),
      },
    });
  }

  // 酒店用户信息查询
  public getHotelUserInfo(): Promise<BaseResponse<GetHotelUserInfoResp>> {
    return axiosClient.get({
      url: RequestUrlMap.USER_SEARCH,
    });
  }

  // 更新用户信息
  public updateHotelUserInfo(data: UpdateUserInfoRequest): Promise<BaseResponse> {
    return axiosClient.put({
      showLoading: true,
      url: RequestUrlMap.USER_UPDATE,
      data,
    });
  }

  // 获取公告列表
  public getNoticeList(): Promise<BaseResponse<GetNoticeListResp>> {
    return axiosClient.get({
      url: RequestUrlMap.NOTICE_LIST,
      params: {
        tenantId: getTenantId(),
      },
    });
  }

  // 获取公告详情
  public getNoticeDetail(id: number): Promise<BaseResponse<GetNoticeDetailResp>> {
    return axiosClient.get({
      showLoading: true,
      url: RequestUrlMap.NOTICE_DETAIL,
      params: {
        tenantId: getTenantId(),
        id,
      },
    });
  }

  // 首页评论获取酒店列表
  public getShopListForComment(): Promise<BaseResponse<GetShopListForCommentResp>> {
    return axiosClient.get({
      showLoading: true,
      url: RequestUrlMap.COMMON_SHOP_LIST,
      params: {
        tenantId: getTenantId(),
      },
    });
  }

  // 获取评论列表
  public getCommentList(): Promise<BaseResponse<GetCommentListResp>> {
    return axiosClient.get({
      showLoading: true,
      url: RequestUrlMap.COMMENT_LIST,
      params: {
        tenantId: getTenantId(),
      },
    });
  }

  // 发表评论
  public submitComment(data: SubmitCommentRequest): Promise<BaseResponse<undefined>> {
    return axiosClient.post({
      showLoading: true,
      url: RequestUrlMap.COMMENT_CREATE,
      data,
    });
  }

  // 查询订单列表
  public getOrderList(userId: number, orderClass?: number): Promise<BaseResponse<GetOrderListResp>> {
    return axiosClient.get({
      url: RequestUrlMap.ORDER_LIST,
      params: {
        userId,
        orderClass: orderClass ? orderClass : -1,
      },
    });
  }

  // 查询酒店订单详情
  public getHotelOrderDetail(params: GetOrderDetailRequest): Promise<BaseResponse<GetHotelOrderDetailResp>> {
    return axiosClient.get({
      showLoading: true,
      url: RequestUrlMap.ORDER_DETAIL_HOTEL,
      params,
    });
  }

  // 查询餐饮订单详情
  public getMealOrderDetail(params: GetOrderDetailRequest): Promise<BaseResponse<GetMealOrderDetailResp>> {
    return axiosClient.get({
      showLoading: true,
      url: RequestUrlMap.ORDER_DETAIL_MEAL,
      params,
    });
  }

  // 查询酒店列表
  public getHotelList(params: HotelListRequest): Promise<BaseResponse<GetHotelListResp>> {
    return axiosClient.get({
      showLoading: true,
      url: RequestUrlMap.HOTEL_LIST,
      params,
    });
  }

  // 查询房间列表
  public getRoomList(params: RoomListRequest): Promise<BaseResponse<GetRoomListResp>> {
    return axiosClient.get({
      showLoading: true,
      url: RequestUrlMap.HOTEL_ROOM_LIST,
      params,
    });
  }

  // 查询房间详情
  public getRoomDetail(params: RoomDetailRequest): Promise<BaseResponse<GetRoomDetailResp>> {
    return axiosClient.get({
      showLoading: true,
      url: RequestUrlMap.HOTEL_ROOM_DETAIL,
      params,
    });
  }

  // 查询餐厅列表
  public getRestaurantList(): Promise<BaseResponse<GetRestaurantListResp>> {
    return axiosClient.get({
      showLoading: true,
      url: RequestUrlMap.RESTAURANT_LIST,
      params: {
        tenantId: getTenantId(),
      },
    });
  }

  // 查询餐厅详情
  public getRestaurantDetail(shopId: number): Promise<BaseResponse<GetRestaurantInfoResp>> {
    return axiosClient.get({
      showLoading: true,
      url: RequestUrlMap.RESTAURANT_DETAIL,
      params: {
        shopId,
      },
    });
  }

  // 查询套餐详情
  public getMealDetail(packageId: number): Promise<BaseResponse<GetMealDetailResp>> {
    return axiosClient.get({
      showLoading: true,
      url: RequestUrlMap.RESTAURANT_MEAL_DETAIL,
      params: {
        packageId,
      },
    });
  }

  // 查询宴会厅酒店列表
  public getBanquetHotelList(): Promise<BaseResponse<GetBanquetHotelListResp>> {
    return axiosClient.get({
      url: RequestUrlMap.BANQUET_HOTEL_LIST,
      showLoading: true,
      params: {
        tenantId: getTenantId(),
      },
    });
  }

  // 查询宴会厅列表
  public getBanquetRoomList(hotelId: number): Promise<BaseResponse<GetBanquetRoomListResp>> {
    return axiosClient.get({
      url: RequestUrlMap.BANQUET_LIST,
      showLoading: true,
      params: {
        tenantId: getTenantId(),
        hotelId,
      },
    });
  }

  // 查询宴会厅详情
  public getBanquetRoomDetail(banquetId: number): Promise<BaseResponse<GetBanquetRoomDetailResp>> {
    return axiosClient.get({
      url: RequestUrlMap.BANQUET_DETAIL + `/${banquetId}`,
      showLoading: true,
    });
  }

  // 酒店订房预下单
  public prepayHotel(data: PrepayRoomRequest): Promise<BaseResponse<PrepayResp>> {
    return axiosClient.post({
      showLoading: true,
      url: RequestUrlMap.PREPAY_HOTEL,
      data: data,
    });
  }

  // 团购套餐预下单
  public prepayMeal(data: PrepayMealRequest): Promise<BaseResponse<PrepayResp>> {
    return axiosClient.post({
      showLoading: true,
      url: RequestUrlMap.PREPAY_MEAL,
      data,
    });
  }
}

const https = new HttpsApi();

export { https };
