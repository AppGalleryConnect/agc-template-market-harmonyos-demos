import { InternalAxiosRequestConfig } from '@ohos/axios';
import {
  ICancelReserveRequest,
  ICreateAppointmentRequest,
  IQueryAppointList,
  IRefundGroup,
  ISubmitOrderRequest,
  IUpdateAppointmentRequest,
} from '../model/IRequest';
import {
  BindMobileWithCodeResp,
  IAppointment,
  IBaseStore,
  IGoodList,
  IMyGroupInfo,
  IMySingleCardInfo,
  IStoreInfo,
  IUserInfo,
} from '../model/IResponse';
import { MockData } from './MockData';
import { AppointState, GroupOrderStatus, OrderType } from '../common/Constant';
import { MyGroupInfo } from '../model/Model';

export class MockApi {
  // 我的预约
  static myAppointmentList: IAppointment[] = [];
  // 我的团购
  static myGroupList: IMyGroupInfo[] = [];
  // 我的次卡
  static mySingleCardList: IMySingleCardInfo[] = [];
  static isBindMobile: boolean = false;

  static transAppointment(raw: ICreateAppointmentRequest): IAppointment {
    let goodName = raw.goodId;
    MockData.GOOD_LIST.forEach(v => {
      v.goods.forEach(g => {
        if (g.id === Number(raw.goodId)) {
          goodName = g.title;
        }
      })
    })
    const resp: IAppointment = {
      id: MockData.initialAppointId++,
      storeId: MockData.STORE_INFO.id,
      userId: MockData.USER_ID,
      type: 0,
      reserveTime: Number(raw.reserveTime),
      duration: 0,
      remarks: raw.remarks,
      state: 10,
      contactName: raw.name,
      contactPhone: raw.phone,
      itemName: goodName,
      itemPic: '',
      numbers: Number(raw.numbers),
      setSchedule: 0,
      setSubscription: 0,
      completedTime: null,
      createdTime: new Date().getTime().toString(),
      nickName: '',
      avatar: '',
    };
    return resp;
  }

  static loginWithHuaweiID() {
    return MockData.LOGIN_RESP;
  }

  static refreshToken() {
    return true;
  }

  static bindMobileWithCode(): BindMobileWithCodeResp {
    MockApi.isBindMobile = true;
    const resp: BindMobileWithCodeResp = {
      status: '0',
      rebindSecret: '',
    };
    return resp;
  }

  static confirmRebindMobileWithSecret() {
    return true;
  }

  static getUserInfo(): IUserInfo {
    return MockApi.isBindMobile ? MockData.USER_INFO_FULL : MockData.USER_INFO_UNBIND;
  }

  static unbindMobile() {
    MockApi.isBindMobile = false;
    return true;
  }

  static getStoreInfo(): IStoreInfo {
    return MockData.STORE_INFO;
  }

  static getStoreList(): IBaseStore[] {
    return MockData.STORE_LIST;
  }

  static getGoodList(): IGoodList[] {
    return MockData.GOOD_LIST;
  }

  static getAppointmentList(config?: InternalAxiosRequestConfig): IAppointment[] {
    const params: IQueryAppointList = config?.params;
    return MockApi.myAppointmentList.filter(v => {
      return (params.status || []).includes(v.state);
    });
  }

  static createAppointmentInfo(config?: InternalAxiosRequestConfig) {
    const data: ICreateAppointmentRequest = JSON.parse(config?.data ?? '{}') as ICreateAppointmentRequest;
    const resp = MockApi.transAppointment(data);
    MockApi.myAppointmentList.splice(0, 0, resp);
    return true;
  }

  static updateAppointmentInfo(config?: InternalAxiosRequestConfig) {
    const data: IUpdateAppointmentRequest = JSON.parse(config?.data ?? '{}') as IUpdateAppointmentRequest;
    const item = MockApi.myAppointmentList.find(v => v.id === data.reserveId);
    if (item) {
      item.setSubscription = data.setSubscription;
      item.setSchedule = data.setSchedule;
    }
    return true;
  }

  static cancelAppointment(config?: InternalAxiosRequestConfig) {
    const data: ICancelReserveRequest = JSON.parse(config?.data ?? '{}') as ICancelReserveRequest;
    const item = MockApi.myAppointmentList.find(v => v.id === data.reserveId);
    if (item) {
      item.state = AppointState.CANCEL;
    }
    return true;
  }

  static activeMemberCard() {
    MockData.USER_INFO_FULL.memberId = new Date().getTime().toString();
    return true;
  }

  static getSingleVisitCardList() {
    return MockData.SINGLE_CARD_LIST;
  }

  static getGroupList() {
    return MockData.GROUP_LIST;
  }

  static preOrder(config?: InternalAxiosRequestConfig) {
    const data: ISubmitOrderRequest = JSON.parse(config?.data ?? '{}') as ISubmitOrderRequest;
    // 区分类型，团购/次卡
    if (data.type === OrderType.SINGLE_CARD) {
      const raw = MockData.SINGLE_CARD_LIST.find(v => v.id === data.projectId);
      const resp: IMySingleCardInfo = {
        singleCardSerialNo: new Date().getTime().toString(),
        singleCardId: data.projectId,
        title: raw?.title ?? '',
        availableNums: raw?.availableNum ?? 0,
        leftNums: raw?.availableNum ?? 0,
        availableProName: raw?.projectNum.toString() ?? '',
        availablePeriod: -1,
        usageRecord: [],
      };
      MockApi.mySingleCardList.splice(0, 0, resp);
    } else {
      const resp = new MyGroupInfo();
      resp.groupId = data.projectId;
      resp.contactPhone = data.contactPhone;
      resp.purchaseNums = data.numbers;
      resp.actualPay = data.actualPay;
      resp.status = GroupOrderStatus.AVAILABLE;
      resp.groupSerialNo = new Date().getTime().toString();
      resp.orderNo = new Date().getTime().toString() + new Date().getTime().toString();
      resp.orderTime = new Date().getTime();
      resp.payTime = new Date().getTime();
      const raw = MockData.GROUP_LIST.find(v => v.id === data.projectId);
      if (raw) {
        resp.title = raw.title;
        resp.subTitle = raw.subTitle;
        resp.images = raw.images;
        resp.vipPrice = raw.vipPrice;
        resp.groupContent = raw.groupContent;
      }
      MockApi.myGroupList.splice(0, 0, resp);
    }
    return true;
  }

  static getMySingleVisitCardList() {
    return MockApi.mySingleCardList;
  }

  static getMyGroupList() {
    return MockApi.myGroupList;
  }

  static refund(config?: InternalAxiosRequestConfig) {
    const data: IRefundGroup = JSON.parse(config?.data ?? '{}') as IRefundGroup;
    MockApi.myGroupList.find((v) => {
      if (v.orderNo === data.orderNo) {
        v.status = GroupOrderStatus.REFUND;
        v.refundTime = new Date().getTime();
      }
    })

    return true;
  }
}