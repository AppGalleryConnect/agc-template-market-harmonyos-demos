import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { BundleUtils, Logger } from 'lib_common';
import { WantUtils } from '../common/WantUtils';
import { NetworkUtils } from '../common/NetworkUtils';
import { WindowUtils } from '../common/WindowUtils';
import { AppUtils } from '../common/AppUtils';
import { LoneTakeAnimationsTransition } from 'module_transition';

const TAG = '[PhoneAbility]';

export default class PhoneAbility extends UIAbility {
  // 标记是否需要执行windowStage.loadContent
  private needLoadContent: boolean = false;

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam) {
    Logger.info(TAG, 'Ability onCreate');
    this.setNeedLoadContent(true);
    WantUtils.handleFormCardCall(want);
    WantUtils.handleRestoreCall(want, launchParam);
    NetworkUtils.initNetwork();
  }

  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    Logger.info(TAG, 'Ability onNewWant');
    this.setNeedLoadContent(false);
    WantUtils.handleFormCardCall(want);
    WantUtils.handleRestoreCall(want, launchParam);
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    Logger.info(TAG, 'Ability onWindowStageCreate');
    this.handleWindowStageCreateOrRestore(windowStage);
  }

  onWindowStageRestore(windowStage: window.WindowStage): void {
    Logger.info(TAG, 'Ability onWindowStageRestore');
    if (this.needLoadContent) {
      this.handleWindowStageCreateOrRestore(windowStage);
    }
  }

  onWindowStageDestroy(): void {
    Logger.info(TAG, 'Ability onWindowStageDestroy');
  }

  onDestroy(): void {
    Logger.info(TAG, 'Ability onDestroy');
    WindowUtils.offAvoidAreaChange();
    NetworkUtils.unRegisterNetwork();
  }

  handleWindowStageCreateOrRestore(windowStage: window.WindowStage) {
    WindowUtils.setWinConfig(windowStage);
    try {
      windowStage.loadContent('pages/Index', (err) => {
        if (err.code) {
          Logger.error(TAG, 'Failed to load the content. Cause: ' + JSON.stringify(err));
          return;
        }
        Logger.info(TAG, 'Succeeded in loading the content.');
        AppUtils.setAppTheme();
        AppUtils.setColorMode(this.context);
        BundleUtils.getBundleInfo(this.context);
        LoneTakeAnimationsTransition.init(windowStage);
      });
    } catch (e) {
      console.error(`Failed to loadContent. error: ${JSON.stringify(e)}`)
    }
  }

  setNeedLoadContent(value: boolean) {
    this.needLoadContent = value;
  }
};
