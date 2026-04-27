import { window } from '@kit.ArkUI';
import { calendarManager } from '@kit.CalendarKit';
import {
  CalendarUtil,
  CountdownModel,
  iData,
  ProductInfoPageParam,
  RouterMap,
  routerStack,
  WindowUtil,
} from 'lib_foundation';
import {
  ProductApis,
  ProductInfo,
  ProductReviewItem,
  SeckillApis,
  SeckillProductInfo,
  SeckillReserveReq,
  SeckillTimeSlot,
} from 'lib_network';
import { CommonConfirmDialog, CustomServiceSheet } from 'lib_widget';

@ObservedV2
export class ProductInfoVM {
  @Trace
  productId: string = '';
  @Trace
  slotId?: string = undefined;
  @Trace
  productInfo?: ProductInfo;
  @Trace
  collectedStatus: boolean = false;
  @Trace
  reviewList: ProductReviewItem[] = [];
  @Trace
  reviewNum: number = 0;
  @Trace
  isLoading: boolean = false;
  @Trace
  isReserved: boolean = false;
  @Trace
  countdown?: CountdownModel;
  @Trace
  currentEventId?: number;
  curWindow?: window.Window;

  @Computed
  get isLogin() {
    return iData.global.isLogin;
  }

  @Computed
  get cartNum() {
    return iData.global.cartTotal;
  }

  @Computed
  get isMember() {
    return iData.global.userInfo.isMember;
  }

  @Computed
  get reserveButtonLabel() {
    if (this.isReserved) {
      return '已预约';
    }
    if (this.productInfo?.seckillInfo && this.productInfo.timeSlot) {
      let str = '';
      if (this.productInfo.seckillInfo.slotId.includes('tomorrow')) {
        str += '明日';
      }
      return '预约' + str + this.productInfo.timeSlot.startTime + '开抢';
    }
    return '';
  }


  public async initData(param: ProductInfoPageParam) {
    this.productId = param.productId;
    this.slotId = param.slotId;
    this.isLoading = true;
    await this.getProductInfo();
    await this._getReviewList();
    this.isLoading = false;
    this._getCollectedStatus();
    ProductApis.addProductViewHistory({
      productId: this.productId,
      slotId: this.slotId,
    });
  }

  public handleClickMemberLink() {
    if (!this.isLogin) {
      this.handleNotLogin();
      return;
    }
    routerStack.pushPath({ name: RouterMap.USER_MEMBER_SUBSCRIPTION });
  }

  public handleClickCustomService() {
    CustomServiceSheet.show();
  }

  public handleClickCart() {
    if (!this.isLogin) {
      this.handleNotLogin();
      return;
    }
    routerStack.pushPath({ name: RouterMap.PRODUCT_CART });
  }

  public handleClickReview() {
    routerStack.pushPath({ name: RouterMap.PRODUCT_REVIEW,
param: this.productId });
  }

  public async changeCollectStatus() {
    if (!this.isLogin) {
      this.handleNotLogin();
      return;
    }
    if (!this.collectedStatus) {
      const res = await ProductApis.collectProduct({
        productId: this.productId,
        slotId: this.slotId,
      });
      if (res.code === 0) {
        WindowUtil.toast('收藏商品成功！');
        this.collectedStatus = true;
      }
    } else {
      CommonConfirmDialog.show({
        content: '是否确认取消收藏该商品？',
        confirm: async () => {
          const res = await ProductApis.cancelCollectProduct([this.productId]);
          if (res.code === 0) {
            WindowUtil.toast('取消收藏成功！');
            this.collectedStatus = false;
          }
        },
      });
    }
  }

  public handleNotLogin() {
    routerStack.pushPath({ name: RouterMap.USER_LOGIN });
  }

  public handleClickReserveButton() {
    if (!this.productInfo?.seckillInfo || !this.productInfo.timeSlot) {
      return;
    }
    if (this.isReserved) {
      this._removeCalendarEvent();
    } else {
      this._addCalendarEvent(this.productInfo.seckillInfo, this.productInfo.timeSlot);
    }
  }

  /**
   * 添加日程
   * @param product
   * @param timeslot
   */
  private async _addCalendarEvent(product: SeckillProductInfo, timeslot: SeckillTimeSlot) {
    const event: calendarManager.Event = {
      title: '您预约的限时秒杀即将开抢！' + product.title,
      type: calendarManager.EventType.NORMAL,
      startTime: timeslot.startTimestamp,
      endTime: timeslot.endTimestamp,
      reminderTime: [5],
      description: `限时秒杀即将开抢！`,
    };

    const eventId = await CalendarUtil.addEvent(event);
    if (eventId && typeof eventId === 'number') {
      this.currentEventId = eventId;
      WindowUtil.toast('商品预约成功！可以在日历中查看预约详情~');
      const param: SeckillReserveReq = {
        productId: product.productId,
        slotId: product.slotId,
        eventId,
      };
      SeckillApis.reserveSeckill(param).then(() => {
        this._getReservedStatus();
      });
    }

  }

  /**
   * 移除日程
   * @param product
   * @param timeslot
   */
  private async _removeCalendarEvent() {
    if (!this.currentEventId) {
      return;
    }
    WindowUtil.toast('元服务不支持日程移除操作，请在日历应用内手动操作移除~');
  }


  private async _getReviewList() {
    const res = await ProductApis.getProductReviewList(this.productId, 1);
    this.reviewList = res.list.slice(0, 2);
    this.reviewNum = res.total;
  }

  public async getProductInfo() {
    const res = await ProductApis.getProductDetail(this.productId, this.slotId);
    if (res.code === 0) {
      this.productInfo = res.data;
      this._getReservedStatus();
    }
  }

  private async _getReservedStatus() {
    if (this.productInfo?.seckillInfo && this.productInfo.timeSlot) {
      const res = await SeckillApis.getReservationStatus({
        productId: this.productInfo.seckillInfo.productId,
        slotId: this.productInfo.seckillInfo.slotId,
      });
      if (res.code === 0) {
        this.isReserved = res.isReserved;
        this.currentEventId = res.eventId;
      }
      if (this.isReserved) {
        this.countdown = new CountdownModel(this.productInfo.timeSlot.startTimestamp);
        this.countdown.startCountdownTimer();
      }
    }
  }

  private async _getCollectedStatus() {
    if (!this.isLogin) {
      return;
    }
    const res = await ProductApis.getProductCollectStatus(this.productId);
    if (res.code === 0 && res.status) {
      this.collectedStatus = true;
    }
  }
}