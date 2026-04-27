import { ComponentContent, UIContext } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { UtilLog } from '@hw-agconnect/util-log';
import { LOG_TAG } from '../commons/Constants';
import { CouponItem, CouponsControllerType, OnPopParams } from '../commons/Types';
import { getReduceAmount } from '../utils/CouponCalculator';
import { SelectCouponsView } from '../views/SelectCouponsView';

@ObservedV2
export class CouponsController implements CouponsControllerType{
  // ── 响应式状态（View 订阅这些字段驱动渲染）──
  @Trace couponList: CouponItem[] = [];
  @Trace isLoading: boolean = false;
  /** 主题色，供优惠券列表与卡片等 UI 统一使用 */
  @Trace themeColor: ResourceColor = $r('sys.color.multi_color_08');
  @Trace selectedId: string = '';
  @Trace reduce: number = 0;
  totalMoney: number = 0;
  // ── 数据回调（外部必须提供）──
  onLoadCoupons?: () => Promise<CouponItem[]>;
  // ── 增删交互回调（外部按需注册）──
  onClaimCoupon?: (couponId: string) => Promise<CouponItem[] | null>;
  onAfterUse?: (couponId: string) => Promise<CouponItem[] | null>;
  // ── 导航/UI 回调 ──
  onUseNow?: (couponId: string) => void;
  onConfirm?: (params: OnPopParams) => void;
  // ── Sheet 关闭回调（由 select 弹层注入）──
  closeSheet?: () => void;
  private readonly _sheetOption: SheetOptions = {
    title: { title: '选择优惠券' },
    backgroundColor: $r('app.color.background_color_sheet'),
    detents: [SheetSize.LARGE],
    preferType: SheetType.CENTER,
  };

  /**
   * 打开选择优惠券底部弹层。
   * @param uiContext 调用方传入的 UIContext
   * @param controller 已配置回调的 CouponsController 实例
   */
  async select(uiContext: UIContext): Promise<void> {
    const contentNode = new ComponentContent<CouponsController>(
      uiContext,
      wrapBuilder<[CouponsController]>(couponsSelectSheetBuilder),
      this,
    );

    this.closeSheet = () => {
      uiContext.closeBindSheet(contentNode).catch((err: BusinessError) => {
        UtilLog.error(LOG_TAG, 'close bind sheet failed. error: ' + JSON.stringify(err));
      });
    };

    uiContext.openBindSheet(contentNode, this._sheetOption).catch((err: BusinessError) => {
      UtilLog.error(LOG_TAG, 'open bind sheet failed. error: ' + JSON.stringify(err));
    });
  }

  async loadCoupons(): Promise<void> {
    if (!this.onLoadCoupons) {
      return;
    }
    this.isLoading = true;
    try {
      this.couponList = await this.onLoadCoupons();
    } catch (e) {
      console.error('[CouponsController] loadCoupons failed: ' + (e as Error).message);
    } finally {
      this.isLoading = false;
    }
  }

  async claimCoupon(couponId: string): Promise<void> {
    if (!this.onClaimCoupon) {
      return;
    }
    const result = await this.onClaimCoupon(couponId);
    if (result !== null) {
      this.couponList = result;
    } else {
      await this.loadCoupons();
    }
  }

  useNow(couponId: string): void {
    this.onUseNow?.(couponId);
  }

  toggleSelect(coupon: CouponItem): void {
    if (this.selectedId === coupon.couponID) {
      this.selectedId = '';
      this.reduce = 0;
    } else {
      this.selectedId = coupon.couponID;
      this.reduce = getReduceAmount(coupon, this.totalMoney);
    }
  }

  async confirm(): Promise<void> {
    const couponId = this.selectedId;
    this.onConfirm?.({ selectId: couponId, reduce: this.reduce });
    if (this.onAfterUse && couponId) {
      const result = await this.onAfterUse(couponId);
      if (result !== null) {
        this.couponList = result;
      } else {
        await this.loadCoupons();
      }
    }
  }
}

@Builder
function couponsSelectSheetBuilder(controller: CouponsController) {
  SelectCouponsView({ controller });
}
