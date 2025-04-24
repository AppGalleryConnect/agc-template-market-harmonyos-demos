import { AppointState, GroupOrderStatus, IntroType } from '../common/Constant'

/**
 * 静默登录请求响应
 */
export interface LoginWithHuaweiIDResp {
  token: string;
  userId: string;
}

/**
 * 绑定手机号响应
 */
export interface BindMobileWithCodeResp {
  status: string;
  rebindSecret: string;
}

/**
 * 用户信息模型
 */
export interface IUserInfo {
  // id
  userId?: number;

  // 昵称
  nickName?: string;

  // 头像
  avatar?: string;

  // 手机号码
  mobile?: string;

  // 会员卡id
  memberId?: string;

  // 积分数量
  points?: number;

  // 创建时间
  createdTime?: string;

  // 更新时间
  updatedTime?: string;
}

/**
 * 门店基础模型
 */
export interface IBaseStore {
  // 门店ID
  id: number;

  // 店铺名称
  storeName: string;

  // 坐标
  coords: string;

  // 地址
  address: string;

  // 联系电话
  mobile: string;

  // 离当前地点的距离
  distance?: string;
}

/**
 * 店铺详细模型
 */
export interface IStoreInfo extends IBaseStore {
  // 品牌商ID
  brandId: number;

  // 店铺简介
  storeProfile: string;

  // 店铺logo链接
  logoUrl: string;

  // 地区
  region: string;

  // 认证名称
  certName: string;

  // 店铺横幅
  storeBanner: string;

  // 营业执照
  businessLicense: string;

  // 评分
  score: string;

  // 经营状态
  businessStatus: number;

  // 经营时间
  businessTimes: string;
}

/**
 * 商品列表模型
 */
export interface IGoodList {
  id: number;
  title: string;
  goods: IGoodInfo[];
}

/**
 * 富文本单元
 */
export interface IntroItem {
  type: IntroType,
  value: string;
}

/**
 * 商品模型
 */
export interface IGoodInfo {
  // 商品ID
  id: number;

  // 商品名称
  title: string;

  // 所属类目ID
  classId: number;

  // 主图
  images: string[];

  // 详情富文本
  intro: IntroItem[];

  // 价格
  price: number;

  // 会员价
  vipPrice: number;
}

/**
 * 预约信息模型
 */
export interface IAppointment {
  // 成功预约的ID
  id: number;

  // 门店ID
  storeId: number;

  // 用户ID
  userId: number;

  //数据类型
  type: number;

  // 预约时间
  reserveTime: number;

  // 持续时间
  duration: number;

  // 预约备注
  remarks: string;

  // 状态
  state: AppointState;

  // 联系人姓名
  contactName: string;

  // 联系人电话
  contactPhone: string;

  // 预约的项目名称
  itemName: string;

  // 商品图片
  itemPic: string;

  // 预约人数
  numbers: number;

  // 是否添加到日程
  setSchedule: number;

  // 是否订阅推送
  setSubscription: number;

  // 完成时间
  completedTime: number | null;

  // 创建时间
  createdTime: string;

  // 昵称
  nickName: string;

  // 头像
  avatar: string;
}

/**
 * 次卡模型
 */
export interface ISingleVisitCard {
  // 次卡ID
  id: number;

  // 次卡名称
  title: string;

  // 次卡副标题
  subTitle?: string;

  // 次卡banner
  image: string;

  // 已售数量
  sales: number;

  // 可使用次数
  availableNum: number;

  // 服务项目个数
  projectNum: number;

  // 有效期，天数，-1表示永久有效
  availablePeriod: number;

  // 价格
  price: number;

  // 价格
  vipPrice: number;

  // 详情富文本
  intro: IntroItem[];

  // 适用门店
  availableStores?: IStoreInfo[];
}

/**
 * 团购套餐内容详情单元模型
 */
export interface GroupContentItem {
  title: string;
  numbers: number;
  price: number;
}

/**
 *
 */
export interface GroupContent {
  // 适用部位
  location: string;

  // 包含项目
  including: string;

  // 附赠项目
  present: string;

  // 团购详情
  detail: GroupContentItem[];
}

/**
 * 团购商品模型
 */
export interface IGroupInfo {
  // 商品ID
  id: number;

  // 商品名称
  title: string;

  // 副标题
  subTitle?: string;

  // 主图
  images: string[];

  // 已售出数量
  soldNum: number;

  // 套餐内容
  groupContent: GroupContent;

  // 商品详情富文本
  intro: IntroItem[];

  // 价格
  price: number;

  // 会员价
  vipPrice: number;

  // 有效期，天数，-1表示永久有效
  availablePeriod: number;

  // 服务项目
  projectNum: number;

  // 可以使用的时间段区间
  availableTimePeriod?: string;

  // 限购数量
  limit?: number;

  // 适用门店
  availableStores?: IStoreInfo[];
}

/**
 * 次卡使用记录模型
 */
export interface IUseRecord {
  // 使用时间，时间戳
  useTime: number;

  // 使用门店
  storeName: string;
}

/**
 * 我的次卡模型
 */
export interface IMySingleCardInfo {
  // 次卡券码
  singleCardSerialNo: string;

  // 次卡id
  singleCardId: number;

  // 次卡名称
  title: string;

  // 总共可用次数
  availableNums: number;

  // 剩余可使用次数
  leftNums: number;

  // 适用项目
  availableProName: string;

  // 有效期
  availablePeriod: number;

  // 使用记录
  usageRecord: IUseRecord[];

  // 适用门店
  availableStores?: IStoreInfo;
}

/**
 * 我的团购模型
 */
export interface IMyGroupInfo {
  // 团购id
  groupId: number;

  // 商品名称
  title: string;

  // 副标题
  subTitle?: string;

  // 主图
  images: string[];

  // 购买数量
  purchaseNums: number;

  // 会员价
  vipPrice: number;

  // 套餐内容
  groupContent: GroupContent;

  // 订单状态
  status: GroupOrderStatus;

  // 实际付款
  actualPay: number;

  // 团购券码
  groupSerialNo: string;

  // 订单编号
  orderNo: string;

  // 下单手机号
  contactPhone: string;

  // 下单时间
  orderTime: number;

  // 付款时间
  payTime: number;

  // 使用时间
  consumeTime?: number;

  // 退款时间
  refundTime?: number;
}
