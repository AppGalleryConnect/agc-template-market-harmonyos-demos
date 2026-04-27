import { BillConstants } from '../commons/Constants';
import { BalanceChangeType } from '../commons/Enums';
import { BillCardItem } from '../commons/Types';

@ComponentV2
export struct BillItem {
  @Param @Require
  billItem: BillCardItem;
  @Param
  showDivider: boolean = false;
  @Param
  showAsset: boolean = true;
  @Param
  titleSize: Length = BillConstants.FONT_SIZE_14;
  @Param
  titleColor: ResourceColor = BillConstants.FONT_COLOR_LEVEL1;
  @Param
  noteSize: Length = BillConstants.FONT_SIZE_12;
  @Param
  noteColor: ResourceColor = BillConstants.FONT_COLOR_LEVEL2;
  @Param
  incomeColor: ResourceColor = BillConstants.THEME_COLOR;
  @Param
  expenseColor: ResourceColor = BillConstants.FONT_COLOR_LEVEL1;
  @Param
  dividerColor: ResourceColor = BillConstants.DIVIDER_COLOR;
  @Param
  bgColor: ResourceColor = BillConstants.BACKGROUND_COLOR;

  build() {
    Row() {
      Image(this.billItem.icon)
        .width(24);
      Column() {
        Row() {
          Text(this.billItem.title)
            .fontSize(this.titleSize)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.titleColor)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis });
          Text() {
            Span(this.billItem.type === BalanceChangeType.INCOME ? '+' : '-');
            Span(this.billItem.amount.toFixed(2));
          }
          .fontSize(this.titleSize)
          .fontWeight(FontWeight.Medium)
          .width(100)
          .textAlign(TextAlign.End)
          .fontColor(this.billItem.type === BalanceChangeType.INCOME ? this.incomeColor : this.expenseColor);
        }
        .width('100%')
        .margin({ bottom: 2 })
        .justifyContent(FlexAlign.SpaceBetween);

        if (this.billItem.note || this.showAsset && this.billItem.assetName) {
          Row() {
            Text(this.billItem.note)
              .fontSize(this.noteSize)
              .fontColor(this.noteColor)
              .width('60%')
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis });
            Blank();
            Text(this.showAsset ? this.billItem.assetName ?? '' : '')
              .fontColor(this.noteColor)
              .fontSize(this.noteSize)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .textAlign(TextAlign.End);
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween);
        }
      }
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.SpaceAround)
      .layoutWeight(1)
      .margin({ left: 16 });
    }
    .height(56)
    .backgroundColor(this.bgColor);
  }
}