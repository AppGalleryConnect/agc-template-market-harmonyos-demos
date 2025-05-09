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
  ContactsResp,
  Contacts,
  GetTimeTicketResp,
  GetTicketTypeInfoResp,
  PrepayBuyTicketResp,
  UpdateUserInfoRequest,
  UserLoginResp,
  ParkTextResp,
  GetTrafficDetailResp,
} from '../types/ResponseTypes';
import { recommendListResp, explainTextResp, introduceTextResp, parkingTextResp } from './MockData/HomeMockData';
import { privacyTextResp } from './MockData/MineMockData';
import { OrderDatasetMock } from './MockData/OrderMockData';
import { PerformanceDatasetMock } from './MockData/PerformanceMockData';
import { ContactsDatasetMock } from './MockData/ContactsMockData';
import { AccountUtil } from 'commonlib';
import {
  BaseSuccessResponse,
  OrderListRequest,
  CancelOrderRequest,
  OrderDetailRequest,
  OrderFreeRequest,
  PrepayBuyTicketRequest,
  GetBannerImgRequest,
} from '../types/RequestTypes';
import { UserInfo } from 'commonlib/src/main/ets/types/Types';
import { MockStorageMap } from './Constants';
import { UserDatasetMock } from './MockData/UserMockData';
import { BannerDatasetMock } from './MockData/BannerMockData';

class HttpApiMock {
  public bindPhone(): Promise<BaseResponse<undefined>> {
    const resp: BaseResponse = { code: 0, data: undefined };
    UserDatasetMock.bindPhone();
    return Promise.resolve(resp);
  }

  public cancelPhone(): Promise<BaseResponse<undefined>> {
    const resp: BaseResponse = { code: 0, data: undefined };
    UserDatasetMock.cancelPhone();
    return Promise.resolve(resp);
  }

  public getUserInfo(): Promise<BaseResponse<GetUserInfoResp>> {
    const userInfoMock = AppStorage.get<GetUserInfoResp>(MockStorageMap.USER_INFO);
    if (userInfoMock) {
      const resp: BaseSuccessResponse<GetUserInfoResp> = {
        code: 0,
        data: userInfoMock,
      };
      return Promise.resolve(resp);
    }
    AppStorage.setOrCreate<GetUserInfoResp>(MockStorageMap.USER_INFO, UserDatasetMock.getUserInfo().data);
    return Promise.resolve(UserDatasetMock.getUserInfo());
  }

  public userLogin(): Promise<BaseResponse<UserLoginResp>> {
    return Promise.resolve(UserDatasetMock.userLoginResp());
  }

  public getRecommendList(): Promise<BaseResponse<GetRecommendListResp>> {
    const resp: BaseResponse<GetRecommendListResp> = recommendListResp;
    return Promise.resolve(resp);
  }

  //  订单列表
  public getOrderList(data: OrderListRequest): Promise<BaseResponse<GetOrderListInfoResp>> {
    const resp: BaseResponse<GetOrderListInfoResp> = OrderDatasetMock.getOrderListMock(data.orderClass);
    return Promise.resolve(resp);
  }

  //  取消预定
  public cancelOrder(data: CancelOrderRequest): Promise<BaseSuccessResponse> {
    OrderDatasetMock.cancelOrder(data);
    const resp: BaseSuccessResponse<undefined> = {
      code: 0,
      data: undefined,
    };
    return Promise.resolve(resp);
  }

  //   获取订单详情
  public getOrderDetail(data: OrderDetailRequest): Promise<BaseResponse<GetOrderDetailResp | undefined>> {
    const resp: BaseResponse<GetOrderDetailResp | undefined> = OrderDatasetMock.getOrderDetailMock(data.orderNo);
    return Promise.resolve(resp);
  }

  //   获取特展信息
  public getPerformanceInfo(): Promise<BaseResponse<GetPerformanceInfoResp>> {
    const resp: BaseResponse<GetPerformanceInfoResp> = PerformanceDatasetMock.getPerformanceInfoResp();
    return Promise.resolve(resp);
  }

  //   免费预约时间票务信息
  public getDayTicket(): Promise<BaseResponse<GetDayTicketResp>> {
    const resp: BaseResponse<GetDayTicketResp> = OrderDatasetMock.getDayTicketMock();
    return Promise.resolve(resp);
  }

  //   付费预约时间票务信息
  public getTimeTicket(data: string): Promise<BaseResponse<GetTimeTicketResp>> {
    const resp: BaseResponse<GetTimeTicketResp> = OrderDatasetMock.getTimeTicketMock();
    return Promise.resolve(resp);
  }

  //   讲解服务文本
  public getExplainText(): Promise<BaseResponse<GetExplainTextResp>> {
    const resp: BaseResponse<GetExplainTextResp> = explainTextResp;
    return Promise.resolve(resp);
  }

  //   省博介绍
  public getIntroduceText(): Promise<BaseResponse<GetIntroduceResp>> {
    const resp: BaseResponse<GetIntroduceResp> = introduceTextResp;
    return Promise.resolve(resp);
  }

  //   停车缴费
  public getParkingText(): Promise<BaseResponse<ParkTextResp[]>> {
    const resp: BaseResponse<ParkTextResp[]> = parkingTextResp;
    return Promise.resolve(resp);
  }

  //   隐私政策
  public getPrivacyText(): Promise<BaseResponse<string[][]>> {
    const resp: BaseResponse<string[][]> = privacyTextResp;
    return Promise.resolve(resp);
  }

  //   获取常用联系人
  public getContacts(): Promise<BaseResponse<ContactsResp>> {
    const resp: BaseResponse<ContactsResp> = ContactsDatasetMock.getContacts();
    return Promise.resolve(resp);
  }

  // 更新用户信息
  public updateUserInfo(data: UpdateUserInfoRequest): Promise<BaseSuccessResponse> {
    const userInfoMock = AppStorage.get<UpdateUserInfoRequest>(MockStorageMap.USER_INFO);
    if (userInfoMock) {
      userInfoMock.name = data.name;
      userInfoMock.nickname = data.nickname;
      userInfoMock.sex = data.sex;
      userInfoMock.cellphone = data.cellphone;
      userInfoMock.birthday = data.birthday;
      userInfoMock.avatar = data.avatar;
      AppStorage.set<UpdateUserInfoRequest>(MockStorageMap.USER_INFO, userInfoMock);
      AccountUtil.updateUserInfo(data as UserInfo);
    }
    const resp: BaseSuccessResponse<undefined> = {
      code: 0,
      data: undefined,
    };
    return Promise.resolve(resp);
  }

  //   更新常用联系人
  public upDateContacts(data: Contacts): Promise<BaseSuccessResponse> {
    ContactsDatasetMock.updateContacts(data);
    const resp: BaseSuccessResponse<undefined> = {
      code: 0,
      data: undefined,
    };
    return Promise.resolve(resp);
  }

  //   免费预定
  public orderFree(data: OrderFreeRequest): Promise<BaseSuccessResponse<GetOrderDetailResp>> {
    const resp: BaseSuccessResponse<GetOrderDetailResp> = OrderDatasetMock.orderFreeMock(data);
    return Promise.resolve(resp);
  }

  //   获取票种信息
  public getTicketType(data: string): Promise<BaseResponse<GetTicketTypeInfoResp>> {
    const resp: BaseResponse<GetTicketTypeInfoResp> = OrderDatasetMock.getTicketType(data);
    return Promise.resolve(resp);
  }

  //   预支付
  public prePayBuyTicket(data: PrepayBuyTicketRequest): Promise<BaseResponse<PrepayBuyTicketResp>> {
    const resp: BaseSuccessResponse<PrepayBuyTicketResp> = OrderDatasetMock.prepayBuyTicket(data);
    return Promise.resolve(resp);
  }

  //   banner图
  public getBannerImg(data: GetBannerImgRequest): Promise<BaseResponse<string | string[]>> {
    const resp: BaseSuccessResponse<string | string[]> = BannerDatasetMock.getBannerSource(data);
    return Promise.resolve(resp);
  }

  //  删除常用联系人
  public delContacts(data: string): Promise<BaseSuccessResponse<undefined>> {
    ContactsDatasetMock.delContacts(data);
    const resp: BaseSuccessResponse<undefined> = {
      code: 0,
      data: undefined,
    };
    return Promise.resolve(resp);
  }

  // 获取交通信息
  public getTrafficDetail(): Promise<BaseResponse<GetTrafficDetailResp>> {
    const data: GetTrafficDetailResp = {
      name: '博物馆',
      coordinate: '113.8827804,22.9241942',
    };
    const resp: BaseSuccessResponse<GetTrafficDetailResp> = {
      code: 0,
      data: data,
    };
    return Promise.resolve(resp);
  }
}

const httpsMock = new HttpApiMock();

export { httpsMock };
