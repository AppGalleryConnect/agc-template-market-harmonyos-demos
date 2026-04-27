/**
 * @fileType: common
 * @zhName: 窗口工具类
 */
import { window } from '@kit.ArkUI';

export class WindowUtils {
  private static windowHeight: number = 0;
  private static windowWidth: number = 0;
  private static w: window.Window | undefined = undefined;

  public static init(w: window.Window) {
    // 屏幕宽高 px
    WindowUtils.windowWidth = w.getWindowProperties().windowRect.width; // 屏幕宽
    WindowUtils.windowHeight = w.getWindowProperties().windowRect.height; // 屏幕高 当前的图像充满屏幕，宽高和图像一样
    // 设置沉浸式
    w.setWindowLayoutFullScreen(true);
    WindowUtils.w = w;
  }

  public static getWindowHeight(): number {
    return WindowUtils.windowHeight;
  }

  public static getWindowWidth(): number {
    return WindowUtils.windowWidth;
  }

  public static getMainWindow(): window.Window {
    return WindowUtils.w as window.Window
  }

  public static getContext() {
    return WindowUtils.w?.getUIContext();
  }
}