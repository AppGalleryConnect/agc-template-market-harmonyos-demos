import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { Logger, RouterMap } from 'module_base';
import { formInfo } from '@kit.FormKit';
import { RouterModule } from 'lib_foundation';

const TAG = '[EntryAbility]';

export default class EntryAbility extends UIAbility {
  public onWindowStageCreate(windowStage: window.WindowStage): void {

    windowStage.getMainWindow((err: BusinessError, data) => {
      AppStorage.setOrCreate('windowClass', data);
    });
    windowStage.loadContent('pages/Index', (err) => {
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
        url: RouterMap.ORDER_INFO_PAGE, param: id
      });
    }
  }
}
