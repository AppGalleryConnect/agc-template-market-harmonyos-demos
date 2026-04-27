import { BillConstants } from '../commons/Constants';

class Tmp {
  label: string = '';
  value: string = '';
}

@Preview
@ComponentV2
export struct BillSummaryCard {
  @Param
  totalExpense: string = '--';
  @Param
  totalIncome: string = '--';
  @Param
  titleFontSize: Length = BillConstants.FONT_SIZE_12;
  @Param
  titleFontColor: ResourceColor = BillConstants.FONT_COLOR_LEVEL2;
  @Param
  contentFontSize: Length = BillConstants.FONT_SIZE_18;
  @Param
  contentFontColor: ResourceColor = BillConstants.FONT_COLOR_LEVEL1;

  build() {
    Row() {
      this.summaryItemBuilder({
        label: '总支出',
        value: this.totalExpense,
      });
      this.summaryItemBuilder({
        label: '总收入',
        value: this.totalIncome,
      });
    }
    .width('100%')
    .alignItems(VerticalAlign.Center)
    .backgroundColor(BillConstants.BACKGROUND_COLOR)
    .borderRadius(16)
    .padding(12)
    .margin({
      bottom: 12,
    });
  }

  @Builder
  summaryItemBuilder(params: Tmp) {
    Column() {
      Text(params.label)
        .fontSize(this.titleFontSize)
        .fontColor(this.titleFontColor);
      Text(params.value)
        .fontSize(this.contentFontSize)
        .fontColor(this.contentFontColor)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 4 });
    }
    .width('50%')
    .alignItems(HorizontalAlign.Start)
    .margin({
      top: 4,
      bottom: 4,
    });
  }
}