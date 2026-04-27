import { common } from '@kit.AbilityKit';
import { MemberStatusUtil } from 'membership';
import { BaseViewModel, contextUtil } from 'module_base';

const TAG = '[HomePageVM]';

@ObservedV2
export class HomePageVM extends BaseViewModel {
  private static _instance: HomePageVM;

  public static get instance() {
    if (!HomePageVM._instance) {
      HomePageVM._instance = new HomePageVM();
    }
    return HomePageVM._instance;
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
  }
}
