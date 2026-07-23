import { display, window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { Logger } from 'lib_common';
import { Constants } from '../constants/Constants';

let uiContext: UIContext = AppStorage.get('uiContext') as UIContext;
const TAG = '[WindowUtils]';

/**
 * 位置信息
 */
export interface Position {
  x: number,
  y: number
}

/**
 * 聚焦到主窗口
 * @param windowStage 窗口管理器
 * @param windowName 子窗口名
 */
export function changeFocus(windowStage: window.WindowStage, windowName: string) {
  setTimeout(() => {
    // 获取子窗口ID
    try {
      let subWindowID: number = window.findWindow(windowName).getWindowProperties().id;
      // 获取主窗口ID
      let mainWindowID: number = windowStage.getMainWindowSync().getWindowProperties().id;
      // 将焦点从子窗口转移到主窗口
      window.shiftAppWindowFocus(subWindowID, mainWindowID).catch((e: BusinessError) => {
        Logger.error(TAG, 'shift AppWindow Focus fail, error: ' + JSON.stringify(e));
      });
    } catch (error) {
      Logger.error(TAG, 'change focus fail, error: ' + JSON.stringify(error));
    }
  }, Constants.CHANGE_FOCUS_DELAY);
}

/**
 * 贴边判断
 * @param window 目标窗口
 * @param windowPosition 位置信息
 */
export function edgeDetermination(window: window.Window, windowPosition: Position): void {
  try {
    const HALF_WIDTH = display.getDefaultDisplaySync().width * Constants.HALF;
    if (windowPosition.x < HALF_WIDTH) {
      windowPosition.x = 0;
    } else {
      windowPosition.x = display.getDefaultDisplaySync().width - window.getWindowProperties().windowRect.width;
    }
    window.moveWindowTo(windowPosition.x, windowPosition.y).catch((e: BusinessError) => {
      Logger.error(TAG, 'move window fail, error: ' + JSON.stringify(e));
    });
  } catch (error) {
    Logger.error(TAG, 'edge determination fail, error: ' + JSON.stringify(error));
  }
}

/**
 * 拖拽滑动
 * @param event 手势事件
 * @param window 目标窗口
 * @param windowPosition 位置信息
 */
export function dragToMove(event: GestureEvent, window: window.Window, windowPosition: Position): void {
  let bottomRectHeight = AppStorage.get('bottomRectHeight') as number;
  let topRectHeight = AppStorage.get('topRectHeight') as number;
  try {
    let bottomY =
      display.getDefaultDisplaySync().height - bottomRectHeight - uiContext.vp2px(Constants.INIT_SUBWINDOW_SIZE);
    windowPosition.x += event.offsetX;
    if (windowPosition.y > topRectHeight && windowPosition.y < bottomY) {
      windowPosition.y += event.offsetY;
    } else if (windowPosition.y <= topRectHeight && event.offsetY > 0) {
      windowPosition.y += event.offsetY;
    } else if (windowPosition.y >= bottomY && event.offsetY < 0) {
      windowPosition.y += event.offsetY;
    }
    window.moveWindowTo(windowPosition.x, windowPosition.y).catch((e: BusinessError) => {
      Logger.error(TAG, 'move window fail, error: ' + JSON.stringify(e));
    });
  } catch (error) {
    Logger.error(TAG, 'getDefaultDisplaySync fail, error: ' + JSON.stringify(error));
  }
}

/**
 * 切换悬浮窗样式
 * @param isExpand 展开标识
 * @param window 目标窗口
 */
export async function switchFloatingWindowStyle(isExpand: boolean, window: window.Window) {
  try {
    if (isExpand) {
      let width = uiContext.vp2px(Constants.EXPANDED_SUBWINDOW_WIDTH);
      let height = uiContext.vp2px(Constants.INIT_SUBWINDOW_SIZE);
      await window.resizeAsync(width, height);
    } else {
      let width = uiContext.vp2px(Constants.INIT_SUBWINDOW_SIZE);
      let height = uiContext.vp2px(Constants.INIT_SUBWINDOW_SIZE);
      await window.resizeAsync(width, height);
    }
  } catch (error) {
    Logger.error(TAG, 'resizeAsync fail, error: ' + JSON.stringify(error));
  }
}

/**
 * 切换悬浮窗样式并贴边
 * @param isExpand 展开标识
 * @param window 目标窗口
 * @param windowPosition 位置信息
 */
export async function switchFloatingWindowStyleMove(isExpand: boolean, window: window.Window,
  windowPosition: Position) {
  try {
    if (isExpand) {
      let width = uiContext.vp2px(Constants.EXPANDED_SUBWINDOW_WIDTH);
      let height = uiContext.vp2px(Constants.INIT_SUBWINDOW_SIZE);

      await window.resizeAsync(width, height);

    } else {
      let width = uiContext.vp2px(Constants.INIT_SUBWINDOW_SIZE);
      let height = uiContext.vp2px(Constants.INIT_SUBWINDOW_SIZE);
      await window.resizeAsync(width, height);
    }
    if (windowPosition.x > display.getDefaultDisplaySync()
      .width * Constants.HALF) {
      windowPosition.x = display.getDefaultDisplaySync().width - window.getWindowProperties().windowRect.width;
      window.moveWindowTo(windowPosition.x, windowPosition.y).catch((e: BusinessError) => {
        Logger.error(TAG, 'move window fail, error: ' + JSON.stringify(e));
      });
    }
  } catch (error) {
    Logger.error(TAG, 'switchFloatingWindowStyleMove fail, error: ' + JSON.stringify(error));
  }
}