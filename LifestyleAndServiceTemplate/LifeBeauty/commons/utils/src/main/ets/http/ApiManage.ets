import { AxiosRequestConfig } from '@ohos/axios';
import request from './AxiosBase';
import { ActiveMemberRequest, AppointmentInfo, GetUserInfoResp, GoodListInfo,
  MyGroupInfo,
  StoreInfo } from '../model/Model';
import { AppointState, URL_MAP } from '../common/Constant';
import {
  IBindCodeRequest,
  ICancelReserveRequest,
  ICreateAppointmentRequest,
  ILoginWithHuaweiIDRequest,
  ISubmitOrderRequest,
  IRebindConfirmRequest,
  IUpdateAppointmentRequest,
  IRefundGroup,
} from '../model/IRequest';
import {
  LoginWithHuaweiIDResp,
  BindMobileWithCodeResp,
  IStoreInfo,
  IGroupInfo,
  ISingleVisitCard,
  IBaseStore,
  IMySingleCardInfo,
} from '../model/IResponse';

/**
 * 华为账号登录
 */
export const loginWithHuaweiID =
  (data: ILoginWithHuaweiIDRequest, config?: AxiosRequestConfig): Promise<LoginWithHuaweiIDResp> => {
    const url = URL_MAP.LOGIN_WITH_HUAWEI_ID;
    return request.post(url, data, config);
  };

/**
 * 刷新用户token
 */
export const refreshToken = () => {
  const url = URL_MAP.REFRESH_TOKEN;
  return request.post(url);
};

/**
 * 绑定手机号
 */
export const bindMobileWithCode = (code: string, config?: AxiosRequestConfig): Promise<BindMobileWithCodeResp> => {
  const url = URL_MAP.BIND_MOBILE_WITH_CODE;
  const data: IBindCodeRequest = { code };
  return request.post(url, data, config);
};

/**
 * 绑定手机号-确认换绑
 */
export const confirmRebindMobileWithSecret = (rebindSecret: string, config?: AxiosRequestConfig) => {
  const url = URL_MAP.CONFIRM_REBIND_MOBILE;
  const data: IRebindConfirmRequest = { rebindSecret: rebindSecret };
  return request.post(url, data, config);
};

/**
 * 读取用户信息
 */
export const getUserInfo = (): Promise<GetUserInfoResp> => {
  const url = URL_MAP.GET_USER_INFO;
  return request.get(url);
};

/**
 * 手机号解绑
 */
export const unbindMobile = () => {
  const url = URL_MAP.UNBIND_MOBILE;
  return request.post(url);
};

/**
 * 查询门店信息
 */
export const getStoreInfo = (): Promise<StoreInfo> => {
  const url = URL_MAP.GET_STORE_INFO;
  return request.get(url);
};

/**
 * 查询所有门店列表信息
 */
export const getStoreList = (): Promise<IBaseStore[]> => {
  const url = URL_MAP.GET_STORE_LIST;
  return request.get(url);
};

/**
 * 查询商品列表
 */
export const getGoodList = (): Promise<GoodListInfo[]> => {
  const url = URL_MAP.GET_GOOD_LIST;
  return request.get(url);
};

/**
 * 查询预约列表
 */
export const getAppointmentList = (status: AppointState[]): Promise<AppointmentInfo[]> => {
  const url = URL_MAP.GET_APPOINTMENT_LIST;
  return request.get(url, { params: { status } });
};

/**
 * 创建预约
 */
export const createAppointmentInfo = (data: ICreateAppointmentRequest, config?: AxiosRequestConfig) => {
  const url = URL_MAP.CREATE_APPOINTMENT_INFO;
  return request.post(url, data, config);
};

/**
 * 修改预约信息
 */
export const updateAppointmentInfo = (data: IUpdateAppointmentRequest, config?: AxiosRequestConfig) => {
  const url = URL_MAP.UPDATE_APPOINTMENT_INFO;
  return request.post(url, data, config);
};

/**
 * 取消预约
 */
export const cancelAppointment = (id: number, config?: AxiosRequestConfig) => {
  const url = URL_MAP.CANCEL_APPOINTMENT;
  const data: ICancelReserveRequest = { reserveId: id };
  return request.post(url, data, config);
};


/**
 * 开通会员卡
 */
export const activeMemberCard = (data: ActiveMemberRequest) => {
  const url = URL_MAP.ACTIVE_MEMBER_CARD;
  return request.post(url, data);
};


/**
 * 次卡查询
 */
export const getSingleVisitCardList = (): Promise<ISingleVisitCard[]> => {
  const url = URL_MAP.GET_SINGLE_VISIT_CARD_LIST;
  return request.get(url);
};

/**
 * 团购查询
 */
export const getGroupList = (): Promise<IGroupInfo[]> => {
  const url = URL_MAP.GET_GROUP_LIST;
  return request.get(url);
};

/**
 * 预下单
 */
export const preOrder = (data: ISubmitOrderRequest, config?: AxiosRequestConfig) => {
  const url = URL_MAP.PRE_ORDER;
  return request.post(url, data, config);
};

/**
 * 查询用户购买的次卡
 */
export const getMySingleVisitCardList = (): Promise<IMySingleCardInfo[]> => {
  const url = URL_MAP.GET_MY_SINGLE_VISIT_CARD_LIST;
  return request.get(url);
};

/**
 * 查询用户购买的团购
 */
export const getMyGroupList = (): Promise<MyGroupInfo[]> => {
  const url = URL_MAP.GET_MY_GROUP_LIST;
  return request.get(url);
};

/**
 * 团购退款
 */
export const refund = (orderNo: string) => {
  const url = URL_MAP.REFUND_GROUP;
  const data: IRefundGroup = { orderNo };
  return request.post(url, data);
}
