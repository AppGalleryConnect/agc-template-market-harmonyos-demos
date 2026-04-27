import { Type } from '@kit.ArkUI';
import { FundLoanParams, ResultParams } from '../types/Index';
import { getInstance, RouterMap } from '../common/Route';

@ObservedV2
export class ResultViewModel {
  @Type(ResultParams)
  @Trace loanParams: ResultParams = new ResultParams();
  @Type(ResultParams)
  @Trace fundLoanParams: ResultParams = new ResultParams();
  @Trace payType: number = 0
  @Trace loanType: number = 0

  initParams(): void {
    const params = getInstance().getParamByName(RouterMap.RESULT)[0] as FundLoanParams
    this.loanParams.rate = params.rate;
    this.loanParams.year = params.year;
    this.loanParams.cost = params.cost;
    this.fundLoanParams.rate = params.fundRate;
    this.fundLoanParams.year = params.fundYear;
    this.fundLoanParams.cost = params.fundCost;
    this.payType = params.payType;
    this.loanType = params.type;
  }

  getNumber(value: number, unit: number = 1): string {
    return (value / unit).toFixed(2)
  }

  handlePayTypeChange(value: number) {
    this.payType = value;
  }
}