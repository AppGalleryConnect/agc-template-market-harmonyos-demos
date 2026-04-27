import { HomeVM } from '../../viewmodels/HomeVM';
import { BalanceTypeSelection } from '../BalanceTypeSelection';
import { ContainerColumn } from '../base/ContainerColumn';
import { BillBarChart } from './BillBarChart';
import { BillPieChart } from './BillPieChart';
import { BillRanking } from './BillRanking';
import { BillReportTable } from './BillReportTable';

@ComponentV2
export struct ChartSummary {
  @Param vm: HomeVM = new HomeVM();

  build() {
    Scroll() {
      Column() {
        // 饼图
        this.pieChartBuilder();
        // 柱状图
        this.barChartBuilder();
        // 逐日报表
        this.reportBuilder();
      };
    }
    .scrollBar(BarState.Off)
    .layoutWeight(1)
    .edgeEffect(EdgeEffect.Spring);

  }

  @Builder
  pieChartBuilder() {
    ContainerColumn() {
      BalanceTypeSelection({
        expenseLabel: '支出占比',
        incomeLabel: '收入占比',
        curType: this.vm.chartType,
        changeType: (type) => {
          this.vm.changeChartType(type);
        },
      });
      BillPieChart({
        chartData: this.vm.pieChartData,
        colorList: this.vm.pieChartColor,
      });
      BillRanking({
        chartData: this.vm.pieChartData,
        colorList: this.vm.pieChartColor,
        handleClickBar: (resource: number) => {
          this.vm.jumpToDetailPage(resource);
        },
      });
    };
  }

  @Builder
  barChartBuilder() {
    ContainerColumn() {
      BalanceTypeSelection({
        expenseLabel: '支出统计',
        incomeLabel: '收入统计',
        curType: this.vm.chartType,
        changeType: (type) => {
          this.vm.changeChartType(type);
        },
      })
        .margin({bottom:$r('app.string.space_m')})

      BillBarChart({
        chartData: this.vm.barChartData,
        initColor: this.vm.barInitColor,
        highlightColor: this.vm.barHighlightColor,
      })
        .margin({bottom:$r('app.string.space_m')})
    };
  }

  @Builder
  reportBuilder() {
    ContainerColumn() {
      Row() {
        Text('报表统计')
          .fontSize($r('app.string.font_size_18'))
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.font_color_level1'));
      }
      .margin({ bottom: $r('app.string.space_l') })
      .width($r('app.string.width_percent_full'))
      .justifyContent(FlexAlign.SpaceBetween);

      BillReportTable({
        tableData: this.vm.reportData,
      });
    };
  }
}