import { common } from '@kit.AbilityKit';
import wantAgent from '@ohos.app.ability.wantAgent';
import { backgroundTaskManager } from '@kit.BackgroundTasksKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { Logger } from 'common';

export class BackgroundUtil {
  public static startContinuousTask(context?: common.UIAbilityContext): void {
    if (!context) {
      Logger.error('this avPlayer: ', `context undefined`);
      return
    }
    let wantAgentInfo: wantAgent.WantAgentInfo = {
      wants: [
        {
          bundleName: context.abilityInfo.bundleName,
          abilityName: context.abilityInfo.name
        }
      ],
      requestCode: 0,
    };

    wantAgent.getWantAgent(wantAgentInfo).then((wantAgentObj: Object) => {
      try {
        backgroundTaskManager.startBackgroundRunning(context,
          backgroundTaskManager.BackgroundMode.AUDIO_PLAYBACK, wantAgentObj).then(() => {
          Logger.info('this avPlayer: ', 'startBackgroundRunning succeeded');
        }).catch((error: BusinessError) => {
          Logger.error('this avPlayer: ', `startBackgroundRunning failed Cause: code ${error.code}`);
        });
      } catch (error) {
        Logger.error('this avPlayer: ', `startBackgroundRunning failed. code ${(error as BusinessError).code}
         message ${(error as BusinessError).message}`);
      }
    });
  }

  public static stopContinuousTask(context: common.UIAbilityContext): void {
    try {
      backgroundTaskManager.stopBackgroundRunning(context).then(() => {
        Logger.info('this avPlayer: ', 'stopBackgroundRunning succeeded');
      }).catch((error: BusinessError) => {
        Logger.error('this avPlayer: ', `stopBackgroundRunning failed Cause: code ${error.code}`);
      });
    } catch (error) {
      Logger.error('this avPlayer: ', `stopBackgroundRunning failed. code ${(error as BusinessError).code}
       message ${(error as BusinessError).message}`);
    }
  }
}