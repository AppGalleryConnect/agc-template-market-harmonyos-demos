import { MockImageData, MockImageMap } from './MockImageMap';
import { PriceType } from '../../types/EnumTypes';
import {
  OrderSkuItem,
  AddressInfo,
  LogisticsItem,
  OrderExpressInfo,
  OrderItem,
  PickupStoreInfo,
} from '../../types/OrderTypes';
import { DiscountItem } from '../../types/ProductTypes';

const mockSku1: OrderSkuItem = {
  productId: 'product_10001',
  skuCode: 'sku_100001',
  skuDesc: '粉色;160/80A',
  count: 1,
  stock: 10,
  banner: MockImageData.getImageResource(MockImageMap.PRODUCT_10001_PINK),
  title: '时尚轻商务系列针织打底纯羊毛内搭',
  serviceDesc: '运费险｜7天无理由',
  price: 200,
  dashPrice: 200,
  priceType: PriceType.NORMAL,
};

const mockSku2: OrderSkuItem = {
  productId: 'product_10001',
  skuCode: 'sku_100004',
  skuDesc: '白色;160/80A',
  stock: 10,
  count: 2,
  banner: MockImageData.getImageResource(MockImageMap.PRODUCT_10001_STRIPE),
  title: '时尚轻商务系列针织打底纯羊毛内搭',
  serviceDesc: '运费险｜7天无理由',
  price: 200,
  dashPrice: 200,
  priceType: PriceType.NORMAL,
};

const mockDiscountItem: DiscountItem = {
  type: 1,
  discountPrice: 20,
  label: '活动优惠',
};

const mockAddress: AddressInfo = {
  name: '张三',
  cellphone: '12300000000',
  address: '北京市海淀区某小区',
  city: '北京市',
  latitude: 39.95,
  longitude: 116.30,
};

export const DEFAULT_PICKUP_STORE: PickupStoreInfo = {
  storeName: '综合商城自提点（海淀店）',
  address: '北京市海淀区中关村大街1号',
  businessHour:'09:00 - 20:00',
  cellphone:'021-88888888',
  latitude: 39.98,
  longitude: 116.31,
};

const mockLogistic101: LogisticsItem = {
  icon: $r('app.media.ic_car'),
  status: 101,
  details: [{
    desc: '您提交了订单，请等待商家确认',
    time: '2025-03-01 09:00:00',
  }],
};

const mockLogistic102: LogisticsItem = {
  icon: $r('app.media.ic_car'),
  status: 102,
  details: [{
    desc: '订单已进入商家仓库，正在打包中',
    time: '2025-03-01 10:00:00',
  }],
};

const mockLogistic201: LogisticsItem = {
  icon: $r('app.media.ic_car'),
  status: 201,
  details: [{
    desc: '商家已发货',
    time: '2025-03-01 16:00:00',
  }],
};

const mockLogistic202: LogisticsItem = {
  icon: $r('app.media.ic_car'),
  status: 202,
  details: [{
    desc: '【南京市】快递员已收取包裹，即将开始运输',
    time: '2025-03-01 18:00:00',
  }],
};

const mockLogistic203: LogisticsItem = {
  icon: $r('app.media.ic_car'),
  status: 203,
  details: [
    {
      desc: '【北京市】已到达 北京市海淀区分拨交付中心 (如遇物流问题，请联系专属客服电话： 010-00000000 为您解决)',
      time: '2025-03-03 10:00:00',
    },
    {
      desc: '【南京市】已离开 江苏南京分拨交付中心 发往 北京市海淀区分拨交付中心(如遇物流问题，请联系专属客服电话： 021-00000000 为您解决)',
      time: '2025-03-02 10:00:00',
    },
  ],
};

const mockLogistic204: LogisticsItem = {
  icon: $r('app.media.ic_car'),
  status: 204,
  details: [{
    desc: '【北京市】北京市海淀区分拨交付中心 派件交给【华为快递员，联系电话： 12345678910 ，正在派送途中（有事呼叫我，勿找平台，少一次投诉，多一份感恩）',
    time: '2025-03-03 20:00:00',
  }],
  courier: '快递员',
  contactPhone: '12345678910',
};

const mockLogistic205: LogisticsItem = {
  icon: $r('app.media.ic_car'),
  status: 205,
  details: [{
    desc: '【代收点】您的快递已暂存至XX小区快递点，请及时领取签收，如有疑问请联系： 10000000000 ',
    time: '2025-03-04 08:00:00',
  }],
  courier: '快递员',
  contactPhone: '12345678910',
};

const mockLogistic301: LogisticsItem = {
  icon: $r('app.media.ic_car'),
  status: 301,
  details: [{
    desc: '您的商品已签收。',
    time: '2025-03-04 18:00:00',
  }],
};

export const mockExpress: OrderExpressInfo = {
  orderId: '',
  expressName: 'XX快递',
  expressNo: 'HW12345678',
  sendPosition: '南京市',
  getPosition: '北京市',
  origins: {
    latitude: 32.06,
    longitude: 118.22,
  },
  destination: {
    latitude: 39.95,
    longitude: 116.3,
  },
  waypoints: [
    { longitude: 118.78, latitude: 31.982 },
    { longitude: 118.79, latitude: 31.985 },
    { longitude: 118.80, latitude: 31.978 },
  ],
};

export class MockOrderData {
  private static orderList: OrderItem[] = [
    {
      orderInfo: {
        status: 1, // 已取消
        orderNo: '20231012001',
        addressInfo: mockAddress,
        orderTime: 1697020800000, // 2023-10-12 00:00:00
        remark: '尽快发货',
        originalPrice: 200,
        finalPrice: 180,
        discounts: [mockDiscountItem],
        refundTime: '2023-10-13 10:00:00',
        receivingMethod: 0,
      },
      logisticInfo: [],
      skuInfo: [mockSku1],
    },
    {
      orderInfo: {
        status: 2, // 待发货
        orderNo: '20231012002',
        addressInfo: mockAddress,
        orderTime: 1697020800000, // 2023-10-12 00:00:00
        originalPrice: 200,
        finalPrice: 180,
        receivingMethod: 0,
        discounts: [mockDiscountItem],
      },
      logisticInfo: [mockLogistic102, mockLogistic101],
      skuInfo: [mockSku1],
    },
    {
      orderInfo: {
        status: 3, // 待收货
        receivingMethod: 0,
        orderNo: '20231012003',
        addressInfo: mockAddress,
        orderTime: 1697020800000, // 2023-10-12 00:00:00
        remark: '请尽快配送',
        originalPrice: 200,
        finalPrice: 180,
        discounts: [mockDiscountItem],
      },
      logisticInfo: [
        mockLogistic205,
        mockLogistic204,
        mockLogistic203,
        mockLogistic202,
        mockLogistic201,
        mockLogistic102,
        mockLogistic101,
      ],
      skuInfo: [mockSku1],
    },
    {
      orderInfo: {
        status: 4, // 待评价
        receivingMethod: 0,
        orderNo: '20231012004',
        addressInfo: mockAddress,
        orderTime: 1697020800000, // 2023-10-12 00:00:00
        remark: '请尽快配送',
        originalPrice: 200,
        finalPrice: 180,
        discounts: [mockDiscountItem],
      },
      logisticInfo: [
        mockLogistic301,
        mockLogistic205,
        mockLogistic204,
        mockLogistic203,
        mockLogistic202,
        mockLogistic201,
        mockLogistic102,
        mockLogistic101,
      ],
      skuInfo: [mockSku1],
    },
    {
      orderInfo: {
        status: 4, // 待评价
        receivingMethod: 0,
        orderNo: '20231112004',
        addressInfo: mockAddress,
        orderTime: 1697020800000, // 2023-10-12 00:00:00
        remark: '请尽快配送',
        originalPrice: 600,
        finalPrice: 580,
        discounts: [mockDiscountItem],
      },
      logisticInfo: [
        mockLogistic301,
        mockLogistic205,
        mockLogistic204,
        mockLogistic203,
        mockLogistic202,
        mockLogistic201,
        mockLogistic102,
        mockLogistic101,
      ],
      skuInfo: [mockSku1, mockSku2],
    },
    {
      orderInfo: {
        status: 8, // 待取件（到店自提）
        receivingMethod: 1,
        orderNo: '20231012007',
        addressInfo: {
          name: DEFAULT_PICKUP_STORE.storeName,
          cellphone: '025-88888888',
          address: DEFAULT_PICKUP_STORE.address,
          latitude: DEFAULT_PICKUP_STORE.latitude,
          longitude: DEFAULT_PICKUP_STORE.longitude,
        },
        orderTime: 1697020800000,
        remark: '到店自提',
        originalPrice: 200,
        finalPrice: 180,
        discounts: [mockDiscountItem],
        pickupCode: 'MOCK07',
        pickupStoreInfo: DEFAULT_PICKUP_STORE,
      },
      logisticInfo: [],
      skuInfo: [mockSku1],
    },
    {
      orderInfo: {
        status: 6, // 退款/售后
        receivingMethod: 1,
        orderNo: '20231012005',
        addressInfo: mockAddress,
        orderTime: 1697020800000, // 2023-10-12 00:00:00
        remark: '商品有问题，申请退款',
        originalPrice: 200,
        finalPrice: 180,
        discounts: [mockDiscountItem],
        refundTime: '2023-10-13 10:00:00',
      },
      logisticInfo: [
        {
          icon: $r('app.media.ic_car'),
          status: 301,
          details: [{
            desc: '您的商品已由本人到店领取。',
            time: '2025-03-03 10:00:00',
          }],
        },
      ],
      skuInfo: [mockSku1],
    },
    {
      orderInfo: {
        status: 7, // 已退款
        receivingMethod: 1,
        orderNo: '20231012006',
        addressInfo: mockAddress,
        orderTime: 1697020800000, // 2023-10-12 00:00:00
        remark: '商品有问题，申请退款',
        originalPrice: 200,
        finalPrice: 180,
        discounts: [mockDiscountItem],
        refundTime: '2023-10-13 10:00:00',
      },
      logisticInfo: [
        mockLogistic301,
        mockLogistic204,
        mockLogistic203,
        mockLogistic202,
        mockLogistic101,
      ],
      skuInfo: [mockSku1],
    },
  ];
  public static DEFAULT_LATITUDE = 31.97;
  public static DEFAULT_LONGITUDE = 118.75;

  public static getOrderList() {
    return MockOrderData.orderList;
  }
}
