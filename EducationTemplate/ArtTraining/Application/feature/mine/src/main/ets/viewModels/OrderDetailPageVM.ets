import { CoursePaymentMap, OrderInfo, OrderStatusMap, RouterMap, RouterModule } from 'commonlib';
import { https } from 'network';
import { ORDER_ACTION_BUTTON_LIST } from '../constants/Constants';
import { OrderActionMap } from '../constants/Enums';
import { OrderUtil } from '../utils/OrderUtil';


@ObservedV2
export class OrderDetailPageVM {
  private static _instance: OrderDetailPageVM;
  @Trace orderInfo: OrderInfo | null = null;
  @Trace timer: number | null = null;
  @Trace isLoading: boolean = false;
  @Trace countdownLabel: string = '';

  public static get instance() {
    if (!OrderDetailPageVM._instance) {
      OrderDetailPageVM._instance = new OrderDetailPageVM();
    }
    return OrderDetailPageVM._instance;
  }

  public async getOrderDetail() {
    const param = RouterModule.getNavParam<string>({
      url: RouterMap.MINE_ORDER_DETAIL,
    });
    if (param) {
      this.isLoading = true;
      const res = await https.getOrderDetail({ orderNo: param });
      if (res.ret.code === 0 && res.result) {
        this.orderInfo = res.result;
      }
      this.isLoading = false;
    }
    if (this.orderInfo && this.orderInfo.orderStatus === OrderStatusMap.PENDING_PAYMENT &&
      this.orderInfo.paymentMethod === CoursePaymentMap.ONLINE) {
      this.paymentCountdown(new Date(this.orderInfo.expireTime), (time) => {
        this.countdownLabel = time;
      });
    }
  }

  public paymentCountdown(expireTime: Date, callback: (timeRemaining: string) => void) {
    const pad = (num: number): string => {
      return num < 10 ? `0${num}` : num.toString();
    };

    this.timer = setInterval(() => {
      const now = new Date().getTime();
      const timeDifference = expireTime.getTime() - now;

      // 如果时间差小于等于 0，停止倒计时
      if (timeDifference <= 0) {
        this.clearCountdown();
        this.getOrderDetail();
        callback('00:00:00');
        return;
      }

      const hours = Math.floor(timeDifference / (1000 * 60 * 60));
      const minutes = Math.floor(timeDifference % (1000 * 60 * 60) / (1000 * 60));
      const seconds = Math.floor(timeDifference % (1000 * 60) / 1000);

      const formattedTime = `${pad(hours)}:${pad(minutes)}:${pad(seconds)}`;
      callback(formattedTime);
    }, 1000);
  }

  public clearCountdown() {
    if (this.timer) {
      clearInterval(this.timer);
      this.timer = null;
      this.countdownLabel = '';
    }
  }

  public handleOrderOperation(buttonType: OrderActionMap) {
    if (this.orderInfo) {
      OrderUtil.handleOrderOperation(this.orderInfo, buttonType, () => {
        this.getOrderDetail();
      });
    }
  }

  public getOrderActionButtonList(orderStatus?: number) {
    const list = ORDER_ACTION_BUTTON_LIST
      .filter((item) => item.orderStatus === orderStatus)
      .filter((item) => item.action !== OrderActionMap.DELETE);
    return list;
  }
}