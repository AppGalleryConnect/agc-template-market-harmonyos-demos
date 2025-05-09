import {
  AppStorageMap,
  CoursePaymentMap,
  DialogInfo,
  DialogMap,
  Logger,
  OrderInfo,
  OrderStatusMap,
  RouterMap,
  RouterModule,
  WindowUtil,
} from 'commonlib';
import { ORDER_ACTION_BUTTON_LIST } from '../constants/Constants';
import { OrderActionMap } from '../constants/Enums';
import { paymentService } from '@kit.PaymentKit';
import { common } from '@kit.AbilityKit';
import { promptAction } from '@kit.ArkUI';
import { BusinessError, Callback, pasteboard } from '@kit.BasicServicesKit';
import { https } from 'network';
import { ConfirmParam } from 'componentlib';

const TAG = '[OrderUtil]';

export class OrderUtil {
  public static getStatusLabel(status: number) {
    const labelMap: Map<OrderStatusMap, string> = new Map([
      [OrderStatusMap.PENDING_PAYMENT, '待支付'],
      [OrderStatusMap.CANCEL, '已取消'],
      [OrderStatusMap.COMPLETE, '已完成'],
      [OrderStatusMap.REFUND_IN_PROGRESS, '退款中'],
      [OrderStatusMap.REFUNDED, '已退款'],
    ]);
    return labelMap.get(status) ?? '';
  }

  public static getStatusDescLabel(status: number) {
    const labelMap: Map<OrderStatusMap, string> = new Map([
      [OrderStatusMap.PENDING_PAYMENT, '请尽快到店完成线下支付~'],
      [OrderStatusMap.CANCEL, '亲~您的订单已关闭'],
      [OrderStatusMap.COMPLETE, '订单已完成，记得按时上课~'],
      [OrderStatusMap.REFUND_IN_PROGRESS, '您的订单退款正在处理中'],
      [OrderStatusMap.REFUNDED, '您的订单已退款'],
    ]);
    return labelMap.get(status) ?? '';
  }

  public static getOrderActionButtonList(orderStatus?: number) {
    const list = ORDER_ACTION_BUTTON_LIST.filter((item) => item.orderStatus === orderStatus);
    return list;
  }

  public static getPaymentLabel(payment: number) {
    if (payment === CoursePaymentMap.OFFLINE) {
      return '线下支付';
    } else if (payment === CoursePaymentMap.ONLINE) {
      return '华为支付';
    }
    return '';
  }

  public static handleOrderOperation(order: OrderInfo, buttonType: OrderActionMap, callback?: Callback<void>) {
    switch (buttonType) {
      case OrderActionMap.IMMEDIATE_PAYMENT:
        OrderUtil._repayOrder(order, callback);
        break;
      case OrderActionMap.CANCEL_ORDER:
        OrderUtil._cancelOrder(order, callback);
        break;
      case OrderActionMap.CONTACT_CUSTOMER_SERVICE:
        const phone = AppStorage.get<string>(AppStorageMap.STORE_PHONE);
        if (phone) {
          RouterModule.push({
            url: DialogMap.CONTACT_CUSTOM_SERVICE,
            param: phone,
          });
        } else {
          promptAction.showToast({ message: '暂时无法联系客服，请前往首页查看商家号码' });
        }
        break;
      case OrderActionMap.REQUEST_REFUND:
        OrderUtil._requestRefund(order, callback);
        break;
      case OrderActionMap.CANCEL_REFUND:
        OrderUtil._cancelRefund(order, callback);
        break;
      case OrderActionMap.REORDER:
        RouterModule.push({
          url: RouterMap.COURSE_DETAIL,
          param: order.courseInfo,
        });
        break;
      case OrderActionMap.DELETE:
        OrderUtil._deleteOrder(order, callback);
        break;
      default:
        break;
    }

  }

  public static copyOrderNo(orderNo: string) {
    let pasteData = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, orderNo);
    let systemPasteboard = pasteboard.getSystemPasteboard();
    systemPasteboard.setData(pasteData)
      .then(() => {
        promptAction.showToast({ message: '订单号复制成功！' });
      })
      .catch((err: BusinessError) => {
        Logger.error(TAG, 'copy orderNo failed. error:' + JSON.stringify(err));
        promptAction.showToast({ message: '订单号复制失败，请稍后重试' });
      });
  }

  private static _repayOrder(order: OrderInfo, callback?: Callback<void>) {
    if (order.paymentMethod === CoursePaymentMap.OFFLINE) {
      promptAction.showToast({ message: '请尽快前往线下门店支付~' });
    } else if (order.paymentMethod === CoursePaymentMap.ONLINE) {
      const context = WindowUtil.context as common.UIAbilityContext;
      paymentService
        .requestPayment(context, order.orderStr)
        .then(() => {
          promptAction.showToast({ message: '支付成功！' });
          callback?.();
        })
        .catch((err: BusinessError) => {
          Logger.error(TAG, `call payment service failed. code: ${err.code},message:${err.message}`);
          promptAction.showToast({ message: '支付失败，请稍后重试~' });
        });
    }
  }

  private static _cancelOrder(order: OrderInfo, callback?: Callback<void>) {
    RouterModule.push({
      url: DialogMap.COMMON_CONFIRM,
      param: {
        title: '提示',
        message: '是否确认取消订单？',
      },
      onPop: async (value) => {
        const result = value.result as DialogInfo<ConfirmParam>;
        if (result.param?.isConfirm) {
          const res = await https.cancelCourseOrder({
            orderNo: order.orderNo,
          });
          if (res.ret.code === 0) {
            promptAction.showToast({ message: '订单取消成功！' });
            callback?.();
          }
        }
      },
    });
  }

  private static _requestRefund(order: OrderInfo, callback?: Callback<void>) {
    RouterModule.push({
      url: DialogMap.COMMON_CONFIRM,
      param: {
        title: '提示',
        message: '是否确认申请退款？',
      },
      onPop: async (value) => {
        const result = value.result as DialogInfo<ConfirmParam>;
        if (result.param?.isConfirm) {
          const res = await https.requestRefundCourseOrder({
            orderNo: order.orderNo,
          });
          if (res.ret.code === 0) {
            promptAction.showToast({ message: '退款申请成功，请耐心等待~' });
            callback?.();
          }
        }
      },
    });
  }

  private static _cancelRefund(order: OrderInfo, callback?: Callback<void>) {
    RouterModule.push({
      url: DialogMap.COMMON_CONFIRM,
      param: {
        title: '提示',
        message: '是否取消退款申请？',
      },
      onPop: async (value) => {
        const result = value.result as DialogInfo<ConfirmParam>;
        if (result.param?.isConfirm) {
          const res = await https.cancelRefundCourseOrder({
            orderNo: order.orderNo,
          });
          if (res.ret.code === 0) {
            promptAction.showToast({ message: '取消退款成功！' });
            callback?.();
          }
        }
      },
    });
  }

  private static _deleteOrder(order: OrderInfo, callback?: Callback<void>) {
    RouterModule.push({
      url: DialogMap.COMMON_CONFIRM,
      param: {
        title: '提示',
        message: '是否确认删除订单？',
      },
      onPop: async (value) => {
        const result = value.result as DialogInfo<ConfirmParam>;
        if (result.param?.isConfirm) {
          const res = await https.deleteCourseOrder({
            orderNo: order.orderNo,
          });
          if (res.ret.code === 0) {
            promptAction.showToast({ message: '订单删除成功！' });
            callback?.();
          }
        }
      },
    });
  }
}