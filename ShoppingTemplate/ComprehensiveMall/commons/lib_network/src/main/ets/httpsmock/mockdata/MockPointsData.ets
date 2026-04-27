import {
  RedemptionOrder,
  UserPointRedemptionSku,
  UserPointsRecordItem,
} from '../../types/responses/PointResponse'
import { AddressInfo, LogisticsItem } from '../../types/OrderTypes'

// -------- 积分记录（迁移自 MockUserData.ets）--------

export const MOCK_POINTS_RECORD_LIST: UserPointsRecordItem[] = [
  {
    time: Date.now(),
    type: 1,
    label: '积分兑换',
    points: -25,
  },
  {
    time: new Date('2025-10-15').getTime(),
    type: 1,
    label: '积分兑换',
    points: -25,
  },
  {
    time: Date.now() - 60 * 60 * 1000 * 24,
    type: 0,
    label: '签到',
    points: 5,
  },
]

// -------- 积分商品（迁移自 MockUserData.ets）--------

export const MOCK_POINTS_REDEMPTION_LIST: UserPointRedemptionSku[] = [
  {
    skuCode: 'redemption_10001',
    price: 25,
    title: '莫兰迪水杯马克杯可泡茶，陶瓷磨砂质感',
    banner: $r('app.media.mock_redemption_1'),
  },
  {
    skuCode: 'redemption_10002',
    price: 40,
    title: '玻璃高脚杯红酒水晶材质耐磨光滑',
    banner: $r('app.media.mock_redemption_2'),
  },
  {
    skuCode: 'redemption_10003',
    price: 10,
    title: '吸水能力强可擦车可洗澡加大加厚毛巾',
    banner: $r('app.media.mock_redemption_3'),
  },
  {
    skuCode: 'redemption_10004',
    price: 15,
    title: '简约纯色咖啡杯',
    banner: $r('app.media.mock_redemption_4'),
  },
]

// -------- 兑换订单（新增）--------
// 初始化 6 条记录，覆盖三种状态（待发货×2 / 待收货×2 / 已完成×2）

const mockAddress: AddressInfo = {
  name: '张三',
  cellphone: '12300000000',
  address: '北京市海淀区某小区',
  city: '北京市',
  latitude: 39.95,
  longitude: 116.30,
}

const mockPointsLogistic203: LogisticsItem = {
  icon: $r('app.media.ic_car'),
  status: 203,
  details: [{
    desc: '【北京市】快递正在运输中，预计明天送达',
    time: '2025-03-10 14:00:00',
  }],
  courier: '快递员',
  contactPhone: '12345678910',
}

const mockPointsLogistic202: LogisticsItem = {
  icon: $r('app.media.ic_car'),
  status: 202,
  details: [{
    desc: '快递员已揽件，即将开始运输',
    time: '2025-03-10 09:00:00',
  }],
  courier: '快递员',
  contactPhone: '12345678910',
}

const mockPointsLogistic201: LogisticsItem = {
  icon: $r('app.media.ic_car'),
  status: 201,
  details: [{
    desc: '商家已发货',
    time: '2025-03-09 18:00:00',
  }],
}

const mockPointsLogistic101: LogisticsItem = {
  icon: $r('app.media.ic_car'),
  status: 102,
  details: [{
    desc: '48小时内发货',
    time: '2025-03-01 10:00:00',
  }],
};


export const MOCK_REDEMPTION_ORDER_LIST: RedemptionOrder[] = [
  {
    orderId: 'redemption_order_001',
    orderTime: Date.now() - 86400000 * 1,
    status: 0,
    product: MOCK_POINTS_REDEMPTION_LIST[0],
    addressInfo: mockAddress,
    logisticInfo: [mockPointsLogistic101],
  },
  {
    orderId: 'redemption_order_002',
    orderTime: Date.now() - 86400000 * 5,
    status: 1,
    product: MOCK_POINTS_REDEMPTION_LIST[1],
    addressInfo: mockAddress,
    logisticInfo: [mockPointsLogistic203, mockPointsLogistic202, mockPointsLogistic201],
  },
  {
    orderId: 'redemption_order_003',
    orderTime: Date.now() - 86400000 * 7,
    status: 1,
    product: MOCK_POINTS_REDEMPTION_LIST[2],
    addressInfo: mockAddress,
    logisticInfo: [mockPointsLogistic202, mockPointsLogistic201],
  },
  {
    orderId: 'redemption_order_004',
    orderTime: Date.now() - 86400000 * 15,
    status: 2,
    product: MOCK_POINTS_REDEMPTION_LIST[0],
    addressInfo: mockAddress,
  },
]
