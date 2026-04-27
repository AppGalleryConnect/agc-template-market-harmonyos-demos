/**
 * 周度心率图表 ViewModel
 */
import {
  AxisBase,
  IAxisValueFormatter,
  JArrayList,
  Legend,
  WaterfallChartModel,
  WaterfallEntry,
  WaterfallDataSet,
  WaterfallData,
  IWaterfallDataSet,
  XAxis,
  XAxisPosition,
  YAxis,
  YAxisLabelPosition,
  ColorTemplate,
  MarkerView,
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

class HRWeeklyMarkerView extends MarkerView {
  private label: string = '';
  private rangeText: string = '';
  private ranges: Array<[number, number]> = [];

  constructor(ranges: Array<[number, number]>) {
    super();
    this.ranges = ranges;
  }

  setRanges(ranges: Array<[number, number]>): void {
    this.ranges = ranges;
  }

  refreshContent(entry: WaterfallEntry, _highlight: Highlight): void {
    const index = Math.round(entry.getX());
    const weekdays = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
    if (index >= 0 && index < weekdays.length) {
      this.label = weekdays[index];
    }

    // 从 ranges 数组中获取对应的值
    const rangeIndex = index;
    if (rangeIndex >= 0 && rangeIndex < this.ranges.length) {
      const low = Math.round(this.ranges[rangeIndex][0]);
      const high = Math.round(this.ranges[rangeIndex][1]);
      this.rangeText = `${low}-${high}`;
    }
  }

  draw(c: CanvasRenderingContext2D, posX: number, _posY: number, e: WaterfallEntry, highlight: Highlight): void {
    this.refreshContent(e, highlight);
    c.save();

    const title = this.label || '';
    c.font = '10vp sans-serif';
    const titleMetrics = c.measureText(title);

    // 分别测量数字和单位
    c.font = 'bold 28vp sans-serif';
    const rangeMetrics = c.measureText(this.rangeText);
    c.font = '14vp sans-serif';
    const unitMetrics = c.measureText(' 次/分');

    const padding = 10;
    const paddingLeft = 12;
    const titleLineHeight = 14;
    const rangeLineHeight = 32;
    const totalRangeWidth = rangeMetrics.width + unitMetrics.width;
    const maxWidth = Math.max(titleMetrics.width, totalRangeWidth);
    const boxWidth = maxWidth + paddingLeft * 2;
    const boxHeight = titleLineHeight + rangeLineHeight + padding * 2;
    const radius = 8;

    let left = posX - boxWidth / 2;
    const top = 10;
    if (e.getX() > 5.5) {
      left = posX - boxWidth - 10;
    }
    if (left < 10) {
      left = 10;
    }

    c.fillStyle = 'rgba(0,0,0,0.8)';
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

    c.fillStyle = '#FFFFFF';
    c.textAlign = 'left';
    c.textBaseline = 'alphabetic';

    // 绘制日期
    c.font = '10vp sans-serif';
    c.fillText(title, left + paddingLeft, top + padding + 10);

    // 绘制心率范围
    const rangeY = top + padding + 10 + titleLineHeight + 18;
    c.font = 'bold 28vp sans-serif';
    c.fillText(this.rangeText, left + paddingLeft, rangeY);

    c.font = '14vp sans-serif';
    c.fillText(' 次/分', left + paddingLeft + rangeMetrics.width, rangeY);

    c.restore();
  }
}

@ObservedV2
export class WeeklyHeartRateChartVM {
  @Trace chartModel: WaterfallChartModel = new WaterfallChartModel();
  @Trace ranges: Array<[number, number]> = [];
  @Trace currentIndex: number = 3;
  private markerView: HRWeeklyMarkerView | null = null;

  public initializeChart(): void {
    this.chartModel.getDescription()?.setEnabled(false);
    this.chartModel.setPinchZoom(false);
    this.chartModel.setDrawGridBackground(false);
    this.chartModel.setTouchEnabled(true);
    this.chartModel.setDragEnabled(false);
    this.chartModel.setScaleEnabled(false);
    this.chartModel.setDrawValueAboveBar(false);
    this.chartModel.setExtraOffsets(3, 15, 15, 3);
    this.chartModel.setHighlightPerTapEnabled(true);
    this.chartModel.setHighlightPerDragEnabled(false);

    // MarkerView
    this.markerView = new HRWeeklyMarkerView(this.ranges);
    this.chartModel.setMarker(this.markerView);

    let legend: Legend | null = this.chartModel.getLegend();
    if (legend) {
      legend.setEnabled(false);
    }

    let heartRateWeeklyXAxis: XAxis | null = this.chartModel.getXAxis();
    if (heartRateWeeklyXAxis) {
      heartRateWeeklyXAxis.setPosition(XAxisPosition.BOTTOM);
      heartRateWeeklyXAxis.setGranularity(1);
      heartRateWeeklyXAxis.setGranularityEnabled(true);
      heartRateWeeklyXAxis.setAxisMinimum(-0.5);
      heartRateWeeklyXAxis.setAxisMaximum(6.5);
      heartRateWeeklyXAxis.setLabelCount(7, false);
      heartRateWeeklyXAxis.setValueFormatter(new WeekdayFormatter());
      heartRateWeeklyXAxis.setDrawGridLines(true);
      heartRateWeeklyXAxis.setGridColor(ColorTemplate.colorRgb(240, 240, 240));
      heartRateWeeklyXAxis.setGridLineWidth(0.8);
      heartRateWeeklyXAxis.setTextColor(ColorTemplate.colorRgb(150, 150, 150));
    }

    let heartRateWeeklyLeftAxis: YAxis | null = this.chartModel.getAxisLeft();
    if (heartRateWeeklyLeftAxis) {
      heartRateWeeklyLeftAxis.setAxisMinimum(0);
      heartRateWeeklyLeftAxis.setAxisMaximum(150);
      heartRateWeeklyLeftAxis.setLabelCount(6, true);
      heartRateWeeklyLeftAxis.setPosition(YAxisLabelPosition.OUTSIDE_CHART);
      heartRateWeeklyLeftAxis.setDrawGridLines(true);
      heartRateWeeklyLeftAxis.setGridColor(ColorTemplate.colorRgb(240, 240, 240));
      heartRateWeeklyLeftAxis.setGridLineWidth(0.8);
      heartRateWeeklyLeftAxis.setTextColor(ColorTemplate.colorRgb(150, 150, 150));
    }
    this.chartModel.getAxisRight()?.setEnabled(false);
  }

  public updateCurrentIndex(index: number): void {
    this.updateChartData();
    this.currentIndex = index;
  }

  public updateRanges(newRanges: Array<[number, number]>): void {
    this.ranges = newRanges.map(range => [range[0], range[1]]);
    if (this.markerView) {
      this.markerView.setRanges(this.ranges);
    }
    this.updateChartData();
  }

  private updateChartData(): void {
    if (this.ranges.length === 0) {
      return;
    }

    let heartRateWeeklyValues: JArrayList<WaterfallEntry> = new JArrayList<WaterfallEntry>();
    for (let i = 0; i < this.ranges.length; i++) {
      const low: number = this.ranges[i][0];
      const high: number = this.ranges[i][1];
      // X轴位置从0开始，平均分布
      heartRateWeeklyValues.add(new WaterfallEntry(i, low, high));
    }

    let heartRateWeeklyDataSet: WaterfallDataSet = new WaterfallDataSet(heartRateWeeklyValues, '');
    heartRateWeeklyDataSet.setDrawIcons(false);
    heartRateWeeklyDataSet.setColorByColor(0x80FF6D6D);
    heartRateWeeklyDataSet.setHighLightColor(ColorTemplate.colorRgb(255, 133, 51)); // 橙色高亮
    heartRateWeeklyDataSet.setDrawValues(false);

    let heartRateWeeklyDataSets: JArrayList<IWaterfallDataSet> = new JArrayList<IWaterfallDataSet>();
    heartRateWeeklyDataSets.add(heartRateWeeklyDataSet);
    let heartRateWeeklyData: WaterfallData = new WaterfallData(heartRateWeeklyDataSets);
    heartRateWeeklyData.setDrawValues(false);
    heartRateWeeklyData.setBarWidth(0.12);

    this.chartModel.setData(heartRateWeeklyData);
    this.chartModel.notifyDataSetChanged();
    this.chartModel.invalidate();
  }
}

