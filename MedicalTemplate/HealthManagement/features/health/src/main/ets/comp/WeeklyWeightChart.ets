import { LineChart, LineChartModel } from '@ohos/mpchart';
import { ChartBuilder, createDefaultChartConfig } from '../types/BaseWeightChartTypes';
import { ChartDataPoint } from '../types/WeeklyReportTypes';


@ComponentV2
export struct WeeklyWeightChart {
  @Param @Require chartData: ChartDataPoint[] = [];
  @Local private model: LineChartModel = new LineChartModel();
  private chartBuilder: ChartBuilder | null = null;

  aboutToAppear(): void {
    const config = createDefaultChartConfig();
    config.markerUnit = '斤'; // 体重单位
    this.chartBuilder = new ChartBuilder(this.model, config);
    this.chartBuilder.initialize(this.chartData);
  }

  build() {
    LineChart({ model: this.model })
      .width('100%')
      .height('100%')
  }
}
