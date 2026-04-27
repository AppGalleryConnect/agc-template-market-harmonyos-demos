import { inputMethod } from '@kit.IMEKit';
import { FinancialType } from '../common/Constant';
import { InvestmentDetail } from '../model/Index';

@ObservedV2
export class FinancialPageVM {
  private static _instance: FinancialPageVM
  @Trace currentIndex: number = 0
  @Trace type:string = '活期'
  @Trace bank: InvestmentDetail = new InvestmentDetail(FinancialType.BANK)
  @Trace compoundRate: InvestmentDetail = new InvestmentDetail(FinancialType.COMPOUND_RATE)
  @Trace regularInvestment: InvestmentDetail = new InvestmentDetail(FinancialType.REGULAR_INVESTMENT)

  public static get instance() {
    if (!FinancialPageVM._instance) {
      FinancialPageVM._instance = new FinancialPageVM();
    }
    return FinancialPageVM._instance;
  }

  checkBank() {
    if (this.bank.money !== '' && this.bank.time !== '' && this.bank.rate !== '') {
      this.bank.isShowButton = true
      return
    }
    this.bank.isShowButton = false
  }

  checkCompoundRate() {
    if (this.compoundRate.money !== '' && this.compoundRate.time !== '' && this.compoundRate.rate !== '' &&
      this.compoundRate.compoundRateCount !== '') {
      this.compoundRate.isShowButton = true
      return
    }
    this.compoundRate.isShowButton = false
  }

  checkRegularInvestment() {
    if (this.regularInvestment.monthlyMoney !== '' && this.regularInvestment.time !== '' &&
      this.regularInvestment.rate !== '') {
      this.regularInvestment.isShowButton = true
      return
    }
    this.regularInvestment.isShowButton = false
  }

  clear() {
    if (this.currentIndex === 0) {
      this.bank = new InvestmentDetail(FinancialType.BANK)
    } else if (this.currentIndex === 1) {
      this.compoundRate = new InvestmentDetail(FinancialType.COMPOUND_RATE)
    } else {
      this.regularInvestment = new InvestmentDetail(FinancialType.REGULAR_INVESTMENT)
    }
  }

  init(){
    this.currentIndex = 0
    this.bank = new InvestmentDetail(FinancialType.BANK)
    this.compoundRate = new InvestmentDetail(FinancialType.COMPOUND_RATE)
    this.regularInvestment = new InvestmentDetail(FinancialType.REGULAR_INVESTMENT)
  }

  closeKeyboard(){
    try {
      inputMethod.getController().stopInputSession();
    } catch (err) {
      console.error('Failed to hide keyboard: ' + err);
    }
  }
}
