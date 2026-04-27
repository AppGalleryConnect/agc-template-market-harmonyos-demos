/**
 * 月度心率图表 ViewModel
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

class FiveLabelFormatter implements IAxisValueFormatter {
  private labels: Array<string> = [];

  constructor(labels: Array<string>) {
    this.labels = labels;
  }

  getFormattedValue(value: number, _axis: AxisBase): string {
    // labels数组包含空字符串，直接使用索引
    const index = Math.round(value);
    if (index >= 0 && index < this.labels.length) {
      // 如果有标签就返回标签
      if (this.labels[index] && this.labels[index].trim() !== '') {
        return this.labels[index];
      }
      // 如果没有标签，根据索引生成日期
      const day = index + 1;
      if (day <= 30) { // 4月有30天
        return `4/${day}`;
      }
    }
    return '';
  }
}

class HRMonthlyMarkerView extends MarkerView {
  private label: string = '';
  private rangeText: string = '';
  private groupSizes: Array<number> = [];
  private ranges: Array<[number, number]> = [];
  private chartWidth: number = 0;

  constructor(groupSizes: Array<number>, ranges: Array<[number, number]>) {
    super();
    this.groupSizes = groupSizes;
    this.ranges = ranges;
  }

  setData(groupSizes: Array<number>, ranges: Array<[number, number]>): void {
    this.groupSizes = groupSizes;
    this.ranges = ranges;
  }

  setChartWidth(width: number): void {
    this.chartWidth = width;
  }

  refreshContent(entry: WaterfallEntry, _highlight: Highlight): void {
    const x = entry.getX();

    // 15个分组的中心点，与updateChartData中保持一致
    const centers: Array<number> = [0, 2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24, 26, 28];

    // 找到最接近的分组
    let groupIdx = -1;
    let minDistance = Number.MAX_VALUE;
    for (let i = 0; i < centers.length; i++) {
      const distance = Math.abs(x - centers[i]);
      if (distance < minDistance) {
        minDistance = distance;
        groupIdx = i;
      }
    }

    // 计算数据索引
    let rangeIdx = 0;
    for (let i = 0; i < groupIdx && i < this.groupSizes.length; i++) {
      rangeIdx += this.groupSizes[i];
    }

    if (groupIdx >= 0 && groupIdx < centers.length) {
      const groupCenter = centers[groupIdx];
      let localIdx = 0;

      // 根据当前组的大小确定偏移量
      const currentGroupSize = this.groupSizes[groupIdx] || 2;
      let offsets: Array<number> = [];
      if (currentGroupSize === 2) {
        offsets = [-0.3, 0.3];
      } else if (currentGroupSize === 3) {
        offsets = [-0.4, 0, 0.4];
      } else {
        offsets = [-0.3, 0.3]; // 默认2个
      }

      // 找到组内的具体位置
      for (let k = 0; k < offsets.length; k++) {
        if (Math.abs(x - (groupCenter + offsets[k])) < 0.25) {
          localIdx = k;
          break;
        }
      }
      rangeIdx += localIdx;
    }

    // 为每个柱子生成不同的日期
    this.label = this.generateDateForBar(rangeIdx);

    if (rangeIdx >= 0 && rangeIdx < this.ranges.length) {
      const low = Math.round(this.ranges[rangeIdx][0]);
      const high = Math.round(this.ranges[rangeIdx][1]);
      this.rangeText = `${low}-${high}`;
    }
  }

  // 为每个柱子生成不同的日期
  private generateDateForBar(barIndex: number): string {
    // 4月30天的日期映射，对应30个心率数据点
    const dateArray: string[] = [
      '4/1', '4/2', '4/3', '4/4', '4/5', '4/6', '4/7', '4/8', '4/9', '4/10', // 0-9
      '4/11', '4/12', '4/13', '4/14', '4/15', '4/16', '4/17', '4/18', '4/19', '4/20', // 10-19
      '4/21', '4/22', '4/23', '4/24', '4/25', '4/26', '4/27', '4/28', '4/29', '4/30'// 20-29
    ];

    if (barIndex >= 0 && barIndex < dateArray.length) {
      return dateArray[barIndex];
    }

    // 备用逻辑
    return `4/${barIndex + 1}`;
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
    if (e.getX() > 8.5) {
      left = posX - boxWidth - 10;
    }

    if (left < 10) {
      left = 10;
    }

    // 边界检查 - 右边界
    const rightEdge = left + boxWidth;
    const chartRightBound = this.chartWidth > 0 ? this.chartWidth - 10 : 350; // 默认350，实际使用图表宽度
    if (rightEdge > chartRightBound) {
      left = chartRightBound - boxWidth;
      if (left < 10) {
        left = 10;
      }
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
export class MonthlyHeartRateChartVM {
  @Trace chartModel: WaterfallChartModel = new WaterfallChartModel();
  @Trace ranges: Array<[number, number]> = [];
  @Trace dateLabels: Array<string> = [];
  @Trace groupSizes: Array<number> = [];
  @Trace currentIndex: number = 4;
  private markerView: HRMonthlyMarkerView | null = null;

  public initializeChart(): void {
    this.chartModel.getDescription()?.setEnabled(false);
    this.chartModel.setPinchZoom(false);
    this.chartModel.setDrawGridBackground(false);
    this.chartModel.setDrawValueAboveBar(false);
    this.chartModel.setExtraOffsets(3, 15, 15, 3);
    this.chartModel.setTouchEnabled(true);
    this.chartModel.setDragEnabled(true); // 启用拖拽滑动
    this.chartModel.setScaleEnabled(false);
    this.chartModel.setHighlightPerTapEnabled(true);
    this.chartModel.setHighlightPerDragEnabled(false);

    // MarkerView
    this.markerView = new HRMonthlyMarkerView(this.groupSizes, this.ranges);
    this.chartModel.setMarker(this.markerView);

    let legend: Legend | null = this.chartModel.getLegend();
    if (legend) {
      legend.setEnabled(false);
    }

    let heartRateMonthlyXAxis: XAxis | null = this.chartModel.getXAxis();
    if (heartRateMonthlyXAxis) {
      heartRateMonthlyXAxis.setPosition(XAxisPosition.BOTTOM);
      heartRateMonthlyXAxis.setGranularity(1);
      heartRateMonthlyXAxis.setGranularityEnabled(true);
      heartRateMonthlyXAxis.setAxisMinimum(-0.5);
      heartRateMonthlyXAxis.setAxisMaximum(this.dateLabels.length - 0.5);
      heartRateMonthlyXAxis.setLabelCount(6, true); // 强制只显示6个标签，防止滑动时变化
      heartRateMonthlyXAxis.setValueFormatter(new FiveLabelFormatter(this.dateLabels));
      heartRateMonthlyXAxis.setDrawGridLines(true);
      heartRateMonthlyXAxis.setGridColor(ColorTemplate.colorRgb(240, 240, 240));
      heartRateMonthlyXAxis.setGridLineWidth(0.8);
      heartRateMonthlyXAxis.setTextColor(ColorTemplate.colorRgb(150, 150, 150));
      heartRateMonthlyXAxis.setYOffset(8);
      heartRateMonthlyXAxis.setAvoidFirstLastClipping(true);

      // 设置可见范围，支持滑动查看完整月份数据
      if (this.dateLabels.length > 10) {
        // 如果数据点超过10个，设置可见范围为12个数据点，支持滑动
        this.chartModel.setVisibleXRangeMaximum(12);
        this.chartModel.setVisibleXRangeMinimum(8);
        // 默认显示前10个数据点（从4/1开始）
        this.chartModel.moveViewToX(-0.5);
      }
    }

    let heartRateMonthlyLeftAxis: YAxis | null = this.chartModel.getAxisLeft();
    if (heartRateMonthlyLeftAxis) {
      heartRateMonthlyLeftAxis.setAxisMinimum(0);
      heartRateMonthlyLeftAxis.setAxisMaximum(150);
      heartRateMonthlyLeftAxis.setLabelCount(6, true);
      heartRateMonthlyLeftAxis.setPosition(YAxisLabelPosition.OUTSIDE_CHART);
      heartRateMonthlyLeftAxis.setDrawGridLines(true);
      heartRateMonthlyLeftAxis.setGridColor(ColorTemplate.colorRgb(240, 240, 240));
      heartRateMonthlyLeftAxis.setGridLineWidth(0.8);
      heartRateMonthlyLeftAxis.setTextColor(ColorTemplate.colorRgb(150, 150, 150));
    }
    this.chartModel.getAxisRight()?.setEnabled(false);
  }

  public updateRanges(newRanges: Array<[number, number]>): void {
    this.ranges = newRanges.map(range => [range[0], range[1]]);
    if (this.markerView) {
      this.markerView.setData(this.groupSizes, this.ranges);
    }
    this.updateChartData();
  }

  public updateDateLabels(labels: Array<string>): void {
    this.dateLabels = labels.slice();
    if (this.markerView) {
      this.markerView.setData(this.groupSizes, this.ranges);
    }
    this.initializeChart();
    this.updateChartData();
  }

  public updateGroupSizes(sizes: Array<number>): void {
    this.groupSizes = sizes.slice();
    if (this.markerView) {
      this.markerView.setData(this.groupSizes, this.ranges);
    }
    this.updateChartData();
  }

  public updateCurrentIndex(index: number): void {
    this.currentIndex = index;
    this.updateChartData();
  }

  private updateChartData(): void {
    if (this.ranges.length === 0) {
      return;
    }

    let heartRateMonthlyValues: JArrayList<WaterfallEntry> = new JArrayList<WaterfallEntry>();
    // 15个分组的中心点，对应4月30天的分布
    const centers: Array<number> = [0, 2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24, 26, 28];
    let dataIdx: number = 0;
    for (let g = 0; g < centers.length && dataIdx < this.ranges.length; g++) {
      const count: number = (this.groupSizes && this.groupSizes[g]) ? this.groupSizes[g] : 0;

      // 根据当前组的大小确定偏移量
      let offsets: Array<number> = [];
      if (count === 2) {
        offsets = [-0.3, 0.3];
      } else if (count === 3) {
        offsets = [-0.4, 0, 0.4];
      } else {
        offsets = [-0.3, 0.3]; // 默认2个
      }

      for (let k = 0; k < count && dataIdx < this.ranges.length; k++) {
        const pair: [number, number] = this.ranges[dataIdx];
        const low: number = pair[0];
        const high: number = pair[1];
        const x: number = centers[g] + (offsets[k] || 0);
        heartRateMonthlyValues.add(new WaterfallEntry(x, low, high));
        dataIdx++;
      }
    }

    let heartRateMonthlyDataSet: WaterfallDataSet = new WaterfallDataSet(heartRateMonthlyValues, '');
    heartRateMonthlyDataSet.setDrawIcons(false);
    heartRateMonthlyDataSet.setColorByColor(0x80FF6D6D);
    heartRateMonthlyDataSet.setHighLightColor(ColorTemplate.colorRgb(255, 133, 51));
    heartRateMonthlyDataSet.setDrawValues(false);

    let heartRateMonthlyDataSets: JArrayList<IWaterfallDataSet> = new JArrayList<IWaterfallDataSet>();
    heartRateMonthlyDataSets.add(heartRateMonthlyDataSet);
    let heartRateMonthlyData: WaterfallData = new WaterfallData(heartRateMonthlyDataSets);
    heartRateMonthlyData.setDrawValues(false);
    heartRateMonthlyData.setBarWidth(0.12);

    this.chartModel.setData(heartRateMonthlyData);
    this.chartModel.notifyDataSetChanged();
    this.chartModel.invalidate();
  }

  public setChartWidth(width: number): void {
    if (this.markerView) {
      this.markerView.setChartWidth(width);
    }
  }
}

