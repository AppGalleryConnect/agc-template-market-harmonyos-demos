import { RequestUrl } from '../constants/NetworkEnums';
import request from '../models/AxiosRequest';
import {
  BaseResponse,
  GetUserInfoResp,
  GetRecommendListResp,
  GetOrderListInfoResp,
  GetOrderDetailResp,
  GetPerformanceInfoResp,
  GetDayTicketResp,
  GetExplainTextResp,
  GetIntroduceResp,
  UpdateUserInfoRequest,
  ContactsResp,
  Contacts,
  GetTimeTicketResp,
  GetTicketTypeInfoResp,
  PrepayBuyTicketResp,
  UserLoginResp,
  ParkTextResp,
  GetTrafficDetailResp,
} from '../types/ResponseTypes';

import {
  BaseSuccessResponse,
  OrderListRequest,
  CancelOrderRequest,
  OrderDetailRequest,
  OrderFreeRequest,
  PrepayBuyTicketRequest,
  GetBannerImgRequest
} from '../types/RequestTypes';

class HttpApi {
  public bindPhone(authCode: string): Promise<BaseResponse<undefined>> {
    return request.post({
      url: RequestUrl.USER_BIND_PHONE,
      data: { authCode },
    });
  }


  public cancelPhone(): Promise<BaseResponse<undefined>> {
    return request.post({
      url: RequestUrl.USER_CANCEL_PHONE,
    });
  }



  public getUserInfo(): Promise<BaseResponse<GetUserInfoResp>> {
    return request.get({ url: RequestUrl.USER_GET_INFO });
  }

  public userLogin(): Promise<BaseResponse<UserLoginResp>> {
    return request.post({ url: RequestUrl.USER_LOGIN });
  }

  public getRecommendList(): Promise<BaseResponse<GetRecommendListResp>> {
    return request.get({ url: RequestUrl.HOME_RECOMMEND_LIST });
  }

  // 获取订单列表
  public getOrderList(data: OrderListRequest): Promise<BaseResponse<GetOrderListInfoResp>> {
    return request.get({
      url: RequestUrl.ORDER_LIST_INFO, data,
    });
  }

  //   获取订单详情
  public getOrderDetail(data: OrderDetailRequest): Promise<BaseResponse<GetOrderDetailResp>> {
    return request.get({
      url: RequestUrl.ORDER_TICKET_DETAIL, data,
    });
  }

  // 取消预定
  public cancelOrder(data: CancelOrderRequest): Promise<BaseSuccessResponse> {
    return request.post({
      url: RequestUrl.CANCEL_ORDER, data,
    });
  }

  //   获取特展信息
  public getPerformanceInfo(): Promise<BaseResponse<GetPerformanceInfoResp>> {
    return request.get({ url: RequestUrl.PERFORMANCE_INFO });
  }

  //  免费约展时间信息
  public getDayTicket(): Promise<BaseResponse<GetDayTicketResp>> {
    return request.get({ url: RequestUrl.ORDER_DAY_TICKET });
  }

  // 付费约展时间信息
  public getTimeTicket(data: string): Promise<BaseResponse<GetTimeTicketResp>> {
    return request.get({ url: RequestUrl.BUY_TIME_TICKET, data });
  }

  //  讲解服务文本
  public getExplainText(): Promise<BaseResponse<GetExplainTextResp>> {
    return request.get({ url: RequestUrl.EXPLAIN_TEXT });
  }

  //   省博介绍文本
  public getIntroduceText(): Promise<BaseResponse<GetIntroduceResp>> {
    return request.get({ url: RequestUrl.INTRODUCE_TEXT });
  }

  //   停车缴费文本
  public getParkingText(): Promise<BaseResponse<ParkTextResp[]>> {
    return request.get({ url: RequestUrl.PARKING_TEXT });
  }

  //   隐私政策文本
  public getPrivacyText(): Promise<BaseResponse<string[][]>> {
    return request.get({ url: RequestUrl.PRIVACY_TEXT });
  }

  // 更新用户信息
  public updateUserInfo(data: UpdateUserInfoRequest): Promise<BaseSuccessResponse> {
    return request.post({
      url: RequestUrl.UPDATE_USERINFO,
      data,
    });
  }

  // 获取常用联系人
  public getContacts(): Promise<BaseResponse<ContactsResp>> {
    return request.get({ url: RequestUrl.CONTACTS_INFO });
  }

  //  更新常用联系人
  public upDateContacts(data: Contacts): Promise<BaseSuccessResponse> {
    return request.post({ url: RequestUrl.UPDATE_CONTACT, data });
  }

  // 免费预定
  public orderFree(data: OrderFreeRequest): Promise<BaseSuccessResponse<GetOrderDetailResp>> {
    return request.post({ url: RequestUrl.ORDER_FREE, data });
  }

  //   获取票种信息
  public getTicketType(data: string): Promise<BaseResponse<GetTicketTypeInfoResp>> {
    return request.post({ url: RequestUrl.TICKET_TYPE_INFO, data });
  }

  //   预支付
  public prePayBuyTicket(data: PrepayBuyTicketRequest): Promise<BaseResponse<PrepayBuyTicketResp>> {
    return request.post({ url: RequestUrl.BUY_TICKET, data });
  }

  //   获取banner图
  public getBannerImg(data: GetBannerImgRequest): Promise<BaseResponse<string|string[]>> {
    return request.get({ url: RequestUrl.BANNER_IMG, data });
  }

  //  删除常用联系人
  public delContacts(data:string): Promise<BaseSuccessResponse<undefined>> {
    return request.delete({ url: RequestUrl.DEL_VISITOR, data });
  }

  // 获取交通信息
  public getTrafficDetail(): Promise<BaseResponse<GetTrafficDetailResp>> {
   return request.get({url:RequestUrl.TRAFFIC_DETAIL})
  }
}

const https = new HttpApi();

export { https };