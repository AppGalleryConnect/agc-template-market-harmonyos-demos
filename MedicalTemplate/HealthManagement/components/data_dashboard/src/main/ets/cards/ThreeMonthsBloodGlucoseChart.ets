import { CombinedChart } from '@ohos/mpchart';
import { ThreeMonthsBloodGlucoseChartVM } from '../viewmodel/charts/ThreeMonthsBloodGlucoseChartVM';

/**
 * @usage: 三个月血糖组合图表组件，用于展示三个月血糖数据的可视化分析。主要数据结构包括CombinedChartModel（组合图表模型）、
 * values（血糖值数组）、monthLabels（月份标签数组）、tooltipLabels（提示标签数组）、currentIndex（当前选中索引）。
 * 包含if逻辑用于数据验证、颜色判断和边界检查。
 * @layout: 单一CombinedChart组件占满整个容器。图表采用底部X轴显示月份，左侧Y轴显示血糖范围0-12mmol/L，
 * 散点图显示所有血糖数据点，垂直线标识当前选中位置。
 * @constraints: values数组与monthLabels数组长度必须一致，Y轴范围固定为0-12不可修改，血糖正常范围颜色判断逻辑不可修改，
 * MarkerView样式和位置不可修改。
 * @isGen: true
 * @fileType: component
 * @zhName: 三个月血糖组合图表组件
 * @subPage:
 * @component: CombinedChart
 */
@ComponentV2
export default struct ThreeMonthsBloodGlucoseChart {
  @Local private vm: ThreeMonthsBloodGlucoseChartVM = new ThreeMonthsBloodGlucoseChartVM();
  @Param values: Array<number> = [];
  @Param monthLabels: Array<string> = [];
  @Param currentIndex: number = 4;
  @Param tooltipLabels: Array<string> = [];
  @Param onValueSelected: (date: string, value: number) => void = () => {
  };

  async aboutToAppear() {
    this.vm.initializeChart();
    this.vm.updateValues(this.values);
    this.vm.updateMonthLabels(this.monthLabels);
    this.vm.updateCurrentIndex(this.currentIndex);
    this.vm.updateTooltipLabels(this.tooltipLabels);

    // 设置点击回调
    this.vm.setOnValueSelectedListener(this.onValueSelected);
  }

  @Monitor('values')
  onValuesChange() {
    this.vm.updateValues(this.values);
  }

  @Monitor('monthLabels')
  onMonthLabelsChange() {
    this.vm.updateMonthLabels(this.monthLabels);
  }

  @Monitor('tooltipLabels')
  onTooltipLabelsChange() {
    this.vm.updateTooltipLabels(this.tooltipLabels);
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
        // 当图表区域改变时，设置MarkerView的图表宽度
        if (newValue.width && typeof newValue.width === 'number') {
          this.vm.setChartWidth(newValue.width);
        }
      })
  }
}

