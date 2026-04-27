import { NumberInput } from '../number_input/Index';

@Extend(Text)
function formLabel() {
  .flexShrink(0)
  .width(80)
  .margin({ right: 10 })
}

@Extend(Text)
function formTextEnd() {
  .flexShrink(0)
  .width(16)
  .margin({ left: 10 })
}

@Extend(Divider)
function formDivider() {
  .margin({ top: 10, bottom: 10 })
}

@ComponentV2
export struct CalculationForm {
  @Param loanType: number = 1;
  @Param loanAmount: string = ''
  @Param loanYear: string = '';
  @Param loanRate: string = '';
  @Param isSmallHeight:boolean = false
  @Event handleAmountChange: (value: string) => void;
  @Event handleYearChange: (value: string) => void;
  @Event handleRateChange: (value: string) => void;

  getText(text: string) {
    if (this.loanType === 1) {
      return '商贷' + text;
    } else {
      return '公积金' + text;
    }
  }

  build() {
    Column() {
      Row() {
        Text(this.getText('金额')).formLabel()
        NumberInput({
          value: this.loanAmount,
          max: 10000,
          isInteger: false,
          isSmallHeight:this.isSmallHeight,
          handleChange: (value: string) => {
            this.handleAmountChange(value);
          }
        }).layoutWeight(1)
        Text('万').formTextEnd()
      }

      Divider().formDivider()
      Row() {
        Text(this.getText('年限')).formLabel()
        NumberInput({
          value: this.loanYear,
          max: 30,
          isInteger: true,
          isSmallHeight:this.isSmallHeight,
          handleChange: (value: string) => {
            this.handleYearChange(value);
          }
        }).layoutWeight(1)
        Text('年').formTextEnd()
      }

      Divider().formDivider()
      Row() {
        Text(this.getText('利率')).formLabel()
        NumberInput({
          value: this.loanRate,
          max: 100,
          isInteger: false,
          isSmallHeight:this.isSmallHeight,
          handleChange: (value: string) => {
            this.handleRateChange(value);
          }
        }).layoutWeight(1)
        Text('%').formTextEnd()
      }

      Divider().formDivider()
    }
  }
}