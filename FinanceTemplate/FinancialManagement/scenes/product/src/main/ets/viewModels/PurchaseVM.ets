import { BaseResponse, https, IDollarCostAveragingRequest, IPrepayRequest } from 'network';
import { Logger, RouterMap, RouterModule, } from 'commonlib';
import { IBuyRule, IProductInfo } from 'network/src/main/ets/types/responseTypes/GetProductResp';
import { IUserAccount } from 'network/src/main/ets/types/responseTypes/GetUserAccountResp';
import { promptAction } from '@kit.ArkUI';
import { paymentService } from '@kit.PaymentKit';
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { IButtonMoney, IRouterPurchase } from '../types';
import { buttonMoneyData, cycleData, dateDataDay, dateDataWeek, initProductInfoData } from '../constants';

const TAG = '[PurchaseVM]';

@ObservedV2
export class PurchaseVM {
  context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
  private static _instance: PurchaseVM;
  @Trace public account: IUserAccount = {
    id: 0,
    userId: 0,
    bankName: '',
    bankCardNo: '',
    bankAmount: 0,
    positionAmount: 0,
    accumulatedEarnings: 0,
  }
  @Trace public productInfo: IProductInfo = initProductInfoData
  @Trace public productBuyRule: IBuyRule | undefined
  @Trace public money: string = ''
  @Trace public isCheckedAgreement: boolean = false
  @Trace public bankCardNo: string = ''
  @Trace public recommendationCode: string = ''
  @Trace public isPurchase: boolean = true
  @Trace public cycle: string = '每周'
  @Trace public date: string = '周一'
  @Trace public tempCycle: string = '每周'
  @Trace public tempDate: string = '周一'
  @Trace public cycleData: string[] = cycleData
  @Trace public dateData1: string[] = dateDataWeek
  @Trace public dateData2: string[] = dateDataDay
  @Trace public currentData: string [] = this.dateData1
  @Trace public buttonMoney: IButtonMoney[] = buttonMoneyData
  @Trace public selectedMoneyIndex: number = 4

  public static get instance() {
    if (!PurchaseVM._instance) {
      PurchaseVM._instance = new PurchaseVM();
    }
    return PurchaseVM._instance;
  }

  init() {
    this.getUserAccount(1)
    const param = RouterModule.getNavParam<IRouterPurchase>({
      url: RouterMap.PURCHASE,
    });
    if (param) {
      this.getProductInfo(param.id)
      this.getProductBuyRule(param.id)
      this.isPurchase = param.isPurchase
    }
  }

  clear() {
    this.productInfo = initProductInfoData
    this.money = ''
    this.isCheckedAgreement = false
    this.bankCardNo = ''
    this.recommendationCode = ''
    this.isPurchase = true
    this.cycle = '每周'
    this.date = '周一'
    this.currentData = this.dateData1
    this.selectedMoneyIndex = 4
  }

  public async getUserAccount(userId: number) {
    const res = await https.getUserAccount(userId);
    if (res.code === 0) {
      this.account = res.data;
      this.bankCardNo = this.account.bankCardNo
    }
  }

  public async getProductInfo(id: number) {
    const res = await https.getProductInfo(id);
    if (res.code === 0) {
      this.productInfo = res.data;
    }
  }

  public async getProductBuyRule(id: number) {
    const res = await https.getProductBuyRule(id);
    if (res.code === 0) {
      this.productBuyRule = res.data;
    }
  }

  public getButtonMoney(index: number) {
    switch (index) {
      case 0:
        if (this.account && this.account.bankAmount < 10000) {
          this.money = this.account.bankAmount.toString()
        } else {
          this.money = '10000'
        }
        break
      case 1:
        if (this.account && this.account.bankAmount < 50000) {
          this.money = this.account.bankAmount.toString()
        } else {
          this.money = '50000'
        }
        break
      case 2:
        if (this.account && this.account.bankAmount < 100000) {
          this.money = this.account.bankAmount.toString()
        } else {
          this.money = '100000'
        }
        break
      case 3:
        if (this.account) {
          this.money = this.account.bankAmount.toString()
        }
        break
    }
  }

  public checkPurchaseInformation(): boolean {
    return this.isCheckedAgreement && this.money !== '' && this.money !== '0'
  }

  public isPrepayRequestValid(): boolean {
    //  金额未填写
    if (this.money === '' || this.money === '0') {
      promptAction.showToast({ message: '请填写金额！' });
      return false;
    }
    //  协议未勾选
    if (!this.isCheckedAgreement) {
      promptAction.showToast({ message: '请勾选协议！' });
      return false
    }

    return true
  }

  public getPrepayParam() {
    if (!this.isPrepayRequestValid()) {
      return undefined;
    }
    const data: IPrepayRequest = {
      productId: this.productInfo.id,
      amount: Number(this.money),
      userId: this.account.id,
      cardNo: this.account.bankCardNo,
      recommendationCode: this.recommendationCode,
    }
    return data
  }

  public getDollarCostAveragingParam() {
    if (!this.isPrepayRequestValid()) {
      return undefined;
    }

    const data: IDollarCostAveragingRequest = {
      productId: this.productInfo.id,
      money: Number(this.money),
      userId: this.account.id,
      bankCardNo: this.account.bankCardNo,
    }
    return data
  }


  public async prepay() {
    let res: BaseResponse | null = null
    if (this.isPurchase) {
      const data: IPrepayRequest | void = this.getPrepayParam();
      if (!data) {
        return;
      }
      res = await https.prepay(data);
    } else {
      const data: IDollarCostAveragingRequest | void = this.getDollarCostAveragingParam();
      if (!data) {
        return;
      }
      res = await https.submitDollarCostAveraging(data);
    }
    if (res && res.code === 500) {
      promptAction.showToast({ message: res.msg });
    }
    if (res && res.code === 0) {
      paymentService
        .requestPayment(this.context, res.data.orderStr)
        .then(() => {
          Logger.info('succeeded in paying');
        })
        .catch((error: BusinessError) => {
          promptAction.showToast({ message: '支付失败！' });
          Logger.error(`failed to pay, error.code: ${error.code}, error.message: ${error.message}`);
        });
    }
  }
}
