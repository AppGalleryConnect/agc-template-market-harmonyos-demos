import { calendarManager } from '@kit.CalendarKit';
import {
  CalendarUtil,
  CountdownModel,
  iData,
  ProductInfoPageParam,
  ProductSearchPageParam,
  RouterMap,
  routerStack,
  WindowUtil,
} from 'lib_foundation';
import {
  ReservedProductInfo,
  SeckillApis,
  SeckillProductInfo,
  SeckillReserveReq,
  SeckillSession,
  SeckillStatus,
  SeckillTimeSlot,
} from 'lib_network';

@ObservedV2
export class SeckillListVM {
  @Trace
  isLoading: boolean = false;
  @Trace
  seckillTimeSlotList: SeckillSession[] = [];
  @Trace
  reservedProduct: ReservedProductInfo[] = [];
  @Trace
  curIndex: number = 0;
  @Trace
  countdown?: CountdownModel;

  @Computed
  get curSeckill() {
    const item = this.seckillTimeSlotList.find((seckill) => seckill.timeSlot.status === SeckillStatus.ONGOING);
    return item;
  }

  async initData() {
    this.isLoading = true;
    await this.getSeckillSessions();
    await this.getReservedProduct();
    this.isLoading = false;
  }

  async getSeckillSessions() {
    const res = await SeckillApis.getSeckillSessions();
    if (res.code === 0) {
      this.seckillTimeSlotList = res.sessions;
      const item = this.seckillTimeSlotList.find((seckill) => seckill.timeSlot.status === SeckillStatus.ONGOING);
      if (item) {
        this.countdown = new CountdownModel(item.timeSlot.endTimestamp);
        this.countdown.startCountdownTimer();
      }
    }
  }

  public async getReservedProduct() {
    const res = await SeckillApis.getBatchReservationStatus();
    if (res.code === 0) {
      this.reservedProduct = res.reservedProducts;
    }
  }

  public getSeckillTabLabel(timeSlot: SeckillTimeSlot) {
    if (timeSlot.status === SeckillStatus.ONGOING) {
      return '正在秒杀';
    }
    const curDay = new Date().getDate();
    if (new Date(timeSlot.startTimestamp).getDate() === curDay) {
      return '即将开抢';
    }
    return '明日开抢';
  }

  /** 点击卡片 */
  public handleClickCard(product: SeckillProductInfo) {
    if (product.remainStock === 0) {
      WindowUtil.toast('商品已抢光，下次再来');
      return;
    }
    this._jumpToDetail(product.productId, product.slotId);
  }

  /**
   * 点击卡片按钮
   * @param product
   * @param timeslot
   */
  public handleClickButton(product: SeckillProductInfo, timeslot: SeckillTimeSlot) {
    if (!iData.global.isLogin) {

      return;
    }
    if (timeslot.status === SeckillStatus.ONGOING) {
      this._jumpToDetail(product.productId, product.slotId);
      return;
    } else if (timeslot.status === SeckillStatus.WAITING) {
      if (this.isProductReserved(product, timeslot)) {
        this._removeCalendarEvent(product);
      } else {
        this._addCalendarEvent(product, timeslot);
      }
    }
  }

  public jumpToSearch() {
    const currentSession = this.seckillTimeSlotList.find((item) => item.timeSlot.status === SeckillStatus.ONGOING);
    if (!currentSession) {
      WindowUtil.toast('暂无正在秒杀场次，请查看或预约后续场次~');
      return;
    }
    routerStack.pushPath({
      name: RouterMap.PRODUCT_SEARCH,
      param: {
        slotId: currentSession.timeSlot.slotId,
      } as ProductSearchPageParam,
    });
  }

  public isProductReserved(product: SeckillProductInfo, timeslot: SeckillTimeSlot) {
    if (timeslot.status !== SeckillStatus.WAITING) {
      return false;
    }
    const item = this.reservedProduct.find((prod) => prod.productId === product.productId &&
      prod.slotId === product.slotId);
    return Boolean(item);
  }

  public getProductCardButtonLabel(product: SeckillProductInfo, timeslot: SeckillTimeSlot) {
    if (timeslot.status === SeckillStatus.ONGOING) {
      return '抢';
    }
    if (timeslot.status === SeckillStatus.WAITING) {
      return this.isProductReserved(product, timeslot) ? '已预约' : '预约';
    }
    return '';
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
      WindowUtil.toast('商品预约成功！可以在日历中查看预约详情~');
      const param: SeckillReserveReq = {
        productId: product.productId,
        slotId: product.slotId,
        eventId,
      };
      SeckillApis.reserveSeckill(param).then(async () => {
        this.getReservedProduct();
      });
    }

  }

  /**
   * 移除日程
   * @param product
   * @param timeslot
   */
  private async _removeCalendarEvent(product: SeckillProductInfo) {
    const reservedItem = this.reservedProduct.find((item) => item.productId === product.productId &&
      item.slotId === product.slotId);
    if (reservedItem?.eventId) {
      WindowUtil.toast('元服务不支持日程移除操作，请在日历应用内手动操作移除~');
    }
  }


  private _jumpToDetail(productId: string, slotId: string) {
    routerStack.pushPath({
      name: RouterMap.PRODUCT_INFO,
      param: {
        productId,
        slotId,
      } as ProductInfoPageParam,
    });
  }
}