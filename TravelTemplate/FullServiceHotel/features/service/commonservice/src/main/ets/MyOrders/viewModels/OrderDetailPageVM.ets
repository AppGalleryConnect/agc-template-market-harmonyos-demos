import { GetHotelOrderDetailResp, GetMealOrderDetailResp, GetOrderDetailRequest, https } from 'network';
import { FormatUtil, Logger, RouterMap, RouterModule } from 'commonlib';
import { Constants } from '../constants';
import { OrderClass, OrderClassLabel, OrderType } from '../types';
import { paymentService } from '@kit.PaymentKit';
import { common } from '@kit.AbilityKit';
import { promptAction } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';

@ObservedV2
export class OrderDetailPageVM {
  @Trace orderType: OrderType = OrderType.HOTEL;
  @Trace orderClass: OrderClass | null = null;
  @Trace hotelOrderItem: GetHotelOrderDetailResp | null = null;
  @Trace mealOrderItem: GetMealOrderDetailResp | null = null;
  @Trace subTitle: string = '';
  context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
  private static _instance: OrderDetailPageVM;

  public static get instance() {
    if (!OrderDetailPageVM._instance) {
      OrderDetailPageVM._instance = new OrderDetailPageVM();
    }
    return OrderDetailPageVM._instance;
  }

  public async getOrderDetail() {
    this.hotelOrderItem = null;
    this.mealOrderItem = null;
    const params: GetOrderDetailRequest | undefined = RouterModule.getNavParam({
      url: RouterMap.ORDER_DETAIL,
    });
    if (params) {
      this.orderType = params.orderType;
      if (this.orderType === OrderType.HOTEL) {
        this.getHotelOrderDetail(params);
      } else if (this.orderType === OrderType.MEAL) {
        this.getMealOrderDetail(params);
      }
    }
  }

  public async getHotelOrderDetail(info: GetOrderDetailRequest) {
    const res = await https.getHotelOrderDetail(info);
    if (res.code === 0) {
      this.hotelOrderItem = res.data;
      this.hotelOrderItem.cover = FormatUtil.getImgResource(res.data.cover);
    }
  }

  public async getMealOrderDetail(info: GetOrderDetailRequest) {
    const res = await https.getMealOrderDetail(info);
    if (res.code === 0) {
      this.mealOrderItem = res.data;
    }
  }

  public getOrderTitleLabel() {
    if (this.orderType === OrderType.HOTEL && this.hotelOrderItem) {
      return Constants.ORDER_STATUS_LABEL.get(this.hotelOrderItem.orderStatus);
    } else if (this.orderType === OrderType.MEAL && this.mealOrderItem) {
      return Constants.ORDER_STATUS_LABEL.get(this.mealOrderItem.status);
    }
    return '';
  }

  public getSubTitleLabel() {
    const label = this.getOrderTitleLabel();
    if (label === OrderClassLabel.CANCEL) {
      return '您的订单已取消，请重新下单';
    }
    return '';
  }

  public getOrderPrice() {
    if (this.orderType === OrderType.HOTEL && this.hotelOrderItem) {
      return this.hotelOrderItem.actualPaidPrice;
    } else if (this.orderType === OrderType.MEAL && this.mealOrderItem) {
      return this.mealOrderItem.actualPaidPrice;
    }
    return '';
  }

  public continuePayment() {
    let orderStr = '';
    if (this.orderType === OrderType.HOTEL && this.hotelOrderItem) {
      orderStr = this.hotelOrderItem.prepayResult;
    } else if (this.orderType === OrderType.MEAL && this.mealOrderItem) {
      orderStr = this.mealOrderItem.prepayResult;
    }
    if (!orderStr) {
      return;
    }
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
}
