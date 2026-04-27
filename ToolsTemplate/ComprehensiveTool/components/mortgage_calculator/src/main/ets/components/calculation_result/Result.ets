import { combinationPay, equalInterestPay, equalPrincipalPay } from '../../common/Utils';
import { LoanPayType, LoanType, MonthlyCombinationRepayment, MonthlyRepayment, ResultParams } from '../../types/Index';
import { MonthlyPayTable } from './MonthlyPayTable';

@ComponentV2
struct CardColumnItem {
  @Require @Param title: string;
  @Require @Param value: string;

  build() {
    Column() {
      Text(this.title).fontColor('#fff').margin({ bottom: 10 })
      Text(this.value).fontColor('#fff')
    }.layoutWeight(1)
  }
}

@ComponentV2
export struct CalculationResult {
  @Local totalCost: number = 0
  @Local totalYear: number = 0
  @Local totalInterest: number = 0
  @Local monthDetail: Array<MonthlyRepayment> = []
  @Local monthCombinationDetail: Array<MonthlyCombinationRepayment> = [];
  @Require @Param loanType: LoanType;
  @Require @Param payType: LoanPayType;
  @Require @Param loanParams: ResultParams = new ResultParams();
  @Param fundLoanParams: ResultParams = new ResultParams();
  detailLabels: string[] = ['期数', '月供总额', '月供本金', '月供利息', '剩余本金']

  @Monitor('payType')
  initData(): void {
    if (this.loanType === LoanType.Combination) {
      const result = combinationPay({
        rate: this.loanParams.rate,
        year: this.loanParams.year,
        cost: this.loanParams.cost,
        fundRate: this.fundLoanParams.rate,
        fundYear: this.fundLoanParams.year,
        fundCost: this.fundLoanParams.cost,
        type: this.payType,
      })
      this.totalCost = result.cost
      this.totalYear = result.year
      this.totalInterest = result.totalInterest
      this.monthCombinationDetail = result.monthDetail

    } else {
      const payFun = this.payType === LoanPayType.EqualInterestPay ? equalInterestPay : equalPrincipalPay
      const result = payFun(this.loanParams.rate, this.loanParams.year, this.loanParams.cost)
      this.totalCost = result.cost
      this.totalYear = result.year
      this.totalInterest = result.totalInterest
      this.monthDetail = result.monthDetail
    }

  }

  aboutToAppear(): void {
    this.initData()
  }

  getNumber(value: number, unit: number = 1): string {
    return (value / unit).toFixed(2)
  }

  build() {
    Column() {
      Column() {
        Column() {
          Text(this.payType === 0 ? '每月应还' : '首月应还').fontColor('#fff').margin({ bottom: 10 })
          Text() {
            Span(this.getNumber(this.monthDetail[0]?.monthPay || this.monthCombinationDetail[0]?.monthPay))
              .fontWeight(FontWeight.Bold)
              .fontColor('#fff')
              .fontSize(40)
            Span(' 元').fontColor('#fff')
          }.margin({ bottom: 20 })

          Flex({ direction: FlexDirection.Row }) {
            CardColumnItem({ title: '贷款总额', value: this.totalCost + '万' })
            CardColumnItem({ title: '利息总额', value: this.getNumber(this.totalInterest, 10000) + '万' })
            CardColumnItem({ title: '贷款年限', value: this.totalYear + '年' })
          }
        }.width('100%')
        .padding({ top: 20, bottom: 20 })
        .backgroundColor($r('app.string.theme_color'))
        .borderRadius(20)
      }.width('100%').padding(20)

      MonthlyPayTable({
        loanType: this.loanType,
        monthDetail: this.monthDetail,
        monthCombinationDetail: this.monthCombinationDetail,
      }).margin({
        left: 20,
        right: 20
      }).layoutWeight(1)
    }.layoutWeight(1)
  }
}