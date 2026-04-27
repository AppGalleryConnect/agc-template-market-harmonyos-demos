import { common, wantAgent } from '@kit.AbilityKit';
import { backgroundTaskManager } from '@kit.BackgroundTasksKit';
import { UtilLog } from '@hw-agconnect/util-log';

const TAG = '[BackgroundTaskUtils]';

/**
 * 后台任务工具类
 */
export class BackgroundTaskUtils {
  /**
   * 创建后台任务
   * @param context
   */
  public static async createBackgroundTask(context: common.UIAbilityContext): Promise<void> {
    let wantAgentInfo: wantAgent.WantAgentInfo = {
      wants: [{ bundleName: context.abilityInfo.bundleName, abilityName: context.abilityInfo.name }],
      actionType: wantAgent.OperationType.START_ABILITY,
      requestCode: 0,
      wantAgentFlags: [wantAgent.WantAgentFlags.UPDATE_PRESENT_FLAG],
    };
    try {
      const agent = await wantAgent.getWantAgent(wantAgentInfo);
      await backgroundTaskManager.startBackgroundRunning(context,
        backgroundTaskManager.BackgroundMode.AUDIO_PLAYBACK, agent);
      UtilLog.info(TAG, `Successed to startBackgroundRunning.`);
    } catch (e) {
      UtilLog.error(TAG, `Failed to startBackgroundRunning. Code: ${e.code}, message: ${e.message}`);
    }
  };

  /**
   * 取消后台任务
   * @param context
   */
  public static async cancelBackgroundTask(context: common.UIAbilityContext): Promise<void> {
    try {
      await backgroundTaskManager.stopBackgroundRunning(context);
      UtilLog.info(TAG, `Successed to stopBackgroundRunning.`);
    } catch (e) {
      UtilLog.error(TAG, `Failed to stopBackgroundRunning. Code: ${e.code}, message: ${e.message}`);
    }
  };
}