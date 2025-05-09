import { https } from 'network';
import { AccountUtil, AppStorageMap, FormatUtil, Logger, RouterMap, RouterModule, } from 'commonlib';
import {
  IBuyRule,
  IProcess,
  IProductInfo,
  IRedemptionRule,
} from 'network/src/main/ets/types/responseTypes/GetProductResp';

interface IParamData {
  id: number,
  index: number
}

const TAG = '[RuleVM]';

@ObservedV2
export class RuleVM {
  private static _instance: RuleVM;
  // 接口数据
  @Trace public productInfo: IProductInfo | undefined
  @Trace public buyRule: IBuyRule | undefined
  @Trace public redemptionRule: IRedemptionRule | undefined
  @Trace public purchaseProcess: IProcess | undefined
  @Trace public redemptionProcess: IProcess | undefined
  //页面数据
  @Trace public currentIndex: number = 0
  @Trace public selectedIndex: number = 0
  @Trace public minimumPurchaseAmount: number = 0
  @Trace public pricePerShare: number = 0
  @Trace public minimumHoldingShare: number = 0
  @Trace public createdTime: string = ''
  @Trace public purchaseRate: number = 0
  @Trace public subscriptionRate: number = 0

  public static get instance() {
    if (!RuleVM._instance) {
      RuleVM._instance = new RuleVM();
    }
    return RuleVM._instance;
  }

  init() {
    const param = RouterModule.getNavParam<IParamData>({ url: RouterMap.RULE })
    if (param) {
      this.currentIndex = param.index
      this.selectedIndex = param.index
      this.getProductInfo(param.id)
    }
  }

  tabChange(index: number) {
    this.currentIndex = index
    this.selectedIndex = index
    if (this.productInfo) {
      if (index === 0) {
        this.getProductPurchaseProcess(this.productInfo.purchaseProcessId)
      } else {
        this.getProductRedemptionProcess(this.productInfo.redemptionProcessId)
      }
    }
  }

  public async getProductInfo(id: number) {
    const res = await https.getProductInfo(id);
    if (res.code === 0) {
      this.productInfo = res.data;
      this.createdTime = this.productInfo.createdTime
      this.getProductBuyRule(this.productInfo.buyRuleId)
      this.getProductRedemptionRule(this.productInfo.redemptionRuleId)
      if (this.currentIndex === 0) {
        this.getProductPurchaseProcess(this.productInfo.purchaseProcessId)
      } else {
        this.getProductRedemptionProcess(this.productInfo.redemptionProcessId)
      }
    }
  }

  public async getProductBuyRule(id: number) {
    const res = await https.getProductBuyRule(id);
    if (res.code === 0) {
      this.buyRule = res.data;
      this.minimumPurchaseAmount = this.buyRule.minimumPurchaseAmount
      this.pricePerShare = this.buyRule.pricePerShare
      this.minimumHoldingShare = this.buyRule.minimumHoldingShare
      this.purchaseRate = this.buyRule.purchaseRate
      this.subscriptionRate = this.buyRule.subscriptionRate
    }
  }

  public async getProductRedemptionRule(id: number) {
    const res = await https.getProductRedemptionRule(id);
    if (res.code === 0) {
      this.redemptionRule = res.data;
    }
  }

  public async getProductPurchaseProcess(id: number) {
    const res = await https.getProductPurchaseProcess(id);
    if (res.code === 0) {
      this.purchaseProcess = res.data;
    }
  }

  public async getProductRedemptionProcess(id: number) {
    const res = await https.getProductRedemptionProcess(id);
    if (res.code === 0) {
      this.redemptionProcess = res.data;
    }
  }
}
