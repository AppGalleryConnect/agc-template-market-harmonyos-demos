/**
 * 三个月睡眠堆叠柱状图 ViewModel
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
  LimitLabelPosition,
  LimitLine,
  XAxis,
  XAxisPosition,
  YAxis,
  YAxisLabelPosition,
  OnChartValueSelectedListener,
  EntryOhos,
  Highlight
} from '@ohos/mpchart';

class MonthFormatter implements IAxisValueFormatter {
  private monthLabels: Array<string> = [];

  constructor(labels: Array<string>) {
    this.monthLabels = labels;
  }

  getFormattedValue(value: number, _axis: AxisBase): string {
    const index = Math.round(value);
    if (index >= 0 && index < this.monthLabels.length) {
      return this.monthLabels[index];
    }
    return '';
  }
}

@ObservedV2
export class ThreeMonthsSleepChartVM implements OnChartValueSelectedListener {
  @Trace chartModel: BarChartModel | undefined = undefined;
  @Trace sleepData: [number, number, number, number][] = [];
  @Trace labels: string[] = [];
  @Trace groupSizes: number[] = [];
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
    this.chartModel.setDragEnabled(false);
    this.chartModel.setScaleEnabled(false);
    this.chartModel.setHighlightPerTapEnabled(true);
    this.chartModel.setHighlightPerDragEnabled(false);
    this.chartModel.setOnChartValueSelectedListener(this);

    let sleepThreeMonthsXAxis: XAxis | null = this.chartModel.getXAxis();
    if (sleepThreeMonthsXAxis) {
      sleepThreeMonthsXAxis.setPosition(XAxisPosition.BOTTOM);
      sleepThreeMonthsXAxis.setGranularity(1);
      sleepThreeMonthsXAxis.setGranularityEnabled(true);
      sleepThreeMonthsXAxis.setDrawGridLines(false);
      sleepThreeMonthsXAxis.setTextColor(ColorTemplate.colorRgb(126, 126, 126));
      sleepThreeMonthsXAxis.setAxisMinimum(-0.5);
      sleepThreeMonthsXAxis.setAxisMaximum(2.5);
      sleepThreeMonthsXAxis.setLabelCount(3, false);
      sleepThreeMonthsXAxis.setYOffset(10);
    }

    let sleepThreeMonthsLeftAxis: YAxis | null = this.chartModel.getAxisLeft();
    if (sleepThreeMonthsLeftAxis) {
      sleepThreeMonthsLeftAxis.setAxisMinimum(0);
      sleepThreeMonthsLeftAxis.setAxisMaximum(12);
      sleepThreeMonthsLeftAxis.setLabelCount(5, false);
      sleepThreeMonthsLeftAxis.setPosition(YAxisLabelPosition.OUTSIDE_CHART);
      sleepThreeMonthsLeftAxis.setGridColor(ColorTemplate.colorRgb(230, 230, 230));
      sleepThreeMonthsLeftAxis.setGridLineWidth(0.8);
      sleepThreeMonthsLeftAxis.setTextColor(ColorTemplate.colorRgb(126, 126, 126));
    }

    let sleepThreeMonthsRightAxis: YAxis | null = this.chartModel.getAxisRight();
    if (sleepThreeMonthsRightAxis) {
      sleepThreeMonthsRightAxis.setEnabled(false);
    }

    this.chartModel.setExtraOffsets(0, 15, 15, 0);

    // 添加月份分隔线
    this.addMonthSeparators();

    this.updateChartData();
  }

  public updateSleepData(data: [number, number, number, number][]): void {
    this.sleepData = data.slice();
    this.updateChartData();
  }

  public updateLabels(labels: string[]): void {
    this.labels = labels.slice();
    this.updateChartData();
  }

  public updateGroupSizes(sizes: number[]): void {
    this.groupSizes = sizes.slice();
    this.updateChartData();
  }

  private addMonthSeparators(): void {
    // 在X轴的0.5和1.5位置添加分隔线
    if (!this.chartModel) {
      return;
    }

    let xAxis: XAxis | null = this.chartModel.getXAxis();
    if (xAxis) {
      let separator1: LimitLine = new LimitLine(0.5);
      separator1.setLineColor(ColorTemplate.colorRgb(220, 220, 220));
      separator1.setLineWidth(1.5);
      separator1.enableDashedLine(5, 5, 0);
      separator1.setLabelPosition(LimitLabelPosition.RIGHT_BOTTOM);
      separator1.setLabel('');
      xAxis.addLimitLine(separator1);

      // 添加第二条分隔线（3月和4月之间）
      let separator2: LimitLine = new LimitLine(1.5);
      separator2.setLineColor(ColorTemplate.colorRgb(220, 220, 220));
      separator2.setLineWidth(1.5);
      separator2.enableDashedLine(5, 5, 0);
      separator2.setLabelPosition(LimitLabelPosition.RIGHT_BOTTOM);
      separator2.setLabel('');
      xAxis.addLimitLine(separator2);

      // 启用LimitLine绘制
      xAxis.setDrawLimitLinesBehindData(true);
    }
  }

  private updateChartData(): void {
    if (!this.chartModel || !this.sleepData || this.sleepData.length === 0) {
      return;
    }

    let sleepThreeMonthsUpdateXAxis: XAxis | null = this.chartModel.getXAxis();
    if (sleepThreeMonthsUpdateXAxis) {
      sleepThreeMonthsUpdateXAxis.setValueFormatter(new MonthFormatter(this.labels));
    }

    let sleepThreeMonthsValues: JArrayList<BarEntry> = new JArrayList<BarEntry>();


    if (this.groupSizes && this.groupSizes.length > 0) {
      const groupCenters = [0, 1, 2];
      const offsets = [-0.3, -0.1, 0.1, 0.3];
      let dataIdx = 0;

      for (let g = 0; g < this.groupSizes.length; g++) {
        const groupSize = this.groupSizes[g];
        const groupCenter = groupCenters[g];

        for (let b = 0; b < groupSize && dataIdx < this.sleepData.length; b++) {
          let xPosition = groupCenter;
          if (groupSize > 1 && offsets[b] !== undefined) {
            xPosition += offsets[b];
          }

          const data = this.sleepData[dataIdx];
          sleepThreeMonthsValues.add(new BarEntry(xPosition, [data[0], data[1], data[2], data[3]]));
          dataIdx++;
        }
      }
    } else {
      for (let i = 0; i < this.sleepData.length; i++) {
        const data = this.sleepData[i];
        sleepThreeMonthsValues.add(new BarEntry(i, [data[0], data[1], data[2], data[3]]));
      }
    }

    let sleepThreeMonthsSet: BarDataSet = new BarDataSet(sleepThreeMonthsValues, '');
    sleepThreeMonthsSet.setDrawIcons(false);
    const deepBlue: number = ColorTemplate.colorRgb(0, 90, 255);
    const lightBlue: number = ColorTemplate.colorRgb(80, 170, 255);
    const yellow: number = ColorTemplate.colorRgb(255, 208, 0);
    const orange: number = ColorTemplate.colorRgb(255, 160, 0);
    sleepThreeMonthsSet.setColorsByArr([deepBlue, lightBlue, yellow, orange]);
    sleepThreeMonthsSet.setStackLabels(['深睡', '浅睡', '快速眼动', '清醒']);
    sleepThreeMonthsSet.setDrawValues(false);

    let sleepThreeMonthsDataSets: JArrayList<IBarDataSet> = new JArrayList<IBarDataSet>();
    sleepThreeMonthsDataSets.add(sleepThreeMonthsSet);
    let sleepThreeMonthsData: BarData = new BarData(sleepThreeMonthsDataSets);
    sleepThreeMonthsData.setDrawValues(false);
    sleepThreeMonthsData.setBarWidth(0.10);
    this.chartModel.setData(sleepThreeMonthsData);
    this.chartModel.notifyDataSetChanged();
  }

  public setOnValueSelectedListener(callback: (date: string, totalHours: number, totalMinutes: number) => void): void {
    this.onValueSelectedCallback = callback;
  }

  public onValueSelected(e: EntryOhos, _h: Highlight): void {
    const xValue = e.getX();

    // 1. 确定月份组 (0: 2月, 1: 3月, 2: 4月)
    // 组中心大约在 0, 1, 2 的位置
    const groupIndex = Math.round(xValue);

    // 2. 计算相对于组中心的偏移量
    // 有效范围大约是 [-0.4, 0.4)
    const offset = xValue - groupIndex;

    // 3. 计算组内索引 (0-3)
    // 每个柱子宽度间隔 0.2，起始位置相对于中心是 -0.4
    // [-0.4, -0.2) -> 0
    // [-0.2, 0.0) -> 1
    // [0.0, 0.2) -> 2
    // [0.2, 0.4) -> 3
    // 添加 0.001 避免浮点数精度临界值问题
    const subIndex = Math.floor((offset + 0.4 + 0.001) / 0.2);
    // 验证索引有效性
    if (groupIndex >= 0 && groupIndex <= 2 && subIndex >= 0 && subIndex <= 3) {
      const dataIndex = groupIndex * 4 + subIndex;
      if (dataIndex >= 0 && dataIndex < this.sleepData.length) {
        const sleepDataItem = this.sleepData[dataIndex];

        // 计算一周的总睡眠时间（假设每个柱子代表一周，需要乘以7天）
        const dailyTotalHours = sleepDataItem[0] + sleepDataItem[1] + sleepDataItem[2] + sleepDataItem[3];
        const weeklyTotalHours = dailyTotalHours * 7; // 一周7天的总时长
        const hours = Math.floor(weeklyTotalHours);
        const minutes = Math.round((weeklyTotalHours - hours) * 60);

        // 生成日期范围
        const dateRange = this.generateDateRangeFromIndex(dataIndex);

        if (this.onValueSelectedCallback) {
          this.onValueSelectedCallback(dateRange, hours, minutes);
        }
      }
    }
  }

  public onNothingSelected(): void {
    // Optional: Reset to default?
  }

  private generateDateRangeFromIndex(index: number): string {
    // 直接为每个索引定义对应的周期范围
    const weekRanges = [
      '2月01日-07日', '2月08日-14日', '2月15日-21日', '2月22日-28日',
      '3月01日-07日', '3月08日-14日', '3月15日-21日', '3月22日-31日',
      '4月01日-07日', '4月08日-14日', '4月15日-21日', '4月22日-30日'
    ];

    if (index >= 0 && index < weekRanges.length) {
      return weekRanges[index];
    }

    // 备用方式
    return `${Math.floor(index / 4) + 2}月01日-07日`;
  }
}
