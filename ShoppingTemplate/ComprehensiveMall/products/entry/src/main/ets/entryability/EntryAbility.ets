import UIAbility from '@ohos.app.ability.UIAbility';
import ConfigurationConstant from '@ohos.app.ability.ConfigurationConstant';
import window from '@ohos.window';
import { BusinessError } from '@ohos.base';
import { KeyboardAvoidMode } from '@ohos.arkui.UIContext';

export default class EntryAbility extends UIAbility {

  onCreate(): void {
    this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT);
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    windowStage.loadContent('pages/Index', (error: BusinessError<void>): void => {
      windowStage.getMainWindowSync().getUIContext().setKeyboardAvoidMode(KeyboardAvoidMode.OFFSET);
      if (error.code) {
        this.context.terminateSelf();
        return;
      }
    });
  }
}
