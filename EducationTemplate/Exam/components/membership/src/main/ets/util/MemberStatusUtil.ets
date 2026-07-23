import { iap } from '@kit.IAPKit';
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { UtilLog } from '@hw-agconnect/util-log';
import {
  MemberList,
  PurchaseData,
  PurchaseOrderPayload,
  SubGroupStatusPayload,
  SubscriptionStatus,
} from '../model/Index';
import { JWSUtil } from './JWSUtil';

export class MemberStatusUtil {
  static getSubGroupStatusPayload(purchaseData: string) {
    let data = JSON.parse(purchaseData) as PurchaseData;
    const jwsSubscriptionStatus = data.jwsSubscriptionStatus;
    if (!jwsSubscriptionStatus) {
      return undefined;
    }
    const subscriptionStatus: string = JWSUtil.decodeJwsObj(jwsSubscriptionStatus);
    if (!subscriptionStatus) {
      return undefined;
    }
    // 需自定义SubGroupStatusPayload类，包含的信息请参见SubGroupStatusPayload
    const subGroupStatusPayload: SubGroupStatusPayload = JSON.parse(subscriptionStatus);
    return subGroupStatusPayload;
  }

  static getLastSubscriptionStatus(purchaseData: string): SubscriptionStatus | undefined {
    let subGroupStatusPayload = MemberStatusUtil.getSubGroupStatusPayload(purchaseData);
    const lastSubscriptionStatus = subGroupStatusPayload?.lastSubscriptionStatus;

    return lastSubscriptionStatus;
  }

  static getLastPurchaseOrder(purchaseData: string): PurchaseOrderPayload | undefined {
    let data = JSON.parse(purchaseData) as PurchaseData;
    const jwsPurchaseOrder = data.jwsPurchaseOrder;
    if (!jwsPurchaseOrder) {
      return undefined;
    }
    const purchaseOrder: string = JWSUtil.decodeJwsObj(jwsPurchaseOrder);
    if (!purchaseOrder) {
      return undefined;
    }
    const purchaseOrderPayload: PurchaseOrderPayload = JSON.parse(purchaseOrder) as PurchaseOrderPayload;

    return purchaseOrderPayload;
  }

  static queryPurchase(uiContext: common.UIAbilityContext): Promise<MemberList> {
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
      UtilLog.error(`query purchase failed with error ${JSON.stringify(e)}`);
    }

    return Promise.all([autoRenewPromise, nonRenewPromise, nonConsumePromise]).then((res) => {
      let autoRenewPurchasedList = res[0]?.purchaseDataList;
      let nonAutoRenewPurchasedList = res[1]?.purchaseDataList;
      let nonConsumePurchasedList = res[2]?.purchaseDataList ?? [];
      memberList.renewList = autoRenewPurchasedList ?? [];
      memberList.nonRenewList = nonAutoRenewPurchasedList ?? [];
      memberList.nonConsumeList = nonConsumePurchasedList;
      return memberList;
    }).catch((err: BusinessError) => {
      UtilLog.error(0xFF00, 'MemberShip',
        `Failed to query purchase record. Code is ${err.code}, message is ${err.message}`);
      return memberList;
    });
  }
}