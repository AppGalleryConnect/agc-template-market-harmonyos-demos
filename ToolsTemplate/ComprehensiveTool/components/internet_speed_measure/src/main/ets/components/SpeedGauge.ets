import { Animator, AnimatorOptions, AnimatorResult } from '@kit.ArkUI';

class GaugeConstants {
  static readonly DASHBOARD_SCALE_COLOR = '#B3B3B3';
  static readonly DASHBOARD_SCALE_FONT = '400 14vp sans-serif';
  static readonly DASHBOARD_VALUE_COLOR = '#E6E6E6';
  static readonly DASHBOARD_VALUE_FONT = '500 36vp sans-serif';
  static readonly DASHBOARD_UNIT = 'Mbps';
  static readonly DASHBOARD_UNIT_COLOR = '#B3B3B3';
  static readonly DASHBOARD_UNIT_FONT = '400 14vp sans-serif';
  static readonly TEXT_ALIGN_CENTER = 'center';
  static readonly TEXT_BASE_LINE_MIDDLE = 'middle';
}

@ComponentV2
export struct SpeedGauge {
  /** 样式配置 **/
  @Require @Param value: number = 0;
  @Param minValue: number = 0;
  @Param maxValue: number = 500;
  @Param startAngle: number = 135;
  @Param endAngle: number = 45;
  @Param progressColors: string = '#0A59F7';
  @Param progressBorderColor: string = 'rgba(255, 255, 255, 0.2)';
  @Param pointColor: string = '#0A59F7';
  @Param animationDuration: number = 800;
  /** 动画相关 **/
  currentValue: number = 0;
  gaugeAnimator: AnimatorResult | undefined = undefined;
  animatorOptions: AnimatorOptions = {
    duration: this.animationDuration,
    easing: 'ease-in-out',
    delay: 0,
    fill: 'forwards',
    direction: 'normal',
    iterations: 1,
    begin: 0,
    end: 0,
  };
  /** 画布相关 **/
  setting: RenderingContextSettings = new RenderingContextSettings(true);
  ctx: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.setting);
  canvasSize: number = 0;
  progressRingWidth: number = 0; // 环形宽度
  radius: number = (this.canvasSize - this.progressRingWidth) * 0.45; // 仪表盘半径
  pointerLength: number = (this.radius - this.progressRingWidth) * 0.8; // 指针长度
  pointerRadius: number = this.pointerLength * 0.1; // 指针圆点半径
  scaleMarginAngle: number = 2;

  @Monitor('value')
  onValueChange() {
    if (this.currentValue === this.value) {
      return;
    }
    if (this.gaugeAnimator) {
      this.gaugeAnimator.finish();
    }
    this._startAnimation(this.currentValue, this.value);
  }

  onCanvasSizeChange(newWidth: number) {
    this.canvasSize = newWidth;
    this.progressRingWidth = this.canvasSize * 0.04;
    this.radius = (this.canvasSize - this.progressRingWidth) * 0.5 * 0.9;
    this.pointerLength = (this.radius - this.progressRingWidth) * 0.8;
    this.pointerRadius = this.pointerLength * 0.1;
  }

  private _startAnimation(startValue: number, targetValue: number) {
    if (!this.gaugeAnimator) {
      return;
    }
    this.animatorOptions.begin = startValue;
    this.animatorOptions.end = targetValue;
    this.gaugeAnimator.reset(this.animatorOptions);
    this.gaugeAnimator.onFrame = (tmpValue) => {
      this.currentValue = tmpValue;
      this._drawGauge();
    };
    this.gaugeAnimator.play();
  }

  private _drawGauge() {
    const centerX = this.canvasSize / 2;
    const centerY = this.canvasSize / 2;
    this.ctx.clearRect(0, 0, this.canvasSize, this.canvasSize);
    this._drawProgressBorder(centerX, centerY);
    this._drawProgressRing(centerX, centerY);
    this._drawScale(centerX, centerY);
    this._drawPointer(centerX, centerY);
    this._drawValueText(centerX, centerY);
  }

  // 1. 绘制边框
  private _drawProgressBorder(cx: number, cy: number) {
    this.ctx.beginPath();
    this.ctx.arc(
      cx, cy, this.radius,
      this._degToRad(this.startAngle),
      this._degToRad(this.endAngle) + 2 * Math.PI,
      false,
    );
    this.ctx.lineWidth = this.progressRingWidth;
    this.ctx.strokeStyle = this.progressBorderColor;

    // 仅圆弧设置圆端
    this.ctx.lineCap = 'round';
    this.ctx.stroke();

    // 重置为默认
    this.ctx.lineCap = 'butt';
  }

  // 2. 绘制进度条
  private _drawProgressRing(cx: number, cy: number) {
    if (this.currentValue > this.maxValue) {
      this.currentValue = this.maxValue;
    }
    if (this.currentValue <= this.minValue) {
      return;
    }

    const progressEndAngle = this.startAngle +
      this._getEffectiveAngleRange() * (this.currentValue - this.minValue) / (this.maxValue - this.minValue);
    this.ctx.beginPath();
    this.ctx.arc(
      cx, cy, this.radius,
      this._degToRad(this.startAngle),
      this._degToRad(progressEndAngle),
    );
    this.ctx.lineWidth = this.progressRingWidth;
    this.ctx.strokeStyle = this.progressColors;

    // 仅圆弧设置圆端
    this.ctx.lineCap = 'round';
    this.ctx.stroke();

    // 立即重置为默认
    this.ctx.lineCap = 'butt';
  }

  private _getEffectiveAngleRange(): number {
    let effectiveEnd = this.endAngle;
    if (this.endAngle < this.startAngle) {
      effectiveEnd += 360;
    }
    return effectiveEnd - this.startAngle;
  }

  // 3. 绘制刻度线
  private _drawScale(cx: number, cy: number) {
    const totalDegrees = this._getEffectiveAngleRange();
    const scaleCount = 4;

    this.ctx.lineWidth = 2;
    this.ctx.strokeStyle = this.progressBorderColor;
    this.ctx.font = GaugeConstants.DASHBOARD_SCALE_FONT;
    this.ctx.textAlign = GaugeConstants.TEXT_ALIGN_CENTER;
    this.ctx.textBaseline = GaugeConstants.TEXT_BASE_LINE_MIDDLE;
    this.ctx.fillStyle = GaugeConstants.DASHBOARD_SCALE_COLOR;

    for (let i = 0; i <= scaleCount; i++) {
      const angle = this.startAngle + totalDegrees * i / scaleCount;
      const effectiveAngle = angle % 360;
      const rad = this._degToRad(effectiveAngle);

      // 刻度线位置计算
      const outerLinePos = this.radius - this.progressRingWidth / 2;
      const innerLinePos = this.radius - this.progressRingWidth;
      const x1 = cx + Math.cos(rad) * outerLinePos;
      const y1 = cy + Math.sin(rad) * outerLinePos;
      const x2 = cx + Math.cos(rad) * innerLinePos;
      const y2 = cy + Math.sin(rad) * innerLinePos;

      // 绘制刻度线
      this.ctx.beginPath();
      this.ctx.moveTo(x1, y1);
      this.ctx.lineTo(x2, y2);
      this.ctx.stroke();

      // 刻度文本绘制
      const value = this.minValue + (this.maxValue - this.minValue) * i / scaleCount;
      const valueText = value.toFixed(0);
      const textWidth = this.ctx.measureText(valueText).width;
      const textOffset = -(this.progressRingWidth * 1.2 + textWidth / 2);
      const textX = cx + Math.cos(rad) * (this.radius + textOffset);
      const textY = cy + Math.sin(rad) * (this.radius + textOffset);
      this.ctx.fillText(valueText, textX, textY);
    }
  }

  private _drawPointer(cx: number, cy: number) {
    this.currentValue = Math.max(this.minValue, Math.min(this.currentValue, this.maxValue));
    const angleRange = this._getEffectiveAngleRange();
    const normalizedValue = (this.currentValue - this.minValue) / (this.maxValue - this.minValue);
    const currentAngle = this.startAngle + angleRange * normalizedValue;
    const rad = this._degToRad(currentAngle - 90);

    this.ctx.save();
    this.ctx.translate(cx, cy);
    this.ctx.rotate(rad);

    // 指针中心圆点
    this.ctx.beginPath();
    this.ctx.arc(0, 0, this.pointerRadius, 0, 2 * Math.PI);
    this.ctx.fillStyle = this.pointColor;
    this.ctx.fill();

    // 指针形状
    this.ctx.beginPath();
    this.ctx.moveTo(0, this.pointerLength);
    this.ctx.lineTo(-this.pointerRadius, 0);
    this.ctx.lineTo(this.pointerRadius, 0);
    this.ctx.closePath();
    this.ctx.fill();

    this.ctx.restore();
  }

  private _drawValueText(cx: number, cy: number) {
    // 主数值
    this.ctx.font = GaugeConstants.DASHBOARD_VALUE_FONT;
    this.ctx.fillStyle = GaugeConstants.DASHBOARD_VALUE_COLOR;
    const valueText = this.value.toFixed(1);
    const yOffset = this.radius * 0.6;
    this.ctx.fillText(valueText, cx, cy + yOffset);

    // 单位
    this.ctx.font = GaugeConstants.DASHBOARD_UNIT_FONT;
    this.ctx.fillStyle = GaugeConstants.DASHBOARD_UNIT_COLOR;
    this.ctx.fillText(GaugeConstants.DASHBOARD_UNIT, cx, cy + yOffset + 30);
  }

  private _degToRad(degrees: number): number {
    return degrees * Math.PI / 180;
  }

  aboutToAppear(): void {
    this.gaugeAnimator = this.getUIContext().createAnimator(this.animatorOptions);
  }

  build() {
    Canvas(this.ctx)
      .width('100%')
      .aspectRatio(1)
      .onSizeChange((_, newSize) => {
        this.onCanvasSizeChange(newSize.width as number);
        this._drawGauge();
      });
  }
}
