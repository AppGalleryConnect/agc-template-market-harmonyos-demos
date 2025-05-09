import { OrderClass, OrderTabListItem, OrderInfo, TotalInfo, Contacts } from '../types/Index';
import { https, TicketOwner, GetOrderDetailResp, BaseSuccessResponse } from 'network';
import { AccountUtil, RouterModule, RouterMap, CommonConstants, FormatUtil, Logger } from 'commonlib';
import { promptAction } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { paymentService } from '@kit.PaymentKit';
import { BusinessError, emitter } from '@kit.BasicServicesKit';


const TAG = '[MyOrdersVM]';

@ObservedV2
export class MyOrdersVM {
  context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
  @Trace userId: number = 0;
  @Trace message: string = '我的订单';
  @Trace fontColor: ResourceColor = CommonConstants.FONT_COLOR_BLACK;
  @Trace selectedFontColor: ResourceColor = '#0A59F7';
  @Trace currentIndex: number = 0;
  @Trace selectedIndex: number = 0;
  @Trace orderTabList: OrderTabListItem[] =
    [{ label: '待使用', type: OrderClass.PENDING_USE, icon: $r('app.media.icon_pending') },
      { label: '待支付', type: OrderClass.PENDING_PAYMENT, icon: $r('app.media.icon_pending') },
      { label: '已使用', type: OrderClass.USED, icon: $r('app.media.icon_used') },
      { label: '已过期', type: OrderClass.EXPIRED, icon: $r('app.media.icon_expired') },
      { label: '已失效', type: OrderClass.INVALIDATION, icon: $r('app.media.icon_expired') }];
  @Trace orderList: OrderInfo[] = [];
  @Trace orderNo: string = '';
  @Trace isLoading: boolean = false;
  @Trace ticketTypeMap: Map<string, string> =
    new Map([['1', '标准票'], ['2', '未成年人免票'], ['3', '老年人票'], ['4', '学生票']]);
  // 门票详情
  @Trace orderDetail: GetOrderDetailResp | undefined = undefined;
  @Trace navTitle: string = '';
  // 预取消订单的订单号
  @Trace targetOrderNo: string = '';
  private static _instance: MyOrdersVM;

  public static get instance() {
    if (!MyOrdersVM._instance) {
      MyOrdersVM._instance = new MyOrdersVM();
    }
    return MyOrdersVM._instance;
  }

  public async initData() {
    this.getUserId();
    this.getOrderList();
  }


  public async getOrderList() {
    this.isLoading = true;
    this.orderList = [];
    const orderClass = this.orderTabList[this.currentIndex].type;
    const res = await https.getOrderList({ orderClass: orderClass.toString(), userId: this.userId });
    if (res.code === 0) {
      if (orderClass === OrderClass.PENDING_PAYMENT) {
        this.orderList = res.data.sort((a, b) => new Date(b.orderTime).getTime() - new Date(a.orderTime).getTime());
      } else if (orderClass === OrderClass.INVALIDATION) {
        this.orderList = res.data.sort((a, b) => new Date(b.cancelTime as string).getTime() -
        new Date(a.cancelTime as string).getTime());
      } else {
        this.orderList = res.data.sort((a, b) => new Date(this.formatVisitTime(a.visitTime)).getTime() -
        new Date(this.formatVisitTime(b.visitTime)).getTime());
      }
      this.isLoading = false;
    }
  }

  public formatVisitTime(visitTime: string) {
    let timeArr = visitTime.split(' ');
    if (timeArr[1] === '上午') {
      return timeArr[0] + ' ' + '8:00:00';
    } else if (timeArr[1] === '下午') {
      return timeArr[0] + ' ' + '14:00:00';
    } else {
      return visitTime;
    }
  }

  public getLabel(status: string): string {
    const label = this.orderTabList.find((item) => item.type === status)?.label;
    this.navTitle = label ?? '';
    return label ?? '';
  }

  public getIcon(status: string): ResourceStr {
    const icon = this.orderTabList.find((item) => item.type === status)?.icon;
    return icon ?? '';
  }

  public getTotal(arr: TicketOwner[] | undefined): TotalInfo {
    let total = 0;
    let totalPrice = 0;
    if (arr && arr.length > 0) {
      arr.forEach((item) => {
        total += item.ticket;
        totalPrice += item.ticket * item.price;
      });
    }
    return {
      total,
      totalPrice,
    };
  }

  public async getOrderDetail() {
    this.isLoading = true;
    const params: Record<string, string> | undefined = RouterModule.getNavParam({ url: RouterMap.TICKET_DETAIL });
    if (params) {
      const res = await https.getOrderDetail({ userId: this.userId, orderNo: params.orderNo });
      if (res.code === 0) {
        this.orderDetail = res.data as GetOrderDetailResp;
        this.isLoading = false;
      }
    }
  }

  public async cancelOrder(orderNo: string) {
    const cancelTime = FormatUtil.formatFullDate(new Date());
    const res: BaseSuccessResponse =
      await https.cancelOrder({ userId: AccountUtil.getUserInfo().id, orderNo, cancelTime });
    if (res.code === 0) {
      promptAction.showToast({ message: '取消成功!' });
      this.getOrderList();
    }
  }

  public async cancelOrderInDetail(orderNo: string) {
    const cancelTime = FormatUtil.formatFullDate(new Date());
    const res: BaseSuccessResponse =
      await https.cancelOrder({ userId: AccountUtil.getUserInfo().id, orderNo, cancelTime });
    if (res.code === 0) {
      promptAction.showToast({ message: '取消成功!' });
      // 刷新卡片
      emitter.emit('refreshCard');
      this.getOrderDetail();
      // 刷新返回时的订单列表
      this.getOrderList();
    }
  }

  public async toPay(orderStr: string) {
    paymentService
      .requestPayment(this.context, orderStr)
      .then(() => {
        Logger.info('succeeded in paying');
      })
      .catch((error: BusinessError) => {
        promptAction.showToast({ message: '支付失败！' });
        Logger.error(`failed to pay, error.code: ${error.code}, error.message: ${error.message}`);
      });
  }

  private getUserId() {
    let userInfo = AccountUtil.getUserInfo();
    this.userId = userInfo.id;
  }
}