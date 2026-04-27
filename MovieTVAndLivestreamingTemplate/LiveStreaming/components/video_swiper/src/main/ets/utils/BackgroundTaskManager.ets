import { common } from '@kit.AbilityKit';
import { backgroundTaskManager } from '@kit.BackgroundTasksKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';


const TAG = '[BackgroundTaskManager]';

/**
 * Background task tool class.
 */
export class BackgroundTaskManager {
  public static startContinuousTask(context?: common.UIAbilityContext): void {
    if (!context) {
      return;
    }
    // let wantAgentInfo: wantAgent.WantAgentInfo = {
    //   wants: [
    //     {
    //       bundleName: context.abilityInfo.bundleName,
    //       abilityName: context.abilityInfo.name
    //     }
    //   ],
    //   operationType: wantAgent.OperationType.START_ABILITY,
    //   requestCode: 0,
    //   wantAgentFlags: [wantAgent.WantAgentFlags.UPDATE_PRESENT_FLAG]
    // };
    //
    // wantAgent.getWantAgent(wantAgentInfo).then((wantAgentObj) => {
    //   backgroundTaskManager.startBackgroundRunning(context,
    //     backgroundTaskManager.BackgroundMode.AUDIO_PLAYBACK, wantAgentObj).then(() => {
    //     hilog.info(0x0000, TAG, 'startBackgroundRunning succeeded');
    //   }).catch((err: BusinessError) => {
    //     hilog.info(0x0000, TAG, `startBackgroundRunning failed Cause:  ${JSON.stringify(err)}`);
    //   });
    // });
  }

  // cancel continuous task
  public static stopContinuousTask(context?: common.UIAbilityContext): void {
    if (!context) {
      return;
    }
    backgroundTaskManager.stopBackgroundRunning(context).then(() => {
      hilog.info(0x0000, TAG, 'stopBackgroundRunning succeeded');
    }).catch((err: BusinessError) => {
      hilog.info(0x0000, TAG, `stopBackgroundRunning failed Cause:  ${JSON.stringify(err)}`);
    });
  }
}