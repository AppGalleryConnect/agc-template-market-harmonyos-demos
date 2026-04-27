/**
 * 周度步数柱状图 ViewModel
 */
import {
  AxisBase,
  BarChartModel,
  BarData,
  BarDataSet,
  BarEntry,
  Description,
  IAxisValueFormatter,
  IBarDataSet,
  JArrayList,
  Legend,
  XAxis,
  XAxisPosition,
  YAxis,
  YAxisLabelPosition,
  MarkerView,
  Highlight,
  ColorTemplate,
  OnChartValueSelectedListener,
  EntryOhos
} from '@ohos/mpchart';

class WeekdayFormatter implements IAxisValueFormatter {
  private labels: Array<string> = ['', '周日', '周一', '周二', '周三', '周四', '周五', '周六'];

  getFormattedValue(value: number, _axis: AxisBase): string {
    const i = Math.round(value);
    if (i >= 1 && i <= 7) {
      return this.labels[i];
    }
    return '';
  }
}

class StepsMarkerView extends MarkerView {
  private steps: number = 0;
  private date: string = '';

  refreshContent(entry: BarEntry, _highlight: Highlight): void {
    if (entry) {
      this.steps = Math.round(entry.getY());
      const index = Math.round(entry.getX());
      const weekdays = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
      if (index >= 1 && index <= 7) {
        this.date = weekdays[index - 1];
      }
    }
  }

  draw(c: CanvasRenderingContext2D, posX: number, _posY: number, e: BarEntry, highlight: Highlight): void {
    this.refreshContent(e, highlight);

    c.save();

    // 测量文本尺寸
    const stepsNumText = `${this.steps}`;
    const stepUnitText = '步';
    c.font = 'bold 28vp sans-serif';
    const stepsNumMetrics = c.measureText(stepsNumText);
    c.font = '14vp sans-serif';
    const stepUnitMetrics = c.measureText(stepUnitText);
    c.font = '10vp sans-serif';
    const dateMetrics = c.measureText(this.date);

    const padding = 10;
    const paddingLeft = 12;
    const dateLineHeight = 14;
    const stepsLineHeight = 32;
    const totalStepsWidth = stepsNumMetrics.width + stepUnitMetrics.width + 2;
    const maxWidth = Math.max(dateMetrics.width, totalStepsWidth);
    const boxWidth = maxWidth + paddingLeft * 2;
    const boxHeight = dateLineHeight + stepsLineHeight + padding * 2;
    const radius = 8;

    const top: number = 10;

    let left: number = posX - boxWidth / 2;

    // 边界检查
    if (left < 10) {
      left = 10;
    }

    const popupRight = left + boxWidth;
    const estimatedMaxX = posX + 50;

    if (popupRight > estimatedMaxX) {
      left = posX - boxWidth + 10;
      if (left < 10) {
        left = 10;
      }
    }

    // 绘制圆角矩形背景
    c.fillStyle = 'rgba(0, 0, 0, 0.8)';
    c.beginPath();
    c.moveTo(left + radius, top);
    c.lineTo(left + boxWidth - radius, top);
    c.arcTo(left + boxWidth, top, left + boxWidth, top + radius, radius);
    c.lineTo(left + boxWidth, top + boxHeight - radius);
    c.arcTo(left + boxWidth, top + boxHeight, left + boxWidth - radius, top + boxHeight, radius);
    c.lineTo(left + radius, top + boxHeight);
    c.arcTo(left, top + boxHeight, left, top + boxHeight - radius, radius);
    c.lineTo(left, top + radius);
    c.arcTo(left, top, left + radius, top, radius);
    c.closePath();
    c.fill();

    // 绘制文本
    c.fillStyle = '#FFFFFF';

    // 绘制日期
    c.textAlign = 'left';
    c.textBaseline = 'alphabetic';
    c.font = '10vp sans-serif';
    c.fillText(this.date, left + paddingLeft, top + padding + 10);

    // 绘制步数
    const stepsY = top + padding + 10 + dateLineHeight + 18;

    // 数字部分
    c.font = 'bold 28vp sans-serif';
    c.fillText(stepsNumText, left + paddingLeft, stepsY);
    c.font = '14vp sans-serif';
    c.fillText(stepUnitText, left + paddingLeft + stepsNumMetrics.width + 4, stepsY);

    c.restore();
  }
}

@ObservedV2
export class WeeklyBarChartVM implements OnChartValueSelectedListener {
  @Trace chartModel: BarChartModel | undefined = undefined;
  @Trace weeklySteps: number[] = [1800, 6000, 2700, 900, 7500, 2500, 4600];
  @Trace dateLabels: string[] = [];
  private onValueSelectedCallback: ((date: string, steps: number) => void) | undefined;

  public async initializeChart(): Promise<void> {
    this.chartModel = new BarChartModel();
    this.chartModel.setOnChartValueSelectedListener(this);
    let description: Description | null = this.chartModel.getDescription();
    if (description) {
      description.setEnabled(false);
    }
    let legend: Legend | null = this.chartModel.getLegend();
    if (legend) {
      legend.setEnabled(false);
    }
    this.chartModel.setDragEnabled(false);
    this.chartModel.setScaleEnabled(false);
    this.chartModel.setPinchZoom(false);
    this.chartModel.setDrawGridBackground(false);
    this.chartModel.setDrawValueAboveBar(false);
    this.chartModel.setHighlightPerTapEnabled(true);
    this.chartModel.setHighlightPerDragEnabled(false);

    // 设置自定义 Marker
    const marker = new StepsMarkerView();
    this.chartModel.setMarker(marker);

    let stepWeeklyXAxis: XAxis | null = this.chartModel.getXAxis();
    if (stepWeeklyXAxis) {
      stepWeeklyXAxis.setPosition(XAxisPosition.BOTTOM);
      stepWeeklyXAxis.setGranularity(1);
      stepWeeklyXAxis.setLabelCount(7);
      stepWeeklyXAxis.setValueFormatter(new WeekdayFormatter());
      stepWeeklyXAxis.setDrawGridLines(false);
      stepWeeklyXAxis.setTextColor(ColorTemplate.colorRgb(150, 150, 150));
    }

    let stepWeeklyLeftAxis: YAxis | null = this.chartModel.getAxisLeft();
    if (stepWeeklyLeftAxis) {
      stepWeeklyLeftAxis.setAxisMinimum(0);
      // 根据数据动态设置Y轴最大值
      const maxSteps = Math.max(...this.weeklySteps);
      const yMax = Math.ceil(maxSteps * 1.2 / 1000) * 1000;
      stepWeeklyLeftAxis.setAxisMaximum(yMax);
      stepWeeklyLeftAxis.setLabelCount(6, false);
      stepWeeklyLeftAxis.setPosition(YAxisLabelPosition.OUTSIDE_CHART);
      stepWeeklyLeftAxis.setTextColor(ColorTemplate.colorRgb(150, 150, 150));
    }
    let stepWeeklyRightAxis: YAxis | null = this.chartModel.getAxisRight();
    if (stepWeeklyRightAxis) {
      stepWeeklyRightAxis.setEnabled(false);
    }

    this.updateChartData();
  }

  public setOnValueSelectedListener(callback: (date: string, steps: number) => void): void {
    this.onValueSelectedCallback = callback;
  }

  public onValueSelected(e: EntryOhos, _h: Highlight): void {
    const index = Math.round(e.getX());
    const labelIndex = index - 1;
    if (labelIndex >= 0 && labelIndex < this.dateLabels.length) {
      const baseDate = this.dateLabels[labelIndex];
      const weekdays = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
      const weekday = weekdays[labelIndex];
      const date = `${baseDate}(${weekday})`;
      const steps = Math.round(e.getY());
      if (this.onValueSelectedCallback) {
        this.onValueSelectedCallback(date, steps);
      }
    }
  }

  public onNothingSelected(): void {
    // Optional: Reset to default?
  }

  public updateWeeklySteps(steps: number[]): void {
    this.weeklySteps = steps.slice();
    this.updateChartData();
  }

  public updateDateLabels(labels: string[]): void {
    this.dateLabels = labels.slice();
  }

  private updateChartData(): void {
    if (!this.chartModel) {
      return;
    }

    let stepWeeklyValues: JArrayList<BarEntry> = new JArrayList<BarEntry>();
    for (let i = 0; i < this.weeklySteps.length; i++) {
      stepWeeklyValues.add(new BarEntry(i + 1, this.weeklySteps[i]));
    }

    let stepWeeklyDataSet: BarDataSet = new BarDataSet(stepWeeklyValues, '');
    stepWeeklyDataSet.setDrawValues(false);
    stepWeeklyDataSet.setColorByColor(0x802B69FF);
    stepWeeklyDataSet.setHighLightColor(ColorTemplate.colorRgb(43, 105, 255));

    let stepWeeklyDataSets: JArrayList<IBarDataSet> = new JArrayList<IBarDataSet>();
    stepWeeklyDataSets.add(stepWeeklyDataSet);
    let stepWeeklyData: BarData = new BarData(stepWeeklyDataSets);
    stepWeeklyData.setDrawValues(false);
    stepWeeklyData.setBarWidth(0.15);

    this.chartModel.setData(stepWeeklyData);
    this.chartModel.setVisibleXRangeMaximum(7);
    this.chartModel.invalidate();
  }
}

