import { display, window } from '@kit.ArkUI';
import { BusinessError, emitter } from '@kit.BasicServicesKit';
import { UtilLog } from '@hw-agconnect/util-log';
import * as AudioSubWindow from '../components/AudioSubWindowPlayer';
import { AudioConstants } from '../constants/Constants';
import { MediaViewModel } from '../viewmodel/MediaViewModel';
import { EventMap } from '../constants/EventMap';

const TAG = '[MediaTools]';

export class MediaTools {
  /**
   * 创建子窗口
   * @param uiContext
   * @param isNotCreate 默认不创建子窗口
   */
  static async createSubWindow(uiContext: UIContext, isNotCreate = true) {
    const windowStage = MediaViewModel.windowStage!
    let hasSubWindow: boolean = await MediaTools.getSubWindow()
    if ((!MediaViewModel.getInstance().isPlaying || hasSubWindow) && isNotCreate) {
      return
    }
    windowStage.createSubWindow(AudioConstants.AUDIO_SUB_NAME).then(async (windowClass) => {
      try {
        // 设置子窗口加载页
        windowClass.loadContentByName(AudioSubWindow.entryName, () => {
          windowClass.setWindowBackgroundColor('#00000000');
        });
        await windowClass.moveWindowTo(uiContext.vp2px(16),
          display.getDefaultDisplaySync().height - uiContext.vp2px(200));
        await windowClass.resize(uiContext.vp2px(AudioConstants.SUB_WIN_STATE_0_WIDTH),
          uiContext.vp2px(AudioConstants.SUB_WIN_HEIGHT));
        await windowClass.showWindow();
        emitter.on(EventMap.DESTROY_SUB_WINDOW, () => {
          MediaTools.destroySubWindow(AudioConstants.AUDIO_SUB_NAME)
        })
      } catch (err) {
        UtilLog.error(TAG, `failed to create subWindow Cause:${err}`);
      }
    }).catch((err: BusinessError) => {
      UtilLog.error(TAG, `failed to create subWindow Cause:${err}`);
      return;
    })
  }

  /**
   * 获取子窗口
   */

  static async getSubWindow() {
    try {
      const windowStage = MediaViewModel.windowStage!
      let windowClass = await windowStage.getSubWindow();
      let windowNameList = windowClass.map(item => item.getWindowProperties().name)
      return windowNameList.includes(AudioConstants.AUDIO_SUB_NAME)
    } catch (e) {
      UtilLog.error(TAG, `failed to getSubWindow Cause:${e}`);
      return false;
    }
  }

  /**
   * 销毁子窗口
   * @param windowName 子窗口名
   */
  static async destroySubWindow(windowName: string) {
    try {
      let hasSubWindow = await MediaTools.getSubWindow()
      if (hasSubWindow) {
        emitter.off(EventMap.DESTROY_SUB_WINDOW)
        await window.findWindow(windowName).destroyWindow()
      }
    } catch (e) {
      UtilLog.info('destroySubWindow error' + `${e}`)
    }
  }

  static async pause() {
    MediaViewModel.getInstance().pause()
  }

  static async createSession() {
    MediaViewModel.getInstance().createSession()
  }
}