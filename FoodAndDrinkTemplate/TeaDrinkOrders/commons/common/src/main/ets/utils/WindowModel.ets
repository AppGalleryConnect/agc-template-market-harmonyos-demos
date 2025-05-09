import { window } from '@kit.ArkUI';
import { logger } from './Logger';
import { BusinessError } from '@kit.BasicServicesKit';

/**
 * 窗口管理模型
 */
export default class WindowModel {
  // 默认的顶部导航栏高度
  public static readonly STATUS_BAR_HEIGHT = 38.8;
  // 默认的底部导航条高度
  public static readonly BOTTOM_AVOID_HEIGHT = 10;

  private constructor() {
  }

  // WindowModel 单例
  private static instance?: WindowModel;
  // 键值对
  private objects = new Map<string, Object>();

  /**
   * 获取WindowModel单例实例
   * @returns {WindowModel} WindowModel
   */
  static getInstance(): WindowModel {
    if (!WindowModel.instance) {
      WindowModel.instance = new WindowModel();
    }
    return WindowModel.instance;
  }

  // 缓存的当前WindowStage实例
  private windowStage?: window.WindowStage;

  /**
   * 缓存windowStage
   * @param windowStage 当前WindowStage实例
   * @returns {void}
   */
  setWindowStage(windowStage: window.WindowStage): void {
    this.windowStage = windowStage;
  }

  /**
   * 当前主窗口是否开启沉浸模式
   * @param enable 是否开启
   * @returns {void}
   */
  setMainWindowImmersive(enable: boolean): void {
    if (this.windowStage === undefined) {
      logger.error('windowStage is undefined.');
      return;
    }
    this.windowStage.getMainWindow((err, windowClass: window.Window) => {
      if (err.code) {
        logger.error(`Failed to obtain the main window. Code:${err.code}, message:${err.message}`);
        return;
      }
      let promise = windowClass.setWindowLayoutFullScreen(enable);
      promise.then(() => {
        logger.info('Succeeded in setting the window layout to full-screen mode.');
      }).catch((err: BusinessError) => {
        logger.error(`Failed to set full-screen mode. Code:${err.code}, message:${err.message}`);
      });
    });
  }

  /**
   * 获取主窗口顶部导航栏高度
   * @returns {callback((statusBarHeight: number) => void))}
   */
  getStatusBarHeight(callback: ((statusBarHeight: number) => void)): void {
    if (this.windowStage === undefined) {
      logger.error('windowStage is undefined.');
      return;
    }
    this.windowStage.getMainWindow((err, windowClass: window.Window) => {
      if (err.code) {
        logger.error(`Failed to obtain the main window. Code:${err.code}, message:${err.message}`);
        return;
      }
      try {
        const type = window.AvoidAreaType.TYPE_SYSTEM;
        const avoidArea = windowClass.getWindowAvoidArea(type);
        const height = avoidArea.topRect.height;
        logger.info('Successful get statusHeight' + height);
        callback(height);
      } catch (err) {
        callback(WindowModel.STATUS_BAR_HEIGHT);
        logger.info('Failed to get statusHeight');
      }
    });
  }

  /**
   * 获取主窗口底部导航条高度
   * @returns {callback: ((bottomAvoidHeight: number) => void)}
   */
  getBottomAvoidHeight(callback: ((bottomAvoidHeight: number) => void)): void {
    if (this.windowStage === undefined) {
      logger.error('windowStage is undefined.');
      return;
    }
    this.windowStage.getMainWindow((err, windowClass: window.Window) => {
      if (err.code) {
        logger.error(`Failed to obtain the main window. Code:${err.code}, message:${err.message}`);
        return;
      }
      try {
        const type = window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR;
        const avoidArea = windowClass.getWindowAvoidArea(type);
        const height = avoidArea.bottomRect.height;
        logger.info('Successful get bottomAvoidHeight ==' + height);
        callback(height);
      } catch (err) {
        callback(WindowModel.BOTTOM_AVOID_HEIGHT);
        logger.info('Failed to get bottomAvoidHeight');
      }
    });
  }
}
