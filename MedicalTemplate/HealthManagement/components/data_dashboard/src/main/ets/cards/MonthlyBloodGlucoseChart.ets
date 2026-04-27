import { CombinedChart } from '@ohos/mpchart';
import { MonthlyBloodGlucoseChartVM } from '../viewmodel/charts/MonthlyBloodGlucoseChartVM';

/**
 * @usage: 月度血糖组合图表组件，用于展示月度血糖数据的可视化分析。主要数据结构包括CombinedChartModel（组合图表模型）、
 * values（血糖值数组）、dateLabels（日期标签数组）、currentIndex（当前选中索引）。
 * 包含if逻辑用于数据验证、颜色判断（正常绿色、偏低橙色、偏高红色）和边界检查。
 * @layout: 单一CombinedChart组件占满整个容器。图表采用底部X轴显示日期，左侧Y轴显示血糖范围0-12mmol/L，
 * 散点图显示当前选中数据点，垂直线标识当前日期位置。
 * @constraints: values数组与dateLabels数组长度必须一致，Y轴范围固定为0-12不可修改，
 * 血糖正常范围颜色判断逻辑不可修改（<3.9橙色，>6.1红色，正常绿色），MarkerView样式和位置不可修改。
 * @isGen: true
 * @fileType: component
 * @zhName: 月度血糖组合图表组件
 * @subPage:
 * @component: CombinedChart
 */
@ComponentV2
export default struct MonthlyBloodGlucoseChart {
  @Local private vm: MonthlyBloodGlucoseChartVM = new MonthlyBloodGlucoseChartVM();
  @Param dateLabels: string[] = [];
  @Param values: number[] = [];
  @Param currentIndex: number = -1;
  @Param onValueSelected: (date: string, value: number) => void = () => {
  };

  async aboutToAppear() {
    this.vm.initializeChart();
    if (this.values.length > 0) {
      this.vm.updateValues(this.values);
    }
    if (this.dateLabels.length > 0) {
      this.vm.updateDateLabels(this.dateLabels);
    }
    this.vm.updateCurrentIndex(this.currentIndex);

    // 设置点击回调
    this.vm.setOnValueSelectedListener(this.onValueSelected);
  }

  @Monitor('values')
  onValuesChange() {
    if (this.values.length > 0) {
      this.vm.updateValues(this.values);
    }
  }

  @Monitor('dateLabels')
  onDateLabelsChange() {
    if (this.dateLabels.length > 0) {
      this.vm.updateDateLabels(this.dateLabels);
    }
  }

  @Monitor('currentIndex')
  onCurrentIndexChange() {
    this.vm.updateCurrentIndex(this.currentIndex);
  }

  build() {
    CombinedChart({ model: this.vm.chartModel })
      .width('100%')
      .height('100%')
      .onAreaChange((_oldValue: Area, newValue: Area) => {
        const width = Number(newValue.width);
        if (width > 0) {
          this.vm.setChartWidth(width);
        }
      })
  }
}

