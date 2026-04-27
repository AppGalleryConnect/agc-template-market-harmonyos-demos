import { ToastDialog as promptAction } from '@hw-agconnect/ui-toast';
import { Type } from '@kit.ArkUI';
import { LoanPrimeRate } from '../types/Index';
import { queryLPRList } from '../common/Request';

@ObservedV2
export class CalculationViewModel {
  @Type(LoanPrimeRate)
  @Trace historyRate: Array<LoanPrimeRate> = [];
  @Trace fundAmount: string = '50';
  @Trace fundYear: string = '30';
  @Trace fundRate: string = '2.6';
  @Trace commercialAmount: string = '100';
  @Trace commercialYear: string = '30';
  @Trace commercialRate: string = '3.5';
  @Trace isSmallHeight:boolean = false
  DEFAULT_HEIGHT:number = 800

  async queryLPRList(): Promise<void> {
    const rateList = await queryLPRList();
    this.historyRate = rateList;
  }

  updateFundAmount(value: string) {
    this.fundAmount = value;
  }

  updateFundYear(value: string) {
    this.fundYear = value;
  }

  updateFundRate(value: string) {
    this.fundRate = value;
  }

  updateCommercialAmount(value: string) {
    this.commercialAmount = value;
  }

  updateCommercialYear(value: string) {
    this.commercialYear = value;
  }

  updateCommercialRate(value: string) {
    this.commercialRate = value;
  }

  verifyParameters(loanAmount: string, loanYear: string, loanRate: string) {
    if (loanAmount === '') {
      promptAction.showToast({
        message: '贷款金额不能为空',
        duration: 2000,
      });
      return false;
    }
    if (loanYear === '') {
      promptAction.showToast({
        message: '贷款年限不能为空',
        duration: 2000,
      });
      return false;
    }
    if (loanRate === '') {
      promptAction.showToast({
        message: '贷款利率不能为空',
        duration: 2000,
      });
      return false;
    }
    if (parseFloat(loanAmount) === 0) {
      promptAction.showToast({
        message: '贷款金额不能为0',
        duration: 2000,
      });
      return false;
    }
    if (parseInt(loanYear) === 0) {
      promptAction.showToast({
        message: '贷款年限不能为0',
        duration: 2000,
      });
      return false;
    }
    const rate = loanRate.endsWith('.') ? loanRate.slice(0, loanRate.length - 1) : loanRate;
    if (parseFloat(rate) === 0) {
      promptAction.showToast({
        message: '贷款利率不能为0',
        duration: 2000,
      });
      return false;
    }
    return true;
  }
}