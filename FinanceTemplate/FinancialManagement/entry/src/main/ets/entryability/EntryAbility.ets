import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { Logger, UIBase } from '@hw-agconnect/ui-base';
import { RouterMap, RouterModule } from 'commonlib';
import { formInfo } from '@kit.FormKit';

const TAG = '[EntryAbility]';

export default class EntryAbility extends UIAbility {
  public onWindowStageCreate(windowStage: window.WindowStage): void {
    UIBase.init(windowStage);
    windowStage.loadContent('pages/MainEntry', (err) => {
      if (err.code) {
        Logger.error(TAG, 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      Logger.info(TAG, 'Succeeded in loading the content.');
    });
  }

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    Logger.info(TAG, 'Ability onCreate');
    this.processWantData(want);
  }

  onNewWant(want: Want): void {
    this.processWantData(want);
  }


  processWantData(want: Want) {
    let data = want.parameters;
    if (data?.[formInfo.FormParam.IDENTITY_KEY] !== undefined) {
      let id: number = (JSON.parse(data.params as string))?.id;
      RouterModule.replace({
        url: RouterMap.PRODUCT_INFO, param:id
      });
    }
  }
}
