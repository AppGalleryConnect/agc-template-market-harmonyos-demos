/**
 * 周度睡眠图表 ViewModel
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

class WeekdayFormatter implements IAxisValueFormatter {
  private labels: Array<string> = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];

  getFormattedValue(value: number, _axis: AxisBase): string {
    const i = Math.round(value);
    if (i >= 0 && i < this.labels.length) {
      return this.labels[i];
    }
    return '';
  }
}

@ObservedV2
export class WeeklySleepChartVM implements OnChartValueSelectedListener {
  @Trace chartModel: BarChartModel | undefined = undefined;
  @Trace sleepData: Array<[number, number, number, number]> = [];
  @Trace dateLabels: string[] = [];
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

    let sleepWeeklyXAxis: XAxis | null = this.chartModel.getXAxis();
    if (sleepWeeklyXAxis) {
      sleepWeeklyXAxis.setPosition(XAxisPosition.BOTTOM);
      sleepWeeklyXAxis.setGranularity(1);
      sleepWeeklyXAxis.setGranularityEnabled(true);
      sleepWeeklyXAxis.setAxisMinimum(-0.5);
      sleepWeeklyXAxis.setAxisMaximum(6.5);
      sleepWeeklyXAxis.setLabelCount(7, false);
      sleepWeeklyXAxis.setValueFormatter(new WeekdayFormatter());
      sleepWeeklyXAxis.setDrawGridLines(false);
      sleepWeeklyXAxis.setTextColor(ColorTemplate.colorRgb(150, 150, 150));
      sleepWeeklyXAxis.setYOffset(10);
    }

    let sleepWeeklyLeftAxis: YAxis | null = this.chartModel.getAxisLeft();
    if (sleepWeeklyLeftAxis) {
      sleepWeeklyLeftAxis.setAxisMinimum(0);
      sleepWeeklyLeftAxis.setAxisMaximum(12);
      sleepWeeklyLeftAxis.setLabelCount(5, false);
      sleepWeeklyLeftAxis.setPosition(YAxisLabelPosition.OUTSIDE_CHART);
      sleepWeeklyLeftAxis.setGridColor(ColorTemplate.colorRgb(240, 240, 240));
      sleepWeeklyLeftAxis.setGridLineWidth(0.8);
      sleepWeeklyLeftAxis.setTextColor(ColorTemplate.colorRgb(150, 150, 150));
    }

    let sleepWeeklyRightAxis: YAxis | null = this.chartModel.getAxisRight();
    if (sleepWeeklyRightAxis) {
      sleepWeeklyRightAxis.setEnabled(false);
    }

    this.chartModel.setExtraOffsets(0, 15, 15, 0);
    this.updateChartData();
  }

  public updateSleepData(data: Array<[number, number, number, number]>): void {
    this.sleepData = data.map(item => [item[0], item[1], item[2], item[3]]);
    this.updateChartData();
  }

  private updateChartData(): void {
    if (!this.chartModel || !this.sleepData || this.sleepData.length === 0) {
      return;
    }

    let sleepWeeklyValues: JArrayList<BarEntry> = new JArrayList<BarEntry>();
    for (let i = 0; i < this.sleepData.length; i++) {
      const data = this.sleepData[i];
      sleepWeeklyValues.add(new BarEntry(i, [data[0], data[1], data[2], data[3]]));
    }

    let sleepWeeklySet: BarDataSet = new BarDataSet(sleepWeeklyValues, '');
    sleepWeeklySet.setDrawIcons(false);
    const deepBlue: number = ColorTemplate.colorRgb(0, 90, 255);
    const lightBlue: number = ColorTemplate.colorRgb(80, 170, 255);
    const yellow: number = ColorTemplate.colorRgb(255, 208, 0);
    const orange: number = ColorTemplate.colorRgb(255, 160, 0);
    sleepWeeklySet.setColorsByArr([deepBlue, lightBlue, yellow, orange]);
    sleepWeeklySet.setStackLabels(['深睡', '浅睡', '快速眼动', '清醒']);
    sleepWeeklySet.setDrawValues(false);

    let sleepWeeklyDataSets: JArrayList<IBarDataSet> = new JArrayList<IBarDataSet>();
    sleepWeeklyDataSets.add(sleepWeeklySet);
    let sleepWeeklyData: BarData = new BarData(sleepWeeklyDataSets);
    sleepWeeklyData.setDrawValues(false);
    sleepWeeklyData.setBarWidth(0.35);
    this.chartModel.setData(sleepWeeklyData);
    this.chartModel.notifyDataSetChanged();
  }

  public setOnValueSelectedListener(callback: (date: string, totalHours: number, totalMinutes: number) => void): void {
    this.onValueSelectedCallback = callback;
  }

  public updateDateLabels(labels: string[]): void {
    this.dateLabels = labels.slice();
  }

  public onValueSelected(e: EntryOhos, _h: Highlight): void {
    const index = Math.round(e.getX());
    if (index >= 0 && index < this.sleepData.length && index < this.dateLabels.length) {
      const sleepDataItem = this.sleepData[index];
      const baseDate = this.dateLabels[index];

      // 计算总睡眠时间（深睡+浅睡+快速眼动+清醒）
      const totalSleepHours = sleepDataItem[0] + sleepDataItem[1] + sleepDataItem[2] + sleepDataItem[3];
      const hours = Math.floor(totalSleepHours);
      const minutes = Math.round((totalSleepHours - hours) * 60);

      // 添加星期几信息
      const weekdays = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
      const weekday = weekdays[index];
      const date = `${baseDate}(${weekday})`;

      if (this.onValueSelectedCallback) {
        this.onValueSelectedCallback(date, hours, minutes);
      }
    }
  }

  public onNothingSelected(): void {
    // Optional: Reset to default?
  }
}

