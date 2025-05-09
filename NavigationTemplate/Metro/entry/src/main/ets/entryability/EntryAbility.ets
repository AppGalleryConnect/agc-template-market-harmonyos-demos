import { Logger } from 'commonlib';
import { UIAbility } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
const TAG: string = '[EntryAbility]';

export default class EntryAbility extends UIAbility {

  onWindowStageCreate(windowStage: window.WindowStage): void {
    windowStage.loadContent('pages/MainEntry', (err, data) => {
      if (err.code) {
        Logger.error(TAG, 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
    });
  }


}