/**
 * 三个月血糖组合图表 ViewModel
 */
import {
  CombinedChartModel,
  CombinedData,
  ScatterData,
  ScatterDataSet,
  JArrayList,
  LineData,
  LineDataSet,
  EntryOhos,
  XAxis,
  XAxisPosition,
  YAxis,
  YAxisLabelPosition,
  IAxisValueFormatter,
  AxisBase,
  Legend,
  ColorTemplate,
  MarkerView,
  Highlight
} from '@ohos/mpchart';

// 月份标签格式化器
class MonthFormatter implements IAxisValueFormatter {
  private monthLabels: Array<string> = [];

  constructor(monthLabels: Array<string>) {
    this.monthLabels = monthLabels;
  }

  getFormattedValue(value: number, _axis: AxisBase): string {
    // value对应数据点的X位置，从0开始
    const i = Math.round(value);
    if (i >= 0 && i < this.monthLabels.length && this.monthLabels[i] && this.monthLabels[i].trim() !== '') {
      return this.monthLabels[i];
    }
    return '';
  }
}

class BloodGlucoseThreeMonthsMarkerView extends MarkerView {
  private value: number = 0;
  private label: string = '';
  private tooltipLabels: Array<string> = [];
  private chartWidth: number = 0;

  constructor(tooltipLabels: Array<string>) {
    super();
    this.tooltipLabels = tooltipLabels;
  }

  setChartWidth(width: number): void {
    this.chartWidth = width;
  }

  setTooltipLabels(tooltipLabels: Array<string>): void {
    this.tooltipLabels = tooltipLabels;
  }

  refreshContent(entry: EntryOhos, _highlight: Highlight): void {
    if (entry) {
      this.value = entry.getY();
      const index = Math.round(entry.getX());
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

    // 第一行：日期
    const dateText = this.label || '';
    c.font = '10vp sans-serif';
    const dateMetrics = c.measureText(dateText);

    // 第二行：血糖值（数字大，单位小）
    const valueNumber = this.value.toFixed(1);
    const unitText = 'mmol/L';
    c.font = 'bold 28vp sans-serif';
    const valueMetrics = c.measureText(valueNumber);
    c.font = '14vp sans-serif';
    const unitMetrics = c.measureText(unitText);

    const padding = 10;
    const paddingLeft = 12;
    const dateLineHeight = 14;
    const valueLineHeight = 32;
    const totalValueWidth = valueMetrics.width + unitMetrics.width + 4;
    const maxWidth = Math.max(dateMetrics.width, totalValueWidth);
    const boxWidth = maxWidth + paddingLeft * 2;
    const boxHeight = dateLineHeight + valueLineHeight + padding * 2;
    const radius = 8;

    let left: number = posX - boxWidth / 2;
    const top: number = 10;

    // 边界检查 - 左边界
    if (left < 10) {
      left = 10;
    }

    const rightEdge = left + boxWidth;
    const chartRightBound = this.chartWidth > 0 ? this.chartWidth - 10 : 350; // 默认350，实际使用图表宽度
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
    c.fillStyle = '#FFFFFF';
    c.textAlign = 'left';
    c.textBaseline = 'alphabetic';

    // 绘制日期（左对齐，贴着左上角）
    c.font = '10vp sans-serif';
    c.fillText(dateText, left + paddingLeft, top + padding + 10);

    // 绘制血糖值（数字大，单位小）
    const valueY = top + padding + 10 + dateLineHeight + 18;
    c.font = 'bold 28vp sans-serif';
    c.fillText(valueNumber, left + paddingLeft, valueY);

    c.font = '14vp sans-serif';
    c.fillText(unitText, left + paddingLeft + valueMetrics.width + 4, valueY);

    c.restore();
  }
}

@ObservedV2
export class ThreeMonthsBloodGlucoseChartVM {
  @Trace chartModel: CombinedChartModel | undefined = undefined;
  @Trace values: number[] = [];
  @Trace monthLabels: string[] = [];
  @Trace currentIndex: number = -1;
  @Trace tooltipLabels: string[] = [];
  private markerView: BloodGlucoseThreeMonthsMarkerView | null = null;
  private onValueSelectedCallback: ((date: string, value: number) => void) | null = null;

  public initializeChart(): void {
    this.chartModel = new CombinedChartModel();
    this.chartModel.getDescription()?.setEnabled(false);
    this.chartModel.setPinchZoom(false);
    this.chartModel.setDrawGridBackground(false);
    this.chartModel.setExtraOffsets(10, 20, 20, 5);
    this.chartModel.setTouchEnabled(true);
    this.chartModel.setDragEnabled(false);
    this.chartModel.setScaleEnabled(false);
    this.chartModel.setHighlightPerTapEnabled(true);
    this.chartModel.setHighlightPerDragEnabled(false);

    // 设置MarkerView
    const effectiveTooltipLabels = this.tooltipLabels.length > 0 ? this.tooltipLabels : this.monthLabels;
    this.markerView = new BloodGlucoseThreeMonthsMarkerView(effectiveTooltipLabels);
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

    let glucoseThreeMonthsXAxis: XAxis | null = this.chartModel.getXAxis();
    if (glucoseThreeMonthsXAxis) {
      glucoseThreeMonthsXAxis.setPosition(XAxisPosition.BOTTOM);
      glucoseThreeMonthsXAxis.setGranularity(1);
      glucoseThreeMonthsXAxis.setGranularityEnabled(true);
      glucoseThreeMonthsXAxis.setAxisMinimum(-0.5);
      glucoseThreeMonthsXAxis.setAxisMaximum(11.5);
      glucoseThreeMonthsXAxis.setLabelCount(12, false);
      glucoseThreeMonthsXAxis.setValueFormatter(new MonthFormatter(this.monthLabels));
      glucoseThreeMonthsXAxis.setDrawGridLines(true);
      glucoseThreeMonthsXAxis.setGridColor(ColorTemplate.colorRgb(230, 233, 236));
      glucoseThreeMonthsXAxis.setGridLineWidth(0.6);
      glucoseThreeMonthsXAxis.setYOffset(0);
      glucoseThreeMonthsXAxis.setTextColor(ColorTemplate.colorRgb(150, 150, 150));
    }

    let glucoseThreeMonthsLeftAxis: YAxis | null = this.chartModel.getAxisLeft();
    if (glucoseThreeMonthsLeftAxis) {
      glucoseThreeMonthsLeftAxis.setAxisMinimum(0);
      glucoseThreeMonthsLeftAxis.setAxisMaximum(12);
      glucoseThreeMonthsLeftAxis.setLabelCount(5, true);
      glucoseThreeMonthsLeftAxis.setGranularity(3);
      glucoseThreeMonthsLeftAxis.setPosition(YAxisLabelPosition.OUTSIDE_CHART);
      glucoseThreeMonthsLeftAxis.setDrawGridLines(true);
      glucoseThreeMonthsLeftAxis.setGridColor(ColorTemplate.colorRgb(230, 233, 236));
      glucoseThreeMonthsLeftAxis.setGridLineWidth(0.6);
      glucoseThreeMonthsLeftAxis.setTextColor(ColorTemplate.colorRgb(150, 150, 150));
    }
    this.chartModel.getAxisRight()?.setEnabled(false);

    this.updateChartData();
  }

  public updateValues(vals: number[]): void {
    this.values = vals.slice();
    this.updateChartData();
  }

  public updateMonthLabels(labels: string[]): void {
    this.monthLabels = labels.slice();
    if (this.chartModel) {
      let xAxis: XAxis | null = this.chartModel.getXAxis();
      if (xAxis) {
        xAxis.setAxisMinimum(-0.5);
        xAxis.setAxisMaximum(11.5);
        xAxis.setLabelCount(12, false);
        xAxis.setValueFormatter(new MonthFormatter(this.monthLabels));
        xAxis.setYOffset(0);
      }
    }
    this.updateChartData();
  }

  public updateCurrentIndex(index: number): void {
    this.currentIndex = index;
    this.updateChartData();
  }

  public updateTooltipLabels(labels: string[]): void {
    this.tooltipLabels = labels.slice();
    if (this.markerView) {
      this.markerView.setTooltipLabels(this.tooltipLabels);
    }
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

      // 生成日期文本（使用tooltipLabels中的周期范围）
      let dateText = '';
      if (dataIndex >= 0 && dataIndex < this.tooltipLabels.length && this.tooltipLabels[dataIndex]) {
        dateText = this.tooltipLabels[dataIndex];
      } else {
        // 备用逻辑：生成周期范围
        dateText = this.generateDateRangeFromIndex(dataIndex);
      }

      if (this.onValueSelectedCallback) {
        this.onValueSelectedCallback(dateText, value);
      }
    }
  }

  public onNothingSelected(): void {
    // 可选：重置为默认值
  }

  private generateDateRangeFromIndex(index: number): string {
    // 生成周期范围，如"2月1日～2月7日"
    const weekRanges = [
      '2月1日～2月7日', // 索引0
      '2月8日～2月14日', // 索引1
      '2月15日～2月21日', // 索引2
      '2月22日～2月28日', // 索引3
      '3月1日～3月7日', // 索引4
      '3月8日～3月14日', // 索引5
      '3月15日～3月21日', // 索引6
      '3月22日～3月28日', // 索引7
      '4月1日～4月7日', // 索引8
      '4月8日～4月14日', // 索引9
      '4月15日～4月21日', // 索引10
      '4月22日～4月28日'// 索引11
    ];

    if (index >= 0 && index < weekRanges.length) {
      return weekRanges[index];
    }

    return `第${index + 1}周`;
  }

  private updateChartData(): void {
    if (this.values.length === 0) {
      return;
    }

    let glucoseThreeMonthsCombinedData: CombinedData = new CombinedData();

    // 散点数据（显示所有血糖值点）
    let glucoseThreeMonthsScatterData: ScatterData = new ScatterData();

    // 按血糖值分组创建不同颜色的数据集
    let normalEntries: JArrayList<EntryOhos> = new JArrayList<EntryOhos>(); // 正常：3.9-6.1
    let lowEntries: JArrayList<EntryOhos> = new JArrayList<EntryOhos>(); // 偏低：<3.9
    let highEntries: JArrayList<EntryOhos> = new JArrayList<EntryOhos>(); // 偏高：>6.1

    // 添加所有数据点，将数据点映射到正确的X轴位置（12个点分布到3个月）
    for (let i = 0; i < this.values.length; i++) {
      const value = this.values[i];
      let xPosition: number;
      if (i < 4) {
        xPosition = i;
      } else if (i < 8) {
        xPosition = i;
      } else {
        xPosition = i;
      }
      const entry = new EntryOhos(xPosition, value);

      // 调整血糖值判断标准，减少正常范围
      if (value < 4.8) {
        lowEntries.add(entry); // 偏低 - 黄色
      } else if (value > 5.2) {
        highEntries.add(entry); // 偏高 - 红色
      } else {
        normalEntries.add(entry); // 正常 - 绿色
      }
    }


    // 创建正常值数据集（绿色）
    if (normalEntries.size() > 0) {
      let normalSet: ScatterDataSet = new ScatterDataSet(normalEntries, '');
      normalSet.setColorByColor(ColorTemplate.colorRgb(76, 175, 80)); // 正常 - 绿色
      normalSet.setScatterShapeSize(7);
      normalSet.setDrawValues(false);
      glucoseThreeMonthsScatterData.addDataSet(normalSet);
    }

    // 创建偏低值数据集（黄色）
    if (lowEntries.size() > 0) {
      let lowSet: ScatterDataSet = new ScatterDataSet(lowEntries, '');
      lowSet.setColorByColor(ColorTemplate.colorRgb(255, 152, 0)); // 偏低 - 橙黄色
      lowSet.setScatterShapeSize(7);
      lowSet.setDrawValues(false);
      glucoseThreeMonthsScatterData.addDataSet(lowSet);
    }

    // 创建偏高值数据集（红色）
    if (highEntries.size() > 0) {
      let highSet: ScatterDataSet = new ScatterDataSet(highEntries, '');
      highSet.setColorByColor(ColorTemplate.colorRgb(255, 0, 0)); // 偏高 - 纯红色
      highSet.setScatterShapeSize(7);
      highSet.setDrawValues(false);
      glucoseThreeMonthsScatterData.addDataSet(highSet);
    }

    glucoseThreeMonthsCombinedData.setScatterData(glucoseThreeMonthsScatterData);

    // 线数据（当前日期的垂直线）- 只有选中点后才显示
    let glucoseThreeMonthsLineData: LineData = new LineData();
    let lEntries: JArrayList<EntryOhos> = new JArrayList<EntryOhos>();
    if (this.currentIndex >= 0 && this.currentIndex < this.values.length) {
      lEntries.add(new EntryOhos(this.currentIndex, 0));
      lEntries.add(new EntryOhos(this.currentIndex, 12));
      let lSet: LineDataSet = new LineDataSet(lEntries, '');
      lSet.setColorByColor(ColorTemplate.colorRgb(200, 200, 200));
      lSet.setLineWidth(1);
      lSet.setDrawCircles(false);
      lSet.setDrawValues(false);
      glucoseThreeMonthsLineData.addDataSet(lSet);
    }
    glucoseThreeMonthsCombinedData.setLineData(glucoseThreeMonthsLineData);

    this.chartModel?.setData(glucoseThreeMonthsCombinedData);
    // 设置可见X轴范围，确保显示所有数据点
    this.chartModel?.setVisibleXRangeMaximum(12);
    this.chartModel?.setVisibleXRangeMinimum(12);
    this.chartModel?.moveViewToX(5.5); // 居中显示
    this.chartModel?.notifyDataSetChanged();
    this.chartModel?.invalidate();
  }
}
