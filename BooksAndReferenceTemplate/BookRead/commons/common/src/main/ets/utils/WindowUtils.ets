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
    AppStorage.set('windowTopHeight', WindowUtils.windowHeight);
    WindowUtils.w = w;
  }

  public static getWindowHeight(): number {
    return WindowUtils.windowHeight;
  }

  public static getWindowWidth(): number {
    return WindowUtils.windowWidth;
  }

  public static async setWindowBright(light: number) {
    if (WindowUtils.w) {
      await WindowUtils.w.setWindowBrightness(light);
    }
  }

  public static getWindowBright() {
    if (WindowUtils.w) {
      return WindowUtils.w.getWindowProperties().brightness;
    }

    return 0;
  }

  public static getMainWindow(): window.Window {
    return WindowUtils.w as window.Window
  }

  public static resize() {
    if (WindowUtils.w) {
      WindowUtils.windowWidth = WindowUtils.w?.getWindowProperties().windowRect.width; // 屏幕宽
      WindowUtils.windowHeight = WindowUtils.w?.getWindowProperties().windowRect.height; // 屏幕高 当前的图像充满屏幕，宽高和图像一样
      AppStorage.set('windowTopHeight', WindowUtils.windowHeight);
    }
  }
}