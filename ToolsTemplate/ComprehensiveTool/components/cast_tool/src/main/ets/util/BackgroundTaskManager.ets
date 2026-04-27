import { common, wantAgent } from '@kit.AbilityKit';
import { backgroundTaskManager } from '@kit.BackgroundTasksKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { UtilLog as Logger, UtilLog } from '@hw-agconnect/util-log';

const TAG = '[BackgroundTaskManager]';

// 后台任务管理
export class BackgroundTaskManager {
  public static startContinuousTask(context?: common.UIAbilityContext): void {
    if (!context) {
      return;
    }
    let wantAgentInfo: wantAgent.WantAgentInfo = {
      wants: [
        {
          bundleName: context.abilityInfo.bundleName,
          abilityName: context.abilityInfo.name,
        },
      ],
      requestCode: 0,
      wantAgentFlags: [wantAgent.WantAgentFlags.UPDATE_PRESENT_FLAG],
    };

    try {
      wantAgent.getWantAgent(wantAgentInfo).then((wantAgentObj) => {
        backgroundTaskManager.startBackgroundRunning(context,
          backgroundTaskManager.BackgroundMode.AUDIO_PLAYBACK, wantAgentObj).then(() => {
          Logger.info(TAG, 'startBackgroundRunning succeeded');
        }).catch((err: BusinessError) => {
          Logger.error(TAG, `startBackgroundRunning failed, cause:  ${JSON.stringify(err)}`);
        });
      });
    } catch (e) {
      UtilLog.error(`task manage failed with error ${JSON.stringify(e)}`)
    }
  }


  public static stopContinuousTask(context?: common.UIAbilityContext): void {
    if (!context) {
      return;
    }
    backgroundTaskManager.stopBackgroundRunning(context).then(() => {
      Logger.info(TAG, 'stopBackgroundRunning succeeded');
    }).catch((err: BusinessError) => {
      Logger.error(TAG, `stopBackgroundRunning failed, cause:  ${JSON.stringify(err)}`);
    });
  }
}