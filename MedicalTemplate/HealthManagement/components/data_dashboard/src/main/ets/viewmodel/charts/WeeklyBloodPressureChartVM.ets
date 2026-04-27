/**
 * 周度血压图表 ViewModel
 */
import {
  AxisBase,
  ColorTemplate,
  EntryOhos,
  Highlight,
  IAxisValueFormatter,
  JArrayList,
  Legend,
  LimitLine,
  LineChartModel,
  LineData,
  LineDataSet,
  MarkerView,
  Mode,
  XAxis,
  XAxisPosition,
  YAxis,
  YAxisLabelPosition
} from '@ohos/mpchart';

// 血压周度MarkerView
class WeeklyBloodPressureMarkerView extends MarkerView {
  private systolicValue: number = 0;
  private diastolicValue: number = 0;
  private weekday: string = '';
  private chartWidth: number = 0;
  private systolicValues: number[] = [];
  private diastolicValues: number[] = [];

  constructor() {
    super();
  }

  setData(systolicValues: number[], diastolicValues: number[]): void {
    this.systolicValues = systolicValues;
    this.diastolicValues = diastolicValues;
  }

  refreshContent(entry: EntryOhos, _highlight: Highlight): void {
    if (entry) {
      const xPos = entry.getX();
      const index = Math.round(xPos) - 1; // X轴从1开始，数组从0开始

      if (index >= 0 && index < this.systolicValues.length && index < this.diastolicValues.length) {
        this.systolicValue = this.systolicValues[index];
        this.diastolicValue = this.diastolicValues[index];

        const weekdays = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
        this.weekday = weekdays[index] || '';
      }
    }
  }

  setChartWidth(width: number): void {
    this.chartWidth = width;
  }

  draw(c: CanvasRenderingContext2D, _posX: number, _posY: number, e: EntryOhos, highlight: Highlight): void {
    this.refreshContent(e, highlight);

    if (!this.weekday || this.systolicValue === 0 || this.diastolicValue === 0) {
      return;
    }

    c.save();

    // 第一行：星期
    const weekdayText = this.weekday;
    c.font = '10vp sans-serif';
    const weekdayMetrics = c.measureText(weekdayText);

    // 第二行：平均 128/88 mmHg
    const avgText = '平均 ';
    const valueText = `${this.systolicValue}/${this.diastolicValue}`;
    const unitText = ' mmHg';
    c.font = '16vp sans-serif';
    const avgMetrics = c.measureText(avgText);
    c.font = 'bold 24vp sans-serif';
    const valueMetrics = c.measureText(valueText);
    c.font = '12vp sans-serif';
    const unitMetrics = c.measureText(unitText);

    const padding = 12;
    const paddingLeft = 16;
    const weekdayLineHeight = 14;
    const valueLineHeight = 30;
    const totalValueWidth = avgMetrics.width + valueMetrics.width + unitMetrics.width;
    const maxWidth = Math.max(weekdayMetrics.width, totalValueWidth);
    const minWidth = 140;
    let boxWidth = Math.max(maxWidth + paddingLeft * 2, minWidth);
    const boxHeight = weekdayLineHeight + valueLineHeight + padding * 2;
    const radius = 12;

    // 固定在图表顶部中间位置
    const actualChartWidth = this.chartWidth > 0 ? this.chartWidth : 400;
    let left: number = (actualChartWidth - boxWidth) / 2;
    const top: number = 20; // 增加距离顶部的距离，避免圆角被截断

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

    // 绘制星期（灰色）
    c.fillStyle = 'rgba(150, 150, 150, 1)';
    c.font = '10vp sans-serif';
    c.fillText(weekdayText, left + paddingLeft, top + padding + 12);

    // 绘制平均值
    const valueY = top + padding + 12 + weekdayLineHeight + 16;
    c.fillStyle = 'rgba(150, 150, 150, 1)';
    c.font = '16vp sans-serif';
    c.fillText(avgText, left + paddingLeft, valueY);
    c.fillStyle = '#FFFFFF';
    c.font = 'bold 24vp sans-serif';
    c.fillText(valueText, left + paddingLeft + avgMetrics.width, valueY);
    c.fillStyle = 'rgba(150, 150, 150, 1)';
    c.font = '12vp sans-serif';
    c.fillText(unitText, left + paddingLeft + avgMetrics.width + valueMetrics.width, valueY);

    c.restore();
  }
}

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

@ObservedV2
export class WeeklyBloodPressureChartVM {
  @Trace chartModel: LineChartModel = new LineChartModel();
  @Trace systolicValues: number[] = [130, 135, 120, 128, 125, 132, 118];
  @Trace diastolicValues: number[] = [95, 110, 100, 98, 96, 105, 92];
  @Trace currentIndex: number = 3;
  private onValueSelectedCallback: ((date: string, systolic: number, diastolic: number) => void) | null = null;
  private marker: WeeklyBloodPressureMarkerView | null = null;

  public initializeChart(): void {
    this.chartModel.setTouchEnabled(true); // 启用触摸以支持浮层
    this.chartModel.setDragEnabled(false); // 禁用拖动
    this.chartModel.setScaleEnabled(false);
    this.chartModel.setHighlightPerTapEnabled(true); // 启用点击高亮
    this.chartModel.setHighlightPerDragEnabled(false);
    this.chartModel.getDescription()?.setEnabled(false);
    this.chartModel.setPinchZoom(false);
    this.chartModel.setDrawGridBackground(false);
    this.chartModel.setExtraOffsets(10, 20, 20, 5);
    this.chartModel.setDrawBorders(false);

    let legend: Legend | null = this.chartModel.getLegend();
    if (legend) {
      legend.setEnabled(false);
    }

    // 设置自定义 Marker
    this.marker = new WeeklyBloodPressureMarkerView();
    this.marker.setData(this.systolicValues, this.diastolicValues);
    this.chartModel.setMarker(this.marker);

    // 设置点击监听器
    this.chartModel.setOnChartValueSelectedListener(this);

    // 配置X轴
    let pressureXAxis: XAxis | null = this.chartModel.getXAxis();
    if (pressureXAxis) {
      pressureXAxis.setPosition(XAxisPosition.BOTTOM);
      pressureXAxis.setGranularity(1);
      pressureXAxis.setGranularityEnabled(true);
      pressureXAxis.setAxisMinimum(0.5); // 调整最小值，避免点挤在Y轴上
      pressureXAxis.setAxisMaximum(7.5); // 调整最大值
      pressureXAxis.setLabelCount(7, false);
      pressureXAxis.setValueFormatter(new WeekdayFormatter());
      pressureXAxis.setDrawGridLines(true);
      pressureXAxis.setGridColor(ColorTemplate.colorRgb(230, 233, 236));
      pressureXAxis.setGridLineWidth(0.6);
      pressureXAxis.setTextColor(ColorTemplate.colorRgb(150, 150, 150));
    }

    // 配置Y轴
    let pressureLeftAxis: YAxis | null = this.chartModel.getAxisLeft();
    if (pressureLeftAxis) {
      pressureLeftAxis.setAxisMinimum(40);
      pressureLeftAxis.setAxisMaximum(200);
      pressureLeftAxis.setLabelCount(5, true);
      pressureLeftAxis.setGranularity(40);
      pressureLeftAxis.setPosition(YAxisLabelPosition.OUTSIDE_CHART);
      pressureLeftAxis.setDrawGridLines(true);
      pressureLeftAxis.setGridColor(ColorTemplate.colorRgb(230, 233, 236));
      pressureLeftAxis.setGridLineWidth(0.6);
      pressureLeftAxis.setTextColor(ColorTemplate.colorRgb(150, 150, 150));

      // 添加收缩压参考线（140 mmHg）
      let systolicLimitLine: LimitLine = new LimitLine(140, '');
      systolicLimitLine.setLineWidth(1.5);
      systolicLimitLine.setLineColor(ColorTemplate.colorRgb(255, 200, 150));
      pressureLeftAxis.addLimitLine(systolicLimitLine);

      // 添加舒张压参考线（100 mmHg）
      let diastolicLimitLine: LimitLine = new LimitLine(100, '');
      diastolicLimitLine.setLineWidth(1.5);
      diastolicLimitLine.setLineColor(ColorTemplate.colorRgb(150, 200, 255));
      pressureLeftAxis.addLimitLine(diastolicLimitLine);
    }
    this.chartModel.getAxisRight()?.setEnabled(false);

    this.updateChartData();
  }

  public updateSystolicValues(values: number[]): void {
    this.updateChartData();
    this.systolicValues = values.slice();
  }

  public updateDiastolicValues(values: number[]): void {
    this.updateChartData();
    this.diastolicValues = values.slice();
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
    const dataIndex = Math.round(xValue - 1); // X轴从1开始，数组从0开始

    if (dataIndex >= 0 && dataIndex < this.systolicValues.length && dataIndex < this.diastolicValues.length) {
      const systolic = this.systolicValues[dataIndex];
      const diastolic = this.diastolicValues[dataIndex];

      // 生成日期文本（04月27日(周三)格式）
      const dateText = this.generateDateWithWeekday(dataIndex);

      if (this.onValueSelectedCallback) {
        this.onValueSelectedCallback(dateText, systolic, diastolic);
      }
    }
  }

  public onNothingSelected(): void {
    // 可选：重置为默认值
  }

  private generateDateWithWeekday(index: number): string {
    // 生成04月27日(周三)格式的日期
    const weekdays = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];

    // 基于当前显示：2025年04月24日 - 04月30日，从04月27日(周日)开始
    const baseDate = new Date(2025, 3, 24); // 2025年4月24日(周日)
    const targetDate = new Date(baseDate.getTime() + index * 24 * 60 * 60 * 1000);

    const month = String(targetDate.getMonth() + 1).padStart(2, '0');
    const day = String(targetDate.getDate()).padStart(2, '0');
    const weekday = weekdays[index];

    return `${month}月${day}日(${weekday})`;
  }

  private updateChartData(): void {
    if (this.systolicValues.length === 0 || this.diastolicValues.length === 0) {
      return;
    }

    // 更新MarkerView的数据
    if (this.marker) {
      this.marker.setData(this.systolicValues, this.diastolicValues);
    }

    // 收缩压数据（高压） - 显示所有数据点
    let systolicList: JArrayList<EntryOhos> = new JArrayList<EntryOhos>();
    for (let i = 0; i < this.systolicValues.length; i++) {
      systolicList.add(new EntryOhos(i + 1, this.systolicValues[i]));
    }

    let systolic: LineDataSet = new LineDataSet(systolicList, '');
    systolic.setMode(Mode.LINEAR);
    systolic.setLineWidth(0.1); // 设置极小线宽
    systolic.setColorByColor(ColorTemplate.colorRgb(255, 255, 255)); // 白色线条（与背景融合）
    systolic.setDrawCircles(true);
    systolic.setCircleColor(ColorTemplate.colorRgb(255, 152, 0));
    systolic.setCircleRadius(5);
    systolic.setDrawCircleHole(false);
    systolic.setDrawValues(false);

    // 舒张压数据（低压） - 显示所有数据点
    let diastolicList: JArrayList<EntryOhos> = new JArrayList<EntryOhos>();
    for (let i = 0; i < this.diastolicValues.length; i++) {
      diastolicList.add(new EntryOhos(i + 1, this.diastolicValues[i]));
    }

    let diastolic: LineDataSet = new LineDataSet(diastolicList, '');
    diastolic.setMode(Mode.LINEAR);
    diastolic.setLineWidth(0.1); // 设置极小线宽
    diastolic.setColorByColor(ColorTemplate.colorRgb(255, 255, 255)); // 白色线条（与背景融合）
    diastolic.setDrawCircles(true);
    diastolic.setCircleColor(ColorTemplate.colorRgb(33, 150, 243));
    diastolic.setCircleRadius(5);
    diastolic.setDrawCircleHole(false);
    diastolic.setDrawValues(false);

    let sets: JArrayList<LineDataSet> = new JArrayList<LineDataSet>();
    sets.add(systolic);
    sets.add(diastolic);

    let lineData: LineData = new LineData(sets);
    this.chartModel.setData(lineData);
    this.chartModel.notifyDataSetChanged();
    this.chartModel.invalidate();
  }

  public setChartWidth(width: number): void {
    if (this.marker) {
      this.marker.setChartWidth(width);
    }
  }
}

