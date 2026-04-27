import { KeyboardAvoidMode, window } from '@kit.ArkUI';
import display from '@ohos.display';
import { Callback } from '@ohos.base';
import { Logger } from "../logger/AppLogger";
import { DeviceUtil } from './DeviceUtil';
import { SafeJson } from '../json/SafeJson';

const TAG = 'WindowManager';

export class WindowManager {
  private static windowStage: window.WindowStage;
  private static videoFullScreen: boolean = false;

  public static initWindowStage(windowStage: window.WindowStage): void {
    WindowManager.windowStage = windowStage;
  }

  /**
   * 设置全屏播放视频的情况下页面旋转
   * @param isFullScreen
   * @returns
   */
  public static async setVideoFullScreen(videoFullScreen: boolean, videoWidth: number, videoHeight: number): Promise<void> {
    WindowManager.videoFullScreen = videoFullScreen;
    let w = this.windowStage?.getMainWindowSync();
    if (!w) {
      return;
    }
    try {
      await w.setWindowSystemBarEnable(videoFullScreen ? [] : ['status', 'navigation']);

      const videoAspectRatio = videoWidth / videoHeight;
      const isLandscapeVideo = videoAspectRatio > 1;

      // 折叠屏
      if (display.isFoldable()) {
        if (display.getFoldStatus() === display.FoldStatus.FOLD_STATUS_FOLDED) {
          Logger.info(TAG, "video fold status: " + display.getFoldStatus());
          await w.setPreferredOrientation(videoFullScreen ? window.Orientation.LANDSCAPE : window.Orientation.PORTRAIT);
        } else {
          await w.setPreferredOrientation(window.Orientation.AUTO_ROTATION_RESTRICTED);
        }
        return;
      }
      // 直板机：根据视频比例决定是否允许旋转
      if (DeviceUtil.isPhone()) {
        if (videoFullScreen) {
          if (isLandscapeVideo) { // 长视频（横屏比例）允许自动旋转
            await w.setPreferredOrientation(window.Orientation.AUTO_ROTATION_LANDSCAPE_RESTRICTED);
          } else { // 短视频（竖屏比例）锁定竖屏
            await w.setPreferredOrientation(window.Orientation.PORTRAIT);
          }
        } else {
          await w.setPreferredOrientation(window.Orientation.PORTRAIT); // 非全屏保持竖屏
        }
        return;
      }
      // 平板
      await w.setPreferredOrientation(window.Orientation.AUTO_ROTATION_RESTRICTED);
    } catch (exception) {
      Logger.error(TAG, 'Failed to setVideoFullScreen: ' + SafeJson.ohAegJsonStringify(exception));
    }
  }

  /**
   * 设置全屏
   * @param isFullScreen
   * @returns
   */
  public static async setWindowLayoutFullScreen(isFullScreen: boolean): Promise<boolean> {
    let w = this.windowStage?.getMainWindowSync();
    if (!w) {
      return false;
    }
    await w.setWindowLayoutFullScreen(isFullScreen);
    return true;
  }

  /**
   * 设置页面防截屏
   * @param isPrivacyMode
   * @returns
   */
  public static async setWindowPrivacyMode(isPrivacyMode: boolean): Promise<boolean> {
    let w = this.windowStage?.getMainWindowSync();
    if (!w) {
      return false;
    }
    //await w.setWindowPrivacyMode(isPrivacyMode);
    return true;
  }

  /**
   * 设置页面旋转
   * @returns
   */
  public static async setWindowOrientation(): Promise<void> {
    let w = this.windowStage?.getMainWindowSync();
    if (!w) {
      return;
    }
    try {
      // 折叠屏
      if (display.isFoldable()) {
        if (display.getFoldStatus() === display.FoldStatus.FOLD_STATUS_FOLDED) {
          Logger.info(TAG, "fold status: " + display.getFoldStatus());
          await w.setPreferredOrientation(window.Orientation.PORTRAIT);
        } else {
          await w.setPreferredOrientation(window.Orientation.AUTO_ROTATION_RESTRICTED);
        }

        let callback: Callback<display.FoldStatus> = async (data: display.FoldStatus) => {
          Logger.info(TAG, 'fold status changed: ' + data);
          if (data === display.FoldStatus.FOLD_STATUS_FOLDED) {
            Logger.info(TAG, 'videoFullScreen: ' + WindowManager.videoFullScreen);
            await w.setPreferredOrientation(WindowManager.videoFullScreen ? window.Orientation.LANDSCAPE :
            window.Orientation.PORTRAIT);
          } else {
            await w.setPreferredOrientation(window.Orientation.AUTO_ROTATION_RESTRICTED);
          }
        };
        display.on('foldStatusChange', callback);
        return;
      }
      // 直板机
      if (DeviceUtil.isPhone()) {
        await w.setPreferredOrientation(window.Orientation.PORTRAIT);
        return;
      }
      // 平板
      Logger.info(TAG, 'window.Orientation : auto_rotation_restricted ');
      await w.setPreferredOrientation(window.Orientation.AUTO_ROTATION_RESTRICTED);
    } catch (exception) {
      Logger.error(TAG, 'Failed to setWindowOrientation: ' + SafeJson.ohAegJsonStringify(exception));
    }
  }

  /**
   * 用于设置窗口内导航栏、状态栏的属性，包括状态栏背景颜色、状态栏文字颜色等
   * @param sysBarProps
   * @returns
   */
  public static async setWindowSystemBarProperties(sysBarProps: window.SystemBarProperties): Promise<void> {
    // 获取主窗口的方式
    let mainWin: window.Window = this.windowStage.getMainWindowSync();
    if (!mainWin) {
      return;
    }
    try {
      await mainWin.setWindowSystemBarProperties(sysBarProps)
    } catch (exception) {
      Logger.error(TAG, 'Failed to setWindowSystemBarProperties: ' + SafeJson.ohAegJsonStringify(exception));
    }
  }
  /**
   * 用于设置窗口内导航栏、状态栏的显隐
   * @param names
   */
  public static async setWindowSystemBarEnable(names?: Array<'status' | 'navigation'>): Promise<void> {
    // 获取主窗口的方式
    let mainWin: window.Window = this.windowStage.getMainWindowSync();
    if (!mainWin) {
      return;
    }
    try {
      await mainWin.setWindowSystemBarEnable(names)
    } catch (exception) {
      Logger.error(TAG, 'Failed to setWindowSystemBarEnable: ' + SafeJson.ohAegJsonStringify(exception));
    }
  }
  /**
   * 用于获取SystemBar属性
   * @returns
   */
  public static getWindowSystemBarProperties(): window.SystemBarProperties | undefined {
    // 获取主窗口的方式
    let mainWin: window.Window = this.windowStage.getMainWindowSync();
    if (mainWin) {
      try {
        return mainWin.getWindowSystemBarProperties();
      } catch (exception) {
        Logger.error(TAG, 'Failed to setWindowSystemBarProperties: ' + SafeJson.ohAegJsonStringify(exception));
      }
    }
    return undefined;
  }

  /**
   * 用于获取窗口的属性
   */
  public static getWindowProperties(): window.WindowProperties | undefined {
    // 获取主窗口的方式
    let mainWin: window.Window = this.windowStage.getMainWindowSync();
    if (mainWin) {
      try {
        return mainWin.getWindowProperties();
      } catch (exception) {
        Logger.error(TAG, 'Failed to getWindowProperties: ' + SafeJson.ohAegJsonStringify(exception));
      }
    }
    return undefined;
  }
  /**
   *  压缩模式用于实现软键盘避让
   */
  public static setKeyboardAvoid(avoid: boolean): void {
    // 获取主窗口的方式
    let mainWin: window.Window = this.windowStage.getMainWindowSync();
    if (mainWin) {
      mainWin.getUIContext().setKeyboardAvoidMode(avoid ? KeyboardAvoidMode.RESIZE : KeyboardAvoidMode.OFFSET);
    }
  }
}