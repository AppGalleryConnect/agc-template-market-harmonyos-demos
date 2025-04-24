import { FormatUtil } from 'commonlib';
import { PrepayMealRequest, PrepayRoomRequest } from '../../types/AxiosRequestParam';
import { GetHotelOrderDetailResp, GetMealOrderDetailResp, OrderItem, PrepayResp } from '../../types/responseTypes';
import { MockImageMap } from '../Constants';
import { getFormattedResp } from '../Utils';

const hotelOrder1: OrderItem = {
  id: 1,
  orderNo: '1001',
  orderStatus: '2',
  shopName: '千和大酒店(1店)',
  goodsName: '海景大床房',
  goodsQty: 1,
  actualPaidPrice: '388',
  createTime: '2024-11-19 11:01:34',
  orderType: '1',
  shopLogo: 'mockImage://ic_hotel',
  displayImg: MockImageMap.IMG_HOTEL_ROOM1,
};

const hotelOrder2: OrderItem = {
  id: 2,
  orderNo: '1002',
  orderStatus: '3',
  shopName: '千和大酒店(1店)',
  goodsName: '海景大床房',
  goodsQty: 1,
  actualPaidPrice: '388',
  createTime: '2025-02-01 11:06:34',
  orderType: '1',
  shopLogo: 'mockImage://ic_hotel',
  displayImg: MockImageMap.IMG_HOTEL_ROOM1,
};

const hotelOrder3: OrderItem = {
  id: 3,
  orderNo: '1003',
  orderStatus: '4',
  shopName: '千和大酒店(1店)',
  goodsName: '海景大床房',
  goodsQty: 1,
  actualPaidPrice: '388',
  createTime: '2025-01-19 11:10:34',
  orderType: '1',
  shopLogo: 'mockImage://ic_hotel',
  displayImg: MockImageMap.IMG_HOTEL_ROOM1,
};

const hotelDetail: GetHotelOrderDetailResp = {
  createTime: '2024-11-19 11:01:34',
  remark: '',
  orderNo: '20250214000001',
  orderStatus: '4',
  hotelId: 101,
  hotelName: '千和大酒店(1店)',
  roomId: 107733,
  roomName: '海景大床房',
  arrDate: '2024-11-19',
  depDate: '2024-11-20',
  nights: 1,
  rmQty: 1,
  actualPaidPrice: '388',
  payTime: '',
  payExpireTime: '2024-11-19 11:31:35',
  prepayResult:
  '{"merc_no":"106510000094","auth_id":"1376051779833979264","sign":"gpe6ZONZf/KKOfVoKmWwoA+hUkT7xbEyIa1sphl5w1ITBQzAMKAxqo2RK9mLsXhP3EoM75ntjAkG8rOf59cI5Q7tykvaavvN6N0b4bPLkFk7T6CIHuuQ3emdoVJbt6nQb4nbLpCrkEMbsqqTxKkcGWx1tNBVzcFAIAAbpfCHZmHhSVYLsZFpktZRIUxmdWscV3Hy4Sc3XV5Pg0i8rkGILl72Dn7mIAw1Zfu6qM1rkYBcuLpSD7g48Nc2xqHOMUHeC1cR1W0tSBtvU69jSxnuQPbZKLfGxWNzB5sOzkEqDotngMMQHZF6vtjt9sjzK3erRJCiBUFhPkSqGRJDMvaEHQ==","noncestr":"9bebb89c95104188ae6c221a707605db","prepay_id":"1241119110135089909652876239","timestamp":"1731985295149"}',
  checkInList: [
    {
      checkInName: '张先生',
      checkInTel: '13800000000',
    },
  ],
  payMethod: '华为支付',
  cover: MockImageMap.IMG_HOTEL_ROOM1,
};

const mealOrder1: OrderItem = {
  id: 4,
  orderNo: '2001',
  orderStatus: '2',
  shopName: '千和大酒店·中餐厅',
  goodsName: '家常三人餐',
  goodsQty: 1,
  actualPaidPrice: '199',
  createTime: '2024-11-18 15:46:37',
  orderType: '2',
  shopLogo: 'mockImage://ic_restaurant',
  displayImg: MockImageMap.IMG_MEAL5,
};

const mealOrder2: OrderItem = {
  id: 5,
  orderNo: '2002',
  orderStatus: '3',
  shopName: '千和大酒店·中餐厅',
  goodsName: '家常三人餐',
  goodsQty: 1,
  actualPaidPrice: '199',
  createTime: '2024-11-01 10:00:00',
  orderType: '2',
  shopLogo: 'mockImage://ic_restaurant',
  displayImg: MockImageMap.IMG_MEAL5,
};

const mealOrder3: OrderItem = {
  id: 6,
  orderNo: '2003',
  orderStatus: '4',
  shopName: '千和大酒店·中餐厅',
  goodsName: '家常三人餐',
  goodsQty: 1,
  actualPaidPrice: '199',
  createTime: '2024-12-01 10:00:00',
  orderType: '2',
  shopLogo: 'mockImage://ic_restaurant',
  displayImg: MockImageMap.IMG_MEAL5,
};

const mealDetail: GetMealOrderDetailResp = {
  updateTime: '2024-11-18 15:50:00',
  orderNo: '20241118000001',
  status: '2',
  actualPaidPrice: '132',
  totalCount: 1,
  payTime: null,
  payExpireTime: '2024-11-18 15:56:38',
  prepayResult:
  '{"merc_no":"106510000094","auth_id":"1376051779833979264","sign":"is9oJ4ywEmZwPIHzt9PebJJqU4KzT/VfN6gDNuU1Gp5J5d0lle1Gu2mRrVZuK+IwaNoJ2+LgyBXrHZEes0i/Ij9Dw5ycHBK06mb05pGbxcN/gWbH9OxS3oIR5iYhvsa6E3iTiIEniDPQKkDLlEfXYO2FidlHimJrLJF1j1FnKu9+WgRym9A8jTFNzIypJlXiWb3/gW8GIBPu1xifB3KNU6Ddus5eEPq9g2wPwEAYrQPDA2yKO22ZDnbGdjr5cKzmMVzrazEt16DHaIhx4nJE7nE1YUDUCxLWZrdxwNru1TMYgtxxM2sB6tYFGESScz1N67r3XXQEEBciziUsDA1JpA==","noncestr":"d3a4eebc645d422fb3ab39248bf6b6da","prepay_id":"1241118154637089645505315324","timestamp":"1731915997763"}',
  usageRule:
  '有效期：购买后30天内有效\r\n除外日期 ·有效期内周末、法定节假日通用\r\n使用时间 ·营业时间内可用\r\n预约提醒·无需预约，消费高峰期可能需要等位\r\n堂食外带·堂食外带均可\r\n温馨提示 · 团购用户可以享受店内其他所有优惠\r\n酒水饮料等问题，请致电商家咨询，以商家反馈为准如部分菜品因时令或其他不可抗因素导致无法提供，商家会用等价菜品替换，具体事宜请与商家协商\r\n使用优惠券购买团单，有效期以优惠券规则为准\r\n发票信息·本单发票由商家提供，详情请咨询商家',
  packageName: '家常三人餐',
  images: MockImageMap.IMG_MEAL5,
};

export const shopMap: Map<number, string> = new Map([
  [101, '千和大酒店(1店)'],
  [102, '千和大酒店(2店)'],
  [103, '千和大酒店·中餐厅'],
  [104, '千和大酒店·西餐厅'],
]);

export class OrderDatasetMock {
  private static _orderList: OrderItem[] = [
    hotelOrder1,
    hotelOrder2,
    hotelOrder3,
    mealOrder1,
    mealOrder2,
    mealOrder3,
  ];
  private static _hotelOrderDetailList: GetHotelOrderDetailResp[] = [];
  private static _mealOrderDetailList: GetMealOrderDetailResp[] = [];

  public static getOrderList(orderClass?: number) {
    if (!orderClass || orderClass === -1) {
      return getFormattedResp(OrderDatasetMock._orderList);
    } else {
      const list = OrderDatasetMock._orderList.filter((item) => item.orderStatus === orderClass.toString());
      return getFormattedResp(list);
    }
  }

  public static getHotelOrderDetail(orderNo: string) {
    let detail = OrderDatasetMock._hotelOrderDetailList.find((item) => orderNo === item.orderNo);
    if (!detail) {
      detail = JSON.parse(JSON.stringify(hotelDetail)) as GetHotelOrderDetailResp;
      const orderItem = OrderDatasetMock._orderList.find((item) => item.orderNo === orderNo);
      if (orderItem) {
        detail.orderNo = orderItem.orderNo;
        detail.orderStatus = orderItem.orderStatus;
        detail.hotelName = orderItem.shopName;
        detail.roomName = orderItem.goodsName;
        detail.rmQty = orderItem.goodsQty;
        detail.actualPaidPrice = orderItem.actualPaidPrice;
        detail.cover = orderItem.displayImg as string;
        detail.createTime = orderItem.createTime;
      }
    }
    const detailCopy: GetHotelOrderDetailResp = JSON.parse(JSON.stringify(detail));
    return getFormattedResp(detailCopy);
  }

  public static prepayHotel(data: PrepayRoomRequest) {
    const timestamp = new Date().getTime();
    const orderNo: string = timestamp.toString();
    // 存入订单列表
    const orderItem: OrderItem = {
      id: timestamp,
      orderNo: orderNo,
      orderStatus: '1',
      shopName: shopMap.get(data.hotelId) as string,
      goodsName: data.roomName,
      goodsQty: data.rmQty,
      actualPaidPrice: data.actualPaidPrice,
      createTime: FormatUtil.formatFullDate(new Date(timestamp)),
      orderType: '1',
      shopLogo: 'mockImage://ic_hotel',
      displayImg: MockImageMap.IMG_HOTEL_ROOM1,
    };
    OrderDatasetMock._orderList.push(orderItem);
    // 存入订单详情
    const orderDetail: GetHotelOrderDetailResp = {
      createTime: orderItem.createTime,
      remark: data.remark,
      orderNo: orderNo,
      orderStatus: '1',
      hotelId: data.hotelId,
      hotelName: orderItem.shopName,
      roomId: data.roomId,
      roomName: data.roomName,
      arrDate: data.arrDate,
      depDate: data.depDate,
      nights: data.nights,
      rmQty: data.rmQty,
      actualPaidPrice: data.actualPaidPrice,
      payTime: '',
      payExpireTime: FormatUtil.formatFullDate(new Date(timestamp + 3600)),
      prepayResult: orderNo,
      checkInList: [
        {
          checkInName: data.guest.name,
          checkInTel: data.guest.tel,
        },
      ],
      payMethod: '华为支付',
      cover: MockImageMap.IMG_HOTEL_ROOM1,
    };
    OrderDatasetMock._hotelOrderDetailList.push(orderDetail);
    const resp: PrepayResp = {
      mercOrderNo: orderNo,
      orderStr: '',
      timestamp: orderNo,
    };
    return getFormattedResp(resp);
  }

  public static getMealOrderDetail(orderNo: string) {
    let detail = OrderDatasetMock._mealOrderDetailList.find((item) => orderNo === item.orderNo);
    if (!detail) {
      detail = JSON.parse(JSON.stringify(mealDetail)) as GetMealOrderDetailResp;
      const orderItem = OrderDatasetMock._orderList.find((item) => item.orderNo === orderNo);
      if (orderItem) {
        detail.updateTime = orderItem.createTime;
        detail.orderNo = orderItem.orderNo;
        detail.status = orderItem.orderStatus;
        detail.actualPaidPrice = orderItem.actualPaidPrice;
        detail.totalCount = orderItem.goodsQty;
        detail.images = orderItem.displayImg as string;
      }
    }
    const detailCopy: GetMealOrderDetailResp = JSON.parse(JSON.stringify(detail));

    return getFormattedResp(detailCopy);
  }

  public static prepayMeal(data: PrepayMealRequest) {
    const timestamp = new Date().getTime();
    const orderNo: string = timestamp.toString();
    // 存入订单列表
    const orderItem: OrderItem = {
      id: timestamp,
      orderNo: orderNo,
      orderStatus: '1',
      shopName: shopMap.get(data.shopId) as string,
      goodsName: data.goodsName,
      goodsQty: data.goodsQty,
      actualPaidPrice: data.actualPaidPrice,
      createTime: FormatUtil.formatFullDate(new Date(timestamp)),
      orderType: '2',
      shopLogo: 'mockImage://ic_restaurant',
      displayImg: MockImageMap.IMG_MEAL5,
    };
    OrderDatasetMock._orderList.push(orderItem);
    // 存入订单详情
    const orderDetail: GetMealOrderDetailResp = {
      updateTime: orderItem.createTime,
      orderNo: orderNo,
      status: '1',
      actualPaidPrice: data.actualPaidPrice,
      totalCount: data.goodsQty,
      payTime: null,
      payExpireTime: FormatUtil.formatFullDate(new Date(timestamp + 3600)),
      prepayResult: orderNo,
      usageRule:
      '有效期：购买后30天内有效\r\n除外日期 ·有效期内周末、法定节假日通用\r\n使用时间 ·营业时间内可用\r\n预约提醒·无需预约，消费高峰期可能需要等位\r\n堂食外带·堂食外带均可\r\n温馨提示 · 团购用户可以享受店内其他所有优惠\r\n酒水饮料等问题，请致电商家咨询，以商家反馈为准如部分菜品因时令或其他不可抗因素导致无法提供，商家会用等价菜品替换，具体事宜请与商家协商\r\n使用优惠券购买团单，有效期以优惠券规则为准\r\n发票信息·本单发票由商家提供，详情请咨询商家',
      packageName: data.goodsName,
      images: MockImageMap.IMG_MEAL5,
    };
    OrderDatasetMock._mealOrderDetailList.push(orderDetail);
    const resp: PrepayResp = {
      mercOrderNo: orderNo,
      orderStr: '',
      timestamp: orderNo,
    };
    return getFormattedResp(resp);
  }

}