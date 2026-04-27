import { BusinessError, pasteboard } from '@kit.BasicServicesKit';
import { CashierPicker, PaymentType, aggregatedPaymentService } from 'aggregated_payment';
import { RouterMap, routerStack, SafeJson, WindowUtil, iData } from 'lib_foundation';
import {
  AddressInfo,
  CouponApis,
  LogisticsItem,
  OrderApis,
  OrderItem,
  OrderSkuItem,
  OrderStatus,
  ProductApis,
  ShoppingCartApis,
} from 'lib_network';
import { OrderReviewReq } from 'lib_network';
import { CartUpdateResp } from 'lib_network/src/main/ets/types/responses/CartResponse';
import { CommonConfirmDialog, CustomServiceSheet } from 'lib_widget';
import { UtilLog as Logger, UtilLog } from '@hw-agconnect/util-log';
import {
  ORDER_STATUS_COMPLETE,
  ORDER_STATUS_PENDING_PAYMENT,
  ORDER_STATUS_PENDING_PICKUP,
  ORDER_STATUS_PENDING_RECEIPT,
  ORDER_STATUS_PENDING_REVIEW,
  ORDER_STATUS_PENDING_SHIPMENT,
  ORDER_STATUS_REFUNDED,
  ORDER_STATUS_REFUND_IN_PROGRESS,
  ORDER_STATUS_REVIEWED,
} from '../common/Constants';
import {
  OrderActionMap, OrderShipmentMap, OrderStatusMap,
} from '../common/Enums';
import { CourierInfo, OrderActionReq, OrderStatusInfo } from '../common/Types';

const TAG: string = '[OrderUtil]';

export class OrderUtil {
  public static getStatusLabel(status: number) {
    const labelMap: Map<OrderStatusMap, string> = new Map([
      [OrderStatusMap.PENDING_PAYMENT, '待付款'],
      [OrderStatusMap.CANCELED, '已取消'],
      [OrderStatusMap.PENDING_SHIPMENT, '待发货'],
      [OrderStatusMap.PENDING_RECEIPT, '待收货'],
      [OrderStatusMap.PENDING_PICKUP, '待取件'],
      [OrderStatusMap.PENDING_REVIEW, '交易成功'],
      [OrderStatusMap.REVIEWED, '已完成'],
      [OrderStatusMap.REFUND_IN_PROGRESS, '退款中'],
      [OrderStatusMap.REFUNDED, '退款成功'],
    ]);
    return labelMap.get(status) ?? '';
  }

  public static getReceiveMethodLabel(method: number) {
    if (method === OrderShipmentMap.EXPRESS) {
      return '快递到家';
    } else if (method === OrderShipmentMap.SELF_PICK_UP) {
      return '到店自提';
    }
    return '';
  }

  public static getLogisticStatusLabel(status: number) {
    const labelMap: Map<number, string> = new Map([
      [101, '待确认'],
      [102, '待发货'],
      [201, '已发货'],
      [202, '已揽收'],
      [203, '运输中'],
      [204, '派件中'],
      [205, '待收货'],
      [301, '已签收'],
    ]);
    return labelMap.get(status) ?? '';
  }

  public static getLogisticStatusTime(node: LogisticsItem) {
    if (node.details.length) {
      return node.details[node.details.length-1].time;
    }
    return '';
  }

  public static getCourierInfo(info?: LogisticsItem[]) {
    if (info?.length && info[0].courier && info[0].contactPhone) {
      return {
        name: info[0].courier,
        contactPhone: info[0].contactPhone,
      } as CourierInfo;
    }
    return undefined;
  }

  public static getButtonList(status: number) {
    const actionMap: Map<OrderStatusMap, OrderStatusInfo> = new Map([
      [OrderStatusMap.CANCELED, ORDER_STATUS_COMPLETE],
      [OrderStatusMap.PENDING_PAYMENT, ORDER_STATUS_PENDING_PAYMENT],
      [OrderStatusMap.PENDING_SHIPMENT, ORDER_STATUS_PENDING_SHIPMENT],
      [OrderStatusMap.PENDING_RECEIPT, ORDER_STATUS_PENDING_RECEIPT],
      [OrderStatusMap.PENDING_PICKUP, ORDER_STATUS_PENDING_PICKUP],
      [OrderStatusMap.PENDING_REVIEW, ORDER_STATUS_PENDING_REVIEW],
      [OrderStatusMap.REVIEWED, ORDER_STATUS_REVIEWED],
      [OrderStatusMap.REFUND_IN_PROGRESS, ORDER_STATUS_REFUND_IN_PROGRESS],
      [OrderStatusMap.REFUNDED, ORDER_STATUS_REFUNDED],
    ]);
    return actionMap.get(status)?.action ?? [];
  }

  public static handleOrderAction(
    actionType: OrderActionMap,
    param: OrderActionReq,
  ) {
    type Handler = (param: OrderActionReq) => void;
    const actionMap: Map<OrderActionMap, Handler> = new Map([
      [OrderActionMap.IMMEDIATE_PAYMENT, OrderUtil.handleImmediatePayment],
      [OrderActionMap.URGE_SHIPMENT, OrderUtil.handleUrgeShipment],
      [OrderActionMap.CONFIRM_RECEIPT, OrderUtil.handleConfirmReceipt],
      [OrderActionMap.CONFIRM_PICKUP, OrderUtil.handleConfirmPickup],
      [OrderActionMap.CANCEL_ORDER, OrderUtil.handleCancelOrder],
      [OrderActionMap.UPDATE_ADDRESS, OrderUtil.handleUpdateAddress],
      [OrderActionMap.REVIEW, OrderUtil.handleReview],
      [OrderActionMap.VIEW_REVIEW, OrderUtil.handleViewReview],
      [
        OrderActionMap.CONTACT_CUSTOMER_SERVICE,
        OrderUtil.handleContactCustomerService,
      ],
      [OrderActionMap.REQUEST_REFUND, OrderUtil.handleRequestRefund],
      [OrderActionMap.CANCEL_REFUND, OrderUtil.handleCancelRefund],
      [OrderActionMap.REORDER, OrderUtil.handleReorder],
      [OrderActionMap.DELETE, OrderUtil.handleDelete],
    ]);
    const handler = actionMap.get(actionType);
    if (handler) {
      handler(param);
    } else {
      Logger.error(TAG, 'invalid action type.' + actionType);
    }
  }

  public static async updateCouponStatus(couponId: string | undefined, couponStatus: number): Promise<boolean> {
    if (!couponId) {
      return true;
    }
    const userId: string = iData.global.userInfo.phone;
    const res = await CouponApis.updateCoupon({
      userId,
      couponId,
      couponStatus,
    });
    if (res.code !== 0) {
      if (couponStatus === 1) {
        WindowUtil.toast('优惠券状态更新失败，请稍后重试');
      } else {
        WindowUtil.toast('优惠券恢复失败，请稍后重试');
      }
      return false;
    }
    return true;
  }

  /**
   * 立即支付
   * @param param
   */
  public static handleImmediatePayment(param: OrderActionReq) {
    const order = param.data as OrderItem;
    const cashierPicker: CashierPicker = new CashierPicker(WindowUtil.globalUIContext)
      .onRealPayment(async (type: PaymentType) => {
        await OrderUtil._startPayment(type);
      })
      .onWillDismiss((reason: DismissReason) => {
        if (reason !== DismissReason.TOUCH_OUTSIDE) {
          routerStack.replacePathByName(RouterMap.ORDER_INFO, param.orderNo);
          cashierPicker.close();
        }
      });
    aggregatedPaymentService.registerPaymentCallback(
      async (_type: PaymentType, isSuccess: boolean) => {
        if (!isSuccess) {
          WindowUtil.toast('本地调试阶段，模拟支付成功回调');
        }
        const payStatus = order.orderInfo.receivingMethod === OrderShipmentMap.SELF_PICK_UP
          ? OrderStatusMap.PENDING_PICKUP
          : OrderStatus.PENDING_SHIPMENT;
        OrderApis.updateDetail(param.orderNo, {
          status: payStatus,
        }).then((res) => {
          if (res.code === 0) {
            WindowUtil.toast('订单支付成功！');
          }
        }).finally(() => {
          routerStack.replacePathByName(RouterMap.ORDER_INFO, param.orderNo);
          cashierPicker.close();
        });
      },
    );
    cashierPicker
      .reset()
      .setAmount(order.orderInfo.finalPrice * 100)
      .open();
  }

  /**
   * 催发货
   * @param param
   */
  public static handleUrgeShipment(param: OrderActionReq) {
    // 处理催促发货逻辑
    WindowUtil.toast('已提交催发货申请，请耐心等待~');
  }

  /**
   * 确认收货
   * @param param
   */
  public static handleConfirmReceipt(param: OrderActionReq) {
    CommonConfirmDialog.show({
      primaryTitle: '提示',
      secondaryTitle: '确认收到货了吗？',
      content: '为了保证您的售后权益，请收到商品确认无误后再确认收货',
      confirm: () => {
        OrderApis.updateDetail(param.orderNo, {
          status: OrderStatusMap.PENDING_REVIEW,
        }).then(() => {
          WindowUtil.toast('订单确认收货成功');
          param.callback?.();
        });
      },
    });
  }

  /**
   * 确认取件（到店自提）
   * @param param
   */
  public static handleConfirmPickup(param: OrderActionReq) {
    CommonConfirmDialog.show({
      primaryTitle: '提示',
      secondaryTitle: '确认已取件了吗？',
      content: '请到店取件确认无误后再确认',
      confirm: () => {
        OrderApis.updateDetail(param.orderNo, {
          status: OrderStatusMap.PENDING_REVIEW,
        }).then(() => {
          WindowUtil.toast('订单确认取件成功');
          param.callback?.();
        });
      },
    });
  }

  /**
   * 取消订单
   * @param param
   */
  public static handleCancelOrder(param: OrderActionReq) {
    const order = param.data as OrderItem;
    CommonConfirmDialog.show({
      primaryTitle: '提示',
      content: '取消后无法恢复，是否确认取消订单',
      confirm: async () => {
        const isCouponUpdated = await OrderUtil.updateCouponStatus(order?.orderInfo?.couponId, 0);
        if (!isCouponUpdated) {
          return;
        }
        OrderApis.updateDetail(param.orderNo, {
          status: OrderStatusMap.CANCELED,
        }).then((res) => {
          if (res.code === 0) {
            WindowUtil.toast('订单取消成功');
            param.callback?.();
          }
        });
      },
    });
  }

  /**
   * 更新地址
   * @param param
   */
  public static handleUpdateAddress(param: OrderActionReq) {
    OrderApis.updateDetail(param.orderNo, {
      addressInfo: param.data as AddressInfo,
    }).then((res) => {
      if (res.code === 0) {
        WindowUtil.toast('地址更新成功！');
        param.callback?.();
      }
    });
  }

  /**
   * 评价商品
   * @param param
   */
  public static handleReview(param: OrderActionReq) {
    const data = param.data as OrderReviewReq;
    OrderApis.addComment(param.orderNo, data).then(
      (res) => {
        if (res.code === 0) {
          WindowUtil.toast('添加评论成功！');
          param.callback?.();
        }
      },
    );
    ProductApis.createProductReview(data.reviews);
  }

  /**
   * 查看商品评价
   * @param param
   */
  public static handleViewReview(param: OrderActionReq) {
    routerStack.pushPath({
      name: RouterMap.ORDER_REVIEW_INFO,
      param: param.data,
    });
  }

  /**
   * 联系客服
   * @param param
   */
  public static handleContactCustomerService(param: OrderActionReq) {
    CustomServiceSheet.show();
  }

  /**
   * 申请退款
   * @param param
   */
  public static handleRequestRefund(param: OrderActionReq) {
    CommonConfirmDialog.show({
      primaryTitle: '提示',
      content: '是否确认申请退款？',
      confirm: () => {
        OrderApis.updateDetail(param.orderNo, {
          status: OrderStatusMap.REFUND_IN_PROGRESS,
        }).then((res) => {
          if (res.code === 0) {
            WindowUtil.toast('订单申请退款成功，请等待商家确认');
            param.callback?.();
          }
        });
      },
    });
  }

  /**
   * 取消退款申请
   * @param param
   */
  public static handleCancelRefund(param: OrderActionReq) {
    const data = param.data as OrderItem;
    let status: number;
    if (data?.orderInfo?.receivingMethod === OrderShipmentMap.SELF_PICK_UP) {
      status = OrderStatusMap.PENDING_PICKUP;
    } else if (data?.logisticInfo?.length === 1) {
      status = OrderStatusMap.PENDING_SHIPMENT;
    } else {
      status = OrderStatusMap.PENDING_RECEIPT;
    }
    CommonConfirmDialog.show({
      primaryTitle: '提示',
      content: '是否确认取消退款申请？',
      confirm: () => {
        OrderApis.updateDetail(param.orderNo, {
          status,
        }).then((res) => {
          if (res.code === 0) {
            WindowUtil.toast(
              '订单取消退款成功，请在收到商品确认无误后确认收货',
            );
            param.callback?.();
          }
        });
      },
    });
  }

  /**
   * 重新下单，将本单商品加入购物车
   * @param param
   */
  public static handleReorder(param: OrderActionReq) {
    const data = param.data as OrderSkuItem[];
    if (data?.length) {
      let promises: Promise<CartUpdateResp>[] = [];
      let skuTable: Record<string, string | number> = {};
      data.forEach((item) => {
        skuTable[item.skuCode] = item.count;
        const promise = ShoppingCartApis.addSkuToCart({
          skuCode: item.skuCode,
          count: item.count,
          priceType: item.priceType,
        });
        promises.push(promise);
      });
      Promise.all(promises).then(() => {
        WindowUtil.toast('成功加入购物车');
        routerStack.pushPath({ name: RouterMap.PRODUCT_CART });
      });
    }
  }

  /**
   * 删除订单
   * @param param
   */
  public static handleDelete(param: OrderActionReq) {
    CommonConfirmDialog.show({
      primaryTitle: '提示',
      content: '是否确认删除订单，删除后不可恢复',
      confirm: () => {
        OrderApis.deleteDetail(param.orderNo).then((res) => {
          if (res.code === 0) {
            WindowUtil.toast('订单删除成功！');
            param.callback?.();
          }
        });
      },
    });
  }

  /**
   * 复制订单号
   * @param orderNo
   */
  public static copyOrderNumber(orderNo: string) {
    try {
      const pasteboardData = pasteboard.createData(
        pasteboard.MIMETYPE_TEXT_PLAIN,
        orderNo,
      );
      const systemPasteboard = pasteboard.getSystemPasteboard();
      systemPasteboard
        .setData(pasteboardData)
        .then(() => {
          WindowUtil.toast('复制成功!');
        })
        .catch((err: BusinessError) => {
          WindowUtil.toast('复制失败!');
          Logger.error(
            TAG,
            'copy order number failed. error:' + JSON.stringify(err),
          );
        });
    } catch (err) {
      WindowUtil.toast('复制失败!');
      Logger.error(TAG, 'copy order number failed. err' + SafeJson.jsonStringify(err));
    }
  }

  private static async _startPayment(type: PaymentType) {
    // todo: 根据支付类型向服务器请求支付所需参数
    try {
      if (type === PaymentType.ALIPAY) {
        /**
         * 请求拉起支付宝
         *
         * 临时测试时，orderInfo 不推荐传入空字符串，这会导致跳转至支付宝行为仅仅是跳转，不会有支付相关的交互
         * 未安装支付宝且参数真实时，SDK 会尝试使用 this.navPathStack 跳转至 H5 页面继续支付，该参数可不传
         */
        aggregatedPaymentService.requestPaymentByAliPay({ orderInfo: 'ORDER_INFO' }, routerStack.getActiveStack());
      } else if (type === PaymentType.HUAWEI) {
        /**
         * 请求拉起华为支付
         */
        aggregatedPaymentService.requestPaymentByHuawei(WindowUtil.globalUIContext, { orderStr: '' });
      } else if (type === PaymentType.WECHAT) {
        /**
         * 请求拉起微信支付
         *
         * 微信支持获取拉起结果，如果拉起成功，则可以进一步尝试等待支付回调。如果拉起失败，则不会有支付回调。
         */
        const isWeChatOpenSuccess: boolean =
          await aggregatedPaymentService.requestPaymentByWeChat(WindowUtil.globalUIContext, {
            partnerId: '',
            prepayId: '',
            nonceStr: '',
            timeStamp: '',
            sign: '',
          });
        if (!isWeChatOpenSuccess) {
          WindowUtil.toast('微信拉起失败');
        }
      }
    } catch (err) {
      UtilLog.error('[OrderSubmitVM]', 'start payment failed. error: ' + JSON.stringify(err));
    }
  }
}
