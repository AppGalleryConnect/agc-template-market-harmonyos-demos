/**
 * 月度血糖图表 ViewModel
 */
import {
  AxisBase,
  ColorTemplate,
  CombinedChartModel,
  CombinedData,
  EntryOhos,
  Highlight,
  IAxisValueFormatter,
  JArrayList,
  Legend,
  LineData,
  LineDataSet,
  MarkerView,
  ScatterData,
  ScatterDataSet,
  XAxis,
  XAxisPosition,
  YAxis,
  YAxisLabelPosition
} from '@ohos/mpchart';

interface DateParts {
  month: number;
  day: number;
}

// 收集所有非空日期及其索引
interface DateInfoPro {
  index: number;
  label: string;
}

class DateFormatter implements IAxisValueFormatter {
  private labels: string[] = [];

  constructor(labels: string[]) {
    this.labels = labels;
  }

  getFormattedValue(value: number, _axis: AxisBase): string {
    // value对应数据点的X位置，从0开始
    const i = Math.round(value);
    if (i >= 0 && i < this.labels.length && this.labels[i] && this.labels[i].trim() !== '') {
      return this.labels[i];
    }
    return '';
  }
}

class BloodGlucoseMonthlyMarkerView extends MarkerView {
  private value: number = 0;
  private label: string = '';
  private tooltipLabels: Array<string> = []; // 浮层专用的完整日期数组
  private chartWidth: number = 0;

  constructor(tooltipLabels: Array<string>) {
    super();
    this.tooltipLabels = tooltipLabels;
  }

  setTooltipLabels(tooltipLabels: Array<string>): void {
    this.tooltipLabels = tooltipLabels;
  }

  setChartWidth(width: number): void {
    this.chartWidth = width;
  }

  refreshContent(entry: EntryOhos, _highlight: Highlight): void {
    if (entry) {
      const index = Math.round(entry.getX());
      this.value = entry.getY();
      if (index >= 0 && index < this.tooltipLabels.length && this.tooltipLabels[index]) {
        this.label = this.tooltipLabels[index];
      } else {
        this.label = '';
      }
    }
  }

  draw(c: CanvasRenderingContext2D, posX: number, _posY: number, e: EntryOhos, highlight: Highlight): void {
    this.refreshContent(e, highlight);

    c.save();

    // 血糖值
    const unitText = 'mmol/L';
    c.font = 'bold 28vp sans-serif';
    const valueNumber = this.value.toFixed(1);
    const valueMetrics = c.measureText(valueNumber);
    c.font = '14vp sans-serif';
    const unitMetrics = c.measureText(unitText);


    // 测量文本尺寸
    c.font = '10vp sans-serif';
    const dateText = this.label || '';
    const dateMetrics = c.measureText(dateText);

    const dateLineHeight = 14;
    const valueLineHeight = 32;
    const padding = 10;
    const paddingLeft = 12;
    const totalValueWidth = valueMetrics.width + unitMetrics.width + 4;
    const maxWidth = Math.max(dateMetrics.width, totalValueWidth);
    const radius = 8;
    const boxWidth = maxWidth + paddingLeft * 2;
    const boxHeight = dateLineHeight + valueLineHeight + padding * 2;


    let left: number = posX - boxWidth / 2;
    const top: number = 10;

    // 边界检查 - 左边界
    if (left < 10) {
      left = 10;
    }

    // 边界检查 - 右边界
    const rightEdge = left + boxWidth;
    const chartRightBound = this.chartWidth > 0 ? this.chartWidth - 10 : 350;
    if (rightEdge > chartRightBound) {
      left = chartRightBound - boxWidth;
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
    c.textBaseline = 'alphabetic';
    c.fillStyle = '#FFFFFF';
    c.textAlign = 'left';

    // 绘制日期
    c.font = '10vp sans-serif';
    c.fillText(dateText, left + paddingLeft, top + padding + 10);

    // 绘制数值
    const valueY = top + padding + 10 + dateLineHeight + 18;
    c.font = 'bold 28vp sans-serif';
    c.fillText(valueNumber, left + paddingLeft, valueY);

    c.font = '14vp sans-serif';
    c.fillText(unitText, left + paddingLeft + valueMetrics.width + 4, valueY);

    c.restore();
  }
}

@ObservedV2
export class MonthlyBloodGlucoseChartVM {
  @Trace chartModel: CombinedChartModel = new CombinedChartModel();
  @Trace values: number[] = [];
  @Trace dateLabels: string[] = []; // X轴标签（包含空字符串）
  @Trace tooltipLabels: string[] = []; // 浮层专用的完整日期数组
  @Trace currentIndex: number = -1;
  private markerView: BloodGlucoseMonthlyMarkerView | null = null;
  private onValueSelectedCallback: ((date: string, value: number) => void) | null = null;

  public initializeChart(): void {
    this.chartModel.getDescription()?.setEnabled(false);
    this.chartModel.setPinchZoom(false);
    this.chartModel.setDrawGridBackground(false);
    this.chartModel.setExtraOffsets(10, 20, 20, 3);
    this.chartModel.setTouchEnabled(true);
    this.chartModel.setDragEnabled(true); // 启用拖动，支持横向滚动
    this.chartModel.setScaleEnabled(false);
    this.chartModel.setHighlightPerTapEnabled(true);
    this.chartModel.setHighlightPerDragEnabled(false);

    // 设置MarkerView - 使用完整的日期数组
    this.markerView = new BloodGlucoseMonthlyMarkerView(this.tooltipLabels);
    this.chartModel.setMarker(this.markerView);

    // 设置点击监听器
    this.chartModel.setOnChartValueSelectedListener({
      onValueSelected: (e: EntryOhos, h: Highlight) => this.onValueSelected(e, h),
      onNothingSelected: () => this.onNothingSelected()
    });

    let legend: Legend | null = this.chartModel.getLegend();
    if (legend) {
      legend.setEnabled(false);
    }

    let glucoseXAxis: XAxis | null = this.chartModel.getXAxis();
    if (glucoseXAxis) {
      const glucoseDateFormatter = new DateFormatter(this.dateLabels);
      glucoseXAxis.setPosition(XAxisPosition.BOTTOM);
      glucoseXAxis.setGranularity(1);
      glucoseXAxis.setGranularityEnabled(true);
      glucoseXAxis.setAxisMinimum(-0.5);
      glucoseXAxis.setAxisMaximum(this.dateLabels.length - 0.5);
      glucoseXAxis.setLabelCount(6, true); // 强制只显示6个标签，防止滑动时变化

      // 设置可见范围，支持滑动查看完整月份数据
      if (this.dateLabels.length > 10) {
        // 如果数据点超过10个，设置可见范围为12个数据点，支持滑动
        this.chartModel.setVisibleXRangeMaximum(12);
        this.chartModel.setVisibleXRangeMinimum(8);
        // 默认显示前10个数据点（从4/1开始）
        this.chartModel.moveViewToX(-0.5);
      }
      glucoseXAxis.setValueFormatter(glucoseDateFormatter);
      glucoseXAxis.setDrawGridLines(true);
      glucoseXAxis.setGridColor(ColorTemplate.colorRgb(230, 233, 236));
      glucoseXAxis.setGridLineWidth(0.6);
      glucoseXAxis.setTextColor(ColorTemplate.colorRgb(150, 150, 150));
    }

    let glucoseYLeft: YAxis | null = this.chartModel.getAxisLeft();
    if (glucoseYLeft) {
      glucoseYLeft.setAxisMinimum(0);
      glucoseYLeft.setAxisMaximum(12);
      glucoseYLeft.setLabelCount(5, true);
      glucoseYLeft.setGranularity(3);
      glucoseYLeft.setPosition(YAxisLabelPosition.OUTSIDE_CHART);
      glucoseYLeft.setDrawGridLines(true);
      glucoseYLeft.setGridColor(ColorTemplate.colorRgb(230, 233, 236));
      glucoseYLeft.setGridLineWidth(0.6);
      glucoseYLeft.setTextColor(ColorTemplate.colorRgb(150, 150, 150));
    }
    this.chartModel.getAxisRight()?.setEnabled(false);
  }

  public updateValues(newValues: number[]): void {
    this.values = newValues.slice();
    this.updateChartData();
  }

  public updateDateLabels(labels: string[]): void {
    this.dateLabels = labels.slice();
    // 生成完整的日期数组用于浮层显示
    this.generateTooltipLabelsList();
    if (this.markerView) {
      this.markerView.setTooltipLabels(this.tooltipLabels);
    }
    let xAxis: XAxis | null = this.chartModel.getXAxis();
    if (xAxis) {
      const dateFormatter = new DateFormatter(this.dateLabels);
      xAxis.setAxisMinimum(-0.5);
      xAxis.setAxisMaximum(this.dateLabels.length - 0.5);
      xAxis.setLabelCount(6, true); // 强制只显示6个标签，防止滑动时变化

      // 设置可见范围，支持滑动查看完整月份数据
      if (this.dateLabels.length > 10) {
        // 如果数据点超过10个，设置可见范围为12个数据点，支持滑动
        this.chartModel.setVisibleXRangeMaximum(12);
        this.chartModel.setVisibleXRangeMinimum(8);
        // 默认显示前10个数据点（从4/1开始）
        this.chartModel.moveViewToX(-0.5);
      }
      xAxis.setValueFormatter(dateFormatter);
    }
    this.updateChartData();
  }

  // 生成完整的日期数组，填充空字符串位置
  private generateTooltipLabelsList(): void {

    this.tooltipLabels = [];

    const nonEmptyDatesList: DateInfoPro[] = [];
    for (let i = 0; i < this.dateLabels.length; i++) {
      if (this.dateLabels[i] && this.dateLabels[i].trim() !== '') {
        nonEmptyDatesList.push({ index: i, label: this.dateLabels[i] });
      }
    }
    // 为每个位置生成日期标签
    for (let i = 0; i < this.dateLabels.length; i++) {
      if (this.dateLabels[i] && this.dateLabels[i].trim() !== '') {
        // 非空位置直接使用原标签
        this.tooltipLabels.push(this.dateLabels[i]);
      } else {
        this.setLoop(nonEmptyDatesList, i)
      }
    }
  }

  public setLoop(nonEmptyDatesList: DateInfoPro[], i: number) {
    // 空位置：通过插值计算具体日期
    let prevDateInfo: DateInfoPro | null = null;
    let nextDateInfo: DateInfoPro | null = null;

    for (let j = 0; j < nonEmptyDatesList.length; j++) {
      if (nonEmptyDatesList[j].index < i) {
        prevDateInfo = nonEmptyDatesList[j];
      } else if (nonEmptyDatesList[j].index > i && !nextDateInfo) {
        nextDateInfo = nonEmptyDatesList[j];
        break;
      }
    }

    // 通过插值计算具体日期
    if (prevDateInfo && nextDateInfo) {
      const calculatedDateObject = this.interpolateDate(
        prevDateInfo.label,
        nextDateInfo.label,
        i - prevDateInfo.index,
        nextDateInfo.index - prevDateInfo.index
      );
      this.tooltipLabels.push(calculatedDateObject);
    } else if (prevDateInfo) {
      // 只有前面的日期，向后推算
      const offsetP = i - prevDateInfo.index;
      const calculatedDateObj = this.addDaysToDate(prevDateInfo.label, offsetP * 2);
      this.tooltipLabels.push(calculatedDateObj);
    } else if (nextDateInfo) {
      // 只有后面的日期，向前推算
      const offset = nextDateInfo.index - i;
      const calculatedDate = this.addDaysToDate(nextDateInfo.label, -offset * 2);
      this.tooltipLabels.push(calculatedDate);
    } else {
      this.tooltipLabels.push('未知');
    }
  }

  // 解析日期字符串（格式：12/4 或 1/2）
  private parseDate(dateStr: string): DateParts | null {
    const parts = dateStr.split('/');
    if (parts.length === 2) {
      const month = parseInt(parts[0]);
      const day = parseInt(parts[1]);
      if (!isNaN(month) && !isNaN(day)) {
        return { month: month, day: day };
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

    // 处理跨月情况
    while (newDay > 30) {
      newDay -= 30;
      newMonth += 1;
    }

    return `${newMonth}/${newDay}`;
  }

  // 给日期添加天数
  private addDaysToDate(dateStr: string, daysToAdd: number): string {
    const date = this.parseDate(dateStr);
    if (!date) {
      return dateStr;
    }

    let newDay = date.day + daysToAdd;
    let newMonth = date.month;

    // 处理跨月情况
    while (newDay > 30) {
      newDay -= 30;
      newMonth += 1;
    }
    while (newDay < 1) {
      newDay += 30;
      newMonth -= 1;
    }

    return `${newMonth}/${newDay}`;
  }

  public updateCurrentIndex(index: number): void {
    this.updateChartData();
    this.currentIndex = index;
  }

  public setChartWidth(width: number): void {
    if (this.markerView) {
      this.markerView.setChartWidth(width);
    }
  }

  public setOnValueSelectedListener(callback: (date: string, value: number) => void): void {
    this.onValueSelectedCallback = callback;
  }

  public onValueSelected(e: EntryOhos, _h: Highlight): void {
    const xValue = e.getX();
    const dataIndex = Math.round(xValue);

    if (dataIndex >= 0 && dataIndex < this.values.length) {
      const value = this.values[dataIndex];

      // 生成日期文本（优先使用dateLabels中的标签，但转换为中文格式）
      let dateText = '';
      if (dataIndex >= 0 && dataIndex < this.dateLabels.length && this.dateLabels[dataIndex] &&
        this.dateLabels[dataIndex].trim() !== '') {
        // 将X轴的"4/5"格式转换为"04月05日"格式
        dateText = this.convertToChineseDate(this.dateLabels[dataIndex]);
      } else {
        // 根据索引生成日期
        dateText = this.generateDateFromDataIndex(dataIndex);
      }

      if (this.onValueSelectedCallback) {
        this.onValueSelectedCallback(dateText, value);
      }
    }
  }

  public onNothingSelected(): void {
    // 可选：重置为默认值
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

    // 超出范围时的备用逻辑
    return `04月${String(index + 1).padStart(2, '0')}日`;
  }

  private updateChartData(): void {
    if (this.values.length === 0) {
      return;
    }

    let combined: CombinedData = new CombinedData();

    // 散点数据 - 按颜色分组显示所有数据点
    let scatterData: ScatterData = new ScatterData();

    // 按血糖值分组创建不同颜色的数据集
    let normalEntries: JArrayList<EntryOhos> = new JArrayList<EntryOhos>(); // 正常：3.9-6.1
    let lowEntries: JArrayList<EntryOhos> = new JArrayList<EntryOhos>(); // 偏低：<3.9
    let highEntries: JArrayList<EntryOhos> = new JArrayList<EntryOhos>(); // 偏高：>6.1

    // 添加所有数据点，根据值分组
    for (let i = 0; i < this.values.length; i++) {
      const value = this.values[i];
      const entry = new EntryOhos(i, value);

      if (value < 3.9) {
        lowEntries.add(entry); // 偏低 - 橙色
      } else if (value > 6.1) {
        highEntries.add(entry); // 偏高 - 红色
      } else {
        normalEntries.add(entry); // 正常 - 绿色
      }
    }

    // 创建正常值数据集（绿色）
    if (normalEntries.size() > 0) {
      let normalSet: ScatterDataSet = new ScatterDataSet(normalEntries, '');
      normalSet.setColorByColor(ColorTemplate.colorRgb(76, 175, 80));
      normalSet.setDrawValues(false);
      scatterData.addDataSet(normalSet);
      normalSet.setScatterShapeSize(6);
    }

    // 创建偏低值数据集（橙色）
    if (lowEntries.size() > 0) {
      let lowSet: ScatterDataSet = new ScatterDataSet(lowEntries, '');
      lowSet.setColorByColor(ColorTemplate.colorRgb(255, 168, 0));
      lowSet.setScatterShapeSize(6);
      lowSet.setDrawValues(false);
      scatterData.addDataSet(lowSet);
    }

    // 创建偏高值数据集（红色）
    if (highEntries.size() > 0) {
      let highSet: ScatterDataSet = new ScatterDataSet(highEntries, '');
      highSet.setScatterShapeSize(6);
      highSet.setColorByColor(ColorTemplate.colorRgb(244, 67, 54));
      highSet.setDrawValues(false);
      scatterData.addDataSet(highSet);
    }

    combined.setScatterData(scatterData);

    // 线数据 - 当前日期的垂直线
    let lineData: LineData = new LineData();
    let lEntries: JArrayList<EntryOhos> = new JArrayList<EntryOhos>();
    if (this.currentIndex >= 0 && this.currentIndex < this.values.length) {
      lEntries.add(new EntryOhos(this.currentIndex, 0));
      lEntries.add(new EntryOhos(this.currentIndex, 12));
      let lSet: LineDataSet = new LineDataSet(lEntries, '');
      lSet.setColorByColor(ColorTemplate.colorRgb(200, 200, 200));
      lSet.setLineWidth(1);
      lSet.setDrawCircles(false);
      lSet.setDrawValues(false);
      lineData.addDataSet(lSet);
    }
    combined.setLineData(lineData);

    this.chartModel.setData(combined);
    this.chartModel.notifyDataSetChanged();
    this.chartModel.invalidate();

    if (this.dateLabels.length > 10) {
      this.chartModel.moveViewToX(-0.5);
    }
  }
}
