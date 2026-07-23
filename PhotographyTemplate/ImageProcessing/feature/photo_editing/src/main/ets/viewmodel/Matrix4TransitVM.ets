import { matrix4 } from '@kit.ArkUI';
import { ContextUtil } from 'commonlib';
import { MAX_SCALE, MID_SCALE, MIN_SCALE } from '../constant/Constants';
import { ImgOffset } from '../model/ImageModel';


@ObservedV2
export class Matrix4TransitVM {
  @Trace currentScale: number = 1.0;
  @Trace baseScale: number = 1.0;
  @Trace matrix: matrix4.Matrix4Transit = matrix4.identity();
  @Trace offsetX: number = 0;
  @Trace offsetY: number = 0;
  @Trace startOffsetX: number = 0;
  @Trace startOffsetY: number = 0;
  @Trace lateralMovementThreshold: number = 0;
  @Trace verticalMovementThreshold: number = 0;
  @Trace imageSizeWidth: number = 0;
  @Trace imageSizeHeight: number = 0;
  @Trace componentWidth: number = 0;
  @Trace componentHeight: number = 0;
  uiContext = ContextUtil.globalUIContext;

  // 图片尺寸变化
  onImgSizeChange(newValue: SizeOptions) {
    this.imageSizeWidth = newValue.width as number;
    this.imageSizeHeight = newValue.height as number;
  }

  // 容器尺寸变化
  onStackSizeChange(newValue: SizeOptions) {
    this.componentWidth = newValue.width as number;
    this.componentHeight = newValue.height as number;
  }

  // 计算最大偏移量
  getMaxOffset(): ImgOffset {
    // 内容缩放后的实际尺寸
    let scaledWidth = this.imageSizeWidth * this.currentScale;
    let scaledHeight = this.imageSizeHeight * this.currentScale;
    // 最大允许偏移量（内容边缘不超出容器）
    let maxX = Math.max(0, (scaledWidth - this.componentWidth) / 2);
    let maxY = Math.max(0, (scaledHeight - this.componentHeight) / 2)

    return {
      x: maxX,
      y: maxY
    };
  }

  // 限制 value 范围
  clamp(value: number, min: number, max: number): number {
    return Math.min(max, Math.max(min, value));
  }

  // 修正 offset 边界
  clampOffset(offset: ImgOffset): ImgOffset {
    const maxOffset = this.getMaxOffset();

    return {
      x: this.clamp(offset.x, -maxOffset.x, maxOffset.x),
      y: this.clamp(offset.y, -maxOffset.y, maxOffset.y)
    };
  }

  // 同步 offset 状态
  applyOffset(offset: ImgOffset) {
    this.offsetX = offset.x;
    this.offsetY = offset.y;
    this.startOffsetX = offset.x;
    this.startOffsetY = offset.y;
  }

  // 更新矩阵
  updateMatrix(): void {
    this.matrix = matrix4.identity().scale({ x: this.currentScale, y: this.currentScale })
  }

  // 回弹到合法区域
  animateOffsetToBoundary() {
    const offset = this.clampOffset({
      x: this.offsetX,
      y: this.offsetY
    });
    this.uiContext.animateTo({ duration: 200, curve: Curve.EaseOut },
      () => {
        this.applyOffset(offset);
      }
    );
  }

  // 限制缩放范围
  clampScale(scale: number): number {
    return this.clamp(scale, 0, MAX_SCALE);
  }

  // 单指拖动 开始
  single4ActionStart() {
    let maxOffset: ImgOffset = this.getMaxOffset(); // 获取当前缩放下的移动阈值
    this.lateralMovementThreshold = maxOffset.x; // 横向移动阈值
    this.verticalMovementThreshold = maxOffset.y; // 纵向移动阈值
  }

  // 单指拖动 更新
  single4ActionUpdate(event: PanGestureEvent) {
    // 水平方向
    this.offsetX = this.startOffsetX + event.offsetX * this.currentScale;
    // 垂直方向
    this.offsetY = this.startOffsetY + event.offsetY * this.currentScale;
  }

  // 单指拖动 结束
  single4ActionEnd() {
    this.animateOffsetToBoundary();
  }

  // 缩放开始
  handlePinchStart() {
    this.baseScale = this.currentScale;
  }

  // 双指缩放
  handlePinchUpdate(event: PinchGestureEvent) {
    let currentScale: number = this.baseScale * event.scale;

    this.currentScale = this.clampScale(currentScale);

    this.updateMatrix();
  }

  // 缩放结束
  handlePinchEnd() {
    this.animateOffsetToBoundary();

    // 缩小到最小 自动归位
    if (this.currentScale <= MIN_SCALE) {
      this.applyOffset({ x: 0, y: 0 });
      this.currentScale = MIN_SCALE;
      this.uiContext.animateTo({ duration: 200, curve: Curve.EaseOut }, () => {
        this.updateMatrix();
      });
    }
  }

  // 双击事件
  handleDoubleTap(fingers: FingerInfo[]) {
    const offset: ImgOffset = this.calcImageScale(fingers);
    this.uiContext.animateTo({ duration: 200, curve: Curve.EaseOut }, () => {
      this.updateImageTransform(offset);
    });
  }

  // 计算倍数
  calcImageScale(fingers?: FingerInfo[]) {
    // 初始化
    this.baseScale = 1.0;
    // 双击事件
    if (fingers) {
      // 放大到 2 倍 还是 回到原始位置
      this.currentScale = this.currentScale === this.baseScale ? MID_SCALE : this.baseScale;
    } else {
      // 回到原始位置
      this.currentScale = this.baseScale;
    }

    const offset = this.clampOffset({
      x: this.offsetX,
      y: this.offsetY
    });
    return offset
  }

  // 更新图片样式
  updateImageTransform(offset: ImgOffset) {
    this.updateMatrix();
    this.applyOffset(offset);
  }

  // 重置图片样式
  resetImageTransform(callback: () => void) {
    const offset = this.calcImageScale();
    this.uiContext.animateTo({ duration: 200, curve: Curve.EaseOut }, () => {
      this.updateImageTransform(offset);
      callback();
    });
  }
}