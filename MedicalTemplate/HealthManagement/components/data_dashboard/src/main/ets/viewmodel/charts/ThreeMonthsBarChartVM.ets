/**
 * 三个月步数柱状图 ViewModel
 */
import {
  AxisBase,
  BarChartModel,
  BarData,
  BarDataSet,
  BarEntry,
  ColorTemplate,
  Description,
  EntryOhos,
  Highlight,
  IAxisValueFormatter,
  IBarDataSet,
  JArrayList,
  Legend,
  MarkerView,
  OnChartValueSelectedListener,
  XAxis,
  XAxisPosition,
  YAxis,
  YAxisLabelPosition
} from '@ohos/mpchart';

// 周标签格式化器（每个月4周）
class WeekFormatter implements IAxisValueFormatter {
  private monthLabels: Array<string> = [];

  constructor(monthLabels: Array<string>) {
    this.monthLabels = monthLabels;
  }

  getFormattedValue(value: number, _axis: AxisBase): string {
    const i = Math.round(value);
    if (i === 3 || i === 7 || i === 11) {
      const monthIndex = Math.floor((i - 3) / 4);
      if (monthIndex >= 0 && monthIndex < this.monthLabels.length) {
        return this.monthLabels[monthIndex];
      }
    }
    return '';
  }
}


class ThreeMonthsMarkerView extends MarkerView {
  private steps: number = 0;
  private dateRange: string = '';
  private chartWidth: number = 0;

  constructor() {
    super();
  }

  setChartWidth(width: number): void {
    this.chartWidth = width;
  }

  refreshContent(entry: BarEntry, _highlight: Highlight): void {
    if (entry) {
      this.steps = Math.round(entry.getY());
      const xPos = entry.getX();
      const index = Math.round(xPos) - 1; // 转换为0-based索引

      // 根据索引生成日期范围
      this.dateRange = this.generateDateRangeFromIndex(index);
    }
  }

  // 根据索引生成日期范围
  private generateDateRangeFromIndex(index: number): string {
    // 假设数据从2月1日开始，每个数据点代表一周
    // 索引0-3: 2月, 索引4-7: 3月, 索引8-11: 4月
    const startMonth = 2; // 2月
    const startDay = 1;

    // 计算当前索引对应的起始日期
    let currentDay = startDay + (index * 7); // 每周7天
    let currentMonth = startMonth;

    // 处理月份边界
    const daysInMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    while (currentDay > daysInMonth[currentMonth - 1]) {
      currentDay -= daysInMonth[currentMonth - 1];
      currentMonth += 1;
      if (currentMonth > 12) {
        currentMonth = 1;
      }
    }

    // 计算结束日期（7天后）
    let endMonth = currentMonth;
    let endDay = currentDay + 6;

    while (endDay > daysInMonth[endMonth - 1]) {
      endDay -= daysInMonth[endMonth - 1];
      endMonth += 1;
      if (endMonth > 12) {
        endMonth = 1;
      }
    }

    // 格式化日期范围
    if (currentMonth === endMonth) {
      return `${currentMonth}月${currentDay}日～${endDay}日`;
    } else {
      return `${currentMonth}月${currentDay}日～${endMonth}月${endDay}日`;
    }
  }

  draw(c: CanvasRenderingContext2D, posX: number, _posY: number, e: BarEntry, highlight: Highlight): void {
    this.refreshContent(e, highlight);

    c.save();

    // 第一行：月份和日期范围
    const dateRangeText = this.dateRange || '3月12日～3月18日';
    c.font = '10vp sans-serif';
    const dateMetrics = c.measureText(dateRangeText);

    // 第二行：步数
    const stepsNumText = `${this.steps}`;
    const stepUnitText = '步';
    c.font = 'bold 28vp sans-serif';
    const stepsNumMetrics = c.measureText(stepsNumText);
    c.font = '14vp sans-serif';
    const stepUnitMetrics = c.measureText(stepUnitText);

    const padding = 10;
    const paddingLeft = 12;
    const dateLineHeight = 14;
    const stepsLineHeight = 32;
    const totalStepsWidth = stepsNumMetrics.width + stepUnitMetrics.width + 2;
    const maxWidth = Math.max(dateMetrics.width, totalStepsWidth);
    const boxWidth = maxWidth + paddingLeft * 2;
    const boxHeight = dateLineHeight + stepsLineHeight + padding * 2;
    const radius = 8;

    let leftX: number = posX - boxWidth / 2;
    const topY: number = 10;
    const chartWidth = this.chartWidth > 0 ? this.chartWidth : (posX + boxWidth + 20);
    const rightBoundary = chartWidth - 10;
    // 边界检查
    if (leftX < 10) {
      leftX = 10;
    }

    // 边界检查
    if (leftX + boxWidth > rightBoundary) {
      leftX = rightBoundary - boxWidth;
      if (leftX < 10) {
        leftX = 10;
      }
    }

    // 绘制圆角矩形背景
    c.fillStyle = 'rgba(0, 0, 0, 0.8)';
    c.beginPath();
    c.moveTo(leftX + radius, topY);
    c.lineTo(leftX + boxWidth - radius, topY);
    c.arcTo(leftX + boxWidth, topY, leftX + boxWidth, topY + radius, radius);
    c.lineTo(leftX + boxWidth, topY + boxHeight - radius);
    c.arcTo(leftX + boxWidth, topY + boxHeight, leftX + boxWidth - radius, topY + boxHeight, radius);
    c.lineTo(leftX + radius, topY + boxHeight);
    c.arcTo(leftX, topY + boxHeight, leftX, topY + boxHeight - radius, radius);
    c.lineTo(leftX, topY + radius);
    c.arcTo(leftX, topY, leftX + radius, topY, radius);
    c.closePath();
    c.fill();

    // 绘制文本
    c.textBaseline = 'alphabetic';
    c.textAlign = 'left';
    c.fillStyle = '#FFFFFF';

    // 绘制日期范围
    c.font = '10vp sans-serif';
    c.fillText(dateRangeText, leftX + paddingLeft, topY + padding + 10);

    // 绘制步数
    const stepsY = topY + padding + 10 + dateLineHeight + 18;
    c.font = 'bold 28vp sans-serif';
    c.fillText(stepsNumText, leftX + paddingLeft, stepsY);
    c.font = '14vp sans-serif';
    c.fillText(stepUnitText, leftX + paddingLeft + stepsNumMetrics.width + 4, stepsY);
    c.restore();
  }
}


@ObservedV2
export class ThreeMonthsBarChartVM implements OnChartValueSelectedListener {
  @Trace chartModel: BarChartModel | undefined = undefined;
  @Trace threeMonthsSteps: number[] = [];
  @Trace monthLabels: string[] = [];
  private marker: ThreeMonthsMarkerView | null = null;
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
    this.marker = new ThreeMonthsMarkerView();
    this.chartModel.setMarker(this.marker);

    let stepThreeMonthsXAxis: XAxis | null = this.chartModel.getXAxis();
    if (stepThreeMonthsXAxis) {
      stepThreeMonthsXAxis.setPosition(XAxisPosition.BOTTOM);
      stepThreeMonthsXAxis.setGranularity(1);
      stepThreeMonthsXAxis.setAxisMinimum(0.5);
      stepThreeMonthsXAxis.setAxisMaximum(12.5);
      stepThreeMonthsXAxis.setLabelCount(12, false);
      stepThreeMonthsXAxis.setValueFormatter(new WeekFormatter(this.monthLabels));
      stepThreeMonthsXAxis.setDrawGridLines(false);
      stepThreeMonthsXAxis.setTextColor(ColorTemplate.colorRgb(150, 150, 150));
    }

    let stepThreeMonthsLeftAxis: YAxis | null = this.chartModel.getAxisLeft();
    if (stepThreeMonthsLeftAxis) {
      stepThreeMonthsLeftAxis.setEnabled(false);
    }
    let stepThreeMonthsRightAxis: YAxis | null = this.chartModel.getAxisRight();
    if (stepThreeMonthsRightAxis) {
      stepThreeMonthsRightAxis.setAxisMinimum(0);
      stepThreeMonthsRightAxis.setAxisMaximum(10000);
      stepThreeMonthsRightAxis.setLabelCount(6, false);
      stepThreeMonthsRightAxis.setPosition(YAxisLabelPosition.OUTSIDE_CHART);
      stepThreeMonthsRightAxis.setTextColor(ColorTemplate.colorRgb(150, 150, 150));
    }
  }

  public setOnValueSelectedListener(callback: (date: string, steps: number) => void): void {
    this.onValueSelectedCallback = callback;
  }

  public onValueSelected(e: EntryOhos, _h: Highlight): void {
    const xPos = e.getX();
    const index = Math.round(xPos) - 1; // 转换为0-based索引
    const dateRange = this.generateDateRangeFromIndex(index);
    const steps = Math.round(e.getY());
    if (this.onValueSelectedCallback) {
      this.onValueSelectedCallback(dateRange, steps);
    }
  }

  public onNothingSelected(): void {
  }

  // 根据索引生成日期范围
  private generateDateRangeFromIndex(index: number): string {
    // 假设数据从2月1日开始，每个数据点代表一周
    // 索引0-3: 2月, 索引4-7: 3月, 索引8-11: 4月
    const startMonth = 2; // 2月
    const startDay = 1;

    // 计算当前索引对应的起始日期
    let currentMonth = startMonth;
    let currentDay = startDay + (index * 7); // 每周7天

    // 处理月份边界
    const daysInMonthMax = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    while (currentDay > daysInMonthMax[currentMonth - 1]) {
      currentDay -= daysInMonthMax[currentMonth - 1];
      currentMonth += 1;
      if (currentMonth > 12) {
        currentMonth = 1;
      }
    }

    // 计算结束日期（7天后）
    let endMonth = currentMonth;
    let endDay = currentDay + 6;

    while (endDay > daysInMonthMax[endMonth - 1]) {
      endDay -= daysInMonthMax[endMonth - 1];
      endMonth += 1;
      if (endMonth > 12) {
        endMonth = 1;
      }
    }

    // 格式化日期范围
    if (currentMonth === endMonth) {
      return `${currentMonth}月${currentDay}日～${endDay}日`;
    } else {
      return `${currentMonth}月${currentDay}日～${endMonth}月${endDay}日`;
    }
  }

  public updateThreeMonthsSteps(steps: number[]): void {
    this.threeMonthsSteps = steps.slice();
    this.updateChartData();
  }

  public updateMonthLabels(labels: string[]): void {
    this.monthLabels = labels.filter(label => label && label.trim() !== '');
    if (this.chartModel) {
      let stepThreeMonthsUpdateXAxis: XAxis | null = this.chartModel.getXAxis();
      if (stepThreeMonthsUpdateXAxis) {
        stepThreeMonthsUpdateXAxis.setAxisMinimum(0.5);
        stepThreeMonthsUpdateXAxis.setAxisMaximum(12.5);
        stepThreeMonthsUpdateXAxis.setLabelCount(12, false);
        stepThreeMonthsUpdateXAxis.setValueFormatter(new WeekFormatter(this.monthLabels));
      }
    }
    this.updateChartData();
  }

  private updateChartData(): void {
    if (!this.chartModel) {
      return;
    }

    if (!this.threeMonthsSteps || this.threeMonthsSteps.length === 0) {
      return;
    }

    const stepsCount = Math.min(this.threeMonthsSteps.length, 12);

    let stepThreeMonthsValues: JArrayList<BarEntry> = new JArrayList<BarEntry>();
    for (let i = 0; i < stepsCount; i++) {
      stepThreeMonthsValues.add(new BarEntry(i + 1, this.threeMonthsSteps[i]));
    }

    let stepThreeMonthsDataSet: BarDataSet = new BarDataSet(stepThreeMonthsValues, '');
    stepThreeMonthsDataSet.setDrawValues(false);
    stepThreeMonthsDataSet.setColorByColor(0x802B69FF);
    stepThreeMonthsDataSet.setHighLightColor(ColorTemplate.colorRgb(43, 105, 255));

    let stepThreeMonthsDataSets: JArrayList<IBarDataSet> = new JArrayList<IBarDataSet>();
    stepThreeMonthsDataSets.add(stepThreeMonthsDataSet);
    let stepThreeMonthsData: BarData = new BarData(stepThreeMonthsDataSets);
    stepThreeMonthsData.setDrawValues(false);
    stepThreeMonthsData.setBarWidth(0.25);

    this.chartModel.setData(stepThreeMonthsData);
    this.chartModel.setVisibleXRangeMaximum(12);
    this.chartModel.notifyDataSetChanged();
    this.chartModel.invalidate();
  }
}
