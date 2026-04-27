import request from './AxiosBase';
import { URL_MAP } from '../common/Constant';
import { ICompany, IServicePoint } from '../model/IResponse';
import {
  IUserIdRequest,
  IPhoneRequest,
  ICommonTemplateReq,
  IUserSignRequest,
  IUserPointRequest,
  IClaimCouponRequest,
} from '../model/IRequest';
import { User } from '../model/User';
import { AddressBook } from '../model/AddressBook';
import { Template } from '../model/Template';
import { Goods } from '../model/Goods';
import { Parcel, ParcelWithLogistics } from '../model/Parcel';
import { UserSign } from '../model/UserSign';
import { PointDetail } from '../model/PointDetail';
import { Logistics } from '../model/Logistics';
import { Coupon } from '../model/Coupon';
import { Task } from '../model/Task';

export class HttpApi {
  /**
   * 用户登录
   */
  public static userLogin(phone: string): Promise<User> {
    const url = URL_MAP.USER_LOGIN;
    return request.post(url, { phone } as IPhoneRequest);
  }

  /**
   * 用户登出
   */
  public static userLogout(phone: string): Promise<boolean> {
    const url = URL_MAP.USER_LOGOUT;
    return request.post(url, { phone } as IPhoneRequest);
  }

  /**
   * 读取用户信息
   */
  public static queryUserInfo(phone: string): Promise<User> {
    const url = URL_MAP.GET_USER_INFO;
    return request.get(url, { params: { phone } });
  };


  /**
   * 更新用户信息
   */
  public static updateUserInfo(data: User): Promise<boolean> {
    const url = URL_MAP.UPDATE_USER_INFO;
    return request.put(url, data);
  };

  /**
   * 获取地址列表
   */
  public static queryAddressList(userId: number): Promise<AddressBook[]> {
    const url = URL_MAP.ADDRESS_LIST;
    return request.get(url, { params: { userId } as IUserIdRequest });
  }

  /**
   * 查询默认地址
   */
  public static queryDefaultAddress(userId: number): Promise<AddressBook> {
    const url = URL_MAP.DEFAULT_ADDRESS;
    return request.get(url, { params: { userId } as IUserIdRequest });
  }

  /**
   *  新增地址
   */
  public static addAddressBook(data: AddressBook): Promise<number> {
    const url = URL_MAP.ADD_ADDRESS;
    return request.post(url, data);
  }

  /**
   *  更新地址
   */
  public static updateAddressBook(data: AddressBook, isSetDefault: boolean = false): Promise<boolean> {
    const url = URL_MAP.UPDATE_ADDRESS;
    return request.put(url, data, { params: { isSetDefault } });
  }

  /**
   * 删除地址
   */
  public static deleteAddress(addressId: number): Promise<boolean> {
    const url = URL_MAP.DELETE_ADDRESS;
    return request.delete(url, { params: { addressId } });
  }

  /**
   * 查询寄件模板列表
   */
  public static queryTemplateList(userId: number): Promise<Template[]> {
    const url = URL_MAP.TEMPLATE_LIST;
    return request.get(url, { params: { userId } as IUserIdRequest });
  }

  /**
   *  新增寄件模板
   */
  public static addTemplate(data: Template): Promise<number> {
    const url = URL_MAP.ADD_TEMPLATE;
    return request.post(url, data);
  }

  /**
   *  查询寄件模板详情
   */
  public static queryTemplateDetail(templateId: number): Promise<Template | null> {
    const url = URL_MAP.TEMPLATE_DETAIL;
    return request.get(url, { params: { templateId } as ICommonTemplateReq });
  }

  /**
   *  更新寄件模板
   */
  public static updateTemplate(data: Template): Promise<number> {
    const url = URL_MAP.UPDATE_TEMPLATE;
    return request.put(url, data);
  }

  /**
   * 删除寄件模板
   */
  public static deleteTemplate(templateId: number): Promise<number> {
    const url = URL_MAP.DELETE_TEMPLATE;
    return request.delete(url, { params: { templateId } });
  }

  /**
   * 查询物品类型列表
   */
  public static queryGoodsList(): Promise<Goods[]> {
    const url = URL_MAP.GOODS_LIST;
    return request.get(url);
  }

  /**
   * 获取快递公司列表
   */
  public static getCompanyList(): Promise<ICompany[]> {
    const url = URL_MAP.COMPANY_LIST;
    return request.get(url);
  }

  /**
   * 获取服务点列表
   */
  public static getServicePointList(): Promise<IServicePoint[]> {
    const url = URL_MAP.SERVICE_POINT_LIST;
    return request.get(url);
  }

  /**
   *  新增寄件订单
   */
  public static createParcel(data: Parcel): Promise<number> {
    const url = URL_MAP.CREATE_ORDER;
    return request.post(url, data);
  }

  /**
   * 查询订单列表
   */
  public static queryParcelList(): Promise<Parcel[]> {
    const url = URL_MAP.ORDER_LIST;
    return request.get(url);
  }

  /**
   * 查询订单列表最新的一条数据
   */
  public static queryLatestParcel(): Promise<ParcelWithLogistics> {
    const url = URL_MAP.ORDER_LATEST;
    return request.get(url);
  }

  /**
   * 查询订单详情
   */
  public static queryParcelDetail(orderNo: string): Promise<ParcelWithLogistics> {
    const url = URL_MAP.ORDER_DETAIL;
    return request.get(url, { params: { orderNo } });
  }

  /**
   * 更新订单
   */
  public static updateOrder(data: Parcel): Promise<boolean> {
    const url = URL_MAP.UPDATE_ORDER;
    return request.put(url, data);
  }

  /**
   * 删除订单
   */
  public static deleteParcel(orderNo: string): Promise<boolean> {
    const url = URL_MAP.DELETE_ORDER;
    return request.delete(url, { params: { orderNo } });
  }

  /**
   *  新增运单物流轨迹
   */
  public static createLogistics(data: Logistics): Promise<boolean> {
    const url = URL_MAP.CREATE_LOGISTICS;
    return request.post(url, data);
  }

  /**
   * 查询运单的物流轨迹个数
   */
  public static queryLogisticsCount(orderNo: string): Promise<number> {
    const url = URL_MAP.LOGISTICS_COUNT;
    return request.get(url, { params: { orderNo } });
  }


  /**
   * 自动补全运单的物流轨迹
   */
  public static autoUpdateLogistics(data: Parcel): Promise<boolean> {
    const url = URL_MAP.AUTO_UPDATE_LOGISTICS;
    return request.post(url, data);
  }

  /**
   * 查询用户本周签到数据
   */
  public static queryWeeklyData(userId: number, monday: number): Promise<UserSign> {
    const url = URL_MAP.WEEKLY_SIGN;
    return request.get(url, { params: { userId, monday } });
  }

  /**
   * 执行签到
   */
  public static doSign(userId: number, dayIndex: number, points: number, monday: number): Promise<number> {
    const url = URL_MAP.DO_SIGN;
    return request.post(url, {
      userId,
      dayIndex,
      points,
      monday,
    } as IUserSignRequest);
  }

  /**
   * 用户积分变动
   */
  public static changeUserPoints(userId: number, amount: number, desc: string): Promise<number> {
    const url = URL_MAP.ADD_POINTS_DETAIL;
    return request.post(url, { userId, amount, desc } as IUserPointRequest);
  }

  /**
   * 查询积分明细列表
   */
  public static queryPointsHistory(userId: number, startTime: number, endTime: number): Promise<PointDetail[]> {
    const url = URL_MAP.POINTS_HISTORY;
    return request.get(url, { params: { userId, startTime, endTime } });
  }

  /**
   * 查询用户日常任务
   */
  public static queryDailyTasks(userId: number): Promise<Task[]> {
    const url = URL_MAP.DAILY_TASK;
    return request.get(url, { params: { userId } });
  }

  /**
   * 完成日常任务，领取积分
   */
  public static claimTaskReward(userId: number, task: Task): Promise<number> {
    const url = URL_MAP.CLAIM_TASK_REWARD;
    return request.post(url, task, { params: { userId }});
  }

  /**
   * 获取用户优惠券列表
   */
  public static queryUserCouponList(userId: number): Promise<Coupon[]> {
    const url = URL_MAP.USER_COUPON_LIST;
    return request.get(url, { params: { userId } });
  }

  /**
   * 获取福利页优惠券模板列表
   */
  public static queryCouponTemplateList(userId: number): Promise<Coupon[]> {
    const url = URL_MAP.COUPON_TEMPLATE_LIST;
    return request.get(url, { params: { userId } });
  }

  /**
   * 领取优惠券
   */
  public static claimCoupon(userId: number, couponId: number): Promise<number> {
    const url = URL_MAP.CLAIM_COUPON;
    return request.post(url, { userId, couponId } as IClaimCouponRequest);
  }

  /**
   * 一键领取所有包含“会员”限制说明的专属优惠券
   */
  public static claimMemberBenefitCoupons(userId: number): Promise<number> {
    const url = URL_MAP.BATCH_CLAIM_COUPON;
    return request.post(url, { userId } as IUserIdRequest);
  }

  /**
   * 检查是否有未领取的会员专属优惠券
   */
  public static hasUnclaimedMemberCoupons(userId: number): Promise<boolean> {
    const url = URL_MAP.HAS_UN_CLAIM_COUPON;
    return request.post(url, { userId } as IUserIdRequest);
  }


  /**
   * 使用优惠券
   */
  public static useCoupon(userId: number, couponId: number): Promise<boolean> {
    const url = URL_MAP.USE_COUPON;
    return request.put(url, { userId, couponId } as IClaimCouponRequest);
  }

  /**
   * 退还优惠券
   */
  public static refundCoupon(userId: number, couponId: number): Promise<boolean> {
    const url = URL_MAP.REFUND_COUPON;
    return request.put(url, { userId, couponId } as IClaimCouponRequest);
  }
}
