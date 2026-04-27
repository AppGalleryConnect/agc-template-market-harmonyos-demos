import { PersistenceV2 } from '@kit.ArkUI';
import { CalculationForm } from '../../../components/calculation_form/Index';
import { LPRTips } from '../../../components/lpr_tips/Index';
import { LoanParams, LoanPayType, LoanType } from '../../../types/Index';
import { getInstance, RouterMap } from '../../../common/Route';
import { CalculationViewModel } from '../../../viewmodel/CalculationViewModel';
import { PrimaryButtonModifier } from './PrimaryButtonModifier';

@ComponentV2
export default struct CommercialLoan {
  @Local vm: CalculationViewModel = PersistenceV2.connect(CalculationViewModel, () => new CalculationViewModel())!;

  calculationResult() {
    const valid =
      this.vm.verifyParameters(this.vm.commercialAmount, this.vm.commercialYear, this.vm.commercialRate);
    if (!valid) {
      return;
    }
    const params: LoanParams = {
      type: LoanType.Commercial,
      payType: LoanPayType.EqualInterestPay,
      rate: Number(this.vm.commercialRate),
      year: Number(this.vm.commercialYear),
      cost: Number(this.vm.commercialAmount),
    }

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
          this.vm.updateCommercialAmount(value)
        },
        handleYearChange: (value: string) => {
          this.vm.updateCommercialYear(value)
        },
        handleRateChange: (value: string) => {
          this.vm.updateCommercialRate(value)
        }
      })
      LPRTips({ historyRate: this.vm.historyRate }).margin({
        bottom: 20
      })
      Button('开始计算')
        .attributeModifier(new PrimaryButtonModifier())
        .onClick(() => this.calculationResult())
    }.padding({ top: 20 }).backgroundColor('#fff').layoutWeight(1)
  }
}