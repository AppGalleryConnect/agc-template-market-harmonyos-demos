/**
 * 三个月血压折线图 ViewModel
 */
import {
  AxisBase,
  IAxisValueFormatter,
  JArrayList,
  EntryOhos,
  LineChartModel,
  LineData,
  LineDataSet,
  Mode,
  XAxis,
  XAxisPosition,
  YAxis,
  YAxisLabelPosition,
  Legend,
  ColorTemplate,
  LimitLine,
  MarkerView,
  Highlight
} from '@ohos/mpchart';

// 血压三个月MarkerView
class ThreeMonthsBloodPressureMarkerView extends MarkerView {
  private systolicValue: number = 0;
  private diastolicValue: number = 0;
  private dateRange: string = '';
  private chartWidth: number = 0;
  private systolicValues: number[] = [];
  private diastolicValues: number[] = [];
  private weekRanges: string[] = [];

  constructor() {
    super();
  }

  setChartWidth(width: number): void {
    this.chartWidth = width;
  }

  setData(systolicValues: number[], diastolicValues: number[]): void {
    this.systolicValues = systolicValues;
    this.diastolicValues = diastolicValues;
  }

  setWeekRanges(ranges: string[]): void {
    this.weekRanges = ranges;
  }

  refreshContent(entry: EntryOhos, _highlight: Highlight): void {
    if (entry) {
      const xPos = entry.getX();
      const index = Math.round(xPos);

      // 获取当前数据点的血压值
      if (index >= 0 && index < this.systolicValues.length && index < this.diastolicValues.length) {
        this.systolicValue = this.systolicValues[index];
        this.diastolicValue = this.diastolicValues[index];

        // 根据索引获取日期范围
        if (index >= 0 && index < this.weekRanges.length) {
          this.dateRange = this.weekRanges[index];
        } else {
          this.dateRange = '';
        }
      } else {
        this.systolicValue = 0;
        this.diastolicValue = 0;
        this.dateRange = '';
      }
    }
  }

  draw(c: CanvasRenderingContext2D, _posX: number, _posY: number, e: EntryOhos, highlight: Highlight): void {
    this.refreshContent(e, highlight);

    if (!this.dateRange || this.systolicValue === 0 || this.diastolicValue === 0) {
      return;
    }

    if (!this.dateRange || this.dateRange.trim() === '') {
      return;
    }


    c.save();

    // 第一行：日期范围
    const dateRangeText = this.dateRange || '';
    c.font = '10vp sans-serif';
    const dateMetrics = c.measureText(dateRangeText);

    // 第二行：平均值（格式：平均 128/88 mmol/L）
    const avgText = '平均 ';
    const valueText = `${this.systolicValue}/${this.diastolicValue}`;
    const unitText = ' mmol/L';
    c.font = '16vp sans-serif'; // 平均字体改小
    const avgMetrics = c.measureText(avgText);
    c.font = 'bold 24vp sans-serif'; // 数值字体改大
    const valueMetrics = c.measureText(valueText);
    c.font = '12vp sans-serif';
    const unitMetrics = c.measureText(unitText);

    const padding = 12;
    const paddingLeft = 16;
    const dateLineHeight = 14;
    const valueLineHeight = 30;
    const totalValueWidth = avgMetrics.width + valueMetrics.width + unitMetrics.width;
    const maxWidth = Math.max(dateMetrics.width, totalValueWidth);
    const minWidth = 140;
    let boxWidth = Math.max(maxWidth + paddingLeft * 2, minWidth);
    const boxHeight = dateLineHeight + valueLineHeight + padding * 2;
    const radius = 12;

    //位置跟随逻辑：浮层垂直方向跟随数据点，但水平方向居中
    const actualChartWidth = this.chartWidth > 0 ? this.chartWidth : 400;
    let left: number = (actualChartWidth - boxWidth) / 2;

    // 默认显示在点上方
    let top: number = _posY - boxHeight - 15;

    // 边界检查：如果上方空间不足（例如高血压点），则显示在点下方
    if (top < 10) {
      top = _posY + 25;
    }

    // 绘制圆角矩形背景
    c.fillStyle = 'rgba(0, 0, 0, 0.8)';
    c.beginPath();
    c.moveTo(left + radius, top);
    c.lineTo(left + boxWidth - radius, top);
    c.arc(left + boxWidth - radius, top + radius, radius, -Math.PI / 2, 0);
    c.lineTo(left + boxWidth, top + boxHeight - radius);
    c.arc(left + boxWidth - radius, top + boxHeight - radius, radius, 0, Math.PI / 2);
    c.lineTo(left + radius, top + boxHeight);
    c.arc(left + radius, top + boxHeight - radius, radius, Math.PI / 2, Math.PI);
    c.lineTo(left, top + radius);
    c.arc(left + radius, top + radius, radius, Math.PI, -Math.PI / 2);
    c.closePath();
    c.fill();

    // 绘制文本
    c.fillStyle = '#FFFFFF';
    c.textAlign = 'left';
    c.textBaseline = 'alphabetic';

    // 绘制日期范围（灰色）
    c.fillStyle = 'rgba(150, 150, 150, 1)'; // 对应 mask_secondary 颜色
    c.font = '10vp sans-serif';
    c.fillText(dateRangeText, left + paddingLeft, top + padding + 12);

    // 绘制平均值
    const valueY = top + padding + 12 + dateLineHeight + 16;
    // "平均"使用浅灰色
    c.fillStyle = 'rgba(150, 150, 150, 1)'; // 对应 mask_secondary 颜色
    c.font = '16vp sans-serif';
    c.fillText(avgText, left + paddingLeft, valueY);
    // 数值使用白色，字体更大
    c.fillStyle = '#FFFFFF';
    c.font = 'bold 24vp sans-serif';
    c.fillText(valueText, left + paddingLeft + avgMetrics.width, valueY);
    // 单位使用灰色
    c.fillStyle = 'rgba(150, 150, 150, 1)'; // 对应 mask_secondary 颜色
    c.font = '12vp sans-serif';
    c.fillText(unitText, left + paddingLeft + avgMetrics.width + valueMetrics.width, valueY);

    c.restore();
  }
}

// 月份标签格式化器（3个月均匀分布）
class WeekFormatter implements IAxisValueFormatter {
  constructor() {
  }

  getFormattedValue(value: number, _axis: AxisBase): string {
    const i = Math.round(value);

    // 在特定位置显示月份标签：每月中间位置显示标签
    if (i === 1) {
      return '2月';
    } else if (i === 5) {
      return '3月';
    } else if (i === 9) {
      return '4月';
    }

    return '';
  }
}

@ObservedV2
export class ThreeMonthsBloodPressureChartVM {
  @Trace chartModel: LineChartModel | undefined = undefined;
  @Trace systolicValues: number[] = [];
  @Trace diastolicValues: number[] = [];
  @Trace monthLabels: string[] = [];
  @Trace currentIndex: number = 4;
  private marker: ThreeMonthsBloodPressureMarkerView | null = null;
  private onValueSelectedCallback: ((date: string, systolic: number, diastolic: number) => void) | null = null;

  private static readonly WEEK_RANGES = [
    '2月1日~2月7日', '2月8日~2月14日', '2月15日~2月21日', '2月22日~2月28日',
    '3月1日~3月7日', '3月8日~3月14日', '3月15日~3月21日', '3月22日~3月28日',
    '4月1日~4月7日', '4月8日~4月14日', '4月15日~4月21日', '4月22日~4月28日'
  ];

  public setChartWidth(width: number): void {
    if (this.marker) {
      this.marker.setChartWidth(width);
    }
  }

  public initializeChart(): void {
    this.chartModel = new LineChartModel();
    this.chartModel.getDescription()?.setEnabled(false);
    this.chartModel.setPinchZoom(false);
    this.chartModel.setDrawGridBackground(false);
    this.chartModel.setExtraOffsets(10, 20, 20, 5);
    this.chartModel.setDrawBorders(false);
    this.chartModel.setTouchEnabled(true);
    this.chartModel.setDragEnabled(false); // 禁用拖动，不需要滑动
    this.chartModel.setScaleEnabled(false);
    this.chartModel.setScaleXEnabled(false);
    this.chartModel.setScaleYEnabled(false);
    this.chartModel.setHighlightPerTapEnabled(true);
    this.chartModel.setHighlightPerDragEnabled(false);

    let legend: Legend | null = this.chartModel.getLegend();
    if (legend) {
      legend.setEnabled(false);
    }

    // 设置自定义 Marker
    this.marker = new ThreeMonthsBloodPressureMarkerView();
    this.marker.setWeekRanges(ThreeMonthsBloodPressureChartVM.WEEK_RANGES);
    this.chartModel.setMarker(this.marker);

    // 设置点击监听器
    this.chartModel.setOnChartValueSelectedListener(this);

    // 配置X轴 - 显示3个月的数据，月份标签均匀分布
    let pressureThreeMonthsXAxis: XAxis | null = this.chartModel.getXAxis();
    if (pressureThreeMonthsXAxis) {
      pressureThreeMonthsXAxis.setPosition(XAxisPosition.BOTTOM);
      pressureThreeMonthsXAxis.setGranularity(1);
      pressureThreeMonthsXAxis.setGranularityEnabled(true);
      pressureThreeMonthsXAxis.setAxisMinimum(-0.5);
      pressureThreeMonthsXAxis.setAxisMaximum(11.5); // 12个数据点，每月4个
      pressureThreeMonthsXAxis.setLabelCount(12, false); // 设置为12个标签位置，让格式化器决定显示哪些
      pressureThreeMonthsXAxis.setValueFormatter(new WeekFormatter());
      pressureThreeMonthsXAxis.setDrawGridLines(true);
      pressureThreeMonthsXAxis.setGridColor(ColorTemplate.colorRgb(230, 233, 236));
      pressureThreeMonthsXAxis.setGridLineWidth(0.6);
      pressureThreeMonthsXAxis.setTextColor(ColorTemplate.colorRgb(150, 150, 150));
    }

    // 配置Y轴（左侧）
    let pressureThreeMonthsLeftAxis: YAxis | null = this.chartModel.getAxisLeft();
    if (pressureThreeMonthsLeftAxis) {
      pressureThreeMonthsLeftAxis.setAxisMinimum(40);
      pressureThreeMonthsLeftAxis.setAxisMaximum(200);
      pressureThreeMonthsLeftAxis.setLabelCount(5, true);
      pressureThreeMonthsLeftAxis.setGranularity(40);
      pressureThreeMonthsLeftAxis.setPosition(YAxisLabelPosition.OUTSIDE_CHART);
      pressureThreeMonthsLeftAxis.setDrawGridLines(true);
      pressureThreeMonthsLeftAxis.setGridColor(ColorTemplate.colorRgb(230, 233, 236));
      pressureThreeMonthsLeftAxis.setGridLineWidth(0.6);
      pressureThreeMonthsLeftAxis.setTextColor(ColorTemplate.colorRgb(150, 150, 150));

      let systolicLimitLine: LimitLine = new LimitLine(140, '');
      systolicLimitLine.setLineWidth(1.5);
      systolicLimitLine.setLineColor(ColorTemplate.colorRgb(255, 152, 0));
      pressureThreeMonthsLeftAxis.addLimitLine(systolicLimitLine);

      let diastolicLimitLine: LimitLine = new LimitLine(100, '');
      diastolicLimitLine.setLineWidth(1.5);
      diastolicLimitLine.setLineColor(ColorTemplate.colorRgb(150, 200, 255));
      pressureThreeMonthsLeftAxis.addLimitLine(diastolicLimitLine);
    }
    this.chartModel.getAxisRight()?.setEnabled(false);

    this.updateChartData();
  }

  public updateSystolicValues(values: number[]): void {
    this.systolicValues = values.slice();
    this.updateChartData();
  }

  public updateDiastolicValues(values: number[]): void {
    this.diastolicValues = values.slice();
    this.updateChartData();
  }

  public updateMonthLabels(labels: string[]): void {
    this.monthLabels = labels.slice();
  }


  public updateCurrentIndex(index: number): void {
    this.currentIndex = index;
    this.updateChartData();
  }

  public setOnValueSelectedListener(callback: (date: string, systolic: number, diastolic: number) => void): void {
    this.onValueSelectedCallback = callback;
  }

  public onValueSelected(e: EntryOhos, _h: Highlight): void {
    const xValue = e.getX();
    const dataIndex = Math.round(xValue);

    if (dataIndex >= 0 && dataIndex < this.systolicValues.length && dataIndex < this.diastolicValues.length) {
      const systolic = this.systolicValues[dataIndex];
      const diastolic = this.diastolicValues[dataIndex];

      // 生成日期文本（根据数据点索引生成对应的日期）
      const dateText = ThreeMonthsBloodPressureChartVM.WEEK_RANGES[dataIndex];

      if (this.onValueSelectedCallback) {
        this.onValueSelectedCallback(dateText, systolic, diastolic);
      }
    }
  }

  public onNothingSelected(): void {
    // 可选：重置为默认值
  }

  private updateChartData(): void {
    if (!this.chartModel) {
      return;
    }

    // 如果没有数据，不更新图表
    if (!this.systolicValues || this.systolicValues.length === 0 || !this.diastolicValues ||
      this.diastolicValues.length === 0) {
      return;
    }

    // 只使用前12个数据点，每月4个点
    const maxDataCount = 12;
    const dataCount = Math.min(maxDataCount, this.systolicValues.length, this.diastolicValues.length);

    // 更新MarkerView的数据
    if (this.marker) {
      this.marker.setData(this.systolicValues.slice(0, maxDataCount), this.diastolicValues.slice(0, maxDataCount));
    }

    // 收缩压数据（高压） - 橙色点
    let pressureThreeMonthsSystolicEntries: JArrayList<EntryOhos> = new JArrayList<EntryOhos>();
    for (let i = 0; i < dataCount; i++) {
      pressureThreeMonthsSystolicEntries.add(new EntryOhos(i, this.systolicValues[i]));
    }

    let pressureThreeMonthsSystolicDataSet: LineDataSet = new LineDataSet(pressureThreeMonthsSystolicEntries, '');
    pressureThreeMonthsSystolicDataSet.setMode(Mode.LINEAR);
    pressureThreeMonthsSystolicDataSet.setLineWidth(0.1); // 设置极小线宽
    pressureThreeMonthsSystolicDataSet.setColorByColor(ColorTemplate.colorRgb(255, 255, 255)); // 白色线条
    pressureThreeMonthsSystolicDataSet.setDrawCircles(true);
    pressureThreeMonthsSystolicDataSet.setCircleColor(ColorTemplate.colorRgb(255, 152, 0)); // 橙色
    pressureThreeMonthsSystolicDataSet.setCircleRadius(5);
    pressureThreeMonthsSystolicDataSet.setDrawCircleHole(false);
    pressureThreeMonthsSystolicDataSet.setDrawValues(false);

    // 舒张压数据（低压） - 蓝色点
    let pressureThreeMonthsDiastolicEntries: JArrayList<EntryOhos> = new JArrayList<EntryOhos>();
    for (let i = 0; i < dataCount; i++) {
      pressureThreeMonthsDiastolicEntries.add(new EntryOhos(i, this.diastolicValues[i]));
    }

    let pressureThreeMonthsDiastolicDataSet: LineDataSet = new LineDataSet(pressureThreeMonthsDiastolicEntries, '');
    pressureThreeMonthsDiastolicDataSet.setMode(Mode.LINEAR);
    pressureThreeMonthsDiastolicDataSet.setLineWidth(0.1); // 设置极小线宽
    pressureThreeMonthsDiastolicDataSet.setColorByColor(ColorTemplate.colorRgb(255, 255, 255)); // 白色线条
    pressureThreeMonthsDiastolicDataSet.setDrawCircles(true);
    pressureThreeMonthsDiastolicDataSet.setCircleColor(ColorTemplate.colorRgb(33, 150, 243)); // 蓝色
    pressureThreeMonthsDiastolicDataSet.setCircleRadius(5);
    pressureThreeMonthsDiastolicDataSet.setDrawCircleHole(false);
    pressureThreeMonthsDiastolicDataSet.setDrawValues(false);

    let pressureThreeMonthsDataSets: JArrayList<LineDataSet> = new JArrayList<LineDataSet>();
    pressureThreeMonthsDataSets.add(pressureThreeMonthsSystolicDataSet);
    pressureThreeMonthsDataSets.add(pressureThreeMonthsDiastolicDataSet);

    let pressureThreeMonthsLineData: LineData = new LineData(pressureThreeMonthsDataSets);
    this.chartModel.setData(pressureThreeMonthsLineData);

    // 显示全部数据点，不需要滑动
    this.chartModel.setVisibleXRangeMaximum(12); // 显示全部12个数据点
    this.chartModel.setVisibleXRangeMinimum(12);
    this.chartModel.moveViewToX(-0.5); // 显示从最左侧开始
    this.chartModel.notifyDataSetChanged();
    this.chartModel.invalidate();
  }
}
