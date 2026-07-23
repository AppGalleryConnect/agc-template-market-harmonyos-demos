import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { UtilLog } from '@hw-agconnect/util-log';
import { RdbInit } from 'calendar_events';
import { WantUtils } from '../common/WantUtils';
import { WindowUtils } from '../common/WindowUtils';

const TAG = '[EntryAbility]'

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    WantUtils.getPushToken(want)
    WantUtils.handlePushCall(want);
    WantUtils.handleFormCardCall(want);
  }


  onWindowStageCreate(windowStage: window.WindowStage): void {
    RdbInit.initDB(this.context)
    try {
      windowStage.loadContent('pages/SplashPage', (err) => {
        if (err.code) {
          UtilLog.error(TAG, 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
          return;
        }
        WindowUtils.initCreateNWeb(windowStage)
        WindowUtils.setWinConfig(windowStage)
        WindowUtils.setColorModeLight(this.context)
        UtilLog.info(TAG, 'Succeeded in loading the content.');
      });
    } catch (e) {
      UtilLog.error(TAG, 'Failed to load the content. Cause: %{public}s', JSON.stringify(e) ?? '')
    }
  }

  // 如果UIAbility已在后台运行，在收到Router事件后会触发onNewWant生命周期回调
  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    WantUtils.handleFormCardCall(want);
    WantUtils.handlePushCall(want);
  }


  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    UtilLog.info(TAG, '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    UtilLog.info(TAG, '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    UtilLog.info(TAG, '%{public}s', 'Ability onBackground');
  }
}
