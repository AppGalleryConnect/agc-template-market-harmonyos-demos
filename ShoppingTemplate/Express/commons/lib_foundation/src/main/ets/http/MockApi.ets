import AxiosMockAdapter from '@hw-agconnect/axios-mock-adapter';
import { AxiosRequestConfig, HttpStatusCode } from '@ohos/axios';
import { URL_MAP } from '../common/Constant';
import { AddressBookDB } from '../database/AddressBookDB';
import { CouponDB } from '../database/CouponDB';
import { GoodsDB } from '../database/GoodsDB';
import { LogisticsDB } from '../database/LogisticsDB';
import { ParcelDB } from '../database/ParcelDB';
import { PointDetailDB } from '../database/PointDetailDB';
import { TaskDB } from '../database/TaskDB';
import { TemplateDB } from '../database/TemplateDB';
import { UserCouponDB } from '../database/UserCouponDB';
import { UserDB } from '../database/UserDB';
import { UserSignDB } from '../database/UserSignDB';
import { AddressBook } from '../model/AddressBook';
import {
  IUserIdRequest,
  IDeleteAddress,
  IPhoneRequest,
  ISetDefaultAddress,
  ICommonTemplateReq,
  ISignWeekRequest,
  IUserSignRequest,
  IUserPointRequest,
  IPointHistoryRequest,
  IParcelDetailRequest,
  IClaimCouponRequest,
} from '../model/IRequest';
import { Logistics } from '../model/Logistics';
import { Parcel } from '../model/Parcel';
import { Task } from '../model/Task';
import { Template } from '../model/Template';
import { User } from '../model/User';
import { MockData } from './MockData';

export class MockApi {
  public start(adapter: AxiosMockAdapter) {
    // 用户登录
    adapter.onPost(URL_MAP.USER_LOGIN).reply((config: AxiosRequestConfig) => {
      return new Promise((resolve) => {
        setTimeout(async() => {
          const data = JSON.parse(config.data) as IPhoneRequest;
          const userInfo = await UserDB.userLogin(data.phone);
          resolve([HttpStatusCode.Ok, userInfo]);
        }, 300);
      });
    });

    // 用户登出
    adapter.onPost(URL_MAP.USER_LOGOUT).reply((config: AxiosRequestConfig) => {
      return new Promise((resolve) => {
        setTimeout(async() => {
          const data = JSON.parse(config.data) as IPhoneRequest;
          const loginStatus = await UserDB.userLogout(data.phone);
          resolve([HttpStatusCode.Ok, loginStatus]);
        }, 300);
      });
    });

    // 获取用户信息
    adapter.onGet(URL_MAP.GET_USER_INFO).reply((config: AxiosRequestConfig) => {
      return new Promise((resolve) => {
        setTimeout(async() => {
          const data: IPhoneRequest = config.params;
          const userInfo = await UserDB.queryUser(data.phone);
          resolve([HttpStatusCode.Ok, userInfo]);
        }, 300);
      });
    });

    // 更新用户信息
    adapter.onPut(URL_MAP.UPDATE_USER_INFO).reply((config: AxiosRequestConfig) => {
      return new Promise((resolve) => {
        setTimeout(async() => {
          const data = JSON.parse(config.data) as User;
          const resp = await UserDB.updateUser(data);
          resolve([HttpStatusCode.Ok, resp]);
        }, 300);
      });
    });

    // 获取用户本周签到数据
    adapter.onGet(URL_MAP.WEEKLY_SIGN).reply((config: AxiosRequestConfig) => {
      return new Promise((resolve) => {
        setTimeout(async() => {
          const data: ISignWeekRequest = config.params;
          const resp = await UserSignDB.getWeeklyData(data.userId, data.monday);
          resolve([HttpStatusCode.Ok, resp]);
        }, 300);
      });
    });

    // 签到操作
    adapter.onPost(URL_MAP.DO_SIGN).reply((config: AxiosRequestConfig) => {
      return new Promise((resolve) => {
        setTimeout(async() => {
          const data = JSON.parse(config.data) as IUserSignRequest;
          const isSubscribe = await UserSignDB.doSign(data);
          resolve([HttpStatusCode.Ok, isSubscribe]);
        }, 300);
      });
    });

    // 获取地址列表
    adapter.onGet(URL_MAP.ADDRESS_LIST).reply((config: AxiosRequestConfig) => {
      return new Promise((resolve) => {
        setTimeout(async() => {
          const data: IUserIdRequest = config.params;
          const addressList = await AddressBookDB.queryAddressList(data.userId);
          resolve([HttpStatusCode.Ok, addressList]);
        }, 300);
      });
    });

    // 获取默认地址
    adapter.onGet(URL_MAP.DEFAULT_ADDRESS).reply((config: AxiosRequestConfig) => {
      return new Promise((resolve) => {
        setTimeout(async() => {
          const data: IUserIdRequest = config.params;
          const address = await AddressBookDB.queryDefaultAddress(data.userId);
          resolve([HttpStatusCode.Ok, address]);
        }, 300);
      });
    });

    // 新增地址
    adapter.onPost(URL_MAP.ADD_ADDRESS).reply((config: AxiosRequestConfig) => {
      return new Promise((resolve) => {
        setTimeout(async() => {
          const data = JSON.parse(config.data) as AddressBook;
          const resp = await AddressBookDB.addAddress(data);
          resolve([HttpStatusCode.Ok, resp]);
        }, 300);
      });
    });

    // 更新地址信息
    adapter.onPut(URL_MAP.UPDATE_ADDRESS).reply((config: AxiosRequestConfig) => {
      return new Promise((resolve) => {
        setTimeout(async() => {
          const data = JSON.parse(config.data) as AddressBook;
          const param = config.params as ISetDefaultAddress;
          const resp = await AddressBookDB.updateAddressBook(data, param.isSetDefault);
          resolve([HttpStatusCode.Ok, resp]);
        }, 300);
      });
    });

    // 删除地址
    adapter.onDelete(URL_MAP.DELETE_ADDRESS).reply((config: AxiosRequestConfig) => {
      return new Promise((resolve) => {
        setTimeout(async() => {
          const param = config.params as IDeleteAddress;
          const resp = await AddressBookDB.deleteAddress(param.addressId);
          resolve([HttpStatusCode.Ok, resp]);
        }, 300);
      });
    })

    // 查询寄件模板列表
    adapter.onGet(URL_MAP.TEMPLATE_LIST).reply((config: AxiosRequestConfig) => {
      return new Promise((resolve) => {
        setTimeout(async() => {
          const data: IUserIdRequest = config.params;
          const templateList = await TemplateDB.queryTemplateList(data.userId);
          resolve([HttpStatusCode.Ok, templateList]);
        }, 300);
      });
    });

    // 新增寄件模板
    adapter.onPost(URL_MAP.ADD_TEMPLATE).reply((config: AxiosRequestConfig) => {
      return new Promise((resolve) => {
        setTimeout(async() => {
          const data = JSON.parse(config.data) as Template;
          const resp = await TemplateDB.addTemplate(data);
          resolve([HttpStatusCode.Ok, resp]);
        }, 300);
      });
    });

    // 查询寄件模板详情
    adapter.onGet(URL_MAP.TEMPLATE_DETAIL).reply((config: AxiosRequestConfig) => {
      return new Promise((resolve) => {
        setTimeout(async() => {
          const data: ICommonTemplateReq = config.params;
          const templateDetail = await TemplateDB.queryTemplateDetail(data.templateId);
          resolve([HttpStatusCode.Ok, templateDetail]);
        }, 300);
      });
    });

    // 更新寄件模板
    adapter.onPut(URL_MAP.UPDATE_TEMPLATE).reply((config: AxiosRequestConfig) => {
      return new Promise((resolve) => {
        setTimeout(async() => {
          const data = JSON.parse(config.data) as Template;
          const resp = await TemplateDB.updateTemplate(data);
          resolve([HttpStatusCode.Ok, resp]);
        }, 300);
      });
    });

    // 删除寄件模板
    adapter.onDelete(URL_MAP.DELETE_TEMPLATE).reply((config: AxiosRequestConfig) => {
      return new Promise((resolve) => {
        setTimeout(async() => {
          const param = config.params as ICommonTemplateReq;
          const resp = await TemplateDB.deleteTemplate(param.templateId);
          resolve([HttpStatusCode.Ok, resp]);
        }, 300);
      });
    })

    // 查询物品类型列表
    adapter.onGet(URL_MAP.GOODS_LIST).reply(() => {
      return new Promise((resolve) => {
        setTimeout(async() => {
          const goodsList = await GoodsDB.queryGoodsList()
          resolve([HttpStatusCode.Ok, goodsList]);
        }, 300);
      });
    });

    // 创建寄件订单
    adapter.onPost(URL_MAP.CREATE_ORDER).reply((config: AxiosRequestConfig) => {
      return new Promise((resolve) => {
        setTimeout(async() => {
          const data = JSON.parse(config.data) as Parcel;
          const resp = await ParcelDB.createParcel(data);
          resolve([HttpStatusCode.Ok, resp]);
        }, 300);
      });
    });

    // 获取订单列表
    adapter.onGet(URL_MAP.ORDER_LIST).reply(() => {
      return new Promise(async (resolve) => {
        setTimeout(async() => {
          const resp = await ParcelDB.queryParcelList();
          resolve([HttpStatusCode.Ok, resp]);
        }, 300);
      });
    });

    // 获取订单列表最新一条数据
    adapter.onGet(URL_MAP.ORDER_LATEST).reply(() => {
      return new Promise(async (resolve) => {
        const resp = await ParcelDB.queryLatestParcel();
        resolve([HttpStatusCode.Ok, resp]);
      });
    });

    // 获取订单详情
    adapter.onGet(URL_MAP.ORDER_DETAIL).reply((config: AxiosRequestConfig) => {
      const param = config.params as IParcelDetailRequest;
      return new Promise((resolve) => {
        setTimeout(async() => {
          const resp = await ParcelDB.queryParcelDetail(param.orderNo);
          resolve([HttpStatusCode.Ok, resp]);
        }, 300);
      });

    });

    // 更新订单
    adapter.onPut(URL_MAP.UPDATE_ORDER).reply((config: AxiosRequestConfig) => {
      return new Promise((resolve) => {
        setTimeout(async() => {
          const data = JSON.parse(config.data) as Parcel;
          const resp = await ParcelDB.updateParcel(data)
          resolve([HttpStatusCode.Ok, resp]);
        }, 300);
      });
    })

    // 删除订单
    adapter.onDelete(URL_MAP.DELETE_ORDER).reply((config: AxiosRequestConfig) => {
      return new Promise((resolve) => {
        setTimeout(async() => {
          const param = config.params as IParcelDetailRequest;
          const resp = await ParcelDB.deleteParcel(param.orderNo);
          resolve([HttpStatusCode.Ok, resp]);
        }, 300);
      });
    })

    // 创建运单物流轨迹
    adapter.onPost(URL_MAP.CREATE_LOGISTICS).reply((config: AxiosRequestConfig) => {
      return new Promise((resolve) => {
        setTimeout(async() => {
          const data = JSON.parse(config.data) as Logistics;
          const resp = await LogisticsDB.createLogistics(data);
          resolve([HttpStatusCode.Ok, resp]);
        }, 300);
      });
    });

    // 查询运单的物流轨迹个数
    adapter.onGet(URL_MAP.LOGISTICS_COUNT).reply((config: AxiosRequestConfig) => {
      return new Promise((resolve) => {
        setTimeout(async() => {
          const param = config.params as IParcelDetailRequest;
          const resp = await LogisticsDB.queryLogisticsCountByNumber(param.orderNo);
          resolve([HttpStatusCode.Ok, resp]);
        }, 300);
      });
    });

    // 自动补全运单的物流轨迹
    adapter.onPost(URL_MAP.AUTO_UPDATE_LOGISTICS).reply((config: AxiosRequestConfig) => {
      return new Promise((resolve) => {
        setTimeout(async() => {
          const data = JSON.parse(config.data) as Parcel;
          const resp = await ParcelDB.autoUpdateLogistics(data);
          resolve([HttpStatusCode.Ok, resp]);
        }, 300);
      });
    });

    // 新增积分明细
    adapter.onPost(URL_MAP.ADD_POINTS_DETAIL).reply((config: AxiosRequestConfig) => {
      return new Promise((resolve) => {
        setTimeout(async() => {
          const data = JSON.parse(config.data) as IUserPointRequest;
          const resp = await PointDetailDB.changePoints(data);
          resolve([HttpStatusCode.Ok, resp]);
        }, 300);
      });
    });

    // 获取积分明细列表
    adapter.onGet(URL_MAP.POINTS_HISTORY).reply((config: AxiosRequestConfig) => {
      return new Promise((resolve) => {
        setTimeout(async() => {
          const param = config.params as IPointHistoryRequest;
          const resp = await PointDetailDB.queryPointHistory(param);
          resolve([HttpStatusCode.Ok, resp]);
        }, 300);
      });
    });

    // 获取用户日常任务
    adapter.onGet(URL_MAP.DAILY_TASK).reply((config: AxiosRequestConfig) => {
      return new Promise((resolve) => {
        setTimeout(async() => {
          const param = config.params as IUserIdRequest;
          const resp = await TaskDB.queryTaskList(param.userId);
          resolve([HttpStatusCode.Ok, resp]);
        }, 300);
      });
    });

    // 完成日常任务，领取积分
    adapter.onPost(URL_MAP.CLAIM_TASK_REWARD).reply((config: AxiosRequestConfig) => {
      return new Promise((resolve) => {
        setTimeout(async() => {
          const data = JSON.parse(config.data) as Task;
          const param = config.params as IUserIdRequest;
          const resp = await TaskDB.claimTaskReward(param.userId, data);
          resolve([HttpStatusCode.Ok, resp]);
        }, 300);
      });
    });

    // 获取服务点列表
    adapter.onGet(URL_MAP.SERVICE_POINT_LIST).reply(() => {
      return [HttpStatusCode.Ok, MockData.SERVICE_POINT_LIST];
    });

    // 获取快递公司列表
    adapter.onGet(URL_MAP.COMPANY_LIST).reply(() => {
      return [HttpStatusCode.Ok, MockData.COMPANY_LIST];
    });

    // 获取用户优惠券列表
    adapter.onGet(URL_MAP.USER_COUPON_LIST).reply((config: AxiosRequestConfig) => {
      return new Promise((resolve) => {
        setTimeout(async() => {
          const data: IUserIdRequest = config.params;
          let resp = await UserCouponDB.queryUserCouponList(data.userId);
          resolve([HttpStatusCode.Ok, resp]);
        }, 300);
      });
    });

    // 获取福利页优惠券列表
    adapter.onGet(URL_MAP.COUPON_TEMPLATE_LIST).reply((config: AxiosRequestConfig) => {
      return new Promise((resolve) => {
        setTimeout(async() => {
          const data: IUserIdRequest = config.params;
          let resp = await CouponDB.queryCouponList(data.userId);
          resolve([HttpStatusCode.Ok, resp]);
        }, 300);
      });
    });

    // 领取优惠券
    adapter.onPost(URL_MAP.CLAIM_COUPON).reply((config: AxiosRequestConfig) => {
      return new Promise((resolve) => {
        setTimeout(async() => {
          const data = JSON.parse(config.data) as IClaimCouponRequest;
          const resp = await UserCouponDB.claimCoupon(data.userId, data.couponId);
          resolve([HttpStatusCode.Ok, resp]);
        }, 300);
      });
    });

    // 一键领取所有包含“会员”限制说明的专属优惠券
    adapter.onPost(URL_MAP.BATCH_CLAIM_COUPON).reply((config: AxiosRequestConfig) => {
      return new Promise((resolve) => {
        setTimeout(async() => {
          const data = JSON.parse(config.data) as IUserIdRequest;
          const resp = await UserCouponDB.claimMemberBenefitCoupons(data.userId);
          resolve([HttpStatusCode.Ok, resp]);
        }, 300);
      });
    });

    // 检查是否有未领取的会员专属优惠券
    adapter.onPost(URL_MAP.HAS_UN_CLAIM_COUPON).reply((config: AxiosRequestConfig) => {
      return new Promise((resolve) => {
        setTimeout(async() => {
          const data = JSON.parse(config.data) as IUserIdRequest;
          const resp = await UserCouponDB.hasUnclaimedMemberCoupons(data.userId);
          resolve([HttpStatusCode.Ok, resp]);
        }, 300);
      });
    });

    // 使用优惠券
    adapter.onPut(URL_MAP.USE_COUPON).reply((config: AxiosRequestConfig) => {
      return new Promise((resolve) => {
        setTimeout(async() => {
          const data = JSON.parse(config.data) as IClaimCouponRequest;
          const resp = await UserCouponDB.useCoupon(data.userId, data.couponId);
          resolve([HttpStatusCode.Ok, resp]);
        }, 300);
      });
    });

    // 退还优惠券
    adapter.onPut(URL_MAP.REFUND_COUPON).reply((config: AxiosRequestConfig) => {
      return new Promise((resolve) => {
        setTimeout(async() => {
          const data = JSON.parse(config.data) as IClaimCouponRequest;
          const resp = await UserCouponDB.refundCoupon(data.userId, data.couponId);
          resolve([HttpStatusCode.Ok, resp]);
        }, 300);
      });
    });
  }
}