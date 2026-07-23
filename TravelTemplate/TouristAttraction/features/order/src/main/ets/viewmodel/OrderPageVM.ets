import { UtilLog } from '@hw-agconnect/util-log';
import { common } from '@kit.AbilityKit';
import { AppStorageV2 } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { paymentService } from '@kit.PaymentKit';
import { BreakpointModel, BreakpointNameEnum, SystemUtil } from 'common';
import { GetCommodityOrderListResp, GetOrderDetailRequest, GetTicketOrderListResp, https } from 'network';
import { CommodityOrderInfo, TicketOrderInfo, WindowSize } from 'types';
import { mapperCommodityOrderList, mapperTicketOrderList } from '../mapper/Index';
import {
  COMMODITY_ORDER_MODULE_INFO,
  ORDER_INFO_MAP,
  OrderType,
  TICKET_ORDER_MODULE_INFO,
} from '../model/OrderModuleInfo';

@ObservedV2
export class OrderPageVM {
  @Trace isFromMine: boolean = false;
  @Trace orderType: number = 0;
  @Trace orderTabIndex: number = 0;
  @Trace isLoading: boolean = false;
  @Trace hasData: boolean = false;
  @Trace breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Trace ticketOrderList: GetTicketOrderListResp =
    AppStorageV2.connect(GetTicketOrderListResp, 'GetTicketOrderListResp', () => new GetTicketOrderListResp()) ?? [];
  @Trace commodityOrderList: GetCommodityOrderListResp =
    AppStorageV2.connect(GetCommodityOrderListResp, 'GetCommodityOrderListResp',
      () => new GetCommodityOrderListResp()) ?? [];
  @Trace windowSize: WindowSize = AppStorageV2.connect(WindowSize, 'WindowSize', () => new WindowSize())!;
  public static _instance: OrderPageVM;

  public static get instance() {
    if (!OrderPageVM._instance) {
      OrderPageVM._instance = new OrderPageVM();
    }
    return OrderPageVM._instance;
  }

  getOrderLane() {
    return [BreakpointNameEnum.MD, BreakpointNameEnum.SM].includes(this.breakPointModel.currentBreakpoint) ? 1 : 2;
  }

  getOrderStatus(item: TicketOrderInfo | CommodityOrderInfo) {
    return item.orderStatus;
  }

  getTicketStatus(item: TicketOrderInfo) {
    return ORDER_INFO_MAP[item.orderStatus];
  }

  getTitle(index: number): ResourceStr {
    return this.orderType === 0 ? TICKET_ORDER_MODULE_INFO[index].title : COMMODITY_ORDER_MODULE_INFO[index].title;
  }

  getCommodityStatus(item: CommodityOrderInfo) {
    return ORDER_INFO_MAP[item.orderStatus];
  }

  getOrderList() {
    this.isLoading = true;
    let param = {
      category: this.orderType, orderStatus: this.orderTabIndex,
    } as GetOrderDetailRequest;

    https.getOrderList(param).then((res: ESObject) => {
      if (this.orderType === 0) {
        this.ticketOrderList = mapperTicketOrderList(res.data);
        this.hasData = 0 < this.ticketOrderList.length;
      } else {
        this.commodityOrderList = mapperCommodityOrderList(res.data);
        this.hasData = 0 < this.commodityOrderList.length;
      }
      this.isLoading = false;
    });
  }

  // 调用华为支付客户端
  requestPaymentPromise(context: common.UIAbilityContext): Promise<void> { // todo: 补充订购信息
    return new Promise((resolve, reject) => {
      try {
        const orderStr = '{}';
        paymentService.requestPayment(context, orderStr).then(() => {
          UtilLog.info('succeeded in paying');
          resolve();
        }).catch((error: BusinessError) => {
          UtilLog.error(`failed to pay, error.code: ${error.code}, error.message: ${error.message}`);
          reject();
        });
      } catch (e) {
        UtilLog.error('paymentService undefined');
        // todo 模拟器无法获取paymentService对象，模拟支付成功，此处应为：reject()
        resolve();
      }
      ;
    });
  }

  refundOrder(info: TicketOrderInfo | CommodityOrderInfo) {
    let param: GetOrderDetailRequest = {
      category: this.orderType, orderNo: info.orderNo, orderStatus: OrderType.REFUNDED,
    };
    https.modifyOrderDetail(param).then((res: ESObject) => {
      if (res.code === 0) {
        this.orderTabIndex = param.orderStatus ?? 0;
        this.getOrderList();
      }
    });
  }

  updateOrder(info: TicketOrderInfo) {
    let param: GetOrderDetailRequest = {
      category: this.orderType,
      orderNo: info.orderNo,
      isAddSchedule: info.isAddSchedule,
      isAddSubscription: info.isAddSubscription,
    };
    https.modifyOrderDetail(param).then((res: ESObject) => {
      if (res.code === 0) {
        this.orderTabIndex = param.orderStatus ?? 0;
        this.getOrderList();
      }
    });
  }

  async addSchedule(item: TicketOrderInfo, context: UIContext) {
    if (item.isAddSchedule) {
      context.getPromptAction().showToast({ message: $r('app.string.toast_schedule_cannot_cancel') });
      return;
    }
    const timeStamp = new Date(item.startTime).getTime();
    const isSuccess =
      await SystemUtil.addEvent(timeStamp, item.productName, context.getHostContext() as common.UIAbilityContext);
    if (!isSuccess) {
      context.getPromptAction().showToast({ message: $r('app.string.toast_schedule_added_fail') });
      return;
    }
    context.getPromptAction().showToast({ message: $r('app.string.toast_schedule_added') });
    item.isAddSchedule = true;
    this.updateOrder(item);
  }
}