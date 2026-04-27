import { ChartDataPoint } from '../types/MonthlyReportTypes';
import { LineChart, LineChartModel, ColorTemplate } from '@ohos/mpchart';
import { ChartBuilder, ChartConfig, ChartOffsets } from '../types/BaseWeightChartTypes';

// 创建月报图表专属配置
function createMonthlyChartConfig(): ChartConfig {
  const config = new ChartConfig();
  config.lineColor = ColorTemplate.colorRgb(90, 177, 232);
  config.lineWidth = 3;
  config.fillAlpha = 30;
  config.gridColor = ColorTemplate.rgb('#F0F0F0');
  config.axisLineColor = ColorTemplate.rgb('#E0E0E0');
  config.textColor = ColorTemplate.rgb('#999999');
  config.textSize = 12;
  config.yAxisMin = 0;
  config.yAxisMax = 160;
  config.yAxisLabelCount = 5;
  config.yAxisGranularity = 40;
  config.chartHeight = 200;
  config.extraOffsets = new ChartOffsets(0, 10, 0, 10);
  config.drawXAxisLine = true;
  return config;
}

@ComponentV2
export struct MonthlyWeightChart {
  @Require @Param chartData: ChartDataPoint[] = [];
  private model: LineChartModel = new LineChartModel();
  private chartBuilder: ChartBuilder | null = null;

  aboutToAppear() {
    const config = createMonthlyChartConfig();
    config.markerUnit = '斤'; // 体重单位
    this.chartBuilder = new ChartBuilder(this.model, config);
    this.chartBuilder.initialize(this.chartData);
  }

  build() {
    LineChart({ model: this.model })
      .width('100%')
      .height(200)
  }
}
