import { Configuration, UIAbility } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { CommonUtil, Logger } from 'commonlib';
import { i18n } from '@kit.LocalizationKit';

const TAG = '[EntryAbility]';

export default class EntryAbility extends UIAbility {
  onWindowStageCreate(windowStage: window.WindowStage): void {
    windowStage.loadContent('/pages/MainEntry'.slice(1), (err) => {
      if (err.code) {
        Logger.error(TAG, '%{public}s ', 'Failed to load the content. Cause: ' + JSON.stringify(err));
        return;
      }
      Logger.info(TAG, '%{public}s ', 'Succeeded in loading the content.');
    });
  }

  onConfigurationUpdate(newConfig: Configuration): void {
    // 监听系统配置变化
    if (newConfig.language) {
      CommonUtil.setIsRTL(i18n.isRTL(newConfig.language))
    }
  }
}
