import { LineChart } from '@ohos/mpchart';
import { ThreeMonthsBloodPressureChartVM } from '../viewmodel/charts/ThreeMonthsBloodPressureChartVM';

/**
 * @usage: 三个月血压折线图组件，用于展示三个月血压数据的可视化分析。主要数据结构包括LineChartModel（折线图模型）、
 * systolicValues（收缩压数组）、diastolicValues（舒张压数组）、monthLabels（月份标签数组）、currentIndex（当前选中索引）。
 * 包含if逻辑用于数据点显示和轴配置。
 * @layout: 垂直布局（Column），内部包含LineChart组件占满整个容器。图表采用底部X轴显示月份，左侧Y轴显示血压范围40-200mmHg，
 * 两条折线分别显示收缩压（橙色）和舒张压（蓝色）趋势。
 * @constraints: systolicValues、diastolicValues和monthLabels数组长度必须为3，Y轴范围固定为40-200不可修改，
 * X轴范围固定为0-4不可修改，收缩压颜色固定为橙色，舒张压颜色固定为蓝色不可修改。
 * @isGen: true
 * @fileType: component
 * @zhName: 三个月血压折线图组件
 * @subPage:
 * @component: LineChart
 */
@ComponentV2
export default struct ThreeMonthsBloodPressureChart {
  @Local private vm: ThreeMonthsBloodPressureChartVM = new ThreeMonthsBloodPressureChartVM();
  @Param systolicValues: number[] = [];
  @Param diastolicValues: number[] = [];
  @Param monthLabels: string[] = [];
  @Param currentIndex: number = 4;
  @Param onValueSelected: (date: string, systolic: number, diastolic: number) => void = () => {
  };

  async aboutToAppear() {
    this.vm.initializeChart();
    this.vm.updateSystolicValues(this.systolicValues);
    this.vm.updateDiastolicValues(this.diastolicValues);
    this.vm.updateMonthLabels(this.monthLabels);
    this.vm.updateCurrentIndex(this.currentIndex);

    // 设置点击回调
    this.vm.setOnValueSelectedListener(this.onValueSelected);
  }

  build() {
    Column() {
      LineChart({ model: this.vm.chartModel })
        .width('100%')
        .height('100%')
        .backgroundColor(Color.Transparent)
        .onAreaChange((_oldValue: Area, newValue: Area) => {
          if (newValue.width) {
            this.vm.setChartWidth(Number(newValue.width));
          }
        })
    }
  }
}

