import { AbilityConstant, UIAbility, Want, ConfigurationConstant } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { Logger, WindowUtil, PushUtil, ContextUtil, RdbUtil } from 'lib_foundation';
import { WantUtils } from '../utils/WantUtils';

const TAG = '[EntryAbility]';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    Logger.info(TAG, 'Ability onCreate');
    WantUtils.handleWant(want);
  }

  onNewWant(want: Want): void {
    WantUtils.handleWant(want);
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // 数据库初始化
    RdbUtil.initDB(this.context);
    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        Logger.error(TAG, 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      Logger.info(TAG, 'Succeeded in loading the content.');
      WindowUtil.setWinConfig(windowStage);
      ContextUtil.setUIContext('EntryAbility', windowStage.getMainWindowSync().getUIContext());
      PushUtil.getTokenSyn();
      try {
        this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT);
      } catch (err) {
        Logger.info(TAG, `Failed to set colorMode. Cause: ${JSON.stringify(err)}`);
      }
    });
  }

  onDestroy(): void {
    Logger.info(TAG, 'Ability onDestroy');
    WindowUtil.offAvoidAreaChange();
    WindowUtil.offWindowSizeChange();
  }
}
