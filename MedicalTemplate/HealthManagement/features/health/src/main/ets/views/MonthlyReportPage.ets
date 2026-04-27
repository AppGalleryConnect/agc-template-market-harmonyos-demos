//月度报告页
import { MonthlyReportModel } from '../viewmodel/MonthlyReportModel';
import { MonthlyWeightChart } from '../comp/MonthlyWeightChart';
import { MonthlyBodyFatChart } from '../comp/MonthlyBodyFatChart';
import { BaseReportPage, ReportPageConfig, ChartDataPoint } from '../comp/BaseReportRow';

@Builder
export function MonthlyReportPageBuilder() {
  MonthlyReportPage()
}

// 月报体重图表Builder
@Builder
function buildMonthlyWeightChart(chartData: ChartDataPoint[]) {
  MonthlyWeightChart({ chartData: chartData })
    .width('100%')
    .padding({ left: 16, right: 16, bottom: 16 })
}

// 月报体脂图表Builder
@Builder
function buildMonthlyBodyFatChart(chartData: ChartDataPoint[]) {
  MonthlyBodyFatChart({ chartData: chartData })
    .width('100%')
    .padding({ left: 16, right: 16, bottom: 16 })
}

//月度报告页
@ComponentV2
export struct MonthlyReportPage {
  private vm: MonthlyReportModel = MonthlyReportModel.instance;

  build() {
    BaseReportPage({
      vm: this.vm,
      config: this.createConfig()
    })
  }

  private createConfig(): ReportPageConfig {
    const config = new ReportPageConfig();
    config.title = '月度报告';
    config.weightChartComponent = wrapBuilder<[ChartDataPoint[]]>(buildMonthlyWeightChart);
    config.bodyFatChartComponent = wrapBuilder<[ChartDataPoint[]]>(buildMonthlyBodyFatChart);
    return config;
  }
}

