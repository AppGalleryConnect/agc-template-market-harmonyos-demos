import { AbilityConstant, UIAbility, Want, Configuration } from '@kit.AbilityKit';
import { window, KeyboardAvoidMode } from '@kit.ArkUI';
import { deviceInfo } from '@kit.BasicServicesKit';
import { BundleUtils, GlobalContext, Logger } from 'lib_common';
import { NetworkUtils } from '../common/NetworkUtils';
import { WindowUtils } from '../common/WindowUtils';
import { AppUtils } from '../common/AppUtils';

const TAG = '[EntryAbility]';

export default class EntryAbility extends UIAbility {
  // 标记是否需要执行windowStage.loadContent
  private needLoadContent: boolean = false;

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam) {
    Logger.info(TAG, 'Ability onCreate');
    this.setNeedLoadContent(true);
  }

  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    Logger.info(TAG, 'Ability onNewWant');
    this.setNeedLoadContent(false);
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    Logger.info(TAG, 'Ability onWindowStageCreate');
    GlobalContext.initContext(this.context, windowStage)
    this.handleWindowStageCreateOrRestore(windowStage);
  }

  onWindowStageRestore(windowStage: window.WindowStage): void {
    Logger.info(TAG, 'Ability onWindowStageRestore');
    if (this.needLoadContent) {
      this.handleWindowStageCreateOrRestore(windowStage);
    }
  }

  onConfigurationUpdate(newConfig: Configuration): void {
    AppUtils.listenConfigurationUpdate(newConfig);
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
        try {
          windowStage.getMainWindowSync().getUIContext().setKeyboardAvoidMode(KeyboardAvoidMode.RESIZE);
        } catch (error) {
          Logger.error(TAG, 'setKeyboardAvoidMode error: ' + JSON.stringify(error));
        }

        AppUtils.setAppTheme();
        AppUtils.setColorMode();
        BundleUtils.getBundleInfo();
        // 判断是否是模拟器
        let productMode = deviceInfo.productModel;
        if (productMode !== 'emulator') {
          NetworkUtils.initNetwork();
        }
      });
    } catch (error) {
      Logger.error(TAG, 'loadContent error: ' + JSON.stringify(error));
    }
  }

  setNeedLoadContent(value: boolean) {
    this.needLoadContent = value;
  }
};
