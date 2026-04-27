/**
 * 月度睡眠图表 ViewModel
 */
import {
  AxisBase,
  BarChartModel,
  BarData,
  BarDataSet,
  BarEntry,
  ColorTemplate,
  Description,
  IAxisValueFormatter,
  IBarDataSet,
  JArrayList,
  Legend,
  XAxis,
  XAxisPosition,
  YAxis,
  YAxisLabelPosition,
  OnChartValueSelectedListener,
  EntryOhos,
  Highlight
} from '@ohos/mpchart';

class DateFormatter implements IAxisValueFormatter {
  private dateLabels: Array<string> = [];

  constructor(labels: Array<string>) {
    this.dateLabels = labels;
  }

  getFormattedValue(value: number, _axis: AxisBase): string {
    const index = Math.round(value);
    if (index >= 0 && index < this.dateLabels.length) {
      // 如果有标签就返回标签
      if (this.dateLabels[index] && this.dateLabels[index].trim() !== '') {
        return this.dateLabels[index];
      }
      // 如果没有标签，根据索引生成日期
      const day = index + 1;
      if (day <= 30) { // 4月有30天
        return `4/${day}`;
      }
    }
    return '';
  }
}

@ObservedV2
export class MonthlySleepChartVM implements OnChartValueSelectedListener {
  @Trace chartModel: BarChartModel | undefined = undefined;
  @Trace sleepData: Array<[number, number, number, number]> = [];
  @Trace labels: Array<string> = [];
  @Trace groupSizes: Array<number> = [];
  private onValueSelectedCallback: ((date: string, totalHours: number, totalMinutes: number) => void) | undefined;

  public initializeChart(): void {
    this.chartModel = new BarChartModel();
    let description: Description | null = this.chartModel.getDescription();
    if (description) {
      description.setEnabled(false);
    }

    let legend: Legend | null = this.chartModel.getLegend();
    if (legend) {
      legend.setEnabled(false);
    }

    this.chartModel.setPinchZoom(false);
    this.chartModel.setDrawGridBackground(false);
    this.chartModel.setDrawValueAboveBar(false);
    this.chartModel.setTouchEnabled(true);
    this.chartModel.setDragEnabled(true); // 启用拖拽滑动
    this.chartModel.setScaleEnabled(false);
    this.chartModel.setHighlightPerTapEnabled(true);
    this.chartModel.setHighlightPerDragEnabled(false);
    this.chartModel.setOnChartValueSelectedListener(this);

    let sleepMonthlyXAxis: XAxis | null = this.chartModel.getXAxis();
    if (sleepMonthlyXAxis) {
      sleepMonthlyXAxis.setPosition(XAxisPosition.BOTTOM);
      sleepMonthlyXAxis.setGranularity(1);
      sleepMonthlyXAxis.setGranularityEnabled(true);
      sleepMonthlyXAxis.setAxisMinimum(-0.5);
      sleepMonthlyXAxis.setAxisMaximum(this.labels.length - 0.5);
      sleepMonthlyXAxis.setLabelCount(6, true); // 强制只显示6个标签，防止滑动时变化
      sleepMonthlyXAxis.setValueFormatter(new DateFormatter(this.labels));
      sleepMonthlyXAxis.setDrawGridLines(true);
      sleepMonthlyXAxis.setGridColor(ColorTemplate.colorRgb(230, 230, 230));
      sleepMonthlyXAxis.setGridLineWidth(0.5);
      sleepMonthlyXAxis.setTextColor(ColorTemplate.colorRgb(150, 150, 150));
      sleepMonthlyXAxis.setYOffset(8);
      sleepMonthlyXAxis.setAvoidFirstLastClipping(true);

      // 设置可见范围，支持滑动查看完整月份数据
      if (this.labels.length > 10) {
        // 如果数据点超过10个，设置可见范围为12个数据点，支持滑动
        this.chartModel.setVisibleXRangeMaximum(12);
        this.chartModel.setVisibleXRangeMinimum(8);
        // 默认显示前10个数据点（从4/1开始）
        this.chartModel.moveViewToX(-0.5);
      }
    }

    let sleepMonthlyLeftAxis: YAxis | null = this.chartModel.getAxisLeft();
    if (sleepMonthlyLeftAxis) {
      sleepMonthlyLeftAxis.setAxisMinimum(0);
      sleepMonthlyLeftAxis.setAxisMaximum(12);
      sleepMonthlyLeftAxis.setLabelCount(5, false);
      sleepMonthlyLeftAxis.setPosition(YAxisLabelPosition.OUTSIDE_CHART);
      sleepMonthlyLeftAxis.setGridColor(ColorTemplate.colorRgb(240, 240, 240));
      sleepMonthlyLeftAxis.setGridLineWidth(0.8);
      sleepMonthlyLeftAxis.setTextColor(ColorTemplate.colorRgb(150, 150, 150));
    }

    let sleepMonthlyRightAxis: YAxis | null = this.chartModel.getAxisRight();
    if (sleepMonthlyRightAxis) {
      sleepMonthlyRightAxis.setEnabled(false);
    }

    this.chartModel.setExtraOffsets(0, 15, 15, 0);
    this.updateChartData();
  }

  public updateSleepData(data: Array<[number, number, number, number]>): void {
    this.sleepData = data.map(item => [item[0], item[1], item[2], item[3]]);
    this.updateChartData();
  }

  public updateLabels(labels: Array<string>): void {
    this.labels = labels.slice();
    this.updateChartData();
  }

  public updateGroupSizes(sizes: Array<number>): void {
    this.groupSizes = sizes.slice();
    this.updateChartData();
  }

  private updateChartData(): void {
    if (!this.chartModel || !this.sleepData || this.sleepData.length === 0) {
      return;
    }

    if (this.chartModel) {
      let sleepMonthlyUpdateXAxis: XAxis | null = this.chartModel.getXAxis();
      if (sleepMonthlyUpdateXAxis) {
        sleepMonthlyUpdateXAxis.setAxisMinimum(-0.5);
        sleepMonthlyUpdateXAxis.setAxisMaximum(this.labels.length - 0.5);
        sleepMonthlyUpdateXAxis.setLabelCount(6, true); // 强制只显示6个标签，防止滑动时变化
        sleepMonthlyUpdateXAxis.setValueFormatter(new DateFormatter(this.labels));
        sleepMonthlyUpdateXAxis.setDrawGridLines(true);
        sleepMonthlyUpdateXAxis.setGridColor(ColorTemplate.colorRgb(230, 230, 230));
        sleepMonthlyUpdateXAxis.setGridLineWidth(0.5);
        sleepMonthlyUpdateXAxis.setYOffset(8);
        sleepMonthlyUpdateXAxis.setAvoidFirstLastClipping(true);

        // 设置可见范围，支持滑动查看完整月份数据
        if (this.labels.length > 10) {
          // 如果数据点超过10个，设置可见范围为12个数据点，支持滑动
          this.chartModel.setVisibleXRangeMaximum(12);
          this.chartModel.setVisibleXRangeMinimum(8);
          // 默认显示前10个数据点（从4/1开始）
          this.chartModel.moveViewToX(-0.5);
        }
      }
    }

    let sleepMonthlyValues: JArrayList<BarEntry> = new JArrayList<BarEntry>();

    // 真实分布：让柱子按照labels数组的范围分布，匹配17个数据点
    const xPositions = [
      1, 2, 3, // 4/2-4/4 连续3天 (位置1-3)
      6, 7, // 4/7-4/8 连续2天 (位置6-7)
      11, // 4/12 单独1天 (位置11)
      14, 15, 16, 17, // 4/15-4/18 连续4天 (位置14-17)
      19, 20, 21, // 4/20-4/22 连续3天 (位置19-21)
      24, 25, // 4/25-4/26 连续2天 (位置24-25)
      28, 29// 4/29-4/30 连续2天 (位置28-29)
    ];

    for (let i = 0; i < this.sleepData.length && i < xPositions.length; i++) {
      const data = this.sleepData[i];
      const xPos = xPositions[i];
      sleepMonthlyValues.add(new BarEntry(xPos, [data[0], data[1], data[2], data[3]]));
    }

    let sleepMonthlySet: BarDataSet = new BarDataSet(sleepMonthlyValues, '');
    sleepMonthlySet.setDrawIcons(false);
    const deepBlue: number = ColorTemplate.colorRgb(0, 90, 255);
    const lightBlue: number = ColorTemplate.colorRgb(80, 170, 255);
    const yellow: number = ColorTemplate.colorRgb(255, 208, 0);
    const orange: number = ColorTemplate.colorRgb(255, 160, 0);
    sleepMonthlySet.setColorsByArr([deepBlue, lightBlue, yellow, orange]);
    sleepMonthlySet.setStackLabels(['深睡', '浅睡', '快速眼动', '清醒']);
    sleepMonthlySet.setDrawValues(false);

    let sleepMonthlyDataSets: JArrayList<IBarDataSet> = new JArrayList<IBarDataSet>();
    sleepMonthlyDataSets.add(sleepMonthlySet);
    let sleepMonthlyData: BarData = new BarData(sleepMonthlyDataSets);
    sleepMonthlyData.setDrawValues(false);
    sleepMonthlyData.setBarWidth(0.15);
    if (this.chartModel) {
      this.chartModel.setData(sleepMonthlyData);
      this.chartModel.notifyDataSetChanged();
    }
  }

  public setOnValueSelectedListener(callback: (date: string, totalHours: number, totalMinutes: number) => void): void {
    this.onValueSelectedCallback = callback;
  }

  public onValueSelected(e: EntryOhos, _h: Highlight): void {
    const xValue = e.getX();

    // 根据X值找到最接近的数据点（与updateChartData中的xPositions保持一致）
    const xPositions = [
      1, 2, 3, // 4/2-4/4 连续3天 (位置1-3)
      6, 7, // 4/7-4/8 连续2天 (位置6-7)
      11, // 4/12 单独1天 (位置11)
      14, 15, 16, 17, // 4/15-4/18 连续4天 (位置14-17)
      19, 20, 21, // 4/20-4/22 连续3天 (位置19-21)
      24, 25, // 4/25-4/26 连续2天 (位置24-25)
      28, 29// 4/29-4/30 连续2天 (位置28-29)
    ];
    let dataIndex = -1;
    let minDistance = Number.MAX_VALUE;

    for (let i = 0; i < xPositions.length; i++) {
      const distance = Math.abs(xValue - xPositions[i]);
      if (distance < minDistance) {
        minDistance = distance;
        dataIndex = i;
      }
    }

    if (dataIndex >= 0 && dataIndex < this.sleepData.length) {
      const sleepDataItem = this.sleepData[dataIndex];

      // 计算总睡眠时间
      const totalSleepHours = sleepDataItem[0] + sleepDataItem[1] + sleepDataItem[2] + sleepDataItem[3];
      const hours = Math.floor(totalSleepHours);
      const minutes = Math.round((totalSleepHours - hours) * 60);

      // 生成对应的日期
      const date = this.generateDateFromIndex(dataIndex);

      if (this.onValueSelectedCallback) {
        this.onValueSelectedCallback(date, hours, minutes);
      }
    }
  }

  public onNothingSelected(): void {
  }

  private generateDateFromIndex(index: number): string {
    const dateMappings = [
      '04月02日', '04月03日', '04月04日',
      '04月07日', '04月08日',
      '04月12日',
      '04月15日', '04月16日', '04月17日', '04月18日',
      '04月20日', '04月21日', '04月22日',
      '04月25日', '04月26日',
      '04月29日', '04月30日'
    ];

    if (index >= 0 && index < dateMappings.length) {
      return dateMappings[index];
    }

    return `04月${(index + 2).toString().padStart(2, '0')}日`;
  }
}

