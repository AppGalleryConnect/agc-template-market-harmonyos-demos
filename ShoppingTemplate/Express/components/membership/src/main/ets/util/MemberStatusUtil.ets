import { iap } from '@kit.IAPKit';
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { MemberList } from '../model/Index';

export class MemberStatusUtil {
  static queryPurchase(uiContext: common.UIAbilityContext): Promise<MemberList> {
    // 查询是否有当前用户的会员购买记录
    let memberList: MemberList = new MemberList();
    let autoRenewParam: iap.QueryPurchasesParameter = {
      productType: iap?.ProductType.AUTORENEWABLE,
      queryType: iap?.PurchaseQueryType.CURRENT_ENTITLEMENT,
    };
    let nonRenewParam: iap.QueryPurchasesParameter = {
      productType: iap?.ProductType.NONRENEWABLE,
      queryType: iap?.PurchaseQueryType.ALL,
    };

    let nonConsumeParam: iap.QueryPurchasesParameter = {
      productType: iap?.ProductType.NONCONSUMABLE,
      queryType: iap?.PurchaseQueryType.CURRENT_ENTITLEMENT,
    };

    let autoRenewPromise: Promise<iap.QueryPurchaseResult> | null = null;
    let nonRenewPromise: Promise<iap.QueryPurchaseResult> | null = null;
    let nonConsumePromise: Promise<iap.QueryPurchaseResult> | null = null;

    try {
      autoRenewPromise = iap?.queryPurchases(uiContext, autoRenewParam);
      nonRenewPromise = iap?.queryPurchases(uiContext, nonRenewParam);
      nonConsumePromise = iap?.queryPurchases(uiContext, nonConsumeParam);
    } catch (e) {
      hilog.error(0xFF00, 'MemberShip',`query purchase failed with error ${JSON.stringify(e)}`);
    }

    return Promise.all([autoRenewPromise, nonRenewPromise, nonConsumePromise]).then((res) => {
      let autoRenewPurchasedList = res[0]?.purchaseDataList;
      let nonAutoRenewPurchasedList = res[1]?.purchaseDataList;
      let nonConsumePurchasedList = res[2]?.purchaseDataList;
      memberList.renewList = autoRenewPurchasedList ?? [];
      memberList.nonRenewList = nonAutoRenewPurchasedList ?? [];
      memberList.nonConsumeList = nonConsumePurchasedList ?? [];
      return memberList;
    }).catch((err: BusinessError) => {
      hilog.error(0xFF00, 'MemberShip',
        `Failed to query purchase record. Code is ${err.code}, message is ${err.message}`);
      return memberList;
    });
  }
}