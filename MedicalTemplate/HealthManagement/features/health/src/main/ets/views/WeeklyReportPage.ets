//周度报告页面
import { WeeklyReportModel } from '../viewmodel/WeeklyReportModel';
import { WeeklyWeightChart } from '../comp/WeeklyWeightChart';
import { WeeklyBodyFatChart } from '../comp/WeeklyBodyFatChart';
import { BaseReportPage, ChartDataPoint, ReportPageConfig } from '../comp/BaseReportRow';


@Builder
export function WeeklyReportPageBuilder() {
  WeeklyReportPage()
}

// 周报体重图表Builder
@Builder
function buildWeeklyWeightChart(chartData: ChartDataPoint[]) {
  WeeklyWeightChart({ chartData: chartData })
    .width('100%')
    .height(180)
    .margin({ top: 8 })
}

// 周报体脂图表Builder
@Builder
function buildWeeklyBodyFatChart(chartData: ChartDataPoint[]) {
  WeeklyBodyFatChart({ chartData: chartData })
    .width('100%')
    .height(180)
    .margin({ top: 8 })
}

//周度报告页面
@ComponentV2
export struct WeeklyReportPage {
  private vm: WeeklyReportModel = WeeklyReportModel.instance;

  build() {
    BaseReportPage({
      vm: this.vm,
      config: this.createConfig()
    })
  }

  private createConfig(): ReportPageConfig {
    const config = new ReportPageConfig();
    config.title = '周度报告';
    config.weightChartComponent = wrapBuilder<[ChartDataPoint[]]>(buildWeeklyWeightChart);
    config.bodyFatChartComponent = wrapBuilder<[ChartDataPoint[]]>(buildWeeklyBodyFatChart);
    return config;
  }
}

