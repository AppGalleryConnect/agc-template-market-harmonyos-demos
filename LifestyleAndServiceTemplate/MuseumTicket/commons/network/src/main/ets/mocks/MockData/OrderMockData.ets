import {
  GetOrderListInfoResp,
  BaseResponse,
  GetOrderDetailResp,
  GetDayTicketResp,
  DayTicketInfo,
  OrderListItem,
  OrderVisitor,
  TicketOwner,
  GetTimeTicketResp,
  TimeTicketInfo,
  TimeSegment,
  TicketTypeInfo,
  GetTicketTypeInfoResp,
  PrepayBuyTicketResp,
} from '../../types/ResponseTypes';
import {
  CancelOrderRequest,
  OrderFreeRequest,
  BaseSuccessResponse,
  PrepayBuyTicketRequest,
} from '../../types/RequestTypes';
import { getNextDays, FormatUtil } from 'commonlib';
import { getFormattedResp } from '../Utils';
import { util } from '@kit.ArkTS';

// 模拟待使用的参观时间
const date = new Date();
date.setDate(date.getDate() + 1);
const tomorrow = FormatUtil.dateAsISO(date);


// 待使用
const order1: OrderListItem = {
  orderNo: '1',
  status: '1',
  visitTime: tomorrow + ' 上午',
  visitor: 2,
  orderTime: '2024-12-29 15:33:02',
  performanceName: '主馆免费展',
};

const order2: OrderListItem = {
  orderNo: '2',
  status: '1',
  visitTime: tomorrow + ' 11:00-14:00',
  visitor: 2,
  orderTime: '2024-12-29 15:33:02',
  actualPay: 79,
  performanceName: '下河文明巡回展',
};

// 待支付
const order3: OrderListItem = {
  orderNo: '3',
  status: '2',
  visitTime: '2025-01-01 11:00-14:00',
  visitor: 4,
  orderTime: '2024-12-29 15:33:02',
  orderAmount: 79,
  performanceName: '下河文明巡回展',
};

const order4: OrderListItem = {
  orderNo: '4',
  status: '2',
  visitTime: '2025-01-01 11:00-14:00',
  visitor: 1,
  orderTime: '2024-12-29 15:33:02',
  orderAmount: 20,
  performanceName: '下河文明巡回展',
};

// 已使用
const order5: OrderListItem = {
  orderNo: '5',
  status: '3',
  visitTime: '2025-01-01 上午',
  visitor: 2,
  orderTime: '2024-12-29 15:33:02',
  performanceName: '主馆免费展',
};

const order6: OrderListItem = {
  orderNo: '6',
  status: '3',
  visitTime: '2025-01-01 11:00-14:00',
  visitor: 4,
  orderTime: '2024-12-29 15:33:02',
  actualPay: 79,
  performanceName: '下河文明巡回展',
};

// 已过期
const order7: OrderListItem = {
  orderNo: '7',
  status: '4',
  visitTime: '2025-01-01 上午',
  visitor: 2,
  cancelTime: '2024-12-29 15:33:02',
  orderTime: '2024-12-29 15:33:02',
  performanceName: '主馆免费展',
};

const order8: OrderListItem = {
  orderNo: '8',
  status: '4',
  visitTime: '2025-01-01 11:00-14:00',
  visitor: 4,
  orderTime: '2024-12-29 15:33:02',
  cancelTime: '2024-12-29 15:33:02',
  orderAmount: 79,
  performanceName: '下河文明巡回展',
};

// 已失效
const order9: OrderListItem = {
  orderNo: '9',
  status: '5',
  visitTime: '2025-01-01 上午',
  visitor: 2,
  cancelTime: '2024-12-29 15:33:02',
  orderTime: '2024-12-29 15:33:02',
  performanceName: '主馆免费展',
};

const order10: OrderListItem = {
  orderNo: '10',
  status: '5',
  visitTime: '2025-01-01 11:00-14:00',
  visitor: 4,
  orderTime: '2024-12-29 15:33:02',
  cancelTime: '2024-12-29 15:33:02',
  performanceName: '下河文明巡回展',
};


const notice: string[][] = [
  [
    '1.开放时间',
    '周二至周日9:00-17:00，16:30停止入展厅，周一闭馆。',
  ],
  [
    '2.安检和安全',
    '参观者需接受安全检查，不得携带易燃易爆、管制械具等危险品入馆。',
    '在展厅内，不得摄像、拍照时请勿使用闪光灯、三脚架及自拍杆。',
  ],
  [
    '3.行为规范',
    '在展馆内进行讲解、研学、调查、采访等活动须提前申请。参观者需注意个人卫生，不得在馆内乱丢杂物。',
  ],
];
const orderVisitor: OrderVisitor[] = [
  { name: '张三', personId: '1' },
  { name: '李四', personId: '2' },
];

const orderVisitor2: OrderVisitor[] = [
  { name: '张三', personId: '1' },
  { name: '李四', personId: '2' },
  { name: '王五', personId: '3' },
  { name: '小米', personId: '4' },
];

const ticketOwner: TicketOwner[] = [
  {
    personId: '1',
    name: '张三',
    ticketType: '1',
    ticket: 1,
    price: 39,
  },
  {
    personId: '2',
    name: '李四',
    ticketType: '2',
    ticket: 1,
    price: 0,
  },
  {
    personId: '3',
    name: '王五',
    ticketType: '3',
    ticket: 1,
    price: 20,
  },
  {
    personId: '4',
    name: '小米',
    ticketType: '4',
    ticket: 1,
    price: 20,
  },
];


const orderDetail1: GetOrderDetailResp = {
  orderNo: '1',
  status: '1',
  visitTime: tomorrow + ' 上午',
  visitor: 2,
  orderTime: '2024-12-29 15:33:02',
  contactPhone: '12011111113',
  notice: notice,
  visitors: orderVisitor,
  isFree: true,
  performanceName: '主馆免费展',
};

const orderDetail2: GetOrderDetailResp = {
  orderNo: '2',
  status: '1',
  visitTime: tomorrow + ' 11:00-14:00',
  visitor: 2,
  orderTime: '2024-12-29 15:33:02',
  actualPay: 79,
  payTime: '2024-12-29 15:33:02',
  placeTime: '2024-12-29 15:33:02',
  notice: notice,
  contactPhone: '12011111113',
  ticketOwner: ticketOwner,
  isFree: false,
  performanceName: '下河文明巡回展',
};

const orderDetail3: GetOrderDetailResp = {
  orderNo: '3',
  status: '2',
  visitTime: '2025-01-01 11:00-14:00',
  visitor: 2,
  orderTime: '2024-12-29 15:33:02',
  placeTime: '2024-12-29 15:33:02',
  orderAmount: 79,
  notice: notice,
  contactPhone: '12011111113',
  ticketOwner: ticketOwner,
  isFree: false,
  performanceName: '下河文明巡回展',
};

const orderDetail4: GetOrderDetailResp = {
  orderNo: '4',
  status: '2',
  visitTime: '2025-01-01 11:00-14:00',
  visitor: 2,
  orderTime: '2024-12-29 15:33:02',
  placeTime: '2024-12-29 15:33:02',
  orderAmount: 79,
  notice: notice,
  contactPhone: '12011111113',
  ticketOwner: ticketOwner.slice(3, 4),
  isFree: false,
  performanceName: '下河文明巡回展',
};

const orderDetail5: GetOrderDetailResp = {
  orderNo: '5',
  status: '3',
  visitTime: '2025-01-01 上午',
  visitor: 2,
  orderTime: '2024-12-29 15:33:02',
  notice: notice,
  contactPhone: '12011111113',
  visitors: orderVisitor,
  isFree: true,
  performanceName: '主馆免费展',
};

const orderDetail6: GetOrderDetailResp = {
  orderNo: '6',
  status: '3',
  visitTime: '2025-01-01 11:00-14:00',
  visitor: 4,
  orderTime: '2024-12-29 15:33:02',
  payTime: '2024-12-29 15:33:02',
  placeTime: '2024-12-29 15:33:02',
  actualPay: 79,
  notice: notice,
  contactPhone: '12011111113',
  ticketOwner: ticketOwner,
  isFree: false,
  performanceName: '下河文明巡回展',
};

const orderDetail7: GetOrderDetailResp = {
  orderNo: '7',
  status: '4',
  visitTime: '2025-01-01 上午',
  visitor: 2,
  cancelTime: '2024-12-29 15:33:02',
  orderTime: '2024-12-29 15:33:02',
  notice: notice,
  contactPhone: '12011111113',
  visitors: orderVisitor,
  isFree: true,
  performanceName: '主馆免费展',
};

const orderDetail8: GetOrderDetailResp = {
  orderNo: '8',
  status: '4',
  visitTime: '2025-01-01 11:00-14:00',
  visitor: 2,
  orderTime: '2024-12-29 15:33:02',
  cancelTime: '2024-12-29 15:33:02',
  payTime: '2024-12-29 15:33:02',
  placeTime: '2024-12-29 15:33:02',
  actualPay: 79,
  orderAmount: 79,
  notice: notice,
  contactPhone: '12011111113',
  ticketOwner: ticketOwner,
  isFree: false,
  performanceName: '下河文明巡回展',
};

const orderDetail9: GetOrderDetailResp = {
  orderNo: '9',
  status: '5',
  visitTime: '2025-01-01 上午',
  visitor: 2,
  cancelTime: '2024-12-29 15:33:02',
  orderTime: '2024-12-29 15:33:02',
  notice: notice,
  contactPhone: '12011111113',
  visitors: orderVisitor,
  isFree: true,
  performanceName: '主馆免费展',
};

const orderDetail10: GetOrderDetailResp = {
  orderNo: '10',
  status: '5',
  visitTime: '2025-01-01 11:00-14:00',
  visitor: 4,
  orderTime: '2024-12-29 15:33:02',
  placeTime: '2024-12-29 15:33:02',
  payTime: '2024-12-29 15:33:02',
  cancelTime: '2024-12-29 15:33:02',
  notice: notice,
  contactPhone: '12011111113',
  ticketOwner: ticketOwner,
  isFree: false,
  performanceName: '下河文明巡回展',
};


const ticketNotice: string[] = [
  '• 购票：观众可通过XX博物馆微信小程序购票，全价票39元，老年票20元，学生票20元，未成年人免票。',
  '• 优惠与免票：',
  '• 60周岁（含）以上的老年人，6周岁以上、18周岁及以下的未成年人，在读全日制大学本科及以下学历学生，现役军人及家属、公安民警、烈士与军人遗属、消防救援人员等群体持有效证件可购优惠票；身高1.3米（含）以下或6周岁（含）以下的儿童、残疾人持有效证件享受免票。免票儿童需有成人陪同，1名成人可带2名免16票儿童。',
  '• 进馆参观：预约成功后凭本人身份证原件按预约时段进馆参观。优惠票与免票观众须携带本人有效证件原件进馆，以便查验。',
];

const ticketType1: TicketTypeInfo[] = [
  {
    ticketType: '1',
    typeCn: '标准票',
    des: '成人',
    price: 39,
    count: 0,
    notice: ticketNotice,
    limit: 5,
  },
  {
    ticketType: '2',
    typeCn: '未成年人免票',
    des: '18周岁以下（含18周岁）未成年人',
    price: 0,
    count: 0,
    notice: ticketNotice,
    limit: 5,
  },
  {
    ticketType: '3',
    typeCn: '老年票',
    des: '60周岁以上（含60周岁）老年人',
    price: 20,
    count: 0,
    notice: ticketNotice,
    limit: 5,
  },
  {
    ticketType: '4',
    typeCn: '学生票',
    des: '18周岁以上，本科及以下学历（不含成人教育、研究生需购买标准票）',
    price: 20,
    count: 0,
    notice: ticketNotice,
    limit: 5,
  },
];

const ticketType2: TicketTypeInfo[] = [
  {
    ticketType: '1',
    typeCn: '标准票',
    des: '成人',
    price: 59,
    count: 0,
    notice: ticketNotice,
    limit: 5,
  },
  {
    ticketType: '2',
    typeCn: '未成年人免票',
    des: '18周岁以下（含18周岁）未成年人',
    price: 0,
    count: 0,
    notice: ticketNotice,
    limit: 5,
  },
  {
    ticketType: '3',
    typeCn: '老年票',
    des: '60周岁以上（含60周岁）老年人',
    price: 30,
    count: 0,
    notice: ticketNotice,
    limit: 5,
  },
  {
    ticketType: '4',
    typeCn: '学生票',
    des: '18周岁以上，本科及以下学历（不含成人教育、研究生需购买标准票）',
    price: 30,
    count: 0,
    notice: ticketNotice,
    limit: 5,
  },
];


export class OrderDatasetMock {
  private static _orderList: GetOrderListInfoResp = [
    order1,
    order2,
    order3,
    order4,
    order5,
    order6,
    order7,
    order8,
    order9,
    order10,
  ];
  private static _orderDetailList: GetOrderDetailResp[] = [
    orderDetail1,
    orderDetail2,
    orderDetail3,
    orderDetail4,
    orderDetail5,
    orderDetail6,
    orderDetail7,
    orderDetail8,
    orderDetail9,
    orderDetail10,
  ];

  public static getOrderListMock(orderClass: string) {
    const orderListResp: GetOrderListInfoResp =
      OrderDatasetMock._orderList.filter((item) => item.status === orderClass);
    return getFormattedResp(orderListResp);
  }

  // 取消订单
  public static cancelOrder(data: CancelOrderRequest) {
    OrderDatasetMock._orderList = OrderDatasetMock._orderList.map(item => {
      if (item.orderNo === data.orderNo) {
        item.status = '5';
        item.cancelTime = data.cancelTime;
      }
      return item;
    });
    OrderDatasetMock._orderDetailList = OrderDatasetMock._orderDetailList.map(item => {
      if (item.orderNo === data.orderNo) {
        item.status = '5';
        item.cancelTime = data.cancelTime;
      }
      return item;
    });
  }

  public static getOrderDetailMock(orderNo: string) {
    const orderDetailResp =
      OrderDatasetMock._orderDetailList.find((item: GetOrderDetailResp) => item.orderNo === orderNo.toString());
    return getFormattedResp(orderDetailResp);
  }

  // 模拟免费订票
  public static orderFreeMock(data: OrderFreeRequest) {
    const order: OrderListItem = {
      orderNo: util.generateRandomUUID(false),
      status: '1',
      visitTime: data.visitTime,
      visitor: data.visitor,
      orderTime: data.orderTime,
      performanceName: '主馆免费展',
    };

    const orderDetail: GetOrderDetailResp = {
      orderNo: order.orderNo,
      status: '1',
      visitTime: data.visitTime,
      visitor: data.visitor,
      visitors: data.visitors,
      orderTime: data.orderTime,
      contactPhone: data.contactPhone,
      notice: notice,
      isFree: true,
      performanceName: '主馆免费展',
    };


    // 存入订单列表
    OrderDatasetMock._orderList.push(order);
    // 存入订单详情
    OrderDatasetMock._orderDetailList.push(orderDetail);
    // 返回订单详情
    const resp: BaseSuccessResponse<GetOrderDetailResp> = {
      code: 0,
      data: orderDetail,
    };
    return resp;
  }

  // 免费约展时间票务数据
  public static getDayTicketMock() {
    // 开发提前预约天数
    const openOrderDays: number = 14;
    // 每周闭馆日期
    const closeDay: string = '星期一';
    const data: GetDayTicketResp = getNextDays(openOrderDays).map((item, index) => {
      if (item.day === closeDay) {
        const res: DayTicketInfo = {
          date: item.date,
          day: item.day,
          total: 0,
          statusCn: '闭馆',
          status: '3',
          morningAmount: 0,
          afternoonAmount: 0,
        };
        return res;
      } else {
        if (index === 0) {
          const res: DayTicketInfo = {
            date: item.date,
            day: item.day,
            total: 0,
            statusCn: '约满',
            status: '2',
            morningAmount: 0,
            afternoonAmount: 0,
          };
          return res;
        } else {
          const res: DayTicketInfo = {
            date: item.date,
            day: item.day,
            total: 2500,
            statusCn: '可约',
            status: '1',
            morningAmount: 0,
            afternoonAmount: 2500,
          };
          return res;
        }
      }
    });

    const dayTicketResp: BaseResponse<GetDayTicketResp> = {
      code: 0,
      data: data,
    };
    return dayTicketResp;
  }

  //   付费约展时间票务信息
  public static getTimeTicketMock() {
    // 开发提前预约天数
    const openOrderDays: number = 14;
    // 每周闭馆日期
    const closeDay: string = '星期一';
    const timeSegment: TimeSegment[] = [
      {
        label: '09:00-11:00',
        buyStatus: '1',
        buyStatusCn: '可约',
        remainTicket: 500,
      },
      {
        label: '11:00-14:00',
        buyStatus: '1',
        buyStatusCn: '可约',
        remainTicket: 1000,
      },
      {
        label: '14:00-16:00',
        buyStatus: '1',
        buyStatusCn: '可约',
        remainTicket: 1000,
      },
    ];
    const data: GetTimeTicketResp = getNextDays(openOrderDays).map((item, index) => {
      if (item.day === closeDay) {
        const res: TimeTicketInfo = {
          date: item.date,
          day: item.day,
          total: 0,
          statusCn: '闭馆',
          status: '3',
          timeSegment: [],
        };
        return res;
      } else {
        if (index === 0) {
          const res: TimeTicketInfo = {
            date: item.date,
            day: item.day,
            total: 0,
            statusCn: '约满',
            status: '2',
            timeSegment: [],
          };
          return res;
        } else {
          const res: TimeTicketInfo = {
            date: item.date,
            day: item.day,
            total: 2500,
            statusCn: '可约',
            status: '1',
            timeSegment: timeSegment,

          };
          return res;
        }
      }
    });


    return getFormattedResp(data);
  }


  //   付费约展票种信息
  public static getTicketType(performanceId: string) {
    if (performanceId.toString() === '1') {
      const dataCopy: GetTicketTypeInfoResp = JSON.parse(JSON.stringify(ticketType1));
      return getFormattedResp(dataCopy);
    } else {
      const dataCopy: GetTicketTypeInfoResp = JSON.parse(JSON.stringify(ticketType2));
      return getFormattedResp(dataCopy);
    }
  }


  //   预支付
  public static prepayBuyTicket(data: PrepayBuyTicketRequest) {
    const orderNo: string = new Date().getTime().toString();
    const orderTime: string = FormatUtil.formatFullDate(new Date());
    const order: OrderListItem = {
      orderNo,
      visitTime: data.visitTime,
      orderTime,
      visitor: data.ticketOwner.length,
      status: '2',
      orderAmount: data.orderAmount,
      performanceName: data.performanceName,
    };
    OrderDatasetMock._orderList.push(order);
    const orderDetail: GetOrderDetailResp = {
      orderNo,
      orderTime,
      visitTime: data.visitTime,
      status: '2',
      orderAmount: data.orderAmount,
      ticketOwner: data.ticketOwner,
      contactPhone: data.contactPhone,
      performanceName: data.performanceName,
      isFree: false,
      notice: notice,
      visitor: data.ticketOwner.length,
      placeTime: orderTime,
    };

    OrderDatasetMock._orderDetailList.push(orderDetail);
    const res: PrepayBuyTicketResp = {
      orderNo,
      orderStr: '',
    };

    return getFormattedResp(res);

  }
}