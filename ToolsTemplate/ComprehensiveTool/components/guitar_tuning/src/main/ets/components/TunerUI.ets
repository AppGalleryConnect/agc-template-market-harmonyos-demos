import { MAX_DEVIATION, TUNE_THRESHOLD } from '../constant/Index';
import { Point } from '../model/Index';


@ComponentV2
export struct GuitarTunerTrajectory {
  @Param targetFreq: number = 0;
  @Param currentFreq: number = 0;
  // 偏差
  @Local deviation: number = 0;
  // 轨迹点
  @Local trajectoryPoints: Point[] = [];
  @Local scrollOffset: number = 0;
  // 画布宽度
  @Local canvasWidth: number = 360;
  @Local canvasHeight: number = 324;
  // 图标X坐标
  @Local iconX: number = this.canvasWidth / 2;
  @Local innerCircleColor: string = '#000';
  // Canvas实例
  private canvasCtx: CanvasRenderingContext2D = new CanvasRenderingContext2D();
  private updateTimer: number | null = null;

  @Monitor('currentFreq','targetFreq')
  onchange() {
    this.updateFreqData();
    this.drawWithCtx();
  }

  // 组件卸载：彻底清理资源
  aboutToDisappear() {
    if (this.updateTimer) {
      clearInterval(this.updateTimer);
    }
    this.trajectoryPoints = [];
  }

  build() {
    Column() {
      Canvas(this.canvasCtx)
        .width(this.canvasWidth)
        .height(this.canvasHeight)
        .backgroundColor('#000000')
        .borderRadius(16)
        .onReady(() => {
          // 初始化图标位置（基准线）
          this.iconX = this.canvasWidth / 2;
          this.innerCircleColor = '#000';
          this.drawWithCtx();
        });
    }
    .backgroundColor('#000')
    .width('100%')
    .constraintSize({ maxWidth: 360 })
    .height(this.canvasHeight)
    // 组件尺寸变化时重新绘制
    .onSizeChange((oldSize, newSize: SizeOptions) => {
      this.canvasWidth = newSize.width as number;
      this.drawWithCtx();
    });
  }

  // 1. 仅更新频率与轨迹数据（无状态直接操作）
  private updateFreqData() {

    // 计算偏差
    this.deviation = this.currentFreq - this.targetFreq;
    // 超出最大偏差的数据，校正
    if (this.deviation > MAX_DEVIATION) {
      this.deviation = MAX_DEVIATION;
    }
    if (this.deviation < -MAX_DEVIATION) {
      this.deviation = -MAX_DEVIATION;
    }

    // 更新图标位置
    const centerX = this.canvasWidth / 2;
    // 频率为0时，图标固定在基准线
    this.iconX = this.currentFreq === 0
      ? centerX
      : centerX + (this.deviation / MAX_DEVIATION) * (centerX - 19); // 减去图标宽度的一半防止超出

    // 内圆颜色
    if (this.currentFreq === 0) {
      this.innerCircleColor = '#000';
    } else {
      this.innerCircleColor = Math.abs(this.deviation) <= TUNE_THRESHOLD
        ? 'rgba(97, 207, 190, 1)'
        : '#ff3b30';
    }
    // 轨迹点开始的位置，UI配置
    const fixedStartY = 100;
    // 更新轨迹点（频率为0时不新增）
    if (this.currentFreq !== 0) {
      this.trajectoryPoints.push({
        x: this.deviation / MAX_DEVIATION,
        y: fixedStartY + this.trajectoryPoints.length * 3,
      });
    } else {
      this.trajectoryPoints = [];
    }
  }

  //  核心绘制函数
  private drawWithCtx() {
    const ctx = this.canvasCtx;
    const centerX = this.canvasWidth / 2;
    // 外圆半径
    const iconOuterRadius = 19;
    //  倒三角尺寸
    const triangleHeight = 16;
    // 底边长度
    const triangleBase = 22;

    // 清空画布（避免残影）
    ctx.clearRect(0, 0, this.canvasWidth, this.canvasHeight);
    ctx.fillStyle = '#000000';
    ctx.fillRect(0, 0, this.canvasWidth, this.canvasHeight);

    // 绘制三竖线（优化线条抗锯齿）
    ctx.lineCap = 'round';
    this.drawVerticalLine(ctx, centerX);

    // 绘制动态图标（圆覆盖三角底边）
    const iconOuterBottomY = 90;
    const iconCenterY = iconOuterBottomY - iconOuterRadius;

    // 外白圆
    ctx.fillStyle = '#fff';
    ctx.beginPath();
    ctx.arc(this.iconX, iconCenterY, iconOuterRadius, 0, 2 * Math.PI);
    ctx.fill();

    // 倒三角（底边缩进，被圆完全覆盖）
    ctx.fillStyle = '#fff';
    ctx.beginPath();
    // 底边向上缩进6vp，确保被外圆覆盖
    ctx.moveTo(this.iconX - triangleBase / 2, iconOuterBottomY - 6);
    ctx.lineTo(this.iconX + triangleBase / 2, iconOuterBottomY - 6);
    ctx.lineTo(this.iconX, iconOuterBottomY + triangleHeight - 6);
    ctx.closePath();
    ctx.fill();


    // 内圆绘制
    ctx.fillStyle = this.innerCircleColor;
    ctx.beginPath();
    ctx.arc(this.iconX, iconCenterY, 14, 0, 2 * Math.PI);
    ctx.fill();

    // 调准对勾
    if (this.currentFreq !== 0 && Math.abs(this.deviation) <= TUNE_THRESHOLD) {
      ctx.strokeStyle = '#fff';
      ctx.lineCap = 'round';
      ctx.lineWidth = 1;
      ctx.beginPath();
      ctx.moveTo(this.iconX - 7, iconCenterY);
      ctx.lineTo(this.iconX - 1, iconCenterY + 4);
      ctx.lineTo(this.iconX + 7, iconCenterY - 5);
      ctx.stroke();
    }


    // 绘制轨迹
    if (this.currentFreq !== 0 && this.trajectoryPoints.length > 1) {
      ctx.beginPath();
      this.trajectoryPoints.forEach((point, index) => {
        const mappedX = centerX + point.x * (centerX - 19);
        const drawnY = point.y;
        ctx.strokeStyle = 'rgba(97, 207, 190, 1)';
        index === 0
          ? ctx.moveTo(mappedX, drawnY)
          : ctx.lineTo(mappedX, drawnY);
      });
      ctx.lineWidth = 3;
      ctx.lineCap = 'round';
      ctx.lineJoin = 'round';
      ctx.stroke();
    }
  }

  // 绘制竖线
  private drawVerticalLine(ctx: CanvasRenderingContext2D, x: number) {
    const grad = ctx.createLinearGradient(x, 38, x, 248);
    grad.addColorStop(0.0, 'rgba(49, 49, 49, 1)');
    grad.addColorStop(0.5, 'rgba(129, 128, 128, 1)');
    grad.addColorStop(1.0, 'rgba(49, 49, 49, 1)');
    ctx.strokeStyle = grad;
    ctx.lineWidth = 4;
    ctx.lineCap = 'square';
    ctx.beginPath();
    ctx.moveTo(x, 38);
    ctx.lineTo(x, 248);
    ctx.stroke();
  }
}



