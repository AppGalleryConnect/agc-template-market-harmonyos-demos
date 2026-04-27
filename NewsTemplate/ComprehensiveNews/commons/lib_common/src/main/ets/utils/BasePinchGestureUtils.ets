import { Logger } from './Logger';

const TAG = '[BasePinchGestureUtils]';

/**
 * 手势缩放识别基类
 */
export class BasePinchGestureUtils {
  protected initialScale: number = 1; // 手势开始时的初始 scale
  protected scaleThreshold: number = 0.3; // 手势识别敏感度阈值
  protected lastTriggerTime: number = 0; // 上次触发时间
  protected triggerInterval: number = 300; // 触发间隔（毫秒），防抖
  protected gestureEnabled: boolean = true;
  protected onScaleChange: ((scale: number) => void) | null = null;
  protected hasReachedMinBoundary: boolean = false; // 是否已触发过最小边界回调
  protected hasReachedMaxBoundary: boolean = false; // 是否已触发过最大边界回调
  protected onReachMinBoundary: (() => void) | null = null; // 达到最小边界回调
  protected onReachMaxBoundary: (() => void) | null = null; // 达到最大边界回调

  /**
   * 构造函数
   * @param scaleThreshold 手势识别敏感度阈值（默认0.3）
   */
  constructor(scaleThreshold: number = 0.3) {
    this.scaleThreshold = scaleThreshold;
  }

  /**
   * 设置系数变化回调
   * @param callback 缩放系数变化时的回调函数
   * @returns
   */
  setOnScaleChange(callback: (scale: number) => void): BasePinchGestureUtils {
    this.onScaleChange = callback;
    return this;
  }

  /**
   * 设置手势是否启用
   * @param enabled 是否启用手势
   * @returns
   */
  setGestureEnabled(enabled: boolean): BasePinchGestureUtils {
    this.gestureEnabled = enabled;
    Logger.debug(TAG, 'Gesture enabled:' + enabled.toString());
    return this;
  }
  
  /**
   * 设置达到最小边界的回调
   * @param callback 达到最小边界时的回调函数
   * @returns
   */
  setOnReachMinBoundary(callback: () => void): BasePinchGestureUtils {
    this.onReachMinBoundary = callback;
    return this;
  }
  
  /**
   * 设置达到最大边界的回调
   * @param callback 达到最大边界时的回调函数
   * @returns
   */
  setOnReachMaxBoundary(callback: () => void): BasePinchGestureUtils {
    this.onReachMaxBoundary = callback;
    return this;
  }
  /**
   * 手势开始处理
   */
  onActionStart(): void {
    this.initialScale = 1;
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
    // 捏合（scale < 1），扩展（scale > 1）
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

      this.lastTriggerTime = currentTime;

      if (this.onScaleChange) {
        this.onScaleChange(scale);
      }

      Logger.debug(TAG, 'PinchGesture scale:' + scale);
    }
  }

  /**
   * 手势结束处理
   */
  onActionEnd(): void {
    Logger.debug(TAG, 'PinchGesture onActionEnd');
  }

  /**
   * 重置边界状态标记
   * 在手势开始或值变化时调用，允许再次触发边界回调
   */
  protected resetBoundaryState(): void {
    this.hasReachedMinBoundary = false;
    this.hasReachedMaxBoundary = false;
  }

  /**
   * 处理最小边界到达
   * @param scale 当前缩放值
   * @param isAtMin 是否在最小边界
   * @param isTowardsMin 是否向最小边界方向缩放
   */
  protected handleMinBoundaryReach(scale: number, isAtMin: boolean, isTowardsMin: boolean): void {
    if (isAtMin && isTowardsMin && !this.hasReachedMinBoundary) {
      this.hasReachedMinBoundary = true;
      this.onReachMinBoundary?.();
    }
  }
  
  /**
   * 处理最大边界到达
   * @param scale 当前缩放值
   * @param isAtMax 是否在最大边界
   * @param isTowardsMax 是否向最大边界方向缩放
   */
  protected handleMaxBoundaryReach(scale: number, isAtMax: boolean, isTowardsMax: boolean): void {
    if (isAtMax && isTowardsMax && !this.hasReachedMaxBoundary) {
      this.hasReachedMaxBoundary = true;
      this.onReachMaxBoundary?.();
    }
  }}