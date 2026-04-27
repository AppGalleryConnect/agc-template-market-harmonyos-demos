/**
 * 三个月心率瀑布图 ViewModel
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

class MonthFormatter implements IAxisValueFormatter {
  private labels: Array<string> = [];

  constructor(labels: Array<string>) {
    this.labels = labels;
  }

  getFormattedValue(value: number, _axis: AxisBase): string {
    const centers = [0, 1.49, 3];
    const tolerance = 0.1;

    for (let i = 0; i < centers.length && i < this.labels.length; i++) {
      if (Math.abs(value - centers[i]) <= tolerance) {
        return this.labels[i];
      }
    }
    return '';
  }
}

class HRThreeMonthsMarkerView extends MarkerView {
  private label: string = '';
  private tooltipLabels: Array<string> = [];
  private rangeText: string = '';

  constructor(tooltipLabels: Array<string>, rangeText: string) {
    super();
    this.tooltipLabels = tooltipLabels;
    this.rangeText = rangeText;
  }

  setTooltipLabels(tooltipLabels: Array<string>): void {
    this.tooltipLabels = tooltipLabels;
  }

  refreshContent(entry: WaterfallEntry, _highlight: Highlight): void {
    // 根据 x 坐标推算所在组和组内索引
    const x = entry.getX();
    const totalWidth = 3;
    const spacing = this.tooltipLabels.length > 1 ? totalWidth / (this.tooltipLabels.length - 1) : 0;

    let dataIndex = 0;
    if (spacing > 0) {
      dataIndex = Math.round(x / spacing);
    }

    // 确保索引在有效范围内
    dataIndex = Math.max(0, Math.min(dataIndex, this.tooltipLabels.length - 1));

    if (dataIndex >= 0 && dataIndex < this.tooltipLabels.length) {
      this.label = this.tooltipLabels[dataIndex];
    } else {
      this.label = '';
    }
  }

  draw(c: CanvasRenderingContext2D, posX: number, _posY: number, e: WaterfallEntry, highlight: Highlight): void {
    this.refreshContent(e, highlight);
    c.save();

    // 第一行：日期
    const dateText = this.label || '';
    c.font = '10vp sans-serif';
    const dateMetrics = c.measureText(dateText);

    // 第二行：心率值（数字大，单位小）
    const valueNumber = this.rangeText;
    const unitText = ' 次/分';
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

    let left = posX - boxWidth / 2;
    const top = 10;
    if (e.getX() > 1.5) {
      left = posX - boxWidth - 10;
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
    c.textAlign = 'left';
    c.textBaseline = 'alphabetic';

    // 绘制日期（左对齐，贴着左上角）
    c.font = '10vp sans-serif';
    c.fillText(dateText, left + paddingLeft, top + padding + 10);

    // 绘制心率值（数字大，单位小）
    const valueY = top + padding + 10 + dateLineHeight + 18;
    c.font = 'bold 28vp sans-serif';
    c.fillText(valueNumber, left + paddingLeft, valueY);

    c.font = '14vp sans-serif';
    c.fillText(unitText, left + paddingLeft + valueMetrics.width + 4, valueY);

    c.restore();
  }
}

@ObservedV2
export class ThreeMonthsHeartRateChartVM {
  @Trace chartModel: WaterfallChartModel | undefined = undefined;
  @Trace ranges: [number, number][] = [];
  @Trace monthLabels: string[] = [];
  @Trace rangeText: string = '';
  @Trace currentIndex: number = 4;
  @Trace tooltipLabels: string[] = [];
  private markerView: HRThreeMonthsMarkerView | null = null;

  public initializeChart(): void {
    this.chartModel = new WaterfallChartModel();
    this.chartModel.getDescription()?.setEnabled(false);
    this.chartModel.setPinchZoom(false);
    this.chartModel.setDrawGridBackground(false);
    this.chartModel.setDrawValueAboveBar(false);
    this.chartModel.setExtraOffsets(3, 15, 15, 3);
    this.chartModel.setTouchEnabled(true);
    this.chartModel.setDragEnabled(false);
    this.chartModel.setScaleEnabled(false);
    this.chartModel.setHighlightPerTapEnabled(true);
    this.chartModel.setHighlightPerDragEnabled(false);

    let legend: Legend | null = this.chartModel.getLegend();
    if (legend) {
      legend.setEnabled(false);
    }

    let heartRateThreeMonthsXAxis: XAxis | null = this.chartModel.getXAxis();
    if (heartRateThreeMonthsXAxis) {
      heartRateThreeMonthsXAxis.setPosition(XAxisPosition.BOTTOM);
      heartRateThreeMonthsXAxis.setGranularity(0.01);
      heartRateThreeMonthsXAxis.setGranularityEnabled(true);
      heartRateThreeMonthsXAxis.setAxisMinimum(-0.5);
      heartRateThreeMonthsXAxis.setAxisMaximum(3.5);
      heartRateThreeMonthsXAxis.setLabelCount(350, false);
      heartRateThreeMonthsXAxis.setValueFormatter(new MonthFormatter(this.monthLabels));
      heartRateThreeMonthsXAxis.setDrawGridLines(false);
      heartRateThreeMonthsXAxis.setTextColor(ColorTemplate.colorRgb(150, 150, 150));
      heartRateThreeMonthsXAxis.setYOffset(0);
    }

    let heartRateThreeMonthsLeftAxis: YAxis | null = this.chartModel.getAxisLeft();
    if (heartRateThreeMonthsLeftAxis) {
      heartRateThreeMonthsLeftAxis.setAxisMinimum(0);
      heartRateThreeMonthsLeftAxis.setAxisMaximum(150);
      heartRateThreeMonthsLeftAxis.setLabelCount(6, true);
      heartRateThreeMonthsLeftAxis.setPosition(YAxisLabelPosition.OUTSIDE_CHART);
      heartRateThreeMonthsLeftAxis.setDrawGridLines(true);
      heartRateThreeMonthsLeftAxis.setGridColor(ColorTemplate.colorRgb(240, 240, 240));
      heartRateThreeMonthsLeftAxis.setGridLineWidth(0.8);
      heartRateThreeMonthsLeftAxis.setTextColor(ColorTemplate.colorRgb(150, 150, 150));
    }
    this.chartModel.getAxisRight()?.setEnabled(false);

    this.updateChartData();
  }

  public updateRanges(ranges: [number, number][]): void {
    this.ranges = ranges.slice();
    this.updateChartData();
  }

  public updateMonthLabels(labels: string[]): void {
    this.monthLabels = labels.slice();
    if (this.chartModel) {
      let heartRateThreeMonthsUpdateXAxis: XAxis | null = this.chartModel.getXAxis();
      if (heartRateThreeMonthsUpdateXAxis) {
        heartRateThreeMonthsUpdateXAxis.setValueFormatter(new MonthFormatter(this.monthLabels));
      }
    }
    this.updateChartData();
  }


  public updateRangeText(text: string): void {
    this.rangeText = text;
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
    this.updateChartData();
  }


  private updateChartData(): void {
    if (this.ranges.length === 0) {
      return;
    }

    let heartRateThreeMonthsValues: JArrayList<WaterfallEntry> = new JArrayList<WaterfallEntry>();
    const totalWidth = 3; // 从0到3的总宽度
    const spacing = totalWidth / (this.ranges.length - 1); // 计算间距

    for (let i = 0; i < this.ranges.length; i++) {
      const pair: [number, number] = this.ranges[i];
      const originalLow: number = pair[0];
      const originalHigh: number = pair[1];

      const shouldShortenRange = i % 3 === 1 || i % 5 === 2;
      let finalLow: number = originalLow;
      let finalHigh: number = originalHigh;

      if (shouldShortenRange) {
        const center = (originalLow + originalHigh) / 2;
        const shortRange = (originalHigh - originalLow) * 0.3;
        finalLow = center - shortRange / 2;
        finalHigh = center + shortRange / 2;
      }

      const x: number = i * spacing;
      heartRateThreeMonthsValues.add(new WaterfallEntry(x, finalLow, finalHigh));
    }

    let heartRateThreeMonthsDataSet: WaterfallDataSet = new WaterfallDataSet(heartRateThreeMonthsValues, '');
    heartRateThreeMonthsDataSet.setDrawIcons(false);
    heartRateThreeMonthsDataSet.setColorByColor(0x80FF6D6D);
    heartRateThreeMonthsDataSet.setHighLightColor(ColorTemplate.colorRgb(255, 133, 51));
    heartRateThreeMonthsDataSet.setDrawValues(false);

    let heartRateThreeMonthsDataSets: JArrayList<IWaterfallDataSet> = new JArrayList<IWaterfallDataSet>();
    heartRateThreeMonthsDataSets.add(heartRateThreeMonthsDataSet);
    let heartRateThreeMonthsData: WaterfallData = new WaterfallData(heartRateThreeMonthsDataSets);
    heartRateThreeMonthsData.setDrawValues(false);
    heartRateThreeMonthsData.setBarWidth(0.05);

    // MarkerView
    const effectiveTooltipLabels = this.tooltipLabels.length > 0 ? this.tooltipLabels : this.monthLabels;
    this.markerView = new HRThreeMonthsMarkerView(effectiveTooltipLabels, this.rangeText);
    this.chartModel?.setMarker(this.markerView);

    this.chartModel?.setData(heartRateThreeMonthsData);
    this.chartModel?.notifyDataSetChanged();
    this.chartModel?.invalidate();
  }
}
