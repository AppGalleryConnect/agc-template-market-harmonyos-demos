/**
 * 周度血糖图表 ViewModel
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

class BloodGlucoseMarkerView extends MarkerView {
  private value: number = 0;
  private date: string = '';
  private chartWidth: number = 0;

  setChartWidth(width: number): void {
    this.chartWidth = width;
  }

  refreshContent(entry: EntryOhos, _highlight: Highlight): void {
    if (entry) {
      this.value = Math.round(entry.getY() * 10) / 10; // 保留一位小数
      const index = Math.round(entry.getX());
      const weekdays = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
      if (index >= 1 && index <= 7) {
        this.date = weekdays[index - 1];
      }
    }
  }

  draw(c: CanvasRenderingContext2D, posX: number, _posY: number, e: EntryOhos, highlight: Highlight): void {
    this.refreshContent(e, highlight);

    c.save();

    // 测量文本尺寸
    const valueText = `${this.value}`;
    const unitText = 'mmol/L';
    c.font = 'bold 28vp sans-serif';
    const valueMetrics = c.measureText(valueText);
    c.font = '14vp sans-serif';
    const unitMetrics = c.measureText(unitText);
    c.font = '10vp sans-serif';
    const dateMetrics = c.measureText(this.date);

    const padding = 10;
    const paddingLeft = 12;
    const dateLineHeight = 14;
    const valueLineHeight = 32;
    const totalValueWidth = valueMetrics.width + unitMetrics.width + 4;
    const maxWidth = Math.max(dateMetrics.width, totalValueWidth);
    const boxWidth = maxWidth + paddingLeft * 2;
    const boxHeight = dateLineHeight + valueLineHeight + padding * 2;
    const radius = 8;

    const top: number = 10;

    let left: number = posX - boxWidth / 2;

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
    c.fillStyle = '#FFFFFF';
    c.textAlign = 'left';
    c.textBaseline = 'alphabetic';

    // 绘制日期（左对齐，贴着左上角）
    c.font = '10vp sans-serif';
    c.fillText(this.date, left + paddingLeft, top + padding + 10);

    // 绘制数值（数字大，单位小）
    const valueY = top + padding + 10 + dateLineHeight + 18;
    c.font = 'bold 28vp sans-serif';
    c.fillText(valueText, left + paddingLeft, valueY);

    c.font = '14vp sans-serif';
    c.fillText(unitText, left + paddingLeft + valueMetrics.width + 4, valueY);

    c.restore();
  }
}

@ObservedV2
export class WeeklyBloodGlucoseChartVM {
  @Trace chartModel: CombinedChartModel = new CombinedChartModel();
  @Trace values: number[] = [];
  @Trace currentIndex: number = -1;
  private markerView: BloodGlucoseMarkerView | null = null;
  private onValueSelectedCallback: ((date: string, value: number) => void) | null = null;

  public initializeChart(): void {
    this.chartModel.getDescription()?.setEnabled(false);
    this.chartModel.setPinchZoom(false);
    this.chartModel.setDrawGridBackground(false);
    this.chartModel.setExtraOffsets(10, 20, 20, 3);
    this.chartModel.setTouchEnabled(true);
    this.chartModel.setDragEnabled(false);
    this.chartModel.setScaleEnabled(false);
    this.chartModel.setHighlightPerTapEnabled(true);
    this.chartModel.setHighlightPerDragEnabled(false);

    // 设置MarkerView
    this.markerView = new BloodGlucoseMarkerView();
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

    let glucoseWeeklyXAxis: XAxis | null = this.chartModel.getXAxis();
    if (glucoseWeeklyXAxis) {
      glucoseWeeklyXAxis.setPosition(XAxisPosition.BOTTOM);
      glucoseWeeklyXAxis.setGranularity(1);
      glucoseWeeklyXAxis.setGranularityEnabled(true);
      glucoseWeeklyXAxis.setAxisMinimum(0.5);
      glucoseWeeklyXAxis.setAxisMaximum(7.5);
      glucoseWeeklyXAxis.setLabelCount(7, false);
      glucoseWeeklyXAxis.setValueFormatter(new WeekdayFormatter());
      glucoseWeeklyXAxis.setDrawGridLines(true);
      glucoseWeeklyXAxis.setGridColor(ColorTemplate.colorRgb(230, 233, 236));
      glucoseWeeklyXAxis.setGridLineWidth(0.6);
      glucoseWeeklyXAxis.setTextColor(ColorTemplate.colorRgb(150, 150, 150));
    }

    let glucoseWeeklyLeftAxis: YAxis | null = this.chartModel.getAxisLeft();
    if (glucoseWeeklyLeftAxis) {
      glucoseWeeklyLeftAxis.setAxisMinimum(0);
      glucoseWeeklyLeftAxis.setAxisMaximum(12);
      glucoseWeeklyLeftAxis.setLabelCount(5, true);
      glucoseWeeklyLeftAxis.setGranularity(3);
      glucoseWeeklyLeftAxis.setPosition(YAxisLabelPosition.OUTSIDE_CHART);
      glucoseWeeklyLeftAxis.setDrawGridLines(true);
      glucoseWeeklyLeftAxis.setGridColor(ColorTemplate.colorRgb(230, 233, 236));
      glucoseWeeklyLeftAxis.setGridLineWidth(0.6);
      glucoseWeeklyLeftAxis.setTextColor(ColorTemplate.colorRgb(150, 150, 150));
    }
    this.chartModel.getAxisRight()?.setEnabled(false);
  }

  public updateValues(newValues: number[]): void {
    this.values = newValues.slice();
    this.updateChartData();
  }

  public updateCurrentIndex(index: number): void {
    this.currentIndex = index;
    this.updateChartData();
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
    const dataIndex = Math.round(xValue - 1); // X轴从1开始，数组从0开始

    if (dataIndex >= 0 && dataIndex < this.values.length) {
      const value = this.values[dataIndex];

      // 生成日期文本（04月24日(周日)格式）
      const dateText = this.generateDateWithWeekday(dataIndex);

      if (this.onValueSelectedCallback) {
        this.onValueSelectedCallback(dateText, value);
      }
    }
  }

  public onNothingSelected(): void {
    // 可选：重置为默认值
  }

  private generateDateWithWeekday(index: number): string {
    // 生成04月24日(周日)格式的日期
    const weekdays = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];

    // 直接根据索引计算日期：4/24是周日(索引0)，4/25是周一(索引1)，以此类推
    const dates = [
      '04月24日', // 索引0 - 周日
      '04月25日', // 索引1 - 周一
      '04月26日', // 索引2 - 周二
      '04月27日', // 索引3 - 周三
      '04月28日', // 索引4 - 周四
      '04月29日', // 索引5 - 周五
      '04月30日'// 索引6 - 周六
    ];

    if (index >= 0 && index < dates.length && index < weekdays.length) {
      return `${dates[index]}(${weekdays[index]})`;
    }

    // 备用逻辑
    return `04月${24 + index}日(${weekdays[index] || '未知'})`;
  }

  private updateChartData(): void {
    if (this.values.length === 0) {
      return;
    }

    let glucoseWeeklyCombinedData: CombinedData = new CombinedData();

    // 散点数据 - 按颜色分组显示所有数据点
    let glucoseWeeklyScatterData: ScatterData = new ScatterData();

    // 按血糖值分组创建不同颜色的数据集
    let normalEntries: JArrayList<EntryOhos> = new JArrayList<EntryOhos>(); // 正常：3.9-6.1
    let lowEntries: JArrayList<EntryOhos> = new JArrayList<EntryOhos>(); // 偏低：<3.9
    let highEntries: JArrayList<EntryOhos> = new JArrayList<EntryOhos>(); // 偏高：>6.1

    // 添加所有数据点，根据值分组
    for (let i = 0; i < this.values.length; i++) {
      const value = this.values[i];
      const xPosition = i + 1;
      const entry = new EntryOhos(xPosition, value);

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
      normalSet.setScatterShapeSize(6);
      normalSet.setDrawValues(false);
      glucoseWeeklyScatterData.addDataSet(normalSet);
    }

    // 创建偏低值数据集（橙色）
    if (lowEntries.size() > 0) {
      let lowSet: ScatterDataSet = new ScatterDataSet(lowEntries, '');
      lowSet.setColorByColor(ColorTemplate.colorRgb(255, 168, 0));
      lowSet.setScatterShapeSize(6);
      lowSet.setDrawValues(false);
      glucoseWeeklyScatterData.addDataSet(lowSet);
    }

    // 创建偏高值数据集（红色）
    if (highEntries.size() > 0) {
      let highSet: ScatterDataSet = new ScatterDataSet(highEntries, '');
      highSet.setColorByColor(ColorTemplate.colorRgb(244, 67, 54));
      highSet.setScatterShapeSize(6);
      highSet.setDrawValues(false);
      glucoseWeeklyScatterData.addDataSet(highSet);
    }

    glucoseWeeklyCombinedData.setScatterData(glucoseWeeklyScatterData);

    // 线数据 - 当前日期的垂直线
    let glucoseWeeklyLineData: LineData = new LineData();
    let glucoseWeeklyLineEntries: JArrayList<EntryOhos> = new JArrayList<EntryOhos>();
    if (this.currentIndex >= 0 && this.currentIndex < this.values.length) {
      const xPosition = this.currentIndex + 1;
      glucoseWeeklyLineEntries.add(new EntryOhos(xPosition, 0));
      glucoseWeeklyLineEntries.add(new EntryOhos(xPosition, 12));
      let glucoseWeeklyLineDataSet: LineDataSet = new LineDataSet(glucoseWeeklyLineEntries, '');
      glucoseWeeklyLineDataSet.setColorByColor(ColorTemplate.colorRgb(200, 200, 200));
      glucoseWeeklyLineDataSet.setLineWidth(1);
      glucoseWeeklyLineDataSet.setDrawCircles(false);
      glucoseWeeklyLineDataSet.setDrawValues(false);
      glucoseWeeklyLineData.addDataSet(glucoseWeeklyLineDataSet);
    }
    glucoseWeeklyCombinedData.setLineData(glucoseWeeklyLineData);

    this.chartModel.setData(glucoseWeeklyCombinedData);
    this.chartModel.notifyDataSetChanged();
    this.chartModel.invalidate();
  }
}

