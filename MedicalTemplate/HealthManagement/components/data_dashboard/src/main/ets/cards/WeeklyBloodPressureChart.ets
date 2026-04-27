import { LineChart } from '@ohos/mpchart';
import { WeeklyBloodPressureChartVM } from '../viewmodel/charts/WeeklyBloodPressureChartVM';

/**
 * @usage: 周度血压折线图组件，用于展示一周血压数据的可视化分析。主要数据结构包括LineChartModel（折线图模型）、
 * systolicValues（收缩压数组）、diastolicValues（舒张压数组）、currentIndex（当前选中索引）。包含if逻辑用于数据点显示和轴配置。
 * @layout: 垂直布局（Column），内部包含LineChart组件占满整个容器。图表采用底部X轴显示周几，左侧Y轴显示血压范围40-200mmHg，
 * 两个数据点分别显示收缩压（橙色）和舒张压（蓝色）。
 * @constraints: systolicValues和diastolicValues数组长度必须为7，Y轴范围固定为40-200不可修改，X轴标签固定为周日到周六不可修改，
 * 收缩压颜色固定为橙色，舒张压颜色固定为蓝色不可修改。
 * @isGen: true
 * @fileType: component
 * @zhName: 周度血压折线图组件
 * @subPage:
 * @component: LineChart
 */
@ComponentV2
export default struct WeeklyBloodPressureChart {
  @Local private vm: WeeklyBloodPressureChartVM = new WeeklyBloodPressureChartVM();
  @Param systolicValues: number[] = [130, 135, 120, 128, 125, 132, 118];
  @Param diastolicValues: number[] = [95, 110, 100, 98, 96, 105, 92];
  @Param currentIndex: number = 3;
  @Param onValueSelected: (date: string, systolic: number, diastolic: number) => void = () => {
  };

  async aboutToAppear() {
    this.vm.initializeChart();
    if (this.systolicValues.length > 0 && this.diastolicValues.length > 0) {
      this.vm.updateDiastolicValues(this.diastolicValues);
      this.vm.updateSystolicValues(this.systolicValues);
    }
    this.vm.updateCurrentIndex(this.currentIndex);

    // 设置点击回调
    this.vm.setOnValueSelectedListener(this.onValueSelected);
  }


  @Monitor('diastolicValues')
  onDiastolicValuesChange() {
    if (this.diastolicValues.length > 0) {
      this.vm.updateDiastolicValues(this.diastolicValues);
    }
  }

  @Monitor('currentIndex')
  onCurrentIndexChange() {
    this.vm.updateCurrentIndex(this.currentIndex);
  }

  @Monitor('systolicValues')
  onSystolicValuesChange() {
    if (this.systolicValues.length > 0) {
      this.vm.updateSystolicValues(this.systolicValues);
    }
  }


  build() {
    Column() {
      LineChart({ model: this.vm.chartModel })
        .height('100%')
        .width('100%')
        .backgroundColor(Color.Transparent)
        .onAreaChange((_oldValue: Area, newValue: Area) => {
          if (newValue.width) {
            this.vm.setChartWidth(Number(newValue.width));
          }
        })
    }
  }
}

