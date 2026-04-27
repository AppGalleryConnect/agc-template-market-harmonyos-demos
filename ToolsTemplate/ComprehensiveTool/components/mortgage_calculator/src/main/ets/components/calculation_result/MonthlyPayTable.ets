import { LoanType, MonthlyCombinationRepayment, MonthlyRepayment } from '../../types/Index';

interface TableColType {
  labels: Array<string>;
  columnsTemplate: string;
  values: Array<string>;
}

const singleConfig: TableColType = {
  labels: ['期数', '月供总额', '月供本金', '月供利息', '剩余本金'],
  columnsTemplate: '1fr 2fr 2fr 2fr 2fr',
  values: ['monthPay', 'monthPrincipal', 'monthInterest', 'remainingPrincipal'],
};

const combinationConfig: TableColType = {
  labels: ['期数', '总还款金额', '商业还款', '公积金还款'],
  columnsTemplate: '1fr 2fr 2fr 2fr',
  values: ['monthPay', 'commercialMonthPay', 'fundMonthPay'],
};

@Extend(Text)
function gridItemText(value: FontWeight = FontWeight.Normal) {
  .fontWeight(value)
  .fontSize(12);
}

@Extend(GridItem)
function gridItemStyle(location = 'cell') {
  .padding({ top: 8, bottom: 8 })
  .backgroundColor(location === 'top' ? '#f7f7f7' : 'fff');
}

@ComponentV2
export struct MonthlyPayTable {
  @Require @Param loanType: LoanType;
  @Param monthDetail: Array<MonthlyRepayment> = [];
  @Param monthCombinationDetail: Array<MonthlyCombinationRepayment> = [];

  @Computed
  get showConfig() {
    return this.loanType === LoanType.Combination ? combinationConfig : singleConfig;
  }

  @Computed
  get tableCells(): Array<Array<number>> {
    if (this.loanType === LoanType.Combination) {
      return this.monthCombinationDetail.map(item => {
        return [item.monthPay, item.commercialMonthPay, item.fundMonthPay];
      });
    } else {
      return this.monthDetail.map(item => {
        return [item.monthPay, item.monthPrincipal, item.monthInterest, item.remainingPrincipal];
      });
    }
  }

  getNumber(value: number, unit: number = 1): string {
    return (value / unit).toFixed(2);
  }

  build() {
    Grid() {
      ForEach(this.showConfig.labels, (label: string) => {
        GridItem() {
          Text(label)
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Medium)
            .fontSize($r('sys.float.Subtitle_S'));
        }.gridItemStyle('top');
      }, (label: string) => label);
      ForEach(this.tableCells, (cells: Array<number>, index: number) => {
        GridItem() {
          Text((index + 1).toString()).gridItemText();
        }.gridItemStyle();

        ForEach(cells, (value: number) => {
          GridItem() {
            Text(this.getNumber(value)).gridItemText();
          }.gridItemStyle();
        }, (value: number, index: number) => value.toString() + index);
      }, (cells: Array<number>, index: number) => JSON.stringify(cells) + index);
    }.columnsTemplate(this.showConfig.columnsTemplate)
    .edgeEffect(EdgeEffect.Spring)
    .scrollBar(BarState.Off);
  }
}