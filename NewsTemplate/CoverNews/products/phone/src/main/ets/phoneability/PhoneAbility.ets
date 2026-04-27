import { UIAbility, Want } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { Logger, WindowUtils } from 'lib_common';
import { ShareUtils } from '../common/ShareUtils';
import { WantUtils } from '../common/WantUtils';

const TAG = '[PhoneAbility]';

export default class PhoneAbility extends UIAbility {
  onCreate(want: Want): void {
    Logger.info(TAG, 'Ability onCreate');
    WantUtils.handleShare(want);
    WantUtils.handleFormCardCall(want);
  }

  onNewWant(want: Want): void {
    Logger.info(TAG, 'Ability onNewWant');
    WantUtils.handleShare(want);
    WantUtils.handleFormCardCall(want);
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    Logger.info(TAG, 'Ability onWindowStageCreate');
    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        Logger.info(TAG, `Failed to load the content. Cause: ${JSON.stringify(err)}`);
        return;
      }
      Logger.info(TAG, 'Succeeded in loading the content.');
      WindowUtils.setWinConfig(windowStage);
    });
  }

  onShare(wantParams: Record<string, Object>) {
    const shareParams = ShareUtils.getShareParams();
    wantParams['atomicservice.param.key.shareInfo'] = shareParams;
  }

  onWindowStageDestroy(): void {
    Logger.info(TAG, 'Ability onWindowStageDestroy');
  }

  onDestroy(): void {
    Logger.info(TAG, 'Ability onDestroy');
    WindowUtils.offAvoidAreaChange();
  }
}
