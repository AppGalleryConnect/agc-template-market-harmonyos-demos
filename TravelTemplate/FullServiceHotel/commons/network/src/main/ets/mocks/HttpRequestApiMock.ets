import { BaseResponse } from '../types/BaseResponse';
import {
  GetMealDetailRequest,
  GetOrderDetailRequest,
  GetRestaurantListRequest,
  GetServiceBannerRequest,
  PrepayMealRequest,
  PrepayRoomRequest,
  RoomDetailRequest,
  SubmitCommentRequest,
  UpdateUserInfoRequest,
} from '../types/AxiosRequestParam';
import {
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
  GetBanquetHotelListResp
} from '../types/responseTypes';
import { OrderDatasetMock } from './mockData/OrderDatasetMock';
import { RestaurantDatasetMock } from './mockData/RestaurantDatasetMock';
import { HotelDatasetMock } from './mockData/HotelDatasetMock';
import { StoreConfigDatasetMock } from './mockData/StoreConfigDatasetMock';
import { BanquetDatasetMock } from './mockData/BanquetDatasetMock';
import { UserManagementMock } from './mockData/UserManagementMock';

class HttpsApiMock {
  // 获取租户信息
  public getTenantInfo(): Promise<BaseResponse<GetTenantInfoResp>> {
    return Promise.resolve(StoreConfigDatasetMock.getTenantInfo());
  }

  // 查询商户页面配置信息
  public getTenantConfig(): Promise<BaseResponse<GetTenantConfigResp>> {
    return Promise.resolve(StoreConfigDatasetMock.getTenantConfig());
  }

  // 登录酒店用户
  public hotelUserLogin(): Promise<BaseResponse<HotelUserLoginResp>> {
    return Promise.resolve(UserManagementMock.hotelUserLogin());
  }

  // 酒店用户信息查询
  public getHotelUserInfo(): Promise<BaseResponse<GetHotelUserInfoResp>> {
    return Promise.resolve(UserManagementMock.getHotelUserInfo());
  }

  // 更新用户信息
  public updateHotelUserInfo(data: UpdateUserInfoRequest): Promise<BaseResponse<undefined>> {
    return Promise.resolve(UserManagementMock.updateHotelUserInfo(data));
  }

  // 获取公告列表
  public getNoticeList(): Promise<BaseResponse<GetNoticeListResp>> {
    return Promise.resolve(StoreConfigDatasetMock.getNoticeList());
  }

  // 获取公告详情
  public getNoticeDetail(): Promise<BaseResponse<GetNoticeDetailResp>> {
    return Promise.resolve(StoreConfigDatasetMock.getNoticeDetail());
  }

  // 获取交通信息
  public getTrafficDetail(): Promise<BaseResponse<GetTrafficDetailResp>> {
    return Promise.resolve(StoreConfigDatasetMock.getTrafficDetail());
  }

  // 获取评论列表
  public getCommentList(): Promise<BaseResponse<GetCommentListResp>> {
    return Promise.resolve(HotelDatasetMock.getCommentList());
  }

  // 发表评论
  public submitComment(data: SubmitCommentRequest): Promise<BaseResponse<undefined>> {
    return Promise.resolve(HotelDatasetMock.submitComment(data));
  }

  // 首页评论获取酒店列表
  public getShopListForComment(): Promise<BaseResponse<GetShopListForCommentResp>> {
    return Promise.resolve(HotelDatasetMock.getShopListForComment());
  }

  // 查询订单列表
  public getOrderList(userId: number, orderClass?: number): Promise<BaseResponse<GetOrderListResp>> {
    return Promise.resolve(OrderDatasetMock.getOrderList(orderClass));
  }

  // 查询酒店订单详情
  public getHotelOrderDetail(data: GetOrderDetailRequest): Promise<BaseResponse<GetHotelOrderDetailResp>> {
    return Promise.resolve(OrderDatasetMock.getHotelOrderDetail(data.orderNo));
  }

  // 查询餐饮订单详情
  public getMealOrderDetail(data: GetOrderDetailRequest): Promise<BaseResponse<GetMealOrderDetailResp>> {
    return Promise.resolve(OrderDatasetMock.getMealOrderDetail(data.orderNo));
  }

  // 查询会员等级列表及介绍
  public getGradeList(): Promise<BaseResponse<GetGradeListResp>> {
    return Promise.resolve(StoreConfigDatasetMock.getGrandList());
  }

  // 查询宴会厅酒店列表
  public getBanquetHotelList(): Promise<BaseResponse<GetBanquetHotelListResp>> {
    return Promise.resolve(BanquetDatasetMock.getBanquetHotelList());
  }

  // 查询宴会厅列表
  public getBanquetRoomList(): Promise<BaseResponse<GetBanquetRoomListResp>> {
    return Promise.resolve(BanquetDatasetMock.getBanquetRoomList());
  }

  // 查询宴会厅详情
  public getBanquetRoomDetail(): Promise<BaseResponse<GetBanquetRoomDetailResp>> {
    return Promise.resolve(BanquetDatasetMock.getBanquetRoomDetail());
  }

  // 查询酒店列表
  public getHotelList(): Promise<BaseResponse<GetHotelListResp>> {
    return Promise.resolve(HotelDatasetMock.getHotelList());
  }

  // 查询房间列表
  public getRoomList(): Promise<BaseResponse<GetRoomListResp>> {
    return Promise.resolve(HotelDatasetMock.getRoomList());
  }

  // 查询房间详情
  public getRoomDetail(params: RoomDetailRequest): Promise<BaseResponse<GetRoomDetailResp>> {
    return Promise.resolve(HotelDatasetMock.getRoomDetail());
  }

  // 酒店订房预下单
  public prepayHotel(data: PrepayRoomRequest): Promise<BaseResponse<PrepayResp>> {
    return Promise.resolve(OrderDatasetMock.prepayHotel(data));
  }

  // 查询顶部banner
  public getServiceBanner(data: GetServiceBannerRequest): Promise<BaseResponse<GetServiceBannerResp>> {
    return Promise.resolve(StoreConfigDatasetMock.getServiceBanner(data));
  }

  // 查询餐厅列表
  public getRestaurantList(): Promise<BaseResponse<GetRestaurantListResp>> {
    return Promise.resolve(RestaurantDatasetMock.getRestaurantList());
  }

  // 查询餐厅详情
  public getRestaurantDetail(data: GetRestaurantListRequest): Promise<BaseResponse<GetRestaurantInfoResp>> {
    return Promise.resolve(RestaurantDatasetMock.getRestaurantDetail(data.shopId));
  }

  // 查询套餐详情
  public getMealDetail(data: GetMealDetailRequest): Promise<BaseResponse<GetMealDetailResp>> {
    return Promise.resolve(RestaurantDatasetMock.getMealDetail(data.packageId));
  }

  // 团购套餐预下单
  public prepayMeal(data: PrepayMealRequest): Promise<BaseResponse<PrepayResp>> {
    return Promise.resolve(OrderDatasetMock.prepayMeal(data));
  }
}

const httpsMock = new HttpsApiMock();

export { httpsMock };