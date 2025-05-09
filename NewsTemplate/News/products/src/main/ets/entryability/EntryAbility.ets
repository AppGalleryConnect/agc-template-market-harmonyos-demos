import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { uiObserver as observer, window } from '@kit.ArkUI';
import { Logger, PreferencesUtil, GlobalContext } from 'commonlib';

const TAG: string = '[EntryAbility]';

function callBackFunc(info: observer.NavDestinationSwitchInfo) {
  console.info(`testTag navDestinationSwitch from: ${JSON.stringify(info.from)} to: ${JSON.stringify(info.to)}`)
}

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    Logger.info(TAG, 'onCreate');
    observer.on('navDestinationSwitch', this.context, callBackFunc);
    GlobalContext.getContext().setObject('abilityWant', want);

    PreferencesUtil.createFontPreferences(this.context);
    // 设置字体默认大小
    PreferencesUtil.saveDefaultFontSize(0);
  }

  onDestroy(): void {
    Logger.info(TAG, 'onDestroy');
    observer.off('navDestinationSwitch', this.context, callBackFunc);
  }

  public onWindowStageCreate(windowStage: window.WindowStage): void {
    Logger.info(TAG, '%{public}s', 'Ability onWindowStageCreate');

    windowStage.loadContent('pages/MainEntry', (err) => {
      if (err.code) {
        Logger.error(TAG, 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      Logger.info(TAG, 'Succeeded in loading the content.');
    });
  }
}
