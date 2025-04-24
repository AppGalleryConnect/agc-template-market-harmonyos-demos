import { AppStorageV2 } from '@kit.ArkUI';
import { AppointState, GroupOrderStatus, OrderType } from '../common/Constant';
import { IActiveMemberRequest } from './IRequest';
import {
  GroupContent,
  IAppointment,
  IGoodInfo,
  IGoodList,
  IGroupInfo,
  IMyGroupInfo,
  IntroItem,
  ISingleVisitCard,
  IStoreInfo,
  IUserInfo,
} from './IResponse';

/**
 * 门店模型
 */
@ObservedV2
export class StoreInfo implements IStoreInfo {
  // 门店ID
  id: number = 0;
  // 品牌商ID
  brandId: number = 0;
  // 店铺名称
  storeName: string = '';
  // 店铺简介
  storeProfile: string = '';
  // 联系电话
  mobile: string = '';
  // 店铺logo链接
  logoUrl: string = '';
  // 坐标
  coords: string = '';
  // 地区
  region: string = '';
  // 地址
  address: string = '';
  // 认证名称
  certName: string = '';
  // 店铺横幅
  storeBanner: string = '';
  // 营业执照
  businessLicense: string = '';
  // 评分
  score: string = '5.0';
  // 经营状态
  businessStatus: number = 0;
  // 经营时间
  businessTimes: string = '';
}

/**
 * 商品信息
 */
@ObservedV2
export class GoodInfo implements IGoodInfo {
  // 商品ID
  id: number = 0;
  // 商品名称
  title: string = '';
  // 所属类目ID
  classId: number = 0;
  // 主图
  images: string[] = [];
  // 详情富文本
  intro: IntroItem[] = [];
  // 价格
  price: number = 0;
  // 会员价
  vipPrice: number = 0;

  constructor(v?: GoodInfo) {
    this.id = v?.id || 0;
    this.title = v?.title || '';
    this.classId = v?.classId || 0;
    this.images = v?.images || [];
    this.intro = v?.intro || [];
    this.price = v?.price || 0;
    this.vipPrice = v?.vipPrice || 0;
  }
}

/**
 * 商品列表
 */
@ObservedV2
export class GoodListInfo implements IGoodList {
  // 类目的ID
  id: number = 0;
  // 类目名称
  title: string = '';
  // 商品列表
  goods: GoodInfo[] = [];

  constructor(v?: GoodListInfo) {
    this.id = v?.id || 0;
    this.title = v?.title || '';
    this.goods = v?.goods?.map(good => new GoodInfo(good)) || [];
  }
}

/**
 * 预约信息
 */
@ObservedV2
export class AppointmentInfo implements IAppointment {
  // 成功预约的ID
  id: number = 0;
  // 门店ID
  storeId: number = 0;
  // 用户ID
  userId: number = 0;
  //数据类型
  type: number = 0;
  // 预约时间
  @Trace reserveTime: number = 0;
  // 持续时间
  duration: number = 0;
  // 预约备注
  remarks: string = '';
  // 状态
  @Trace state: AppointState = AppointState.NEW;
  // 联系人姓名
  contactName: string = '';
  // 联系人电话
  contactPhone: string = '';
  // 预约的项目名称
  itemName: string = '';
  // 商品图片
  itemPic: string = '';
  // 预约人数
  numbers: number = 0;
  // 是否添加到日程
  @Trace setSchedule: number = 0;
  // 是否订阅推送
  @Trace setSubscription: number = 0;
  // 完成时间
  completedTime: number | null = null;
  // 创建时间
  createdTime: string = '';
  // 昵称
  nickName: string = '';
  // 头像
  avatar: string = '';

  constructor(item?: AppointmentInfo) {
    this.id = item?.id || 0;
    this.storeId = item?.storeId || 0;
    this.contactName = item?.contactName || '';
    this.contactPhone = item?.contactPhone || '';
    this.numbers = item?.numbers || 1;
    this.itemName = item?.itemName || '';
    this.reserveTime = item?.reserveTime || 0;
    this.state = item?.state || 10;
    this.remarks = item?.remarks || '';
    this.setSchedule = item?.setSchedule || 0;
    this.setSubscription = item?.setSubscription || 0;
  }
}

/**
 * 次卡信息
 */
@ObservedV2
export class SingleCardInfo implements ISingleVisitCard {
  // 次卡ID
  id: number = 0;
  // 次卡名称
  title: string = '';
  // 次卡副标题
  subTitle?: string = '';
  // 次卡banner
  image: string = '';
  // 已售数量
  sales: number = 0;
  // 可使用次数
  availableNum: number = 1;
  // 服务项目个数
  projectNum: number = 0;
  // 有效期，天数，-1表示永久有效
  availablePeriod: number = -1;
  // 价格
  price: number = 0;
  // 价格
  vipPrice: number = 0;
  // 详情富文本
  intro: IntroItem[] = [];
  // 适用门店
  availableStores?: IStoreInfo[] = [];
}

/**
 * 团购信息
 */
@ObservedV2
export class GroupInfo implements IGroupInfo {
  // 商品ID
  id: number = 0;
  // 商品名称
  title: string = '';
  // 副标题
  subTitle?: string = '';
  // 主图
  images: string[] = [''];
  // 已售出数量
  soldNum: number = 0;
  // 套餐内容
  groupContent: GroupContent = {
    location: '',
    including: '',
    present: '',
    detail: [],
  };
  // 商品详情富文本
  intro: IntroItem[] = [];
  // 价格
  price: number = 0;
  // 会员价
  vipPrice: number = 0;
  // 服务项目
  projectNum: number = 0;
  // 有效期，天数，-1表示永久有效
  availablePeriod: number = -1;
  // 可以使用的时间段区间
  availableTimePeriod?: string;
  // 限购数量
  limit?: number;
  // 适用门店
  availableStores?: IStoreInfo[];
}

/**
 * 我的团购模型
 */
@ObservedV2
export class MyGroupInfo implements IMyGroupInfo {
  // 团购id
  groupId: number = 0;
  // 商品名称
  title: string = '';
  // 副标题
  subTitle?: string = '';
  // 主图
  images: string[] = [];
  // 购买数量
  purchaseNums: number = 0;
  // 会员价
  vipPrice: number = 0;
  // 套餐内容
  groupContent: GroupContent = {
    location: '',
    including: '',
    present: '',
    detail: [],
  };
  // 订单状态
  status: GroupOrderStatus = GroupOrderStatus.USE_UP;
  // 实际付款
  actualPay: number = 0;
  // 团购券码
  groupSerialNo: string = '';
  // 订单编号
  orderNo: string = '';
  // 下单手机号
  contactPhone: string = '';
  // 下单时间
  orderTime: number = 0;
  // 付款时间
  payTime: number = 0;
  // 使用时间
  consumeTime?: number = 0;
  // 退款时间
  refundTime?: number = 0;
}

@ObservedV2
export class SimpleGoodInfo {
  type: OrderType = OrderType.SINGLE_CARD;
  id: number = 0;
  title: string = '';
  subTitle?: string = '';
  vipPrice: number = 0;
  image: string = '';
}

@ObservedV2
export class SimpleOrderInfo extends SimpleGoodInfo {
  // 联系人姓名
  contactName: string = '';
  // 联系人电话
  contactPhone: string = '';
  // 备注信息
  remark: string = '';
  // 订购的数量
  numbers: number = 0;
  // 实际付款
  actualPay: number = 0;
}

/**
 * 读取用户信息响应
 */
@ObservedV2
export class GetUserInfoResp implements IUserInfo {
  @Trace userId?: number;
  @Trace nickName?: string;
  @Trace avatar?: string;
  @Trace mobile?: string;
  /**
   * 会员卡id
   */
  @Trace memberId?: string;
  /**
   * 积分数量
   */
  @Trace points?: number;
  /**
   * 创建时间
   */
  createdTime?: string;
  /**
   * 更新时间
   */
  updatedTime?: string;
}

export class ActiveMemberRequest implements IActiveMemberRequest {
  name: string = '';
  gender: string = '';
  mobile: string = '';
  birth: number = 0;
}


/**
 * AppStorageV2应用全局缓存库
 */
export class AppStorageBank {
  static userInfo: GetUserInfoResp = AppStorageV2.connect(GetUserInfoResp, () => new GetUserInfoResp())!;

  static updateUserInfo(v: GetUserInfoResp) {
    AppStorageBank.userInfo.userId = v.userId;
    AppStorageBank.userInfo.nickName = v.nickName;
    AppStorageBank.userInfo.avatar = v.avatar;
    AppStorageBank.userInfo.mobile = v.mobile;
    AppStorageBank.userInfo.createdTime = v.createdTime;
    AppStorageBank.userInfo.updatedTime = v.updatedTime;
    AppStorageBank.userInfo.memberId = v.memberId;
    AppStorageBank.userInfo.points = v.points;
  }
}

