/**
 * 月度血压图表 ViewModel
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

// 血压月度MarkerView
class MonthlyBloodPressureMarkerView extends MarkerView {
  private systolicValue: number = 0;
  private diastolicValue: number = 0;
  private date: string = '';
  private chartWidth: number = 0;
  private systolicValues: number[] = [];
  private diastolicValues: number[] = [];
  private dateLabels: string[] = [];

  constructor(dateLabels: string[]) {
    super();
    this.dateLabels = dateLabels;
  }

  setChartWidth(width: number): void {
    this.chartWidth = width;
  }

  setData(systolicValues: number[], diastolicValues: number[]): void {
    this.systolicValues = systolicValues;
    this.diastolicValues = diastolicValues;
  }

  setDateLabels(dateLabels: string[]): void {
    this.dateLabels = dateLabels;
  }

  refreshContent(entry: EntryOhos, _highlight: Highlight): void {
    if (entry) {
      const xPos = entry.getX();
      const index = Math.round(xPos);

      if (index >= 0 && index < this.systolicValues.length && index < this.diastolicValues.length) {
        this.systolicValue = this.systolicValues[index];
        this.diastolicValue = this.diastolicValues[index];

        // 优先使用dateLabels中的标签，但转换为中文格式
        if (index >= 0 && index < this.dateLabels.length && this.dateLabels[index] &&
          this.dateLabels[index].trim() !== '') {
          this.date = this.convertToChineseDate(this.dateLabels[index]);
        } else {
          // 根据已有标签推算日期
          this.date = this.generateDateFromDataIndex(index);
        }
      }
    }
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

  // 根据索引生成日期
  private generateDateFromDataIndex(index: number): string {
    // 4月30天的日期映射
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

  draw(c: CanvasRenderingContext2D, _posX: number, _posY: number, e: EntryOhos, highlight: Highlight): void {
    this.refreshContent(e, highlight);

    if (!this.date || this.systolicValue === 0 || this.diastolicValue === 0) {
      return;
    }

    c.save();

    // 第一行：日期
    const dateText = this.date;
    c.font = '10vp sans-serif';
    const dateMetrics = c.measureText(dateText);

    // 第二行：平均 128/88 mmHg
    const valueText = `${this.systolicValue}/${this.diastolicValue}`;
    const avgText = '平均 ';
    c.font = '16vp sans-serif';
    const unitText = ' mmHg';
    const avgMetrics = c.measureText(avgText);
    c.font = 'bold 24vp sans-serif';
    const valueMetrics = c.measureText(valueText);
    c.font = '12vp sans-serif';
    const unitMetrics = c.measureText(unitText);

    const padding = 12;
    const paddingLeft = 16;
    const valueLineHeight = 30;
    const dateLineHeight = 14;
    const totalValueWidth = avgMetrics.width + valueMetrics.width + unitMetrics.width;
    const maxWidth = Math.max(dateMetrics.width, totalValueWidth);
    const minWidth = 140;
    let boxWidth = Math.max(maxWidth + paddingLeft * 2, minWidth);
    const boxHeight = dateLineHeight + valueLineHeight + padding * 2;
    const radius = 12;
    // 默认显示在点上方
    let top: number = _posY - boxHeight - 15;
    // 位置跟随逻辑：浮层垂直方向跟随数据点，但水平方向居中
    const actualChartWidth = this.chartWidth > 0 ? this.chartWidth : 400;
    let left: number = (actualChartWidth - boxWidth) / 2;
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

    // 绘制日期（灰色）
    c.fillStyle = 'rgba(150, 150, 150, 1)';
    c.font = '10vp sans-serif';
    c.fillText(dateText, left + paddingLeft, top + padding + 12);

    // 绘制平均值
    const valueY = top + padding + 12 + dateLineHeight + 16;
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

class DateFormatter implements IAxisValueFormatter {
  private dateLabels: Array<string> = [];

  constructor(dateLabels: Array<string>) {
    this.dateLabels = dateLabels;
  }

  getFormattedValue(value: number, _axis: AxisBase): string {
    // value对应数据点的X位置，从0开始
    const i = Math.round(value);
    if (i >= 0 && i < this.dateLabels.length) {
      // 如果有标签就返回标签
      if (this.dateLabels[i] && this.dateLabels[i].trim() !== '') {
        return this.dateLabels[i];
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

@ObservedV2
export class MonthlyBloodPressureChartVM {
  @Trace dateLabels: string[] = [];
  @Trace currentIndex: number = 4;
  @Trace chartModel: LineChartModel = new LineChartModel();
  @Trace systolicValues: number[] = [];
  @Trace diastolicValues: number[] = [];
  private marker: MonthlyBloodPressureMarkerView | null = null;
  private onValueSelectedCallback: ((date: string, systolic: number, diastolic: number) => void) | null = null;

  public initializeChart(): void {
    this.chartModel.getDescription()?.setEnabled(false);
    this.chartModel.setPinchZoom(false);
    this.chartModel.setDrawGridBackground(false);
    this.chartModel.setExtraOffsets(10, 20, 20, 5);
    this.chartModel.setDrawBorders(false);
    this.chartModel.setTouchEnabled(true); // 启用触摸以支持浮层
    this.chartModel.setDragEnabled(true); // 启用拖拽滑动
    this.chartModel.setScaleEnabled(false);
    this.chartModel.setHighlightPerTapEnabled(true); // 启用点击高亮
    this.chartModel.setHighlightPerDragEnabled(false);

    let legend: Legend | null = this.chartModel.getLegend();
    if (legend) {
      legend.setEnabled(false);
    }

    // 设置自定义 Marker
    this.marker = new MonthlyBloodPressureMarkerView(this.dateLabels);
    this.marker.setData(this.systolicValues, this.diastolicValues);
    this.chartModel.setMarker(this.marker);

    // 设置点击监听器
    this.chartModel.setOnChartValueSelectedListener(this);

    // 配置X轴
    let pressureMonthlyXAxis: XAxis | null = this.chartModel.getXAxis();
    if (pressureMonthlyXAxis) {
      pressureMonthlyXAxis.setPosition(XAxisPosition.BOTTOM);
      pressureMonthlyXAxis.setGranularity(1);
      pressureMonthlyXAxis.setGranularityEnabled(true);
      pressureMonthlyXAxis.setAxisMinimum(-0.5);
      pressureMonthlyXAxis.setAxisMaximum(this.dateLabels.length - 0.5);
      pressureMonthlyXAxis.setLabelCount(6, true); // 强制只显示6个标签，防止滑动时变化
      pressureMonthlyXAxis.setValueFormatter(new DateFormatter(this.dateLabels));
      pressureMonthlyXAxis.setDrawGridLines(true);
      pressureMonthlyXAxis.setGridColor(ColorTemplate.colorRgb(230, 233, 236));
      pressureMonthlyXAxis.setGridLineWidth(0.6);
      pressureMonthlyXAxis.setTextColor(ColorTemplate.colorRgb(150, 150, 150));
      pressureMonthlyXAxis.setYOffset(8);
      pressureMonthlyXAxis.setAvoidFirstLastClipping(true);

      // 设置可见范围，支持滑动查看完整月份数据
      if (this.dateLabels.length > 10) {
        // 如果数据点超过10个，设置可见范围为12个数据点，支持滑动
        this.chartModel.setVisibleXRangeMaximum(12);
        this.chartModel.setVisibleXRangeMinimum(8);
        // 默认显示前10个数据点（从4/1开始）
        this.chartModel.moveViewToX(-0.5);
      }
    }

    // 配置Y轴
    let pressureMonthlyLeftAxis: YAxis | null = this.chartModel.getAxisLeft();
    if (pressureMonthlyLeftAxis) {
      pressureMonthlyLeftAxis.setAxisMinimum(40);
      pressureMonthlyLeftAxis.setAxisMaximum(200);
      pressureMonthlyLeftAxis.setLabelCount(5, true);
      pressureMonthlyLeftAxis.setGranularity(40);
      pressureMonthlyLeftAxis.setPosition(YAxisLabelPosition.OUTSIDE_CHART);
      pressureMonthlyLeftAxis.setDrawGridLines(true);
      pressureMonthlyLeftAxis.setGridColor(ColorTemplate.colorRgb(230, 233, 236));
      pressureMonthlyLeftAxis.setGridLineWidth(0.6);
      pressureMonthlyLeftAxis.setTextColor(ColorTemplate.colorRgb(150, 150, 150));

      let systolicLimitLine: LimitLine = new LimitLine(140, '');
      systolicLimitLine.setLineWidth(1.5);
      systolicLimitLine.setLineColor(ColorTemplate.colorRgb(255, 200, 150));
      pressureMonthlyLeftAxis.addLimitLine(systolicLimitLine);

      let diastolicLimitLine: LimitLine = new LimitLine(100, '');
      diastolicLimitLine.setLineWidth(1.5);
      diastolicLimitLine.setLineColor(ColorTemplate.colorRgb(150, 200, 255));
      pressureMonthlyLeftAxis.addLimitLine(diastolicLimitLine);
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

  public setChartWidth(width: number): void {
    if (this.marker) {
      this.marker.setChartWidth(width);
    }
  }

  public setOnValueSelectedListener(callback: (date: string, systolic: number, diastolic: number) => void): void {
    this.onValueSelectedCallback = callback;
  }

  public updateDateLabels(labels: string[]): void {
    this.dateLabels = labels.slice();
    if (this.marker) {
      this.marker.setDateLabels(this.dateLabels);
    }
    let pressureMonthlyUpdateXAxis: XAxis | null = this.chartModel.getXAxis();
    if (pressureMonthlyUpdateXAxis) {
      pressureMonthlyUpdateXAxis.setAxisMinimum(-0.5);
      pressureMonthlyUpdateXAxis.setAxisMaximum(this.dateLabels.length - 0.5);
      pressureMonthlyUpdateXAxis.setLabelCount(6, true); // 强制只显示6个标签，防止滑动时变化
      pressureMonthlyUpdateXAxis.setValueFormatter(new DateFormatter(this.dateLabels));
      pressureMonthlyUpdateXAxis.setDrawGridLines(true);
      pressureMonthlyUpdateXAxis.setGridColor(ColorTemplate.colorRgb(230, 233, 236));
      pressureMonthlyUpdateXAxis.setGridLineWidth(0.6);
      pressureMonthlyUpdateXAxis.setYOffset(8);
      pressureMonthlyUpdateXAxis.setAvoidFirstLastClipping(true);

      // 设置可见范围，支持滑动查看完整月份数据
      if (this.dateLabels.length > 10) {
        // 如果数据点超过10个，设置可见范围为12个数据点，支持滑动
        this.chartModel.setVisibleXRangeMaximum(12);
        this.chartModel.setVisibleXRangeMinimum(8);
        // 默认显示前10个数据点（从4/1开始）
        this.chartModel.moveViewToX(-0.5);
      }
    }
    this.updateChartData();
  }

  public onValueSelected(e: EntryOhos, _h: Highlight): void {
    const xValue = e.getX();
    const dataIndex = Math.round(xValue);

    if (dataIndex >= 0 && dataIndex < this.systolicValues.length && dataIndex < this.diastolicValues.length) {
      const systolic = this.systolicValues[dataIndex];
      const diastolic = this.diastolicValues[dataIndex];

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
        this.onValueSelectedCallback(dateText, systolic, diastolic);
      }
    }
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

  public onNothingSelected(): void {
    // 可选：重置为默认值
  }

  public updateCurrentIndex(index: number): void {
    this.currentIndex = index;
    this.updateChartData();
  }

  private generateDateFromDataIndex(index: number): string {
    // 4月30天的日期映射
    const dateMappingList = [
      '04月01日', '04月02日', '04月03日', '04月04日', '04月05日',
      '04月06日', '04月07日', '04月08日', '04月09日', '04月10日',
      '04月11日', '04月12日', '04月13日', '04月14日', '04月15日',
      '04月16日', '04月17日', '04月18日', '04月19日', '04月20日',
      '04月21日', '04月22日', '04月23日', '04月24日', '04月25日',
      '04月26日', '04月27日', '04月28日', '04月29日', '04月30日'
    ];
    if (index >= 0 && index < dateMappingList.length) {
      return dateMappingList[index];
    }
    // 超出范围时的备用逻辑
    return `04月${String(index + 1).padStart(2, '0')}日`;
  }

  private updateChartData(): void {
    if (this.systolicValues.length === 0 || this.diastolicValues.length === 0) {
      return;
    }

    // 更新MarkerView的数据
    if (this.marker) {
      this.marker.setData(this.systolicValues, this.diastolicValues);
    }

    // 根据实际数据长度更新X轴范围
    const dataLength = this.systolicValues.length;
    let xAxis: XAxis | null = this.chartModel.getXAxis();
    if (xAxis) {
      xAxis.setAxisMinimum(-0.5);
      xAxis.setAxisMaximum(dataLength - 0.5);
      // 保持与updateDateLabels中一致的配置
      xAxis.setLabelCount(6, true); // 强制只显示6个标签，防止滑动时变化
      xAxis.setValueFormatter(new DateFormatter(this.dateLabels));
    }

    // 收缩压数据（高压） - 显示所有数据点
    let pressureMonthlySystolicEntries: JArrayList<EntryOhos> = new JArrayList<EntryOhos>();
    for (let i = 0; i < this.systolicValues.length; i++) {
      pressureMonthlySystolicEntries.add(new EntryOhos(i, this.systolicValues[i]));
    }

    let pressureMonthlySystolicDataSet: LineDataSet = new LineDataSet(pressureMonthlySystolicEntries, '');
    pressureMonthlySystolicDataSet.setMode(Mode.LINEAR);
    pressureMonthlySystolicDataSet.setLineWidth(0.1); // 设置极小线宽
    pressureMonthlySystolicDataSet.setColorByColor(ColorTemplate.colorRgb(255, 255, 255)); // 白色线条
    pressureMonthlySystolicDataSet.setDrawCircles(true);
    pressureMonthlySystolicDataSet.setCircleColor(ColorTemplate.colorRgb(255, 152, 0));
    pressureMonthlySystolicDataSet.setCircleRadius(5);
    pressureMonthlySystolicDataSet.setDrawCircleHole(false);
    pressureMonthlySystolicDataSet.setDrawValues(false);

    // 舒张压数据（低压） - 显示所有数据点
    let pressureMonthlyDiastolicEntries: JArrayList<EntryOhos> = new JArrayList<EntryOhos>();
    for (let i = 0; i < this.diastolicValues.length; i++) {
      pressureMonthlyDiastolicEntries.add(new EntryOhos(i, this.diastolicValues[i]));
    }

    let pressureMonthlyDiastolicDataSet: LineDataSet = new LineDataSet(pressureMonthlyDiastolicEntries, '');
    pressureMonthlyDiastolicDataSet.setMode(Mode.LINEAR);
    pressureMonthlyDiastolicDataSet.setLineWidth(0.1); // 设置极小线宽
    pressureMonthlyDiastolicDataSet.setColorByColor(ColorTemplate.colorRgb(255, 255, 255)); // 白色线条
    pressureMonthlyDiastolicDataSet.setDrawCircles(true);
    pressureMonthlyDiastolicDataSet.setCircleColor(ColorTemplate.colorRgb(33, 150, 243));
    pressureMonthlyDiastolicDataSet.setCircleRadius(5);
    pressureMonthlyDiastolicDataSet.setDrawCircleHole(false);
    pressureMonthlyDiastolicDataSet.setDrawValues(false);

    let pressureMonthlyDataSets: JArrayList<LineDataSet> = new JArrayList<LineDataSet>();
    pressureMonthlyDataSets.add(pressureMonthlySystolicDataSet);
    pressureMonthlyDataSets.add(pressureMonthlyDiastolicDataSet);

    let pressureMonthlyLineData: LineData = new LineData(pressureMonthlyDataSets);
    this.chartModel.setData(pressureMonthlyLineData);
    this.chartModel.notifyDataSetChanged();
    this.chartModel.invalidate();
  }
}
