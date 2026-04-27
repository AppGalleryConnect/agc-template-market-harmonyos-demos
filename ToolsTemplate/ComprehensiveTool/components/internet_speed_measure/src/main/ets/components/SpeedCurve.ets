import {
  Description,
  EntryOhos,
  ILineDataSet,
  JArrayList,
  Legend,
  LineChart,
  LineChartModel,
  LineData,
  LineDataSet,
  Mode,
  XAxis,
  YAxis,
} from '@ohos/mpchart';

@ComponentV2
export struct SpeedCurve {
  @Require @Param data: number[];
  @Param lineColor: string = '#0A59F7';
  @Param duration: number = 2000;
  @Param limit: number = 10;
  model: LineChartModel | null = null;
  leftAxis: YAxis | null = null;
  rightAxis: YAxis | null = null;
  xAxis: XAxis | null = null;
  lineData: LineData = new LineData();

  @Monitor('trendData','trendData.length')
  onDataChange() {
    if (this.model) {
      this.model.setData(this._getLineData());
      this.model.notifyDataSetChanged();
      this.model.invalidate();
    }
  }

  hexToArgb(hex: string, alpha: number = 1): number {
    const validAlpha = Math.max(0, Math.min(1, alpha));
    const alpha255 = Math.round(validAlpha * 255);
    const cleanHex = hex.slice(1);
    const r = parseInt(cleanHex.slice(0, 2), 16);
    const g = parseInt(cleanHex.slice(2, 4), 16);
    const b = parseInt(cleanHex.slice(4, 6), 16);
    return (alpha255 << 24 | r << 16 | g << 8 | b) >>> 0;
  }

  aboutToAppear(): void {
    this.model = new LineChartModel();
    this.model.setPinchZoom(false);
    this.model.setDrawGridBackground(false);
    // 首次渲染动画
    this.model.animateX(this.duration);

    const description: Description | null = this.model.getDescription();
    if (description) {
      description.setEnabled(false);
    }
    const legend: Legend | null = this.model.getLegend();
    if (legend) {
      legend.setEnabled(false);
    }
    this.xAxis = this.model.getXAxis();
    if (this.xAxis) {
      this.xAxis.setEnabled(false);
    }
    this.leftAxis = this.model.getAxisLeft();
    if (this.leftAxis) {
      this.leftAxis.setEnabled(true);
      this.leftAxis.setDrawAxisLine(false);
      this.leftAxis.setDrawGridLines(false);
      this.leftAxis.setLabelXOffset(-10);
      this.leftAxis.setXOffset(10);
      this.leftAxis.setTextColor('#ffffff');
      this.leftAxis.setStartAtZero(true);
      this.leftAxis.setLabelCount(5);
      this.leftAxis.setAxisMinLabels(5);
      this.leftAxis.setAxisMaxLabels(5);
    }
    this.rightAxis = this.model.getAxisRight();
    if (this.rightAxis) {
      this.rightAxis.setEnabled(false);
    }
    this.model.setScaleEnabled(false);
    if (!this.data.length) {
      return;
    }
    this.lineData = this._getLineData();
    if (this.model) {
      this.model.setData(this.lineData);
      this.model.setVisibleXRangeMaximum(this.limit);
      this.model.invalidate();
    }
  }

  // 生成线形图数据
  private _getLineData(): LineData {
    const values: JArrayList<EntryOhos> = new JArrayList<EntryOhos>();
    let i: number = 0;
    this.data.forEach((value: number) => {
      values.add(new EntryOhos(i++, value));
    });
    const dataSetList: JArrayList<ILineDataSet> = new JArrayList<ILineDataSet>();
    const dataSet = new LineDataSet(values, 'Dataset');
    // 关闭高亮线
    dataSet.setHighlightEnabled(false);
    // 曲线样式
    dataSet.setLineWidth(2);
    dataSet.setDrawIcons(false);
    dataSet.setMode(Mode.CUBIC_BEZIER);
    dataSet.setColorByColor(this.hexToArgb(this.lineColor));
    // 底部填充
    dataSet.setDrawFilled(false);
    // 数据值
    dataSet.setDrawValues(false);
    // 数据点
    dataSet.setDrawCircles(true);
    dataSet.setCircleColor(this.hexToArgb('#ffffff'));
    dataSet.setCircleRadius(3);
    dataSetList.add(dataSet);
    return new LineData(dataSetList);
  }

  build() {
    LineChart({ model: this.model })
  }
}

