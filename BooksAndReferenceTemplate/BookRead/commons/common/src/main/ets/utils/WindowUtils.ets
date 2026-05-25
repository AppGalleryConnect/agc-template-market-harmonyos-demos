import { window } from '@kit.ArkUI';

@ObservedV2
export class WindowUtils {
  private static windowHeight: number = 0;
  private static windowWidth: number = 0;
  private static w: window.Window | undefined = undefined;

  public static init(w: window.Window) {
    try {
      // 屏幕宽高 px
      WindowUtils.windowWidth = w.getWindowProperties().windowRect.width; // 屏幕宽
      WindowUtils.windowHeight = w.getWindowProperties().windowRect.height; // 屏幕高 当前的图像充满屏幕，宽高和图像一样
      // 设置沉浸式
      w.setWindowLayoutFullScreen(true);
      let type = window.AvoidAreaType.TYPE_SYSTEM; // 以状态栏避让为例
      let avoidArea = w.getWindowAvoidArea(type);
      let topRectHeight = avoidArea.topRect.height; // 获取状态栏区域高度
      AppStorage.setOrCreate('windowTopHeight', w.getUIContext().px2vp(topRectHeight));

      type = window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR;
      avoidArea = w.getWindowAvoidArea(type);
      let bottomRectHeight = avoidArea.bottomRect.height; // 获取到导航区域的高度
      AppStorage.setOrCreate('bottomRectHeight', w.getUIContext().px2vp(bottomRectHeight));
      WindowUtils.w = w;

      // 3. 注册监听函数，动态获取避让区域数据
      w.on('avoidAreaChange', (data) => {
        if (data.type === window.AvoidAreaType.TYPE_SYSTEM) {
          let topRectHeight = data.area.topRect.height;
          AppStorage.setOrCreate('windowTopHeight', w.getUIContext().px2vp(topRectHeight));
        } else if (data.type === window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR) {
          let bottomRectHeight = data.area.bottomRect.height;
          AppStorage.setOrCreate('bottomRectHeight', w.getUIContext().px2vp(bottomRectHeight));
        }
      });
      WindowUtils.onWindowSizeChange()
    } catch (error) {
      console.error('WindowUtils', `init error = ${JSON.stringify(error)}`)
    }
  }

  public static onWindowSizeChange(callback?: () => void): void {
    if (!WindowUtils.w) {
      return;
    }
    try {
      WindowUtils.w?.on('windowSizeChange', (data) => {
        let properties = data
        WindowUtils.windowWidth = properties.width
        WindowUtils.windowHeight = properties.height
        callback?.();
      });
    } catch (error) {
      console.error('WindowUtils', ` onWindowSizeChange error = ${JSON.stringify(error)}`)
    }
  }

  public static onWindowSizeOff() {
    try {
      WindowUtils.w?.off('windowSizeChange')
    } catch (error) {
      console.error('WindowUtils', ` onWindowSizeOff error = ${JSON.stringify(error)}`)
    }
  }

  public static getWindowHeight(): number {
    return WindowUtils.windowHeight;
  }

  public static getWindowWidth(): number {
    return WindowUtils.windowWidth;
  }

  public static setWindowWidth(windowWidth: number) {
    WindowUtils.windowWidth = windowWidth
  }

  public static setWindowHeight(windowHeight: number) {
    WindowUtils.windowHeight = windowHeight
  }

  public static async setWindowBright(light: number) {
    if (WindowUtils.w) {
      try {
        await WindowUtils.w.setWindowBrightness(light);
      } catch (error) {
        console.error('WindowUtils', `setWindowBright error = ${JSON.stringify(error)}`)
      }
    }
  }

  public static getWindowBright() {
    if (WindowUtils.w) {
      try {
        return WindowUtils.w.getWindowProperties().brightness;
      } catch (error) {
        console.error('WindowUtils', ` getWindowProperties error = ${JSON.stringify(error)}`)
      }
    }
    return 0;
  }

  public static getMainWindow(): window.Window {
    return WindowUtils.w as window.Window
  }

  public static resize() {
    if (WindowUtils.w) {
      try {
        WindowUtils.windowWidth = WindowUtils.w?.getWindowProperties().windowRect.width; // 屏幕宽
        WindowUtils.windowHeight = WindowUtils.w?.getWindowProperties().windowRect.height; // 屏幕高 当前的图像充满屏幕，宽高和图像一样
        AppStorage.set('windowTopHeight', WindowUtils.windowHeight);
      } catch (error) {
        console.error('WindowUtils', ` resize getWindowProperties error = ${JSON.stringify(error)}`)
      }
    }
  }
}