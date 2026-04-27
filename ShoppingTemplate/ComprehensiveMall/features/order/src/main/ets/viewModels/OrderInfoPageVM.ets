import { RouterMap, routerStack, WindowUtil } from 'lib_foundation';
import { OrderApis, OrderItem } from 'lib_network';
import {
  OrderActionMap, OrderShipmentMap, OrderStatusMap,
} from '../common/Enums';
import { formatTime } from '../utils';
import { OrderUtil } from '../utils/OrderUtil';
import { buildOrderAddressSheetOptions } from '../views/UpdateAddressSheet';
import { petalMaps } from '@kit.MapKit';
import { UtilLog } from '@hw-agconnect/util-log';

const TAG:string = '[OrderInfoPageVM]'

@ObservedV2
export class OrderInfoPageVM {
  @Trace
  orderItem: OrderItem | undefined = undefined;
  @Trace
  orderNo: string = '';
  @Trace
  isLoading: boolean = false;
  @Trace
  countdown: string | undefined = undefined;

  @Computed
  get enableEditAddress() {
    if (this.orderItem) {
      const status = this.orderItem.orderInfo.status;
      if (
        this.orderItem.orderInfo.receivingMethod ===
        OrderShipmentMap.SELF_PICK_UP
      ) {
        return false;
      }
      if (
        status === OrderStatusMap.PENDING_PAYMENT ||
          status === OrderStatusMap.PENDING_SHIPMENT
      ) {
        return true;
      }
    }
    return false;
  }

  @Computed
  get enableExpressPage() {
    if (!this.orderItem || this.orderItem.orderInfo.receivingMethod === OrderShipmentMap.SELF_PICK_UP) {
      return false;
    }
    const enableArr = [
      OrderStatusMap.PENDING_RECEIPT,
      OrderStatusMap.PENDING_REVIEW,
      OrderStatusMap.REVIEWED,
      OrderStatusMap.REFUND_IN_PROGRESS,
      OrderStatusMap.REFUNDED,
    ];
    return enableArr.includes(this.orderItem.orderInfo.status);
  }

  @Computed
  get isPickupOrder(): boolean {
    if (!this.orderItem) {
      return false;
    }
    return this.orderItem.orderInfo.receivingMethod === OrderShipmentMap.SELF_PICK_UP;
  }

  @Computed
  get showPickupSignedRow(): boolean {
    if (!this.orderItem) {
      return false;
    }
    if (!this.isPickupOrder) {
      return false;
    }
    const status = this.orderItem.orderInfo.status;
    return status === OrderStatusMap.PENDING_REVIEW || status === OrderStatusMap.REVIEWED;
  }

  @Computed
  get logisticInfo() {
    const len = this.orderItem?.logisticInfo?.length;
    if (this.orderItem && len) {
      return this.orderItem.logisticInfo[0];
    }
    return undefined;
  }

  getGapTime(remainingTime: number) {
    const now = new Date().getTime();
    let gap = Math.floor((remainingTime - now) / 1000);
    this.countdown = formatTime(gap);
    const timer = setInterval(() => {
      gap--;
      if (gap < 0) {
        clearInterval(timer);
      }
      this.countdown = formatTime(gap);
    }, 1000);
  }

  async getOrderItem(orderNo: string) {
    this.isLoading = true;
    this.orderNo = orderNo;
    const res = await OrderApis.getDetail(orderNo);
    if (res.code === 0) {
      this.orderItem = res.detail;
      if (res.detail.orderInfo.status === OrderStatusMap.PENDING_PAYMENT) {
        const remainTime = res.detail.orderInfo.remainingTime;
        if (remainTime) {
          this.getGapTime(remainTime);
        }
      }
    }
    this.isLoading = false;
  }

  public handleOrderItem(action: OrderActionMap) {
    if (!this.orderItem) {
      return;
    }
    if (action === OrderActionMap.UPDATE_ADDRESS) {
      routerStack.pushPath(
        {
          name: RouterMap.ORDER_UPDATE_ADDRESS,
          param: buildOrderAddressSheetOptions({
            originalAddress: this.orderItem.orderInfo.addressInfo,
            orderNo: this.orderNo,
            handleSubmitSuccess: () => {
              routerStack.pop();
              this.getOrderItem(this.orderNo);
            },
          }),
        },
        false,
      );
    } else if (action === OrderActionMap.REVIEW) {
      routerStack.pushPath({
        name: RouterMap.ORDER_REVIEW_CREATE,
        param: this.orderItem,
        onPop: () => {
          this.getOrderItem(this.orderNo);
        },
      });
    } else if (action === OrderActionMap.REORDER) {
      const skuList = this.orderItem.skuInfo;
      OrderUtil.handleReorder({
        orderNo: this.orderNo,
        data: skuList,
      });
    } else if (action === OrderActionMap.VIEW_REVIEW) {
      OrderUtil.handleViewReview({
        orderNo: this.orderNo,
        data: this.orderItem,
      });
    } else {
      OrderUtil.handleOrderAction(action, {
        orderNo: this.orderItem.orderInfo.orderNo,
        data: this.orderItem,
        callback: () => {
          this.getOrderItem(this.orderNo);
        },
      });
    }
  }

  openEditSheet() {
    routerStack.pushPath(
      {
        name: RouterMap.ORDER_UPDATE_ADDRESS,
        param: buildOrderAddressSheetOptions({
          originalAddress: this.orderItem?.orderInfo.addressInfo,
          orderNo: this.orderNo,
          handleSubmitSuccess: () => {
            routerStack.pop();
            this.getOrderItem(this.orderNo);
          },
        }),
      },
      false,
    );
  }

  jumpToExpressPage() {
    if (this.enableExpressPage) {
      routerStack.pushPath({
        name: RouterMap.ORDER_EXPRESS_INFO,
        param: this.orderItem,
      });
    }
  }

  /**
   * 打开地图 App 导航到指定经纬度
   */
  async openMapNavigation(latitude: number, longitude: number, _name?: string) {
    const context = WindowUtil.globalUIAbilityContext;
    if (!context) {
      WindowUtil.toast('无法打开地图');
      return;
    }
    try {
      let params: petalMaps.RoutePlanParams = {
        destinationPosition: {
          latitude: latitude,
          longitude: longitude
        }
      };
      await petalMaps.openMapRoutePlan(context ,params);
    } catch (e) {
      WindowUtil.toast('打开地图失败，请确认已安装地图应用');
      UtilLog.error(TAG, `code:${e.code}, message:${e.message}`);
    }
  }
}
