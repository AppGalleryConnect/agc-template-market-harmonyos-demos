import { CheckIn, getCheckInList, getCouponList } from 'lib_foundation';
import { MemberStatusUtil } from 'membership';
import { BaseViewModel, contextUtil, Coupon } from 'module_base';
import { common } from '@kit.AbilityKit';

@ObservedV2
export class VipPageVM extends BaseViewModel {
  private static _instance: VipPageVM;
  @Trace public checkInList: CheckIn[] = []
  @Trace public couponList: Coupon[] = []
  @Trace public isSign: boolean = false
  @Trace public signInCount: number = 0
  @Trace public currentIndex: number = 0

  static get instance() {
    if (!VipPageVM._instance) {
      VipPageVM._instance = new VipPageVM();
    }
    return VipPageVM._instance;
  }

  // 初始化
  async init() {
    this.signInCount = 0
    if (this.userInfoModel.isLogin) {
      this.queryMemberStatus()
      this.getCheckInList()
    }
  }

  async queryMemberStatus() {
    const res = await MemberStatusUtil.queryPurchase(contextUtil.getContext() as common.UIAbilityContext)
    if (res) {
      const autoRenewPurchasedList = res.renewList;
      const nonAutoRenewPurchasedList = res.nonRenewList;

      if (autoRenewPurchasedList?.length || nonAutoRenewPurchasedList?.length) {
        this.userInfoModel.isVip = true
      } else {
        this.userInfoModel.isVip = false
      }
    } else {
      this.userInfoModel.isVip = false
    }
    this.getCouponList()
  }

  async getCouponList() {
    const res = await getCouponList({ isVip: this.userInfoModel.isVip })
    this.couponList = res
    if (this.userInfoModel.couponList.length !== 0) {
      for (let userCoupon of this.userInfoModel.couponList) {
        for (let coupon of this.couponList) {
          if (userCoupon.id === coupon.id) {
            coupon.isAvailable = false
          }
        }
      }
    }
  }

  async getCheckInList() {
    const res = await getCheckInList()
    this.checkInList = res
    this.checkInList.forEach((item) => {
      if (item.isChecked) {
        this.signInCount += 1
      }
    })
    this.isSign = this.checkInList[this.currentIndex].isChecked
  }
}
