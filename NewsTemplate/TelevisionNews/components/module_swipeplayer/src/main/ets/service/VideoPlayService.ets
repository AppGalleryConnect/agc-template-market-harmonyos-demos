import { VideoSessionController } from '../controller/VideoSessionController';

const TAG = '[VideoPlayService]';

/**
 * 视频播放服务类
 */
export class VideoPlayService {
  /**
   * 释放AVSession
   * @param context
   */
  public static async destroySession(context: Context) {
    await VideoSessionController.instance.destroy(context);
  }
}