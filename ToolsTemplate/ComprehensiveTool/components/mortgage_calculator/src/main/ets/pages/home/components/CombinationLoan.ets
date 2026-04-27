import { PersistenceV2 } from '@kit.ArkUI';
import { CalculationForm } from '../../../components/calculation_form/Index';
import { FundLoanParams, LoanPayType, LoanType } from '../../../types/Index';
import { getInstance, RouterMap } from '../../../common/Route';
import { CalculationViewModel } from '../../../viewmodel/CalculationViewModel';
import { PrimaryButtonModifier } from './PrimaryButtonModifier';

@ComponentV2
export default struct CombinationLoan {
  @Local vm: CalculationViewModel = PersistenceV2.connect(CalculationViewModel, () => new CalculationViewModel())!;

  calculationResult() {
    const valid1 =
      this.vm.verifyParameters(this.vm.commercialAmount, this.vm.commercialYear, this.vm.commercialRate);
    const valid2 =
      this.vm.verifyParameters(this.vm.fundAmount, this.vm.fundYear, this.vm.fundAmount);
    if (!valid1 || !valid2) {
      return;
    }
    const params: FundLoanParams = {
      type: LoanType.Combination,
      payType: LoanPayType.EqualInterestPay,
      rate: Number(this.vm.commercialRate),
      year: Number(this.vm.commercialYear),
      cost: Number(this.vm.commercialAmount),
      fundRate: Number(this.vm.fundRate),
      fundYear: Number(this.vm.fundYear),
      fundCost: Number(this.vm.fundAmount),
    };

    getInstance().pushPath({
      name: RouterMap.RESULT,
      param: params,
    }, false);
  }

  build() {
    Flex({ direction: FlexDirection.Column }) {
      CalculationForm({
        loanAmount: this.vm.commercialAmount,
        loanRate: this.vm.commercialRate,
        loanYear: this.vm.commercialYear,
        isSmallHeight:this.vm.isSmallHeight,
        loanType: 1,
        handleAmountChange: (value: string) => {
          this.vm.updateCommercialAmount(value);
        },
        handleYearChange: (value: string) => {
          this.vm.updateCommercialYear(value);
        },
        handleRateChange: (value: string) => {
          this.vm.updateCommercialRate(value);
        },
      });

      CalculationForm({
        loanAmount: this.vm.fundAmount,
        loanRate: this.vm.fundRate,
        loanYear: this.vm.fundYear,
        isSmallHeight:this.vm.isSmallHeight,
        loanType: 2,
        handleAmountChange: (value: string) => {
          this.vm.updateFundAmount(value);
        },
        handleYearChange: (value: string) => {
          this.vm.updateFundYear(value);
        },
        handleRateChange: (value: string) => {
          this.vm.updateFundRate(value);
        },
      });

      Button('开始计算')
        .attributeModifier(new PrimaryButtonModifier())
        .onClick(() => this.calculationResult());
    }.padding({ top: 20 }).backgroundColor('#fff').layoutWeight(1);
  }
}