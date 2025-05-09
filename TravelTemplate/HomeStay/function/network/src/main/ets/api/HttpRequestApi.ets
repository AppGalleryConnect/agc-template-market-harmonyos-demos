import { AxiosRequestHeaders } from '@ohos/axios';
import axiosClient from '../models/AxiosRequest';
import { Constants } from 'constant';
import { Mock } from '../mock/Mock';
import {
  AddComplaintsRequest,
  AddOrModifyPassengerRequest,
  CreateOrderRequest,
  GetHotelInfo,
  GetInfoRequest,
  UpdateOrderRequest,
} from '../types/AxiosRequestParam';
import { Order, Passenger, PersonalInfo } from 'type';
import { BaseResponse, HomeResp } from '../types/ResponceTypes';

class HttpsApi {
  // 获取租户信息
  public getTenantInfo() {
    const data: GetInfoRequest = {
      appId: '',
    };

    return Constants.MODE === 'MOCK' ? Mock.TENANTINFO : axiosClient.post({
      showLoading: true,
      url: '/tenant/detail',
      headers: {} as AxiosRequestHeaders,
      data,
    });
  }

  // 编辑个人信息
  public editUserInfo(data: PersonalInfo): Promise<BaseResponse<undefined>> | BaseResponse<undefined> {
    return Constants.MODE === 'MOCK' ? Mock.setUserInfo(data) :
    axiosClient.post({
      showLoading: true,
      url: '/userInfo/edit',
      headers: {} as AxiosRequestHeaders,
      data,
    });
  }

  //查询个人信息
  public queryUserInfo(data: GetInfoRequest): Promise<BaseResponse<PersonalInfo>> | BaseResponse<PersonalInfo> {
    return Constants.MODE === 'MOCK' ? Mock.getPersonalInfo() : axiosClient.post({
      showLoading: true,
      url: '/userInfo/detail',
      headers: {} as AxiosRequestHeaders,
      data,
    });
  }

  // 获取首页聚合信息
  public getHomeRollupInfo(): Promise<BaseResponse<HomeResp>> | HomeResp {
    const data: GetHotelInfo = {
      appId: '',
      recommendGoodsCount: Constants.RECOMMEND_GOODS_COUNT,
      roomTypeCount: 0,
      featureRoomTypeCount: 0,
      brandStoryCount: Constants.BRAND_TORY_COUNT,
      hotScenicSpotCategoryCount: Constants.HOT_SCENIC_SPOT_CATEGORY_COUNT,
      recommendScenicSpotCount: 0,
    };
    return Constants.MODE === 'MOCK' ? Mock.HOME : axiosClient.post({
      showLoading: true,
      url: '/home/detail',
      headers: {} as AxiosRequestHeaders,
      data,
    });
  }

  public getCommodityList() {
    const data: GetInfoRequest = {
      appId: '',
    };

    return Constants.MODE === 'MOCK' ? Mock.COMMODITY :
    axiosClient.post({
      showLoading: true,
      url: '/commodity/list',
      headers: {} as AxiosRequestHeaders,
      data,
    });
  }

  public getCommodityCarouselImages() {
    return Constants.MODE === 'MOCK' ? Mock.COMMODITY_CAROUSEL_IMAGES : axiosClient.get({
      showLoading: true,
      url: '/commodity/carousel',
      headers: {} as AxiosRequestHeaders,
    });
  }

  public addPassengers(data: AddOrModifyPassengerRequest): Promise<BaseResponse<undefined>> | BaseResponse<undefined> {
    return Constants.MODE === 'MOCK' ? Mock.createPsg(data) : axiosClient.post({
      showLoading: true,
      url: '/passenger/create',
      headers: {} as AxiosRequestHeaders,
      data,
    });
  }

  public modifyPassenger(data: AddOrModifyPassengerRequest):
    Promise<BaseResponse<undefined>> | BaseResponse<undefined> {
    return Constants.MODE === 'MOCK' ? Mock.modifyPsg(data) : axiosClient.post({
      showLoading: true,
      url: '/passenger/create',
      headers: {} as AxiosRequestHeaders,
    });
  }

  public deletePassenger(passengerId: number): Promise<BaseResponse<undefined>> | BaseResponse<undefined> {
    return Constants.MODE === 'MOCK' ? Mock.deletePsg(passengerId) : axiosClient.post({
      showLoading: true,
      url: '/passenger/create',
      headers: {} as AxiosRequestHeaders,
    });
  }

  public queryPassengers(data: GetInfoRequest): Promise<BaseResponse<Passenger[]>> | BaseResponse<Passenger[]> {
    return Constants.MODE === 'MOCK' ? Mock.getPassengerList() : axiosClient.post({
      showLoading: true,
      url: '/passenger/detail',
      headers: {} as AxiosRequestHeaders,
      data,
    });
  }

  public addComplaints(data: AddComplaintsRequest): Promise<BaseResponse<undefined>> | BaseResponse<undefined> {
    return Constants.MODE === 'MOCK' ? Mock.ADD_PSG : axiosClient.post({
      showLoading: true,
      url: '/complaints/create',
      headers: {} as AxiosRequestHeaders,
      data,
    });
  }

  // 获取民宿详情聚合信息
  public getHotelDetail() {
    const data: GetHotelInfo = {
      appId: '',
      recommendGoodsCount: Constants.RECOMMEND_GOODS_COUNT,
      roomTypeCount: 2,
      featureRoomTypeCount: 0,
      brandStoryCount: 0,
      hotScenicSpotCategoryCount: 0,
      recommendScenicSpotCount: Constants.RECOMMEND_SCENIC_SPOT_CATEGORY_COUNT,
    };

    return Constants.MODE === 'MOCK' ? Mock.HOME_DETAIL : axiosClient.post({
      showLoading: true,
      url: '/hotel/detail',
      headers: {} as AxiosRequestHeaders,
      data,
    });
  }

  //创建订单
  public createOrder(data: CreateOrderRequest): Promise<BaseResponse<undefined>> | BaseResponse<undefined> {
    return Constants.MODE === 'MOCK' ? Mock.createOrder(data) : axiosClient.post({
      showLoading: true,
      url: '/order/create',
      headers: {} as AxiosRequestHeaders,
      data,
    });
  }

  //更新订单
  public updateOrder(data: UpdateOrderRequest): Promise<BaseResponse<undefined>> | BaseResponse<undefined> {
    return Constants.MODE === 'MOCK' ? Mock.updateOrder(data) : axiosClient.post({
      showLoading: true,
      url: '/order/update',
      headers: {} as AxiosRequestHeaders,
      data,
    });
  }

  //查询订单列表
  public queryOrderList(openId: string): Promise<BaseResponse<Order[]>> | BaseResponse<Order[]> {
    const data: GetInfoRequest = {
      appId: '',
      openId: openId,
    };

    return Constants.MODE === 'MOCK' ? Mock.getOrderList() : axiosClient.post({
      showLoading: true,
      url: '/order/list',
      headers: {} as AxiosRequestHeaders,
      data,
    });
  }

  public queryTravelNotes() {
    return Constants.MODE === 'MOCK' ? Mock.TRAVEL_NOTE : axiosClient.get({
      showLoading: true,
      url: '/note/list',
      headers: {} as AxiosRequestHeaders,
    });
  }
}

const https = new HttpsApi();

export { https };
