import { PersistenceV2 } from '@kit.ArkUI';
import { CalculationForm } from '../../../components/calculation_form/Index';
import { LoanParams, LoanPayType, LoanType } from '../../../types/Index';
import { getInstance, RouterMap } from '../../../common/Route';
import { CalculationViewModel } from '../../../viewmodel/CalculationViewModel';
import { PrimaryButtonModifier } from './PrimaryButtonModifier';

@ComponentV2
export default struct CommercialLoan {
  @Local vm: CalculationViewModel = PersistenceV2.connect(CalculationViewModel, () => new CalculationViewModel())!;

  calculationResult() {
    const valid =
      this.vm.verifyParameters(this.vm.fundAmount, this.vm.fundYear, this.vm.fundAmount);
    if (!valid) {
      return;
    }
    const params: LoanParams = {
      type: LoanType.ProvidentFund,
      payType: LoanPayType.EqualInterestPay,
      rate: Number(this.vm.fundRate),
      year: Number(this.vm.fundYear),
      cost: Number(this.vm.fundAmount),
    }
    getInstance().pushPath({
      name: RouterMap.RESULT,
      param: params,
    },false);
  }

  build() {
    Flex({ direction: FlexDirection.Column }) {
      CalculationForm({
        loanAmount: this.vm.fundAmount,
        loanRate: this.vm.fundRate,
        loanYear: this.vm.fundYear,
        isSmallHeight:this.vm.isSmallHeight,
        loanType: 2,
        handleAmountChange: (value: string) => {
          this.vm.updateFundAmount(value)
        },
        handleYearChange: (value: string) => {
          this.vm.updateFundYear(value)
        },
        handleRateChange: (value: string) => {
          this.vm.updateFundRate(value)
        }
      })

      Button('开始计算')
        .attributeModifier(new PrimaryButtonModifier())
        .onClick(() => this.calculationResult())
    }.padding({ top: 20 }).backgroundColor('#fff').layoutWeight(1)
  }
}