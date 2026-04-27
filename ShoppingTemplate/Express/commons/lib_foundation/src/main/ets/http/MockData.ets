import { address1, address2, goodsList, IAddrInfo } from 'module_base'
import { ExpressStatus, OrderStatus, OrderType, PaymentMethod, ShippingMethod } from '../common/Constant'
import {
  ICompany,
  IGoods,
  ILogisticsInfo,
  IOrder,
  IOrderInfo,
  IServicePoint,
  IUserInfo,
} from '../model/IResponse'
import { CheckIn, Coupon } from '../model/ObserveModel'

const sendAddress: IAddrInfo = address1
const getAddress: IAddrInfo = address2
const order1: IOrder = {
  id: 1,
  type: OrderType.SEND,
  status: OrderStatus.SUCCESS,
  expressStatus: ExpressStatus.PICKUP_PENDING,
  companyName: 'x1标快',
  orderNo: 'x111111111',
  remark: '让本人签收',
  deliveryTime: '2025-08-10 09:24',
  receiptTime: '',
  price: 0,
  sendAddress: sendAddress,
  getAddress: getAddress,
  goods: {
    id: 1,
    name: '文件',
    weight: 1,
  },
  day: '今天',
  time: '8:00 - 9:00',
  paymentMethod: PaymentMethod.PAY_NOW,
  shippingMethod: ShippingMethod.PICK_UP_AT_HOME,
  mailCode: 1252,
}

const order2: IOrder = {
  id: 2,
  type: OrderType.SEND,
  status: OrderStatus.SUCCESS,
  expressStatus: ExpressStatus.IN_TRANSIT,
  companyName: 'x1标快',
  orderNo: 'x13474634277',
  remark: '',
  deliveryTime: '2025-07-10 09:24',
  receiptTime: '',
  price: 0,
  sendAddress: sendAddress,
  getAddress: getAddress,
  goods: {
    id: 1,
    name: '文件',
    weight: 1,
  },
  day: '今天',
  time: '8:00 - 9:00',
  paymentMethod: PaymentMethod.PAY_NOW,
  shippingMethod: ShippingMethod.PICK_UP_AT_HOME,
  mailCode: 5843,
}

const order3: IOrder = {
  id: 3,
  type: OrderType.SEND,
  status: OrderStatus.SUCCESS,
  expressStatus: ExpressStatus.IN_DELIVERY,
  companyName: 'x1标快',
  orderNo: 'x13456523',
  remark: '',
  deliveryTime: '2025-07-12 09:24',
  receiptTime: '',
  price: 0,
  sendAddress: sendAddress,
  getAddress: getAddress,
  goods: {
    id: 1,
    name: '文件',
    weight: 1,
  },
  day: '今天',
  time: '8:00 - 9:00',
  paymentMethod: PaymentMethod.PAY_NOW,
  shippingMethod: ShippingMethod.PICK_UP_AT_HOME,
  mailCode: 6984,
}

const order4: IOrder = {
  id: 4,
  type: OrderType.SEND,
  status: OrderStatus.SUCCESS,
  expressStatus: ExpressStatus.SIGNED_FOR,
  companyName: 'x1标快',
  orderNo: 'x1345768577',
  remark: '',
  deliveryTime: '2025-07-14 09:24',
  receiptTime: '',
  price: 35,
  sendAddress: sendAddress,
  getAddress: getAddress,
  goods: {
    id: 1,
    name: '文件',
    weight: 1,
  },
  day: '今天',
  time: '8:00 - 9:00',
  paymentMethod: PaymentMethod.PAY_NOW,
  shippingMethod: ShippingMethod.PICK_UP_AT_HOME,
  mailCode: 6952,
}

const order6: IOrder = {
  id: 6,
  type: OrderType.RECEIVE,
  status: OrderStatus.SUCCESS,
  expressStatus: ExpressStatus.PICKUP_PENDING,
  companyName: 'x1标快',
  orderNo: 'x1345665678877',
  remark: '',
  deliveryTime: '2025-04-10 09:24',
  receiptTime: '',
  price: 0,
  sendAddress: sendAddress,
  getAddress: getAddress,
  goods: {
    id: 1,
    name: '文件',
    weight: 1,
  },
  day: '今天',
  time: '8:00 - 9:00',
  paymentMethod: PaymentMethod.PAY_NOW,
  shippingMethod: ShippingMethod.PICK_UP_AT_HOME,
  mailCode: 8452,
}

const order7: IOrder = {
  id: 7,
  type: OrderType.RECEIVE,
  status: OrderStatus.SUCCESS,
  expressStatus: ExpressStatus.IN_TRANSIT,
  companyName: 'x5标快',
  orderNo: 'x124124312',
  remark: '',
  deliveryTime: '2025-04-10 09:24',
  receiptTime: '',
  price: 20,
  sendAddress: sendAddress,
  getAddress: getAddress,
  goods: {
    id: 1,
    name: '文件',
    weight: 1,
  },
  day: '今天',
  time: '8:00 - 9:00',
  paymentMethod: PaymentMethod.PAY_NOW,
  shippingMethod: ShippingMethod.PICK_UP_AT_HOME,
  mailCode: 9541,
}

const order8: IOrder = {
  id: 8,
  type: OrderType.RECEIVE,
  status: OrderStatus.SUCCESS,
  expressStatus: ExpressStatus.IN_DELIVERY,
  companyName: 'x4标快',
  orderNo: 'x2214125123',
  remark: '',
  deliveryTime: '2025-04-10 09:24',
  receiptTime: '',
  price: 30,
  sendAddress: sendAddress,
  getAddress: getAddress,
  goods: {
    id: 1,
    name: '文件',
    weight: 1,
  },
  day: '今天',
  time: '8:00 - 9:00',
  paymentMethod: PaymentMethod.PAY_NOW,
  shippingMethod: ShippingMethod.PICK_UP_AT_HOME,
  mailCode: 6985,
}

const order9: IOrder = {
  id: 9,
  type: OrderType.RECEIVE,
  status: OrderStatus.SUCCESS,
  expressStatus: ExpressStatus.SIGNED_FOR,
  companyName: 'x1标快',
  orderNo: 'x2124325123',
  remark: '',
  deliveryTime: '2025-04-10 09:24',
  receiptTime: '',
  price: 30,
  sendAddress: sendAddress,
  getAddress: getAddress,
  goods: {
    id: 1,
    name: '文件',
    weight: 1,
  },
  day: '今天',
  time: '8:00 - 9:00',
  paymentMethod: PaymentMethod.PAY_NOW,
  shippingMethod: ShippingMethod.PICK_UP_AT_HOME,
  mailCode: 6985,
}

const order13: IOrder = {
  id: 13,
  type: OrderType.RECEIVE,
  status: OrderStatus.DO_ING,
  expressStatus: ExpressStatus.IN_DELIVERY,
  companyName: 'x6标快',
  orderNo: 'x283141288',
  remark: '',
  deliveryTime: '2025-06-20 09:24',
  receiptTime: '',
  price: 50,
  sendAddress: sendAddress,
  getAddress: getAddress,
  goods: {
    id: 1,
    name: '文件',
    weight: 1,
  },
  day: '今天',
  time: '8:00 - 9:00',
  paymentMethod: PaymentMethod.PAY_ON_DELIVERY,
  shippingMethod: ShippingMethod.PICK_UP_AT_HOME,
  mailCode: 6985,
}

/**
 * Mock数据类
 */
export class MockData {
  static USER_INFO: IUserInfo = {
    isLogin: true,
    id: 1,
    name: 'xx',
    nickname: '用户',
    sex: '1',
    cellphone: '10000000000',
    birthday: '1932-28-58',
    avatar: '',
    isVip: false,
    points: 0,
    couponList: [],
    realNameAuthFlag: 0,
  }
  static CHECK_IN_LIST: CheckIn[] =
    [
      new CheckIn(1, false, 50),
      new CheckIn(2, false, 55),
      new CheckIn(3, false, 60),
      new CheckIn(4, false, 65),
      new CheckIn(5, false, 70),
      new CheckIn(6, false, 75),
      new CheckIn(7, false, 80),
    ]
  static COUPON_LIST: Coupon[] = [
    new Coupon(1, '优惠券1', 1, 99, 299, '满¥299可用', '限指定商品可用', '2025.01.31 23:59', true, false,
      ['此券仅供指定商品使用', '本券不与其他优惠活动叠加使用']),
    new Coupon(2, '优惠券2', 2, 10, 0, '', '限指定商品可用', '2025.01.31 23:59', true, false,
      ['此券仅供指定商品使用', '本券不与其他优惠活动叠加使用']),
    new Coupon(3, '优惠券3', 1, 7.5, 0, '新品折扣券', '限指定商品可用', '2025.01.31 23:59', true, false,
      ['此券仅供指定商品使用', '本券不与其他优惠活动叠加使用']),
    new Coupon(4, '优惠券4', 2, 99, 299, '满¥299可用', '限指定商品可用', '2025.01.31 23:59', true, false,
      ['此券仅供指定商品使用', '本券不与其他优惠活动叠加使用']),
    new Coupon(5, '优惠券5', 2, 5, 99, '满¥99可用', '限指定商品可用', '2025.01.31 23:59', true, false,
      ['此券仅供指定商品使用', '本券不与其他优惠活动叠加使用']),
    new Coupon(6, '优惠券6', 2, 20, 199, '满¥199可用', '限指定商品可用', '2025.01.31 23:59', true, false,
      ['此券仅供指定商品使用', '本券不与其他优惠活动叠加使用']),
  ]
  static VIP_COUPON_LIST: Coupon[] = [
    new Coupon(7, '会员专属', 1, 15, 99, '满¥99可用', '限指定商品可用', '2025.01.31 23:59', true, false,
      ['此券仅供指定商品使用', '本券不与其他优惠活动叠加使用']),
  ]
  static COMPANY_LIST: ICompany[] =
    [
      {
        id: 1,
        name: 'x1快递',
      },
      {
        id: 2,
        name: 'x2快递',
      },
      {
        id: 3,
        name: 'x3快递',
      },
      {
        id: 4,
        name: 'x4快递',
      },
    ]
  static SERVICE_POINT_LIST: IServicePoint[] =
    [
      {
        id: 1,
        name: '幕府街道绿地缤纷丰巢 快递柜A区（沙县对面）',
        image: '',
        title: '距离最近',
        tips: ['24h自助', '便捷快发'],
        distance: '84m',
        positionName: '绿地缤纷',
        position: {
          'latitude': 32.975,
          'longitude': 118.78,
        },
      },
      {
        id: 2,
        name: '幕府街道绿地缤纷丰巢快递柜C区 （山墙旁）',
        image: '',
        title: '',
        tips: ['24h自助', '隔日取走'],
        distance: '106m',
        positionName: '绿地缤纷',
        position: {
          'latitude': 31.975,
          'longitude': 119.78,
        },
      },
    ]
  static GOODS_LIST: IGoods[] = goodsList
  static ORDER_LIST: IOrder[] =
    [order1, order2, order3, order4, order6, order7, order8, order9, order13]
  static LOGISTICS_INFO: ILogisticsInfo[] = [
    {
      time: '2025-04-10  09:39',
      content: '快递员正在取包裹',
    },
    {
      time: '2025-04-10  11:39',
      content: '快递员已取包裹，即将开始运输',
    },
    {
      time: '2025-04-10  11:39',
      content: '快件正在发往北京',
    },
    {
      time: '2025-04-10  11:39',
      content: '派件交给【华为快递员，联系电话：10000000000】，正在派送途中（如 有任何问题可优先联系我，我将尽全力为您解决，您的认可，是我最 大的动力！）',
    },
    {
      time: '2025-04-10  11:39',
      content: '您的快件已由本人签收，如有疑问请电话联系快递员。您的体验对于 我们至关重要，如果您对我们有任何想法或建议，请随时联系我们， 我们一定用心倾听，全力改进，不辜负您的信任和支持。',
    },
  ]
  static ORDER_INFO: IOrderInfo = {
    id: 1,
    type: OrderType.SEND,
    status: OrderStatus.SUCCESS,
    expressStatus: ExpressStatus.SIGNED_FOR,
    price: 0,
    companyName: '',
    goods: {
      id: 1,
      name: '',
      weight: 0,
    },
    day: '',
    time: '',
    paymentMethod: PaymentMethod.PAY_NOW,
    sendAddress: address1,
    getAddress: address2,
    sendPosition: '',
    getPosition: '',
    orderNo: '',
    shippingMethod: ShippingMethod.SELF_SENDING,
    mailCode: 1000,
    courier: {
      name: '华为快递员',
      cellphone: '10000000000',
    },
    logisticsInfo: MockData.LOGISTICS_INFO,
    origins: {
      'latitude': 31.975,
      'longitude': 118.78,
    },
    destination: {
      'latitude': 31.976,
      'longitude': 118.86,
    },
    waypoints: [
      { longitude: 118.78, latitude: 31.982 },
      { longitude: 118.79, latitude: 31.985 },
      { longitude: 118.80, latitude: 31.978 },
    ],
  }
}
