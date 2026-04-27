import { common } from '@kit.AbilityKit';
import { BaseViewModel, contextUtil } from 'module_base';
import { IVipPrepayRequest, vipPrepay } from 'lib_foundation';
import { vipList } from '../constants';

@ObservedV2
export class PurchasePageVM extends BaseViewModel {
  private static _instance: PurchasePageVM;
  context: common.UIAbilityContext = contextUtil.getContext() as common.UIAbilityContext;
  @Trace currentIndex: number = 0
  @Trace isSign: boolean = false
  @Trace public isLogin: boolean = false

  public static get instance() {
    if (!PurchasePageVM._instance) {
      PurchasePageVM._instance = new PurchasePageVM();
    }
    return PurchasePageVM._instance;
  }

  public async prepay() {
    const data: IVipPrepayRequest = {
      id: vipList[this.currentIndex].id,
      userId: this.userInfoModel?.id as number,
      price: vipList[this.currentIndex].discountPrice,
    }
    this.userInfoModel.isVip = true
    await vipPrepay(data);
  }
}
