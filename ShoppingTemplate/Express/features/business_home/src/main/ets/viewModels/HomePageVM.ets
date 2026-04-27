import { common } from '@kit.AbilityKit';
import { MemberStatusUtil } from 'membership';
import { BaseViewModel, BreakpointNameEnum, ContextUtil, RouterMap, RouterModule } from 'lib_foundation';

@ObservedV2
export class HomePageVM extends BaseViewModel {
  private static _instance: HomePageVM;

  static get instance() {
    if (!HomePageVM._instance) {
      HomePageVM._instance = new HomePageVM();
    }
    return HomePageVM._instance;
  }

  @Computed
  get isTabVertical() {
    return [
      BreakpointNameEnum.LG,
      BreakpointNameEnum.XL,
    ].includes(this.breakPointModel.currentBreakpoint);
  }

  async queryMemberStatus() {
    const res = await MemberStatusUtil.queryPurchase(ContextUtil.globalContext as common.UIAbilityContext)
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
  }

  // 登录跳转
  loginJumpPage(routeName: RouterMap) {
    if (!this.userInfoModel.isLogin) {
      RouterModule.push({ url: RouterMap.QUICK_LOGIN_PAGE }, () => {
        RouterModule.push({ url: routeName });
      })
      return
    }
    RouterModule.push({ url: routeName })
  }
}
