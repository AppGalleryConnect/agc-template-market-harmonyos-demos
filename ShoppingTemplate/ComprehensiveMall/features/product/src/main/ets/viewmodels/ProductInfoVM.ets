import { calendarManager } from '@kit.CalendarKit';
import { SharePicker, ShareRecordData } from 'aggregated_share';
import { AbilityConstant, common, StartOptions, Want } from '@kit.AbilityKit';
import {
  CalendarUtil,
  CountdownModel,
  iData,
  ProductInfoPageParam,
  RouterMap,
  routerStack,
  SafeJson,
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
import { ShareUtil } from '../utils/ShareUtil';
import { UtilLog } from '@hw-agconnect/util-log';
import { window } from '@kit.ArkUI';

const TAG: string = '[ProductInfoVM]'

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
  shareOptions: ShareRecordData = { title: '' };
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
  curWindow?: window.Window
  /** 当前页面所属的 Ability 名称，由 ProductInfoPage 在 onReady 中注入 */
  abilityName: string = '';
  /** 保存 entryWindowActive 事件的回调引用，用于取消订阅 */
  private _windowActiveCallback?: (type: WindowStatusType) => void

  @Computed
  get isSplitScreen(): boolean {
    return routerStack.isSplitActive;
  }

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


  public async initData(param: ProductInfoPageParam, abilityName: string = 'EntryAbility') {
    this.abilityName = abilityName;
    this.productId = param.productId;
    this.slotId = param.slotId;
    this.isLoading = true;
    try {
      await this.getProductInfo();
      await this._getReviewList();
      this._getCollectedStatus();
      ProductApis.addProductViewHistory({
        productId: this.productId,
        slotId: this.slotId,
      });
    } catch (err) {
      UtilLog.error('init product info failed. error: ' + JSON.stringify(err))
    } finally {
      this.isLoading = false;
    }
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
    routerStack.pushPath({ name: RouterMap.PRODUCT_REVIEW, param: this.productId });
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

  public openShare() {
    const picker: SharePicker = new SharePicker(this.shareOptions);
    picker.show(WindowUtil.globalUIContext);
  }

  /** 以分屏次窗口方式启动当前商品详情页，实现应用内左右分屏比较 */
  public async startSplitScreen(): Promise<void> {
    const context = WindowUtil.globalUIAbilityContext;
    const want: Want = {
      bundleName: context.abilityInfo.bundleName,
      abilityName: 'SecondAbility',
      parameters: {
        productId: this.productId,
        slotId: this.slotId !== undefined ? this.slotId : '',
        isSplitPage: true,
      },
    };
    const option: StartOptions = {
      windowMode: AbilityConstant.WindowMode.WINDOW_MODE_SPLIT_SECONDARY,
    };
    try {
      await context.startAbility(want, option);
      routerStack.isSplitActive = true;
    } catch (err) {
      UtilLog.error(TAG, 'split window failed. error: ' + SafeJson.jsonStringify(err))
    }
  }

  /** 合并分屏。EntryAbility 侧：迁移 SecondAbility 路由栈后关闭 SecondAbility；SecondAbility 侧：关闭自身 */
  public async mergeSplitScreen(): Promise<void> {
    if (!this.isSplitScreen) {
      return;
    }
    if (this.abilityName === 'EntryAbility') {
      routerStack.migrateStack('SecondAbility', 'EntryAbility');
      routerStack.isSplitActive = false;
      const secondCtx = WindowUtil.getUIAbilityContext('SecondAbility');
      try {
        await secondCtx?.terminateSelf();
      } catch (err) {
        UtilLog.error(TAG, 'terminate SecondAbility failed. error: ' + SafeJson.jsonStringify(err));
      }
    } else {
      const secondCtx = WindowUtil.getUIAbilityContext('SecondAbility');
      try {
        await secondCtx?.terminateSelf();
      } catch (err) {
        UtilLog.error(TAG, 'terminate self failed. error: ' + SafeJson.jsonStringify(err));
      }
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
    const res = await CalendarUtil.deleteEvent(this.currentEventId);
    if (res) {
      WindowUtil.toast('取消预约成功！');
      await SeckillApis.cancelReservation(this.currentEventId);
      this._getReservedStatus();
    }
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
      this.shareOptions = {
        coverUrl: this.productInfo.productDetail.banners[0],
        thumbUrl: this.productInfo.productDetail.banners[0],
        title: this.productInfo.productDetail.title,
        landingPageUrl: ShareUtil.getShareLink(this.productInfo.productDetail.productId),
      };
      ShareUtil.initShareData(this.productInfo.productDetail);
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

  /**
   * 注册主窗口激活事件监听，仅在 EntryAbility 侧有效。
   * 当 SecondAbility 被系统导航条关闭、主窗口 SHOWN 事件触发时，同步最新分屏状态。
   */
  public registerWindowActiveListener(): void {
    if (this.abilityName !== 'EntryAbility') {
      return;
    }
    this._windowActiveCallback = (statusType: window.WindowStatusType) => {
      if (statusType === window.WindowStatusType.FULL_SCREEN) {
        routerStack.isSplitActive = false;
      }
    };
    window.getLastWindow(WindowUtil.globalContext).then((win) => {
      this.curWindow = win;
      try {
        win.on('windowStatusChange', this._windowActiveCallback!)
      } catch (err) {
        UtilLog.error(TAG, 'set window status change listener failed. error:' + SafeJson.jsonStringify(err))
      }
    }).catch((err: BusinessError) => {
      UtilLog.error(TAG, 'get last window failed. error:' + SafeJson.jsonStringify(err))
    })
  }

  /**
   * 取消主窗口激活事件监听，防止页面销毁后内存泄漏。
   */
  public unregisterWindowActiveListener(): void {
    if (this.curWindow && this._windowActiveCallback) {
      try {
        this.curWindow.off('windowStatusChange', this._windowActiveCallback);
      } catch (err) {
        UtilLog.error(TAG, 'remove window status change listener. error:' + SafeJson.jsonStringify(err))
      }
      this._windowActiveCallback = undefined;
    }
  }
}