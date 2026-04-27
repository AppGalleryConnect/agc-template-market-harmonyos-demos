import { window } from '@kit.ArkUI';
import { LongTakeTransitionConstants } from '../constants/LongTakeTransitionConstants';

const TAG = 'WindowUtils';

export class WindowUtils {
  public static window: window.Window;

  public static windowWidthPx: number;

  public static windowHeightPx: number;

  public static topAvoidAreaHeightPx: number;

  public static navigationIndicatorHeightPx: number;

  public static init(windowStage: window.WindowStage) {
    // 获取窗口宽高
    WindowUtils.window = windowStage.getMainWindowSync();
    WindowUtils.windowWidthPx = WindowUtils.window.getWindowProperties().windowRect.width;
    WindowUtils.windowHeightPx = WindowUtils.window.getWindowProperties().windowRect.height;

    AppStorage.setOrCreate(LongTakeTransitionConstants.WINDOW_SIZE,
      { width: WindowUtils.windowWidthPx, height: WindowUtils.windowHeightPx });

    // 获取上方避让区(状态栏等)高度
    let avoidArea = WindowUtils.window.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
    WindowUtils.topAvoidAreaHeightPx = avoidArea.topRect.height;

    // 获取导航条高度
    let navigationArea = WindowUtils.window.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR);
    WindowUtils.navigationIndicatorHeightPx = navigationArea.bottomRect.height;

    // 监听窗口尺寸、状态栏高度及导航条高度的变化并更新
    try {
      WindowUtils.window.on('windowSizeChange', (data) => {
        console.info(TAG, 'on windowSizeChange, the width is ' + data.width + ', the height is ' + data.height);
        WindowUtils.windowWidthPx = data.width;
        WindowUtils.windowHeightPx = data.height;
        AppStorage.setOrCreate(LongTakeTransitionConstants.ON_WINDOW_SIZE_CHANGED, Date.now());
        AppStorage.setOrCreate(LongTakeTransitionConstants.WINDOW_SIZE, { width: data.width, height: data.height });
      })

      WindowUtils.window.on('avoidAreaChange', (data) => {
        if (data.type === window.AvoidAreaType.TYPE_SYSTEM) {
          let topRectHeight = data.area.topRect.height;
          console.info(TAG, 'on avoidAreaChange, the top avoid area height is ' + topRectHeight);
          WindowUtils.topAvoidAreaHeightPx = topRectHeight;
        } else if (data.type === window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR) {
          let bottomRectHeight = data.area.bottomRect.height;
          console.info(TAG, 'on avoidAreaChange, the navigation indicator height is ' + bottomRectHeight);
          WindowUtils.navigationIndicatorHeightPx = bottomRectHeight;
        }
      })
    } catch (exception) {
      console.info(TAG, 'register failed ' + JSON.stringify(exception));
    }
  }
}