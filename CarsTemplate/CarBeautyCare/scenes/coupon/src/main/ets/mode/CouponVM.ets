import { COUPON_DEFAULT, CouponModel } from './CouponModel';

@ObservedV2
export class CouponVM {
  @Trace couponList: CouponModel[] = [];
  @Trace selectCoupon: CouponModel[] = [];
  @Trace willUserCoupon: CouponModel | null = null;
  private static _instance: CouponVM;

  public static get instance() {
    if (!CouponVM._instance) {
      CouponVM._instance = new CouponVM();
      CouponVM._instance.couponList = COUPON_DEFAULT;
    }
    return CouponVM._instance;
  }

  public addCoupon(product: CouponModel) {
    const hasAdd: boolean = this.selectCoupon.some((item: CouponModel) => product.id === item.id);
    if (!hasAdd) {
      this.selectCoupon.push(product);
    }
  }

  public removeSelectProduct(product: CouponModel) {
    const index = this.selectCoupon.findIndex((item: CouponModel) => item.id === product.id);
    if (index !== -1) {
      this.selectCoupon.splice(index, 1);
    }
  }
}