import { LineChart, LineChartModel, ColorTemplate } from '@ohos/mpchart';
import { ChartDataPoint } from '../types/WeeklyReportTypes';
import { ChartBuilder, ChartConfig, ChartOffsets } from '../types/BaseWeightChartTypes';

// 创建周报体脂图表配置
function createWeeklyBodyFatChartConfig(): ChartConfig {
  const config = new ChartConfig();
  config.lineColor = ColorTemplate.colorRgb(255, 184, 77); // 橙色
  config.lineWidth = 3;
  config.fillAlpha = 30;
  config.gridColor = ColorTemplate.colorRgb(240, 240, 240);
  config.textColor = ColorTemplate.colorRgb(153, 153, 153);
  config.textSize = 10;
  config.yAxisMin = 0;
  config.yAxisMax = 50;
  config.yAxisLabelCount = 6;
  config.yAxisGranularity = 10;
  config.chartHeight = 200;
  config.extraOffsets = new ChartOffsets(10, 10, 20, 15);
  config.xAxisOffset = 10;
  config.yAxisOffset = 5;
  config.drawXAxisLine = false;
  return config;
}

@ComponentV2
export struct WeeklyBodyFatChart {
  @Param @Require chartData: ChartDataPoint[] = [];
  @Local private model: LineChartModel = new LineChartModel();
  private chartBuilder: ChartBuilder | null = null;

  aboutToAppear(): void {
    const config = createWeeklyBodyFatChartConfig();
    config.markerUnit = '%'; // 体脂率单位
    this.chartBuilder = new ChartBuilder(this.model, config);
    this.chartBuilder.initialize(this.chartData);
  }

  build() {
    LineChart({ model: this.model })
      .width('100%')
      .height('100%')
  }
}

