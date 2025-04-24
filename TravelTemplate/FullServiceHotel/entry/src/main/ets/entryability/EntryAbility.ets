import { UIAbility } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { Logger, UIBase } from '@hw-agconnect/ui-base';

const TAG = '[EntryAbility]';

export default class EntryAbility extends UIAbility {
  public onWindowStageCreate(windowStage: window.WindowStage): void {
    UIBase.init(windowStage);
    windowStage.loadContent('pages/EmptyPage', (err) => {
      if (err.code) {
        Logger.error(TAG, 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      Logger.info(TAG, 'Succeeded in loading the content.');
    });
  }
}
