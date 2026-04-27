import { CombinedChart } from '@ohos/mpchart';
import { WeeklyBloodGlucoseChartVM } from '../viewmodel/charts/WeeklyBloodGlucoseChartVM';

/**
 * @usage: 周度血糖组合图表组件，用于展示一周血糖数据的可视化分析。主要数据结构包括CombinedChartModel（组合图表模型）、
 * values（血糖值数组）、currentIndex（当前选中索引）。包含if逻辑用于数据验证、颜色判断（正常绿色、偏低橙色、偏高红色）和边界检查。
 * @layout: 单一CombinedChart组件占满整个容器。图表采用底部X轴显示周几，左侧Y轴显示血糖范围0-12mmol/L，散点图显示当前选中数据点，
 * 垂直线标识当前日期位置。
 * @constraints: values数组长度必须为7，Y轴范围固定为0-12不可修改，X轴标签固定为周日到周六不可修改，
 * 血糖正常范围颜色判断逻辑不可修改（<3.9橙色，>6.1红色，正常绿色），MarkerView样式不可修改。
 * @isGen: true
 * @fileType: component
 * @zhName: 周度血糖组合图表组件
 * @subPage:
 * @component: CombinedChart
 */
@ComponentV2
export default struct WeeklyBloodGlucoseChart {
  @Local private vm: WeeklyBloodGlucoseChartVM = new WeeklyBloodGlucoseChartVM();
  @Param currentIndex: number = -1;
  @Param values: number[] = [];
  @Param onValueSelected: (date: string, value: number) => void = () => {
  };

  async aboutToAppear() {
    this.vm.initializeChart();
    if (this.values.length > 0) {
      this.vm.updateValues(this.values);
    }
    this.vm.updateCurrentIndex(this.currentIndex);

    // 设置点击回调
    this.vm.setOnValueSelectedListener(this.onValueSelected);
  }

  @Monitor('currentIndex')
  onCurrentIndexChange() {
    this.vm.updateCurrentIndex(this.currentIndex);
  }

  @Monitor('values')
  onValuesChange() {
    if (this.values.length > 0) {
      this.vm.updateValues(this.values);
    }
  }


  build() {
    CombinedChart({ model: this.vm.chartModel })
      .height('100%')
      .width('100%')
      .onAreaChange((_oldValue: Area, newValue: Area) => {
        const width = Number(newValue.width);
        if (width > 0) {
          this.vm.setChartWidth(width);
        }
      })
  }
}

