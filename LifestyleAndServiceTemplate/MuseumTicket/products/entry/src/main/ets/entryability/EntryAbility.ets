import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { Logger } from 'commonlib';
import { UIBase } from 'uicalendarpicker';
import { formInfo } from '@kit.FormKit';
import { RouterModule, RouterMap } from 'commonlib';

const TAG: string = '[EntryAbility]';

export default class EntryAbility extends UIAbility {
  public onWindowStageCreate(windowStage: window.WindowStage): void {
    Logger.info(TAG, '%{public}s', 'Ability onWindowStageCreate');
    // 初始化UIBase
    UIBase.init(windowStage);
    windowStage.loadContent('pages/EmptyPage', (err) => {
      if (err.code) {
        Logger.error(TAG, 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      Logger.info(TAG, 'Succeeded in loading the content.');
    });
  }

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    Logger.info(TAG, 'Ability onCreate');
    this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    this.processWantData(want);
  }

  onNewWant(want: Want): void {
    this.processWantData(want);
  }


  processWantData(want: Want) {
    let data = want.parameters;
    if (data?.[formInfo.FormParam.IDENTITY_KEY] !== undefined) {
      let hasData: boolean = (JSON.parse(data.params as string))?.hasData;
      let orderNo: string = (JSON.parse(data.params as string))?.orderNo;
      if (hasData) {
        RouterModule.replace({ url: RouterMap.TICKET_DETAIL, param: { orderNo } });
      }
    }
  }
};
