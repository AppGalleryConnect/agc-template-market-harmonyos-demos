import { BasePinchGestureUtils } from './BasePinchGestureUtils';
import { Logger } from './Logger';

const TAG = '[FontPinchGestureUtils]';

/**
 * 字体缩放手势工具类
 * 封装捏合手势处理逻辑，支持动态调整字体大小
 */
export class FontPinchGestureUtils extends BasePinchGestureUtils {
  private readonly FONT_SCALE_LEVELS: number[] = [1, 1.15, 1.45, 2];
  private currentScaleIndex: number = 0;
  private onFontSizeChange: ((scale: number) => void) | null = null;

  /**
   * 构造函数
   * @param scaleThreshold 手势识别敏感度阈值（默认0.3）
   */
  constructor(scaleThreshold: number = 0.3) {
    super(scaleThreshold);
    this.currentScaleIndex = 0; // 默认为 1（正常比例）
  }

  /**
   * 设置字体倍数变化回调
   * @param callback 字体倍数变化时的回调函数
   * @returns
   */
  setOnFontSizeChange(callback: (scale: number) => void): FontPinchGestureUtils {
    this.onFontSizeChange = callback;
    return this;
  }
  
  /**
   * 设置字体倍数达到最小值的回调
   * @param callback 字体倍数达到最小值的回调函数
   * @returns
   */
  setOnReachMinScale(callback: () => void): FontPinchGestureUtils {
    this.setOnReachMinBoundary(callback);
    return this;
  }
  
  /**
   * 设置字体倍数达到最大值的回调
   * @param callback 字体倍数达到最大值的回调函数
   * @returns
   */
  setOnReachMaxScale(callback: () => void): FontPinchGestureUtils {
    this.setOnReachMaxBoundary(callback);
    return this;
  }
  /**
   * 获取当前字体缩放倍数
   * @returns 当前字体缩放倍数
   */
  getCurrentFontScale(): number {
    return this.FONT_SCALE_LEVELS[this.currentScaleIndex];
  }

  /**
   * 重置字体缩放倍数到默认值
   */
  resetFontScale(): void {
    this.currentScaleIndex = 0;
    Logger.debug(TAG, 'Font scale reset to:' + this.getCurrentFontScale().toString());
  }

  /**
   * 手势开始处理
   */
  onActionStart(): void {
    this.initialScale = 1;
    this.resetBoundaryState();
    Logger.debug(TAG, 'PinchGesture onActionStart');
  }

  /**
   * 手势更新处理
   * @param event 手势事件
   */
  onActionUpdate(event: GestureEvent): void {
    // 如果手势被禁用，不处理
    if (!this.gestureEnabled) {
      return;
    }

    const scale = event.scale;
    // 计算相对于初始 scale 的总变化
    const totalScaleChange = scale - this.initialScale;

    // 使用 scaleThreshold 控制敏感度，避免轻微手势触发
    if (Math.abs(totalScaleChange) > this.scaleThreshold) {
      const currentTime = Date.now();

      // 防抖：检查距离上次触发的时间间隔
      if (currentTime - this.lastTriggerTime < this.triggerInterval) {
        return;
      }

      let oldScaleIndex = this.currentScaleIndex;

      // 双指外滑（scale > 1）：放大（增加倍数）
      // 双指捏合（scale < 1）：缩小（减少倍数）
      if (scale > 1) {
        // 放大：向下一档
        this.currentScaleIndex = Math.min(this.currentScaleIndex + 1, this.FONT_SCALE_LEVELS.length - 1);
      } else {
        // 缩小：向上一档
        this.currentScaleIndex = Math.max(this.currentScaleIndex - 1, 0);
      }

      // 只有发生变化时才当倍数触发回调
      if (this.currentScaleIndex !== oldScaleIndex) {
        const newScale = this.getCurrentFontScale();
        Logger.debug(TAG, 'Font scale changed to:' + newScale.toString());

        if (this.onFontSizeChange) {
          this.onFontSizeChange(newScale);
        }
        // 索引变化，重置边界状态，允许再次触发边界回调
        this.resetBoundaryState();
      } else {
        // 倍数没有变化，说明已经达到边界，使用父类方法处理边界回调
        const maxIndex = this.FONT_SCALE_LEVELS.length - 1;
        this.handleMinBoundaryReach(scale, this.currentScaleIndex === 0, scale < 1);
        this.handleMaxBoundaryReach(scale, this.currentScaleIndex === maxIndex, scale > 1);
      }

      this.lastTriggerTime = currentTime;
    }
  }

  /**
   * 手势结束处理
   */
  onActionEnd(): void {
    Logger.debug(TAG, 'PinchGesture onActionEnd, final font scale:' + this.getCurrentFontScale().toString());
  }
}
