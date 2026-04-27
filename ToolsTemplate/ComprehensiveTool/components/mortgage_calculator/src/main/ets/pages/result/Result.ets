import { CalculationResult } from '../../components/calculation_result/Result';
import { LoanPayType } from '../../types/Index';
import { ResultViewModel } from '../../viewmodel/ResultViewModel';

@ComponentV2
struct TabItem1 {
  @Require @Param active: number;
  @Require @Param value: number;
  @Require @Param title: string;
  @Event handleClick: (value: number) => void;

  build() {
    Row() {
      Text(this.title)
        .fontSize(16);
    }
    .layoutWeight(1)
    .height(36)
    .borderRadius(18)
    .backgroundColor(this.active === this.value ? '#fff' : '')
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      this.handleClick(this.value);
    });
  }
}

@Builder
export function CalculationResultBuilder() {
  CalculationResultPage();
}

@ComponentV2
struct CalculationResultPage {
  @Local loanType: number = 0;
  @Local vm: ResultViewModel = new ResultViewModel();

  aboutToAppear(): void {
    this.vm.initParams();
  }

  build() {
    NavDestination() {
      Column() {
        Row() {
          TabItem1({
            title: '等额本息',
            value: LoanPayType.EqualInterestPay,
            active: this.vm.payType,
            handleClick: (value: number) => {
              this.vm.payType = value;
            },
          });
          TabItem1({
            title: '等额本金',
            value: LoanPayType.EqualPrincipalPay,
            active: this.vm.payType,
            handleClick: (value: number) => {
              this.vm.payType = value;
            },
          });
        }
        .height(40)
        .borderRadius(20)
        .backgroundColor('#0C000000')
        .padding(2)
        .margin(16);

        CalculationResult({
          loanParams: this.vm.loanParams,
          fundLoanParams: this.vm.fundLoanParams,
          loanType: this.vm.loanType,
          payType: this.vm.payType,
        });
      }.height('100%');
    }.title('计算结果');
  }
}