import { Logger } from './Logger';

const TAG = '[CanvasUtil]';

// 基础点类型接口
export interface Point {
  x: number;
  y: number;
}

// 定义带温度信息的点类型接口
export interface PointWithTemp extends Point {
  temp: number;
}

// 定义贝塞尔曲线控制点容器
interface BezierControls {
  C1: Point;
  C2: Point;
}

// 垂直线样式配置
interface VerticalLineStyle {
  color?: string; // 线条颜色
  width?: number; // 线条宽度
  dashPattern?: number[]; // 虚线模式
  startGap?: number; // 首部空白长度
  endGap?: number; // 尾部空白长度
}

// 样式选项接口
interface StyleOptions {
  /**
   * 曲线样式
   */
  curveColor?: string; // 曲线颜色
  curveWidth?: number; // 曲线宽度

  /**
   * 虚线样式配置及控制
   */
  firstSegmentDashed?: boolean; // 控制第一段是否为虚线
  dashPattern?: number[]; // 虚线模式，如 [5, 3] 表示 5px 实线 3px 空白
  dashOffset?: number; // 虚线偏移量
  /**
   * 内孔及轮廓样式
   */
  holeRadius?: number; // 内孔半径
  holeFillColor?: string; // 内孔填充颜色
  outlineWidth?: number; // 轮廓宽度
  outlineColor?: string; // 轮廓颜色
  /**
   * 垂直线样式
   */
  verticalLineStyle?: VerticalLineStyle;

  /**
   * 数据点文字样式
   */
  labelPosition?: 'none' | 'top' | 'bottom'; // 不显示|上方|下方
  labelOffset?: number; // 偏移距离
  labelColor?: string; // 文字颜色
  labelFont?: string; // 文字大小
}

export class CanvasController {
  // 曲线样式
  private _curveColor: string = '#3F7EF7';
  private _curveWidth: number = 2;
  // 虚线样式及控制
  private _firstSegmentDashed: boolean = true;
  private _dashPattern: number[] = [5, 3];
  // 内孔及轮廓样式
  private _holeRadius: number = 4;
  private _holeFillColor: string = '#3F7EF7';
  private _outlineWidth: number = 2;
  private _outlineColor: string = '#ffffff';
  // 垂直线样式
  private _verticalLineStyle: VerticalLineStyle = {
    color: '#3F7EF7',
    width: 1,
    dashPattern: [4, 2],
    startGap: 12,
    endGap: 4,
  };
  // 文字样式
  private _labelPosition: 'none' | 'top' | 'bottom' = 'none';
  private _labelOffset: number = 2;
  private _labelColor: string = '#333333';
  private _labelFont: string = '14vp';

  /**
   构造函数，可通过参数初始化样式
   @param options 初始化样式选项
   */
  constructor(options: StyleOptions = {}) {
    this._setStyleOptions(options);
  }

  /**
   * 根据输入参数生成对应的带温度信息的点数组
   * @param temperatureArray 温度数组
   * @param intervalLength 区间长度
   * @param canvasHeight 画板高度
   * @param minTemperature 最低温度
   * @param maxTemperature 最高温度
   * @returns 温度位置点数组
   */
  public generateTemperaturePoints(
    temperatureArray: number[],
    intervalLength: number,
    canvasHeight: number,
    minTemperature: number,
    maxTemperature: number,
  ): PointWithTemp[] {
    const points: PointWithTemp[] = [];
    const dataLength = temperatureArray.length;

    if (dataLength === 0) {
      Logger.error(TAG, '气温数组不能为空');
      return points;
    }
    if (intervalLength <= 0) {
      Logger.error(TAG, '区间长度必须为正数');
      return points;
    }
    if (canvasHeight <= 0) {
      Logger.error(TAG, 'Canvas 高度必须为正数');
      return points;
    }
    if (minTemperature >= maxTemperature) {
      Logger.error(TAG, '最低气温必须小于最高气温');
      return points;
    }

    const temperatureRange = maxTemperature - minTemperature;
    for (let i = 0; i < dataLength; i++) {
      const x = intervalLength / 2 + i * intervalLength;
      const temp = Math.max(minTemperature, Math.min(maxTemperature, temperatureArray[i]));
      const normalizedValue = (temp - minTemperature) / temperatureRange;
      const y = canvasHeight - normalizedValue * canvasHeight;

      points.push({ x, y, temp });
    }

    return points;
  }

  /**
   * Canvas绘图
   * @param ctx 绘图上下文
   * @param temps 带温度信息的点数组
   * @param verticalLineIndex 需要绘制垂直线的点索引（可选，null表示不绘制）
   */
  public draw(ctx: CanvasRenderingContext2D, temps: PointWithTemp[], verticalLineIndex: number | null = null) {
    if (!temps || temps.length < 2) {
    Logger.error(TAG, '至少需要 2 个点才能绘制曲线');
      return;
    }
    ctx.clearRect(0, 0, ctx.width, ctx.height);
    ctx.save();
    // 画曲线
    this._drawCurve(ctx, temps);
    // 画数据点和标文字
    this._drawPointsAndLabels(ctx, temps);
    // 画垂直线
    if (verticalLineIndex !== null &&
      verticalLineIndex >= 0 &&
      verticalLineIndex < temps.length && this._verticalLineStyle.width && this._verticalLineStyle.width > 0) {
      this._drawVerticalLine(ctx, temps[verticalLineIndex]);
    }
    ctx.restore();
  }

  /**
   * 批量设置样式选项
   */
  private _setStyleOptions(options: StyleOptions): void {
    if (options.curveColor !== undefined) {
      this._setCurveColor(options.curveColor);
    }
    if (options.curveWidth !== undefined) {
      this._setCurveWidth(options.curveWidth);
    }
    if (options.firstSegmentDashed !== undefined) {
      this._setFirstSegmentDashed(options.firstSegmentDashed);
    }
    if (options.dashPattern !== undefined) {
      this._setDashPattern(options.dashPattern);
    }
    if (options.holeRadius !== undefined) {
      this._setHoleRadius(options.holeRadius);
    }
    if (options.holeFillColor !== undefined) {
      this._setHoleFillColor(options.holeFillColor);
    }
    if (options.outlineWidth !== undefined) {
      this._setOutlineWidth(options.outlineWidth);
    }
    if (options.outlineColor !== undefined) {
      this._setOutlineColor(options.outlineColor);
    }
    if (options.verticalLineStyle !== undefined) {
      this._setVerticalLineStyle(options.verticalLineStyle);
    }
    if (options.labelPosition !== undefined) {
      this._setLabelPosition(options.labelPosition);
    }
    if (options.labelOffset !== undefined) {
      this._setLabelOffset(options.labelOffset);
    }
    if (options.labelColor !== undefined) {
      this._setLabelColor(options.labelColor);
    }
    if (options.labelFont !== undefined) {
      this._setLabelFont(options.labelFont);
    }
  }

  private _setCurveColor(value: string): void {
    this._curveColor = value;
  }

  private _setCurveWidth(value: number): void {
    this._curveWidth = Math.max(0.5, value);
  }

  private _setFirstSegmentDashed(value: boolean): void {
    this._firstSegmentDashed = value;
  }

  private _setDashPattern(value: number[]): void {
    if (Array.isArray(value) && value.length > 0) {
      this._dashPattern = value;
    }
  }

  private _setHoleRadius(value: number): void {
    this._holeRadius = Math.max(1, value);
  }

  private _setHoleFillColor(value: string): void {
    this._holeFillColor = value;
  }

  private _setOutlineWidth(value: number): void {
    this._outlineWidth = Math.max(0, value);
  }

  private _setOutlineColor(value: string): void {
    this._outlineColor = value;
  }

  private _setVerticalLineStyle(style: VerticalLineStyle): void {
    if (style.color !== undefined) {
      this._verticalLineStyle.color = style.color;
    }
    if (style.width !== undefined) {
      this._verticalLineStyle.width = style.width;
    }
    if (style.dashPattern !== undefined) {
      this._verticalLineStyle.dashPattern = style.dashPattern;
    }
    if (style.startGap !== undefined) {
      this._verticalLineStyle.startGap = Math.max(0, style.startGap);
    }
    if (style.endGap !== undefined) {
      this._verticalLineStyle.endGap = Math.max(0, style.endGap);
    }
  }

  private _setLabelPosition(value: 'none' | 'top' | 'bottom'): void {
    this._labelPosition = value;
  }

  private _setLabelOffset(value: number): void {
    this._labelOffset = Math.max(0, value);
  }

  private _setLabelColor(value: string): void {
    this._labelColor = value;
  }

  private _setLabelFont(value: string): void {
    this._labelFont = value;
  }

  /**
   创建控制点对象的工厂函数
   */
  private _createBezierControls(c1: Point, c2: Point): BezierControls {
    return { C1: c1, C2: c2 };
  }

  /**
   * 贝塞尔曲线的控制点计算
   */
  private _calcBezierControls(p0: Point, p1: Point, p2: Point, p3: Point): BezierControls {
    const C1: Point = {
      x: p1.x + (p2.x - p0.x) / 6,
      y: p1.y + (p2.y - p0.y) / 6,
    };
    const C2: Point = {
      x: p2.x - (p3.x - p1.x) / 6,
      y: p2.y - (p3.y - p1.y) / 6,
    };
    return this._createBezierControls(C1, C2);
  }

  /**
   * 绘制指定点的垂直线
   */
  private _drawVerticalLine(ctx: CanvasRenderingContext2D, point: Point): void {
    const canvasHeight = ctx.height;
    const lineTotalHeight = canvasHeight - point.y;
    const startGap = this._verticalLineStyle.startGap || 0;
    const endGap = this._verticalLineStyle.endGap || 0;
    const effectiveLength = lineTotalHeight - startGap - endGap;
    if (effectiveLength <= 0) {
      return;
    }
    ctx.save();
    ctx.strokeStyle = this._verticalLineStyle.color || '#3F7EF7';
    ctx.lineWidth = this._verticalLineStyle.width || 1;
    const startY = point.y + startGap;
    ctx.beginPath();
    ctx.moveTo(point.x, startY);
    ctx.lineTo(point.x, startY + effectiveLength);
    const dashPattern = this._verticalLineStyle.dashPattern || [4, 2];
    ctx.setLineDash(dashPattern);
    ctx.stroke();
    ctx.restore();
  }

  /**
   * 绘制曲线
   */
  private _drawCurve(ctx: CanvasRenderingContext2D, temps: PointWithTemp[]): void {
    // 设置基础曲线样式
    ctx.strokeStyle = this._curveColor;
    ctx.lineWidth = this._curveWidth;

    // 创建虚拟点，用于处理曲线两端
    const virtualStart1: Point = {
      x: temps[0].x * 2 - temps[1].x,
      y: temps[0].y * 2 - temps[1].y,
    };
    const virtualStart2: Point = {
      x: temps[0].x,
      y: temps[0].y,
    };
    const lastIndex = temps.length - 1;
    const virtualEnd1: Point = {
      x: temps[lastIndex].x,
      y: temps[lastIndex].y,
    };
    const virtualEnd2: Point = {
      x: temps[lastIndex].x * 2 - temps[lastIndex - 1].x,
      y: temps[lastIndex].y * 2 - temps[lastIndex - 1].y,
    };

    // 扩展点数组，包含虚拟点
    const extendedPoints: Point[] = [];
    extendedPoints.push(virtualStart1);
    extendedPoints.push(virtualStart2);
    for (let i = 0; i < temps.length; i++) {
      extendedPoints.push({ x: temps[i].x, y: temps[i].y });
    }
    extendedPoints.push(virtualEnd1);
    extendedPoints.push(virtualEnd2);

    // 绘制贝塞尔曲线段
    for (let i = 2; i < extendedPoints.length - 2; i++) {
      const bezierControls = this._calcBezierControls(
        extendedPoints[i - 1],
        extendedPoints[i],
        extendedPoints[i + 1],
        extendedPoints[i + 2],
      );

      ctx.beginPath();
      ctx.moveTo(extendedPoints[i].x, extendedPoints[i].y);

      // 设置虚线样式
      if (this._firstSegmentDashed && i === 2) {
        ctx.setLineDash(this._dashPattern);
      } else {
        ctx.setLineDash([]);
      }

      // 绘制贝塞尔曲线
      ctx.bezierCurveTo(
        bezierControls.C1.x, bezierControls.C1.y,
        bezierControls.C2.x, bezierControls.C2.y,
        extendedPoints[i + 1].x, extendedPoints[i + 1].y,
      );
      ctx.stroke();
    }
  }

  /**
   * 绘制带轮廓的内孔数据点和文字标签
   */
  private _drawPointsAndLabels(ctx: CanvasRenderingContext2D, temps: PointWithTemp[]): void {
    for (let i = 0; i < temps.length; i++) {
      const point = temps[i];
      const displayRadius = this._holeRadius + this._outlineWidth;

      // 绘制内孔填充
      ctx.beginPath();
      ctx.arc(point.x, point.y, this._holeRadius, 0, Math.PI * 2);
      ctx.fillStyle = this._holeFillColor;
      ctx.fill();

      // 绘制轮廓
      if (this._outlineWidth > 0) {
        ctx.beginPath();
        ctx.arc(point.x, point.y, this._holeRadius + this._outlineWidth / 2, 0, Math.PI * 2);
        ctx.strokeStyle = this._outlineColor;
        ctx.lineWidth = this._outlineWidth;
        ctx.stroke();
      }

      if (this._labelPosition !== 'none') {
        const roundedTemp = Math.round(point.temp);
        const labelText = roundedTemp + '°';
        let labelY: number;

        if (this._labelPosition === 'top') {
          labelY = point.y - displayRadius - this._labelOffset;
          ctx.textBaseline = 'bottom';
        } else {
          labelY = point.y + displayRadius + this._labelOffset;
          ctx.textBaseline = 'top';
        }

        ctx.font = this._labelFont;
        // 第一个数据点文字颜色变浅
        ctx.fillStyle =
          i === 0 && this._firstSegmentDashed ? this._lightenTextColor(this._labelColor) : this._labelColor;
        ctx.textAlign = 'center';
        ctx.fillText(labelText, point.x, labelY);
      }
    }
  }

  /**
   * 降低颜色透明度
   * @param color 十六进制颜色（如 '#333333'） 或 rgb颜色 如 'rgb(255,255,255)'）
   */
  private _lightenTextColor(color: string): string {
    if (color.startsWith('#')) {
      const r = parseInt(color.slice(1, 3), 16);
      const g = parseInt(color.slice(3, 5), 16);
      const b = parseInt(color.slice(5, 7), 16);
      return `rgba(${r}, ${g}, ${b}, 0.5)`;
    }
    if (color.startsWith('rgb')) {
      return color.replace('rgb', 'rgba').replace(')', ', 0.5)');
    }
    return color;
  }
}