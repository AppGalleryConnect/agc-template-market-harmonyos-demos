import { CourseInfo, OrderInfo } from 'commonlib';
import { CourseOrderReq } from '../types/RequestTypes';
import { course1, CourseDatasetMock } from './CourseDatasetMock';

const order1: OrderInfo = {
  orderTime: '2025-02-01T12:00:00', // 订单时间
  expireTime: '',
  orderStatus: 1, // 订单状态已支付
  orderNo: 'order20250201001', // 订单编号
  paymentMethod: 1, // 支付方式：支付宝
  orderStr: 'order20250201', // 订单字符串（可选）
  courseInfo: course1, // 关联课程信息
  totalPrice: 199,
  student: '小明',
  phone: '12300000000',
};

// 订单信息 2
const order2: OrderInfo = {
  orderTime: '2025-02-02T09:30:00', // 订单时间
  expireTime: '',
  orderStatus: 2, // 订单状态未支付
  orderNo: 'order20250202001', // 订单编号
  paymentMethod: 2, // 支付方式：微信支付
  orderStr: 'order20250202001', // 订单字符串（可选）
  courseInfo: course1, // 关联课程信息
  totalPrice: 199,
  student: '小明',
  phone: '12300000000',

};

// 订单信息 3
const order3: OrderInfo = {
  orderTime: '2025-02-10T15:00:00', // 订单时间
  expireTime: '',
  orderStatus: 3, // 订单状态已支付
  orderNo: 'order202502010001', // 订单编号
  paymentMethod: 3, // 支付方式：银行转账
  orderStr: 'order202502010001', // 订单字符串（可选）
  courseInfo: course1, // 关联课程信息
  totalPrice: 199,
  student: '小明',
  phone: '12300000000',
};

export class OrderDatasetMock {
  private static _orderList = [order1, order2, order3];

  public static createCourseOrder(data: CourseOrderReq): OrderInfo | undefined {
    const course: CourseInfo = JSON.parse(JSON.stringify(CourseDatasetMock.getCourseDetail(data.courseId)));
    if (course) {
      const orderTime = new Date();
      const expireTime = new Date((orderTime.getTime() + 60 * 60 * 24 * 1000).toString());
      const timeStr = orderTime.getTime().toString();
      const order: OrderInfo = {
        orderTime: timeStr,
        expireTime: expireTime.getTime().toString(),
        orderNo: `order${orderTime.getTime()}`,
        orderStatus: 1,
        paymentMethod: data.paymentMethod,
        student: data.student,
        phone: data.phone,
        courseInfo: course,
        totalPrice: course.price,
        orderStr: timeStr,
      };
      OrderDatasetMock._orderList.push(order);
      return order;
    }
    return undefined;
  }

  public static cancelCourseOrder(orderNo: string): boolean {
    const order = OrderDatasetMock._orderList.find((item) => item.orderNo === orderNo);
    if (order) {
      order.orderStatus = 2;
      return true;
    }
    return false;
  }

  public static getOrderList(statusArr: number[]): OrderInfo[] {
    const list = OrderDatasetMock._orderList.filter((item) => statusArr.includes(item.orderStatus));
    return list;
  }

  public static getOrderDetail(orderNo: string) {
    const item = OrderDatasetMock._orderList.find((item) => item.orderNo === orderNo)!;
    return item;
  }
}