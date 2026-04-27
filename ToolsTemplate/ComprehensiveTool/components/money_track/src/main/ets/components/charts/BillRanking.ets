import { BillPieChartItem, BillRankingItem } from '../../commons/Types';

@ComponentV2
export struct BillRanking {
  @Param
  colorList: number[] = [];
  @Param
  chartData: BillPieChartItem[] = [];
  @Param
  maxBarLength: number = 180;
  @Param
  labelColor: ResourceColor = '#e6000000';
  @Param
  labelSize: Length = 12;
  @Local
  rankingData: BillRankingItem[] = [];
  @Event
  handleClickBar: (resource: number) => void;

  @Monitor('chartData')
  refreshChart() {
    this.getRankingData();
  }

  async aboutToAppear() {
    this.getRankingData();
  }

  build() {
    List({ space: 16 }) {
      ForEach(this.rankingData, (item: BillRankingItem) => {
        ListItem() {
          Row() {
            Text(item.label)
              .width('20%')
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .fontColor(this.labelColor)
              .fontSize(this.labelSize);
            Flex() {
              Line()
                .width(item.barLength)
                .backgroundColor(item.color)
                .height(8)
                .borderRadius(4);
            }
            .layoutWeight(1);

            Blank();
            Row() {
              Text() {
                Span('¥');
                Span(this.getFormattedAmount(item.value));
              }
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .fontColor(this.labelColor)
              .fontSize(this.labelSize)
              .fontWeight(FontWeight.Medium)
              .textAlign(TextAlign.End)
              .width(80)

              Image($r('app.media.ic_arrow_right'))
                .height(16)
                .width(16)
            }

            .justifyContent(FlexAlign.End);
          }
          .onClick(() => {
            this.handleClickBar?.(item.resource);
          });
        };
      }, (item: BillRankingItem) => JSON.stringify(item));
    }
    .width('100%');
  }

  getRankingData() {
    this.rankingData = [];
    if (!this.chartData.length) {
      return;
    }
    this.chartData.sort((a, b) => b.value - a.value);
    const maxValue = this.chartData[0].value;
    this.chartData.forEach((item, index) => {
      const barLength = item.value / maxValue * this.maxBarLength;
      const rankingItem: BillRankingItem = {
        label: item.label,
        value: item.value,
        resource: item.resource,
        barLength,
        color: this.colorList[index],
      };
      this.rankingData.push(rankingItem);
    });
  }

  getFormattedAmount(value: number) {
    if (value < 100000) {
      return value.toFixed(2);
    }
    return (value / 10000).toFixed(2) + '万';
  }
}