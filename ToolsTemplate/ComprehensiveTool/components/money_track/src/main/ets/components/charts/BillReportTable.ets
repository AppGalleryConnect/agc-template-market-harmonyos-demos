import dayjs from 'dayjs';
import { ReportTableItem } from '../../commons/Types';

@ComponentV2
export struct BillReportTable {
  @Param
  tableData: ReportTableItem[] = [];
  @Param
  headerFontSize: Length = 16;
  @Param
  headerFontColor: ResourceColor = $r('sys.color.font_primary');
  @Param
  contentFontSize: Length = 14;
  @Param
  contentFontColor: ResourceColor = $r('sys.color.font_primary');
  @Local
  ascend: boolean = true;
  @Local
  displayData: ReportTableItem[] = [];

  @Monitor('tableData')
  refreshTable() {
    this.getTableData();
  }

  @Monitor('ascend')
  sortDisplayData() {
    this.displayData.sort((a, b) => {
      const pre: number = new Date(a.date).getTime();
      const cur: number = new Date(b.date).getTime();
      return this.ascend ? pre - cur : cur - pre;
    });
  }

  aboutToAppear(): void {
    this.getTableData();
  }

  getTableData() {
    this.displayData = this.tableData.slice();
    this.sortDisplayData();
  }

  build() {
    List() {
      if (this.displayData.length) {
        ListItem() {
          this.tableHeaderBuilder();
        };

        ForEach(this.displayData, (item: ReportTableItem, index: number) => {
          ListItem() {
            Column() {
              this.tableItemBuilder(item.date, item.totalIncome, item.totalExpense);

              if (index < this.displayData.length - 1) {
                Divider()
                  .margin({ top: 12, bottom: 12 })
                  .strokeWidth(1)
                  .color('#33000000');
              }
            };
          };
        }, (item: ReportTableItem, index: number) => index + JSON.stringify(item));
      } else {
        ListItem() {
          Column() {
            Image($r('app.media.ic_data_empty')).width(80).height(80);
            Text('暂无内容')
              .fontColor('#99000000')
              .fontSize(14)
              .fontWeight(FontWeight.Regular);
          }
          .width('100%')
          .padding(24)
          .alignItems(HorizontalAlign.Center)
          .justifyContent(FlexAlign.Center);
        };
      }
    };
  }

  @Builder
  tableHeaderBuilder() {
    Row() {
      Row() {
        Text('日期').headerFontStyle(this.headerFontSize, this.headerFontColor);
        Image(this.ascend ? $r('app.media.ic_asc') : $r('app.media.ic_desc'))
          .width(16)
          .height(16)
          .onClick(() => {
            this.ascend = !this.ascend;
          });
      }
      .width('calc(100% / 3)');

      Text('收入')
        .headerFontStyle(this.headerFontSize, this.headerFontColor)
        .width('calc(100% / 3)')
        .textAlign(TextAlign.Center);
      Text('支出')
        .headerFontStyle(this.headerFontSize, this.headerFontColor)
        .width('calc(100% / 3)')
        .textAlign(TextAlign.End);
    }
    .width('100%')
    .margin({ bottom: 24 })
    .justifyContent(FlexAlign.SpaceBetween);
  }

  @Builder
  tableItemBuilder(date: string, totalIncome: number, totalExpense: number) {
    Row() {
      Text(dayjs(date).format('MM-DD')).contentFontStyle(this.contentFontSize, this.contentFontColor);
      Text(totalIncome.toFixed(2))
        .contentFontStyle(this.contentFontSize, this.contentFontColor)
        .textAlign(TextAlign.Center);
      Text(totalExpense.toFixed(2))
        .contentFontStyle(this.contentFontSize, this.contentFontColor)
        .textAlign(TextAlign.End);

    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween);
  }
}

@Extend(Text)
function headerFontStyle(size: Length, color: ResourceColor) {
  .fontSize(size)
  .fontColor(color)
  .fontWeight(FontWeight.Medium);
}

@Extend(Text)
function contentFontStyle(size: Length, color: ResourceColor) {
  .fontSize(size)
  .fontColor(color)
  .fontWeight(FontWeight.Regular)
  .width('calc(100% / 3)');
}
