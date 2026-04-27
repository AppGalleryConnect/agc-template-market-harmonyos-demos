import dayjs from 'dayjs';
import { BillConstants } from '../commons/Constants';
import { BalanceChangeType } from '../commons/Enums';
import { BillCardItemModel } from '../commons/Models';

class Temp {
  title: string = '';
  content: string = '';
}

@Preview
@ComponentV2
export struct BillDetail {
  @Param @Require
  bill: BillCardItemModel;
  @Param
  amountFontColor: ResourceColor = BillConstants.FONT_COLOR_LEVEL1;
  @Param
  amountFontSize: Length = BillConstants.FONT_SIZE_24;
  @Param
  contentFontSize: Length = BillConstants.FONT_SIZE_14;
  @Param
  contentFontColor: ResourceColor = $r('sys.color.font_primary');
  @Param
  bgColor: ResourceColor = BillConstants.BACKGROUND_COLOR;
  @Event
  handleDelete: () => void;
  @Event
  handleEdit: () => void;

  @Computed
  get isIncome() {
    return Boolean(this.bill?.type === BalanceChangeType.INCOME);
  }

  build() {
    Column() {
      Row() {
        Image(this.bill.icon)
          .width(24)
          .margin({ right: 8 });
        Text(this.bill.title)
          .fontColor(BillConstants.FONT_COLOR_LEVEL1);
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .padding(16)
      .margin({ bottom: 8 });

      Text() {
        Span(this.isIncome ? '+' : '-');
        Span(this.bill.amount.toFixed(2));
      }
      .fontColor(this.amountFontColor)
      .fontSize(this.amountFontSize)
      .fontWeight(FontWeight.Bold)
      .width('100%')
      .margin({ bottom: 16 })
      .textAlign(TextAlign.Center);

      this.formItemBuilder({ title: '记录时间', content: dayjs(this.bill.date).format('YYYY年MM月DD日') });
      this.formItemBuilder({ title: '备注', content: this.bill.note ?? '' });

      Divider()
        .margin({
          top: 16,
          bottom: 16,
        });

      Flex() {
        Row() {
          Image($r('app.media.ic_delete'))
            .width(16)
            .margin({ right: 4 });
          Text('删除')
            .fontSize(this.contentFontSize)
            .fontColor(BillConstants.WARNING_COLOR);
        }
        .justifyContent(FlexAlign.Center)
        .flexGrow(1)
        .backgroundColor(BillConstants.BACKGROUND_COLOR)
        .onClick(() => {
          this.handleDelete?.();
        });

        Divider()
          .vertical(true)
          .height(16);

        Row() {
          Image($r('app.media.ic_edit'))
            .width(16)
            .margin({ right: 4 });
          Text('编辑')
            .fontSize(this.contentFontSize)
            .fontColor(this.contentFontColor);
        }
        .justifyContent(FlexAlign.Center)
        .flexGrow(1)
        .backgroundColor(BillConstants.BACKGROUND_COLOR)
        .onClick(() => {
          this.handleEdit?.();
        });
      }
      .padding(8);
    }
    .backgroundColor(this.bgColor);
  }

  @Builder
  formItemBuilder($$: Temp) {
    Row() {
      Text($$.title)
        .fontColor(BillConstants.FONT_COLOR_LEVEL2)
        .fontSize(this.contentFontSize)
        .width('20%');
      Row() {
        Text($$.content)
          .fontColor(this.contentFontColor)
          .fontSize(this.contentFontSize);
      }
      .width('70%')
      .justifyContent(FlexAlign.End);
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .width('100%')
    .padding(8);
  }
}