import { GlobalContextUtils } from 'lib_common';
import { VideoPlayService } from 'module_swipeplayer';

const TAG = '[AVSessionUtils]';

/**
 * 播控中心工具类
 */
export class AVSessionUtils {
  /**
   * 释放【视频】Session
   */
  public static async destroyVideoSession() {
    await VideoPlayService.destroySession(GlobalContextUtils.globalContext);
  }

}
