/**
 * 月度步数柱状图 ViewModel
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

class DateFormatter implements IAxisValueFormatter {
  private labels: Array<string> = [];

  constructor(labels: Array<string>) {
    this.labels = labels;
  }

  getFormattedValue(value: number, _axis: AxisBase): string {
    // value对应数据点的X位置，从0开始
    const i = Math.round(value);
    if (i >= 0 && i < this.labels.length) {
      // 如果有标签就返回标签
      if (this.labels[i] && this.labels[i].trim() !== '') {
        return this.labels[i];
      }
      // 如果没有标签，根据索引生成日期
      const day = i + 1;
      if (day <= 30) { // 4月有30天
        return `4/${day}`;
      }
    }
    return '';
  }
}

class MonthlyMarkerView extends MarkerView {
  private steps: number = 0;
  private date: string = '';
  private dateLabels: Array<string> = [];
  private chartWidth: number = 0;

  constructor(dateLabels: Array<string>) {
    super();
    this.dateLabels = dateLabels;
  }

  setChartWidth(width: number): void {
    this.chartWidth = width;
  }

  setDateLabels(dateLabels: Array<string>): void {
    this.dateLabels = dateLabels;
  }

  refreshContent(entry: BarEntry, _highlight: Highlight): void {
    if (entry) {
      this.steps = Math.round(entry.getY());
      const index = Math.round(entry.getX());
      if (index >= 0 && index < this.dateLabels.length) {
        const label = this.dateLabels[index];
        // 优先使用dateLabels中的标签
        if (label && label.trim() !== '') {
          this.date = label;
        } else {
          // 根据已有标签推算日期
          this.date = this.generateDateFromIndex(index);
        }
      } else {
        this.date = '';
      }
    }
  }

  // 根据索引生成日期
  private generateDateFromIndex(index: number): string {
    // 找到距离目标索引最近的已知日期（向前查找）
    let baseDate = '';
    let baseIndex = -1;

    // 从目标索引向前查找最近的有效日期
    for (let i = index; i >= 0; i--) {
      if (i < this.dateLabels.length && this.dateLabels[i] && this.dateLabels[i].trim() !== '') {
        baseDate = this.dateLabels[i];
        baseIndex = i;
        break;
      }
    }

    // 如果向前没找到，向后查找
    if (baseIndex === -1) {
      for (let i = index + 1; i < this.dateLabels.length; i++) {
        if (this.dateLabels[i] && this.dateLabels[i].trim() !== '') {
          baseDate = this.dateLabels[i];
          baseIndex = i;
          break;
        }
      }
    }

    if (baseIndex === -1 || !baseDate) {
      return `${index + 1}日`;
    }

    // 解析基准日期（格式如 "4/4" 或 "11/15"）
    const parts = baseDate.split('/');
    if (parts.length !== 2) {
      return `${index + 1}日`;
    }

    let month = parseInt(parts[0]);
    let day = parseInt(parts[1]);

    // 计算目标日期
    const dayDiff = index - baseIndex;
    day += dayDiff;

    // 处理月份边界
    const daysInMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    while (day > daysInMonth[month - 1]) {
      day -= daysInMonth[month - 1];
      month += 1;
      if (month > 12) {
        month = 1;
      }
    }
    while (day < 1) {
      month -= 1;
      if (month < 1) {
        month = 12;
      }
      day += daysInMonth[month - 1];
    }

    return `${month}/${day}`;
  }

  draw(c: CanvasRenderingContext2D, posX: number, _posY: number, e: BarEntry, highlight: Highlight): void {
    this.refreshContent(e, highlight);

    c.save();

    const stepsNumText = `${this.steps}`;
    const stepUnitText = '步';
    c.font = 'bold 28vp sans-serif';
    const stepsNumMetrics = c.measureText(stepsNumText);
    c.font = '14vp sans-serif';
    const stepUnitMetrics = c.measureText(stepUnitText);

    let maxWidth = stepsNumMetrics.width + stepUnitMetrics.width + 4;
    let boxHeight = 0;
    const dateLineHeight = 14;
    const stepsLineHeight = 32;

    if (this.date) {
      c.font = '10vp sans-serif';
      const dateMetrics = c.measureText(this.date);
      maxWidth = Math.max(maxWidth, dateMetrics.width);
      boxHeight = dateLineHeight + stepsLineHeight;
    } else {
      boxHeight = stepsLineHeight;
    }

    const padding = 10;
    const paddingLeft = 12;
    const boxWidth = maxWidth + paddingLeft * 2 + 16;
    boxHeight = boxHeight + padding * 2;
    const radius = 8;

    let left: number = posX - boxWidth / 2;
    const top: number = 10;
    const chartWidth = this.chartWidth > 0 ? this.chartWidth : (posX + boxWidth + 40);
    const rightBoundary = chartWidth - 10;

    if (left + boxWidth > rightBoundary) {
      left = rightBoundary - boxWidth;
    }

    if (left < 10) {
      left = 10;
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
    c.textBaseline = 'alphabetic';

    if (this.date) {
      c.textAlign = 'left';
      let textY = top + padding + 10;

      c.font = '10vp sans-serif';
      c.fillText(this.date, left + paddingLeft, textY);
      textY += dateLineHeight + 18;

      c.font = 'bold 28vp sans-serif';
      c.fillText(stepsNumText, left + paddingLeft, textY);

      c.font = '14vp sans-serif';
      c.fillText(stepUnitText, left + paddingLeft + stepsNumMetrics.width + 4, textY);
    } else {
      c.textAlign = 'left';
      const centerX = left + boxWidth / 2;
      const textY = top + boxHeight / 2 + stepsLineHeight / 2 - 4;

      c.font = 'bold 28vp sans-serif';
      const stepsNumMetrics2 = c.measureText(stepsNumText);
      c.font = '14vp sans-serif';
      const stepUnitMetrics2 = c.measureText(stepUnitText);
      const totalTextWidth = stepsNumMetrics2.width + stepUnitMetrics2.width + 4;
      const stepsTextX = centerX - totalTextWidth / 2 + 4;

      c.font = 'bold 28vp sans-serif';
      c.fillText(stepsNumText, stepsTextX, textY);

      c.font = '14vp sans-serif';
      c.fillText(stepUnitText, stepsTextX + stepsNumMetrics2.width + 4, textY);
    }

    c.restore();
  }
}

interface DateParts {
  month: number;
  day: number;
}

@ObservedV2
export class MonthlyBarChartVM implements OnChartValueSelectedListener {
  @Trace chartModel: BarChartModel | undefined = undefined;
  @Trace monthlySteps: number[] = [];
  @Trace dateLabels: string[] = [];
  private tooltipLabels: string[] = []; // 用于tooltip显示的完整日期标签
  private marker: MonthlyMarkerView | null = null;
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
    this.chartModel.setDragEnabled(true); // 启用拖拽滑动
    this.chartModel.setScaleEnabled(false);
    this.chartModel.setPinchZoom(false);
    this.chartModel.setDrawGridBackground(false);
    this.chartModel.setDrawValueAboveBar(false);
    this.chartModel.setHighlightPerTapEnabled(true);
    this.chartModel.setExtraOffsets(10, 20, 20, 5);
    this.chartModel.setHighlightPerDragEnabled(false);

    // 设置自定义 Marker
    this.marker = new MonthlyMarkerView(this.dateLabels);
    this.chartModel.setMarker(this.marker);

    let stepMonthlyXAxis: XAxis | null = this.chartModel.getXAxis();
    if (stepMonthlyXAxis) {
      stepMonthlyXAxis.setPosition(XAxisPosition.BOTTOM);
      stepMonthlyXAxis.setGranularity(1);
      stepMonthlyXAxis.setGranularityEnabled(true);
      stepMonthlyXAxis.setAxisMinimum(-0.5);
      stepMonthlyXAxis.setAxisMaximum(this.dateLabels.length - 0.5);
      stepMonthlyXAxis.setLabelCount(6, true); // 强制只显示6个标签，防止滑动时变化
      stepMonthlyXAxis.setValueFormatter(new DateFormatter(this.dateLabels));
      stepMonthlyXAxis.setDrawGridLines(true);
      stepMonthlyXAxis.setGridColor(ColorTemplate.colorRgb(230, 230, 230));
      stepMonthlyXAxis.setGridLineWidth(0.5);
      stepMonthlyXAxis.setTextColor(ColorTemplate.colorRgb(150, 150, 150));
      // 设置X轴标签与图表的间距
      stepMonthlyXAxis.setYOffset(8);
      // 避免标签重叠
      stepMonthlyXAxis.setAvoidFirstLastClipping(true);

      // 设置可见范围，支持滑动查看完整月份数据
      if (this.dateLabels.length > 10) {
        // 如果数据点超过10个，设置可见范围为12个数据点，支持滑动
        this.chartModel.setVisibleXRangeMaximum(12);
        this.chartModel.setVisibleXRangeMinimum(8);
        // 默认显示前10个数据点（从4/1开始）
        this.chartModel.moveViewToX(-0.5);
      }
    }

    let stepMonthlyLeftAxis: YAxis | null = this.chartModel.getAxisLeft();
    if (stepMonthlyLeftAxis) {
      stepMonthlyLeftAxis.setAxisMinimum(0);
      stepMonthlyLeftAxis.setAxisMaximum(10000);
      stepMonthlyLeftAxis.setLabelCount(6, false);
      stepMonthlyLeftAxis.setPosition(YAxisLabelPosition.OUTSIDE_CHART);
      stepMonthlyLeftAxis.setTextColor(ColorTemplate.colorRgb(150, 150, 150));
      stepMonthlyLeftAxis.setDrawGridLines(true);
      stepMonthlyLeftAxis.setGridColor(ColorTemplate.colorRgb(230, 230, 230));
      stepMonthlyLeftAxis.setGridLineWidth(0.5);
    }
    let stepMonthlyRightAxis: YAxis | null = this.chartModel.getAxisRight();
    if (stepMonthlyRightAxis) {
      stepMonthlyRightAxis.setEnabled(false);
    }

    this.updateChartData();
  }

  public setOnValueSelectedListener(callback: (date: string, steps: number) => void): void {
    this.onValueSelectedCallback = callback;
  }

  public onValueSelected(e: EntryOhos, _h: Highlight): void {
    const xValue = e.getX();
    const dataIndex = Math.round(xValue);

    if (dataIndex >= 0 && dataIndex < this.monthlySteps.length) {
      const steps = this.monthlySteps[dataIndex];

      // 生成日期文本（优先使用dateLabels中的标签，但转换为中文格式）
      let dateText = '';
      if (dataIndex >= 0 && dataIndex < this.dateLabels.length && this.dateLabels[dataIndex] &&
        this.dateLabels[dataIndex].trim() !== '') {
        // 将X轴的"4/5"格式转换为"04月05日"格式
        dateText = this.convertToChineseDate(this.dateLabels[dataIndex]);
      } else if (dataIndex >= 0 && dataIndex < this.tooltipLabels.length) {
        // 使用tooltipLabels中的完整日期，也转换为中文格式
        dateText = this.convertToChineseDate(this.tooltipLabels[dataIndex]);
      } else {
        // 根据索引生成日期
        dateText = this.generateDateFromDataIndex(dataIndex);
      }

      if (this.onValueSelectedCallback) {
        this.onValueSelectedCallback(dateText, steps);
      }
    }
  }

  public onNothingSelected(): void {
  }

  private convertToChineseDate(dateStr: string): string {
    // 将"4/5"格式转换为"04月05日"格式
    const parts = dateStr.split('/');
    if (parts.length === 2) {
      const month = String(parseInt(parts[0])).padStart(2, '0');
      const day = String(parseInt(parts[1])).padStart(2, '0');
      return `${month}月${day}日`;
    }
    return dateStr; // 如果格式不对，返回原字符串
  }

  private generateDateFromDataIndex(index: number): string {
    // 根据完整的4月日期数据，使用中文日期格式
    const dateMapping = [
      '04月01日', '04月02日', '04月03日', '04月04日', '04月05日', // 0-4
      '04月06日', '04月07日', '04月08日', '04月09日', '04月10日', // 5-9
      '04月11日', '04月12日', '04月13日', '04月14日', '04月15日', // 10-14
      '04月16日', '04月17日', '04月18日', '04月19日', '04月20日', // 15-19
      '04月21日', '04月22日', '04月23日', '04月24日', '04月25日', // 20-24
      '04月26日', '04月27日', '04月28日', '04月29日', '04月30日'// 25-29
    ];

    if (index >= 0 && index < dateMapping.length) {
      return dateMapping[index];
    }

    // 如果索引超出范围，生成默认格式
    const day = String(index + 1).padStart(2, '0');
    return `04月${day}日`;
  }

  // 生成完整的日期数组，填充空字符串位置
  private generateTooltipLabels(): void {
    this.tooltipLabels = [];

    // 收集所有非空日期及其索引
    interface DateInfo {
      index: number;
      label: string;
    }

    const nonEmptyDates: DateInfo[] = [];
    for (let i = 0; i < this.dateLabels.length; i++) {
      if (this.dateLabels[i] && this.dateLabels[i].trim() !== '') {
        nonEmptyDates.push({ index: i, label: this.dateLabels[i] });
      }
    }

    // 为每个位置生成日期标签
    for (let i = 0; i < this.dateLabels.length; i++) {
      if (this.dateLabels[i] && this.dateLabels[i].trim() !== '') {
        // 非空位置直接使用原标签
        this.tooltipLabels.push(this.dateLabels[i]);
      } else {
        // 空位置：通过插值计算具体日期
        let prevDate: DateInfo | null = null;
        let nextDate: DateInfo | null = null;

        for (let j = 0; j < nonEmptyDates.length; j++) {
          if (nonEmptyDates[j].index < i) {
            prevDate = nonEmptyDates[j];
          } else if (nonEmptyDates[j].index > i && !nextDate) {
            nextDate = nonEmptyDates[j];
            break;
          }
        }

        // 通过插值计算具体日期
        if (prevDate && nextDate) {
          const calculatedDate = this.interpolateDate(
            prevDate.label,
            nextDate.label,
            i - prevDate.index,
            nextDate.index - prevDate.index
          );
          this.tooltipLabels.push(calculatedDate);
        } else if (prevDate) {
          // 只有前面的日期，向后推算
          const offset = i - prevDate.index;
          const calculatedDate = this.addDaysToDate(prevDate.label, offset);
          this.tooltipLabels.push(calculatedDate);
        } else if (nextDate) {
          // 只有后面的日期，向前推算
          const offset = nextDate.index - i;
          const calculatedDate = this.addDaysToDate(nextDate.label, -offset);
          this.tooltipLabels.push(calculatedDate);
        } else {
          this.tooltipLabels.push('未知');
        }
      }
    }
  }

  // 解析日期字符串（格式：4/1 或 12/4）
  private parseDate(dateStr: string): DateParts | null {
    const parts = dateStr.split('/');
    if (parts.length === 2) {
      const month = parseInt(parts[0]);
      const day = parseInt(parts[1]);
      if (!isNaN(month) && !isNaN(day)) {
        return { month: month, day: day } as DateParts;
      }
    }
    return null;
  }

  // 在两个日期之间插值
  private interpolateDate(startDateStr: string, endDateStr: string, position: number, totalGap: number): string {
    const startDate = this.parseDate(startDateStr);
    const endDate = this.parseDate(endDateStr);

    if (!startDate || !endDate) {
      return startDateStr;
    }

    // 简单处理：计算日期差值并线性插值
    let dayDiff = endDate.day - startDate.day;

    // 如果跨月，需要特殊处理
    if (endDate.month > startDate.month) {
      // 假设每月30天的简化计算
      dayDiff = (endDate.month - startDate.month) * 30 + (endDate.day - startDate.day);
    }

    // 根据位置计算插值天数
    const interpolatedDayDiff = Math.round(dayDiff * position / totalGap);

    // 从起始日期加上插值天数
    let newDay = startDate.day + interpolatedDayDiff;
    let newMonth = startDate.month;

    // 处理月份边界
    const daysInMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    while (newDay > daysInMonth[newMonth - 1]) {
      newDay -= daysInMonth[newMonth - 1];
      newMonth += 1;
      if (newMonth > 12) {
        newMonth = 1;
      }
    }

    return `${newMonth}/${newDay}`;
  }

  // 给日期加上指定天数
  private addDaysToDate(dateStr: string, days: number): string {
    const date = this.parseDate(dateStr);
    if (!date) {
      return dateStr;
    }

    let newDay = date.day + days;
    let newMonth = date.month;

    const daysInMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

    // 处理日期溢出
    while (newDay > daysInMonth[newMonth - 1]) {
      newDay -= daysInMonth[newMonth - 1];
      newMonth += 1;
      if (newMonth > 12) {
        newMonth = 1;
      }
    }

    // 处理日期为负数
    while (newDay < 1) {
      newMonth -= 1;
      if (newMonth < 1) {
        newMonth = 12;
      }
      newDay += daysInMonth[newMonth - 1];
    }

    return `${newMonth}/${newDay}`;
  }


  public updateMonthlySteps(steps: number[]): void {
    this.monthlySteps = steps.slice();
    this.updateChartData();
  }

  public updateDateLabels(labels: string[]): void {
    this.dateLabels = labels.slice();
    this.generateTooltipLabels(); // 生成完整的日期标签
    if (this.marker) {
      this.marker.setDateLabels(this.dateLabels);
    }
    if (this.chartModel) {
      let stepMonthlyUpdateXAxis: XAxis | null = this.chartModel.getXAxis();
      if (stepMonthlyUpdateXAxis) {
        stepMonthlyUpdateXAxis.setAxisMinimum(-0.5);
        stepMonthlyUpdateXAxis.setAxisMaximum(this.dateLabels.length - 0.5);
        stepMonthlyUpdateXAxis.setLabelCount(6, true); // 强制只显示6个标签，防止滑动时变化
        stepMonthlyUpdateXAxis.setValueFormatter(new DateFormatter(this.dateLabels));
        stepMonthlyUpdateXAxis.setDrawGridLines(true);
        stepMonthlyUpdateXAxis.setGridColor(ColorTemplate.colorRgb(230, 230, 230));
        stepMonthlyUpdateXAxis.setGridLineWidth(0.5);
        stepMonthlyUpdateXAxis.setYOffset(8);
        stepMonthlyUpdateXAxis.setAvoidFirstLastClipping(true);

        // 设置可见范围，支持滑动查看完整月份数据
        if (this.dateLabels.length > 10) {
          // 如果数据点超过10个，设置可见范围为12个数据点，支持滑动
          this.chartModel.setVisibleXRangeMaximum(12);
          this.chartModel.setVisibleXRangeMinimum(8);
          // 默认显示前10个数据点（从4/1开始）
          this.chartModel.moveViewToX(-0.5);
        }
      }
    }
    this.updateChartData();
  }

  private updateChartData(): void {
    if (!this.chartModel) {
      return;
    }

    let stepMonthlyValues: JArrayList<BarEntry> = new JArrayList<BarEntry>();
    for (let i = 0; i < this.monthlySteps.length; i++) {
      stepMonthlyValues.add(new BarEntry(i, this.monthlySteps[i]));
    }

    let stepMonthlyDataSet: BarDataSet = new BarDataSet(stepMonthlyValues, '');
    stepMonthlyDataSet.setDrawValues(false);
    stepMonthlyDataSet.setColorByColor(0x802B69FF);
    stepMonthlyDataSet.setHighLightColor(ColorTemplate.colorRgb(43, 105, 255));

    let stepMonthlyDataSets: JArrayList<IBarDataSet> = new JArrayList<IBarDataSet>();
    stepMonthlyDataSets.add(stepMonthlyDataSet);
    let stepMonthlyData: BarData = new BarData(stepMonthlyDataSets);
    stepMonthlyData.setDrawValues(false);
    stepMonthlyData.setBarWidth(0.25);

    this.chartModel.setData(stepMonthlyData);
    const maxRange = this.dateLabels.length > 0 ? this.dateLabels.length : this.monthlySteps.length;
    if (maxRange > 0) {
      this.chartModel.setVisibleXRangeMaximum(maxRange);
    }
    this.chartModel.notifyDataSetChanged();
    this.chartModel.invalidate();
  }
}

