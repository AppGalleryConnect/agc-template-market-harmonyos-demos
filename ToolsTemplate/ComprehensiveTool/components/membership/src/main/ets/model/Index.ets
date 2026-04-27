import { iap } from '@kit.IAPKit';
import { FinishStatus } from '../constant/Enum';

export class MemberShipPrivilege {
  id: string = '';
  icon: ResourceStr = '';
  title: string = '';
  des: string = '';
}

export interface PurchaseData {
  type: number;
  jwsPurchaseOrder?: string;
  jwsSubscriptionStatus?: string;
}

export interface PurchaseOrderPayload {
  productType: string;
  purchaseOrderId: string;
  purchaseToken: string;
  finishStatus?: FinishStatus;
  productId: string;
  purchaseTime: number;
}

export interface SubGroupStatusPayload {
  environment: string,
  applicationId: string,
  packageName: string,
  subGroupId: string,
  lastSubscriptionStatus?: SubscriptionStatus,
  historySubscriptionStatusList?: SubscriptionStatus[]
}

export interface SubscriptionStatus {
  status: string,
  expiresTime: number
  lastPurchaseOrder: PurchaseOrderPayload
  renewalInfo: SubRenewalInfo
}

interface SubRenewalInfo {
  renewalTime: number,
  productId: string
}

export interface HintParam {
  node: ComponentContent<Object>,
  uiContext: UIContext
}

export class MemberList {
  renewList: string[] = [];
  nonRenewList: string[] = [];
  nonConsumeList: string[] = [];
}

export class ProductInfo {
  type: iap.ProductType = iap?.ProductType.AUTORENEWABLE;
  productId: string = '';
  privileges: MemberShipPrivilege[] = [];
  privacyName?: string = '';
  privacyContent?: string = '';
}

export class MemberParams {
  productId: string = '';
  type: iap.ProductType = iap?.ProductType.AUTORENEWABLE;
  status: FinishStatus = FinishStatus.FINISHED;
  purchaseTime: number = 0;
  errCode?: number = 0;
  errMsg?: string = '';
}

@ObservedV2
export class Privacy {
  @Trace title: string = '';
  @Trace content: string = '';
}


