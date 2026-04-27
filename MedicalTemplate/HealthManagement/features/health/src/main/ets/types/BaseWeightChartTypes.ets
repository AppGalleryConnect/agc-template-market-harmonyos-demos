import {
  AxisBase,
  LineChartModel,
  LineData,
  LineDataSet,
  EntryOhos,
  IAxisValueFormatter,
  JArrayList,
  XAxisPosition,
  YAxisLabelPosition,
  Mode,
  ColorTemplate,
  MarkerView,
  Highlight
} from '@ohos/mpchart';

// 健康数据 MarkerView
class HealthMarkerView extends MarkerView {
  private value: number = 0;
  private date: string = '';
  private chartWidth: number = 0;
  private dates: string[] = [];
  private unit: string = '';

  constructor(dates: string[], unit: string = '') {
    super();
    this.dates = dates;
    this.unit = unit;
  }

  setChartWidth(width: number): void {
    this.chartWidth = width;
  }

  refreshContent(entry: EntryOhos, _highlight: Highlight): void {
    if (entry) {
      this.value = entry.getY();
      const index = Math.round(entry.getX());
      if (index >= 0 && index < this.dates.length) {
        this.date = this.dates[index];
      } else {
        this.date = '';
      }
    }
  }

  draw(c: CanvasRenderingContext2D, _posX: number, _posY: number, e: EntryOhos, highlight: Highlight): void {
    this.refreshContent(e, highlight);

    if (!this.date || this.value === 0) {
      return;
    }

    c.save();

    // 第一行：日期
    const dateText = this.date;
    c.font = '10vp sans-serif';
    const dateMetrics = c.measureText(dateText);

    // 第二行：数值
    const valueText = `${this.value.toFixed(1)}${this.unit}`;
    c.font = 'bold 20vp sans-serif';
    const valueMetrics = c.measureText(valueText);

    const padding = 10;
    const paddingLeft = 14;
    const dateLineHeight = 12;
    const valueLineHeight = 24;
    const maxWidth = Math.max(dateMetrics.width, valueMetrics.width);
    const minWidth = 100;
    let boxWidth = Math.max(maxWidth + paddingLeft * 2, minWidth);
    const boxHeight = dateLineHeight + valueLineHeight + padding * 2;
    const radius = 10;

    // 水平居中
    const actualChartWidth = this.chartWidth > 0 ? this.chartWidth : 400;
    let left: number = (actualChartWidth - boxWidth) / 2;

    // 统一固定在图表顶部显示
    const top: number = 15;

    // 绘制圆角矩形背景
    c.fillStyle = 'rgba(0, 0, 0, 0.75)';
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
    c.fillStyle = 'rgba(180, 180, 180, 1)';
    c.font = '10vp sans-serif';
    c.fillText(dateText, left + paddingLeft, top + padding + 10);

    // 绘制数值（白色）
    c.fillStyle = '#FFFFFF';
    c.font = 'bold 20vp sans-serif';
    c.fillText(valueText, left + paddingLeft, top + padding + 10 + dateLineHeight + 14);

    c.restore();
  }
}

// 图表偏移配置类
export class ChartOffsets {
  left: number = 0;
  top: number = 0;
  right: number = 0;
  bottom: number = 0;

  constructor(left: number, top: number, right: number, bottom: number) {
    this.left = left;
    this.top = top;
    this.right = right;
    this.bottom = bottom;
  }
}

// 图表配置类
export class ChartConfig {
  lineColor: number = 0;
  lineWidth: number = 3;
  fillAlpha: number = 30;
  gridColor: number = 0;
  axisLineColor: number = 0;
  textColor: number = 0;
  textSize: number = 10;
  yAxisMin: number = 0;
  yAxisMax: number = 200;
  yAxisLabelCount: number = 5;
  yAxisGranularity: number = 50;
  chartHeight: number = 200;
  extraOffsets: ChartOffsets = new ChartOffsets(0, 0, 0, 0);
  xAxisOffset: number = 0;
  yAxisOffset: number = 0;
  drawXAxisLine: boolean = false;
  enableMarker: boolean = true; // 是否启用浮层
  markerUnit: string = ''; // 浮层显示的单位
}

// 创建默认配置
export function createDefaultChartConfig(): ChartConfig {
  const config = new ChartConfig();
  config.lineColor = ColorTemplate.colorRgb(90, 177, 232);
  config.lineWidth = 3;
  config.fillAlpha = 30;
  config.gridColor = ColorTemplate.colorRgb(240, 240, 240);
  config.axisLineColor = ColorTemplate.colorRgb(224, 224, 224);
  config.textColor = ColorTemplate.colorRgb(153, 153, 153);
  config.textSize = 10;
  config.yAxisMin = 0;
  config.yAxisMax = 200;
  config.yAxisLabelCount = 5;
  config.yAxisGranularity = 50;
  config.chartHeight = 200;
  config.extraOffsets = new ChartOffsets(10, 10, 20, 15);
  config.xAxisOffset = 10;
  config.yAxisOffset = 5;
  config.drawXAxisLine = false;
  return config;
}

// 日期格式化器
export class DateAxisFormatter implements IAxisValueFormatter {
  private dates: string[];

  constructor(dates: string[]) {
    this.dates = dates;
  }

  getFormattedValue(value: number, _axis?: AxisBase): string {
    const index = Math.round(value);
    return (index >= 0 && index < this.dates.length) ? this.dates[index] : '';
  }
}

// 图表数据点接口
export interface ChartDataPoint {
  date: string;
  value: number;
}

// 基础图表工具类
export class ChartBuilder {
  private model: LineChartModel;
  private config: ChartConfig;
  private marker: HealthMarkerView | null = null;

  constructor(model: LineChartModel, config: ChartConfig) {
    this.model = model;
    this.config = config;
  }

  // 设置图表宽度（用于 MarkerView）
  setChartWidth(width: number): void {
    if (this.marker) {
      this.marker.setChartWidth(width);
    }
  }

  // 创建折线数据
  createLineData(dataPoints: ChartDataPoint[]): LineDataResult {
    const entries = new JArrayList<EntryOhos>();
    const dates: string[] = [];

    dataPoints.forEach((point, index) => {
      entries.add(new EntryOhos(index, point.value));
      dates.push(point.date);
    });

    const dataSet = this.createDataSet(entries);
    const lineData = new LineData();
    lineData.addDataSet(dataSet);

    const result = new LineDataResult();
    result.lineData = lineData;
    result.dates = dates;
    return result;
  }

  // 创建数据集
  private createDataSet(entries: JArrayList<EntryOhos>): LineDataSet {
    const dataSet = new LineDataSet(entries, '');
    const lineColor = this.config.lineColor;
    const lineWidth = this.config.lineWidth;
    const fillAlpha = this.config.fillAlpha;

    dataSet.setColorByColor(lineColor);
    dataSet.setLineWidth(lineWidth);
    dataSet.setDrawCircles(false);
    dataSet.setDrawValues(false);
    dataSet.setMode(Mode.LINEAR);
    dataSet.setDrawFilled(true);
    dataSet.setFillColor(lineColor);
    dataSet.setFillAlpha(fillAlpha);

    return dataSet;
  }

  // 配置X轴
  configureXAxis(dates: string[]) {
    const xAxis = this.model.getXAxis();
    if (!xAxis) {
      return
    }

    const textColor = this.config.textColor;
    const textSize = this.config.textSize;
    const drawXAxisLine = this.config.drawXAxisLine;
    const axisLineColor = this.config.axisLineColor;
    const xAxisOffset = this.config.xAxisOffset;

    xAxis.setPosition(XAxisPosition.BOTTOM);
    xAxis.setDrawGridLines(false);
    xAxis.setDrawAxisLine(drawXAxisLine);
    if (drawXAxisLine && axisLineColor) {
      xAxis.setAxisLineColor(axisLineColor);
    }
    xAxis.setTextColor(textColor);
    xAxis.setTextSize(textSize);
    xAxis.setGranularity(1);
    xAxis.setValueFormatter(new DateAxisFormatter(dates));
    xAxis.setLabelCount(dates.length, false);
    if (xAxisOffset !== undefined && xAxisOffset > 0) {
      xAxis.setYOffset(xAxisOffset);
    }
  }

  // 配置Y轴
  configureYAxis() {
    this.configureLeftYAxis();
    this.disableRightYAxis();
  }

  // 配置左侧Y轴
  private configureLeftYAxis() {
    const leftAxis = this.model.getAxisLeft();
    if (!leftAxis) {
      return
    }

    const yAxisMin = this.config.yAxisMin;
    const yAxisMax = this.config.yAxisMax;
    const gridColor = this.config.gridColor;
    const textColor = this.config.textColor;
    const textSize = this.config.textSize;
    const yAxisLabelCount = this.config.yAxisLabelCount;
    const yAxisGranularity = this.config.yAxisGranularity;
    const yAxisOffset = this.config.yAxisOffset;

    leftAxis.setAxisMinimum(yAxisMin);
    leftAxis.setAxisMaximum(yAxisMax);
    leftAxis.setDrawGridLines(true);
    leftAxis.setGridColor(gridColor);
    leftAxis.setGridLineWidth(1);
    leftAxis.setDrawAxisLine(false);
    leftAxis.setTextColor(textColor);
    leftAxis.setTextSize(textSize);
    leftAxis.setPosition(YAxisLabelPosition.OUTSIDE_CHART);
    leftAxis.setLabelCount(yAxisLabelCount, false);
    leftAxis.setGranularity(yAxisGranularity);
    if (yAxisOffset !== undefined && yAxisOffset > 0) {
      leftAxis.setXOffset(yAxisOffset);
    }
  }

  // 禁用右侧Y轴
  private disableRightYAxis() {
    const rightAxis = this.model.getAxisRight();
    rightAxis?.setEnabled(false);
  }

  // 配置图表外观
  configureAppearance(dates: string[]) {
    const legend = this.model.getLegend();
    if (legend) {
      legend.setEnabled(false);
    }

    const description = this.model.getDescription();
    if (description) {
      description.setEnabled(false);
    }

    this.model.setScaleEnabled(false);
    this.model.setDragEnabled(false);
    this.model.setDoubleTapToZoomEnabled(false);
    this.model.setPinchZoom(false);
    this.model.setDrawGridBackground(false);
    this.model.setDrawBorders(false);
    this.model.setTouchEnabled(true); // 启用触摸以支持浮层
    this.model.setHighlightPerTapEnabled(true); // 启用点击高亮

    const offsets = this.config.extraOffsets;
    this.model.setExtraOffsets(offsets.left, offsets.top, offsets.right, offsets.bottom);

    // 配置 MarkerView
    if (this.config.enableMarker) {
      this.marker = new HealthMarkerView(dates, this.config.markerUnit);
      this.model.setMarker(this.marker);
    }
  }

  // 完整初始化流程
  initialize(dataPoints: ChartDataPoint[]) {
    const result = this.createLineData(dataPoints);
    this.model.setData(result.lineData);
    this.configureXAxis(result.dates);
    this.configureYAxis();
    this.configureAppearance(result.dates);
    this.model.notifyDataSetChanged();
    this.model.invalidate();
  }
}

// 折线数据结果类
class LineDataResult {
  lineData: LineData | null = null;
  dates: string[] = [];
}
