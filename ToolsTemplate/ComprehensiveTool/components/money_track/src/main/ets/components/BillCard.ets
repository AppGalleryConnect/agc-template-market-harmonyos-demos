import { BillItem } from './BillCardItem';
import dayjs from 'dayjs';
import { BalanceChangeType } from '../commons/Enums';
import { DailyBillGroupModel } from '../commons/Models';
import { BillCardItem } from '../commons/Types';
import { BillConstants } from '../commons/Constants';

@Preview
@ComponentV2
export struct BillCard {
  @Param
  card: DailyBillGroupModel = new DailyBillGroupModel();
  @Param
  cardBgColor: ResourceColor = '#ffffff';
  @Param
  showSummary: boolean = true;
  @Param
  headerFontSize: Length = BillConstants.FONT_SIZE_12;
  @Param
  headerFontColor: ResourceColor = BillConstants.FONT_COLOR_LEVEL1;
  @Param
  deleteButtonFontSize: Length = BillConstants.FONT_SIZE_14;
  @Param
  deleteButtonFontColor: ResourceColor = BillConstants.FONT_COLOR_1_INVERT;
  @Param
  deleteButtonBgColor: ResourceColor = BillConstants.WARNING_COLOR;
  @Param
  emptyNoteSize: Length = BillConstants.FONT_SIZE_14;
  @Param
  emptyNoteColor: ResourceColor = BillConstants.FONT_COLOR_LEVEL2;
  @Param
  dividerColor: ResourceColor = BillConstants.DIVIDER_COLOR;
  @Param
  showOperation: boolean = true;
  @Param
  showAsset: boolean = true;
  @Event
  handleDelete: (id: number) => void;
  @Event
  handleClickItem: (id: BillCardItem) => void;

  @Computed
  get dateLabel() {
    return this.card.dateStr ? dayjs(this.card.dateStr).format('MM月DD日') : '';
  }

  @Computed
  get totalIncome() {
    const incomeList = this.card.list.filter((item) => item.type === BalanceChangeType.INCOME);
    return incomeList.reduce((a, item) => a + item.amount, 0) ?? 0;
  }

  @Computed
  get totalExpense() {
    const expenseList = this.card.list.filter((item) => item.type === BalanceChangeType.EXPENSE);
    return expenseList.reduce((a, item) => a + item.amount, 0) ?? 0;
  }

  build() {
    Column() {
      Column() {
        Row() {
          Text() {
            Span(this.dateLabel);
          }
          .cardHeaderStyle(this.headerFontSize, this.headerFontColor)
          .layoutWeight(1);

          if (this.showSummary) {
            Text() {
              Span('收：');
              Span(this.totalIncome.toFixed(2));
              Span(' ').letterSpacing(6);
              Span('支: ');
              Span(this.totalExpense.toFixed(2));
            }.cardHeaderStyle(this.headerFontSize, this.headerFontColor);
          }
        }
        .margin({ bottom: 16 })
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween);

        if (this.card.list.length) {
          List() {
            ForEach(this.card.list, (item: BillCardItem) => {
              if (this.showOperation) {
                ListItem() {
                  BillItem({
                    billItem: item,
                    showAsset: this.showAsset,
                  });
                }
                .onClick(() => {
                  this.handleClickItem?.(item);
                })
                .swipeAction({ end: this.itemEndBuilder(item.transactionId) });
              } else {
                ListItem() {
                  BillItem({
                    billItem: item,
                  });
                }
                .onClick(() => {
                  this.handleClickItem?.(item);
                });
              }
            }, (item: BillCardItem) => item.transactionId.toString());
          }
          .divider({
            strokeWidth: 0.5,
            color: this.dividerColor,
            startMargin: 40,
          });
        } else {
          Column() {
            Image($r('app.media.ic_empty_asset_bill'))
              .width(80)
              .height(80);
            Text('暂无记录')
              .fontSize(this.emptyNoteSize)
              .fontColor(this.emptyNoteColor);
          }
          .width('100%');
        }
      }
      .alignItems(HorizontalAlign.Start)
      .margin({ bottom: 16 })
      .backgroundColor(this.cardBgColor)
      .borderRadius(16)
      .width('100%')
      .padding(12);
    };

  }

  @Builder
  itemEndBuilder(id: number) {
    Row() {
      Text('删除')
        .fontSize(this.deleteButtonFontSize)
        .fontColor(this.deleteButtonFontColor);
    }
    .padding(16)
    .margin({ left: 16 })
    .backgroundColor(this.deleteButtonBgColor)
    .onClick(() => {
      this?.handleDelete(id);
    })
    .height(56);
  }
}

@Extend(Text)
function cardHeaderStyle(size: Length, color: ResourceColor) {
  .fontSize(size)
  .fontColor(color)
  .fontWeight(FontWeight.Regular);
}