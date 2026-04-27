import { BasePinchGestureUtils } from './BasePinchGestureUtils';
import { Logger } from './Logger';

const TAG = '[LanesPinchGestureUtils]';

/**
 * 列数手势工具类
 * 封装捏合手势处理逻辑，支持动态调整列表列数
 */
export class LanesPinchGestureUtils extends BasePinchGestureUtils {
  private minLanes: number;
  private maxLanes: number;
  private currentLanes: number = 1;
  private onLanesChange: ((lanes: number) => void) | null = null;

  /**
   * 构造函数
   * @param currentLanes 当前列数
   * @param minLanes 最小列数
   * @param maxLanes 最大列数
   * @param scaleThreshold 手势识别敏感度阈值（默认0.3）
   */
  constructor(currentLanes: number = 1, minLanes: number = 1, maxLanes: number = 4, scaleThreshold: number = 0.3) {
    super(scaleThreshold);
    this.currentLanes = currentLanes;
    this.minLanes = minLanes;
    this.maxLanes = maxLanes;
  }

  /**
   * 设置列数变化回调
   * @param callback 列数变化时的回调函数
   * @returns
   */
  setOnLanesChange(callback: (lanes: number) => void): LanesPinchGestureUtils {
    this.onLanesChange = callback;
    return this;
  }
  
  /**
   * 设置列数达到最小值的回调
   * @param callback 列数达到最小值的回调函数
   * @returns
   */
  setOnReachMinLanes(callback: () => void): LanesPinchGestureUtils {
    this.setOnReachMinBoundary(callback);
    return this;
  }
  
  /**
   * 设置列数达到最大值的回调
   * @param callback 列数达到最大值的回调函数
   * @returns
   */
  setOnReachMaxLanes(callback: () => void): LanesPinchGestureUtils {
    this.setOnReachMaxBoundary(callback);
    return this;
  }
  /**
   * 设置列数范围
   * @param minLanes 最小列数
   * @param maxLanes 最大列数
   * @returns
   */
  setLanesRange(minLanes: number, maxLanes: number): LanesPinchGestureUtils {
    this.minLanes = minLanes;
    this.maxLanes = maxLanes;
    return this;
  }

  /**
   * 获取当前列数
   * @returns 当前列数
   */
  getCurrentLanes(): number {
    return this.currentLanes;
  }

  /**
   * 手势开始处理
   */
  onActionStart(): void {
    this.initialScale = 1;
    this.resetBoundaryState();
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

    // 捏合（scale < 1）增加列数，扩展（scale > 1）减少列数
    // 使用 scaleThreshold 控制敏感度，避免轻微手势触发
    if (Math.abs(totalScaleChange) > this.scaleThreshold) {
      const currentTime = Date.now();

      // 防抖：检查距离上次触发的时间间隔
      if (currentTime - this.lastTriggerTime < this.triggerInterval) {
        return;
      }

      let newLanes = this.currentLanes;

      if (scale < 1) {
        // 捏合：增加列数
        newLanes = Math.min(this.currentLanes + 1, this.maxLanes);
      } else {
        // 扩展：减少列数
        newLanes = Math.max(this.currentLanes - 1, this.minLanes);
      }

      if (newLanes !== this.currentLanes) {
        Logger.debug(TAG, 'PinchGesture lanes changed to:' + newLanes.toString());
        this.currentLanes = newLanes;
        if (this.onLanesChange) {
          this.onLanesChange(newLanes);
        }
        // 列数变化，重置边界状态，允许再次触发边界回调
        this.resetBoundaryState();
      } else {
        // 列数没有变化，说明已经达到边界，使用父类方法处理边界回调
        // 注意：捏合（scale < 1）增加列数，扩展（scale > 1）减少列数
        // 所以 scale > 1 时向最小列数方向，scale < 1 时向最大列数方向
        this.handleMinBoundaryReach(scale, this.currentLanes === this.minLanes, scale > 1);
        this.handleMaxBoundaryReach(scale, this.currentLanes === this.maxLanes, scale < 1);
      }
      this.lastTriggerTime = currentTime;
    }
  }

  /**
   * 手势结束处理
   */
  onActionEnd(): void {
    Logger.debug(TAG, 'PinchGesture onActionEnd, final lanes:' + this.currentLanes.toString());
  }
}